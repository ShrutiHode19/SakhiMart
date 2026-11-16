package controller;

import dao.ChatbotDAO;
import model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;


@WebServlet("/ChatbotServlet")
public class ChatbotServlet extends HttpServlet {

   
    private static final String GEMINI_API_KEY = "AIzaSyALRY3lVn_X0tN1yNRjgSjwbRqM4A-q2jY";

    // Gemini model endpoint (free tier)
    private static final String GEMINI_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=";

    private ChatbotDAO chatbotDAO;

    // ── Servlet init ───────────────────────────────────────────────
    @Override
    public void init() throws ServletException {
        chatbotDAO = new ChatbotDAO();
        boolean keyOk = isKeySet();
        System.out.println("╔══════════════════════════════════════════════╗");
        System.out.println("║   SakhiMart ChatbotServlet — Initialized     ║");
        System.out.println("║   AI Engine : Google Gemini 2.0 Flash        ║");
        System.out.println("║   API Key   : " + (keyOk ? "SET ✓" : "NOT SET ✗ — set GEMINI_API_KEY") + "          ║");
        System.out.println("╚══════════════════════════════════════════════╝");
        if (!keyOk) {
            System.out.println("[ChatbotServlet] WARNING: GEMINI_API_KEY not set!");
            System.out.println("[ChatbotServlet] Get free key: https://aistudio.google.com/apikey");
        }
    }

    // ── GET — quick health check ───────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.getWriter().print(
            "{\"reply\":\"ChatbotServlet running! API Key set: " + isKeySet() + "\",\"products\":[]}"
        );
    }

    // ── POST — main chatbot handler ────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json;charset=UTF-8");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Cache-Control", "no-cache");

        // ── STEP 1: Read JSON body ───────────────────────────────────
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        }
        String body = sb.toString().trim();
        System.out.println("[Chatbot] Received: " + body.substring(0, Math.min(200, body.length())));

        if (body.isEmpty()) {
            writeJson(res, err("Empty request body.")); return;
        }

        // ── STEP 2: Parse fields ─────────────────────────────────────
        String userMessage = extractStr(body, "message");
        String userRole    = extractStr(body, "userRole");
        String historyJson = extractArr(body, "history");

        if (userMessage == null || userMessage.trim().isEmpty()) {
            writeJson(res, err("Please type a message.")); return;
        }
        userMessage = userMessage.trim();
        if (userMessage.length() > 500) userMessage = userMessage.substring(0, 500);
        if (userRole == null || userRole.isEmpty()) userRole = "guest";

        System.out.println("[Chatbot] user=" + userRole + " | msg=" + userMessage);

        // ── STEP 3: Get session customer id ──────────────────────────
        HttpSession session = req.getSession(false);
        int customerId = 0;
        if (session != null && session.getAttribute("c_id") != null) {
            try { customerId = (Integer) session.getAttribute("c_id"); } catch (Exception ignored) {}
        }

        // ── STEP 4: Check keyword rules first (no API cost) ─────────
        try {
            String ruleReply = chatbotDAO.matchRule(userMessage);
            if (ruleReply != null) {
                System.out.println("[Chatbot] Rule matched → " + ruleReply.substring(0, Math.min(60, ruleReply.length())));
                chatbotDAO.saveChatLog(userRole, customerId, userMessage, ruleReply);
                writeJson(res, buildJsonResponse(ruleReply, null));
                return;
            }
        } catch (Exception e) {
            System.out.println("[Chatbot] Rule check skipped: " + e.getMessage());
        }

        // ── STEP 5: Fetch product context ────────────────────────────
        List<Product> matchedProducts = new ArrayList<>();
        List<Product> topProducts     = new ArrayList<>();
        try {
            matchedProducts = chatbotDAO.searchProductsForChat(userMessage);
            if (matchedProducts.isEmpty() && chatbotDAO.isGeneralProductQuery(userMessage)) {
                topProducts = chatbotDAO.getTopApprovedProducts(6);
            }
        } catch (Exception e) {
            System.out.println("[Chatbot] Product search skipped: " + e.getMessage());
        }
        List<Product> contextProducts = !matchedProducts.isEmpty() ? matchedProducts : topProducts;

        // ── STEP 6: Fetch order context for customer ─────────────────
        String orderSummary = null;
        if (customerId > 0 && isOrderQuery(userMessage)) {
            try { orderSummary = chatbotDAO.getLatestOrderSummary(customerId); }
            catch (Exception e) { System.out.println("[Chatbot] Order lookup skipped: " + e.getMessage()); }
        }

        // ── STEP 7: Load FAQs for context ───────────────────────────
        String faqText = "";
        try { faqText = chatbotDAO.getFAQsForPrompt(); }
        catch (Exception ignored) {}

        // ── STEP 8: Build prompt and call Gemini ─────────────────────
        String aiReply;
        if (isKeySet()) {
            System.out.println("[Chatbot] Calling Gemini API...");
            try {
                String prompt  = buildGeminiPrompt(userRole, userMessage, contextProducts, orderSummary, faqText);
                String rawJson = callGeminiAPI(prompt);
                aiReply        = parseGeminiResponse(rawJson);
                System.out.println("[Chatbot] Gemini reply: " + aiReply.substring(0, Math.min(80, aiReply.length())));
            } catch (Exception e) {
                System.out.println("[Chatbot] Gemini API error: " + e.getMessage());
                e.printStackTrace();
                // Fallback on API error
                aiReply = buildFallbackReply(userMessage, userRole, contextProducts, orderSummary);
            }
        } else {
            System.out.println("[Chatbot] No API key — using rule-based reply.");
            aiReply = buildFallbackReply(userMessage, userRole, contextProducts, orderSummary);
        }

        // ── STEP 9: Save to chatbot_log ──────────────────────────────
        try { chatbotDAO.saveChatLog(userRole, customerId, userMessage, aiReply); }
        catch (Exception e) { System.out.println("[Chatbot] Log save skipped: " + e.getMessage()); }

        // ── STEP 10: Send response ───────────────────────────────────
        writeJson(res, buildJsonResponse(aiReply, contextProducts));
    }

    // ══════════════════════════════════════════════════════════════════
    //  GEMINI PROMPT BUILDER
    // ══════════════════════════════════════════════════════════════════
    private String buildGeminiPrompt(String role, String userMsg, List<Product> products,
                                      String orderSummary, String faqText) {
        StringBuilder p = new StringBuilder();

        // Identity & persona
        p.append("You are Sakhi, a warm and friendly AI shopping assistant for SakhiMart — ");
        p.append("an e-commerce platform selling handmade products by Women Self-Help Groups (SHGs) in India.\n");
        p.append("Be concise (under 120 words), warm, use simple English, and 1-2 relevant emojis.\n\n");

        // Platform knowledge
        p.append("SAKHIMART PLATFORM INFO:\n");
        p.append("- Products: Food & Snacks, Pickles, Handicrafts, Cloth & Textiles, Beauty & Wellness, Jewellery, Home Decor\n");
        p.append("- Payments accepted: COD (Cash on Delivery), UPI, Card\n");
        p.append("- Delivery time: 3 to 7 business days\n");
        p.append("- Return policy: within 7 days of delivery with Order ID\n");
        p.append("- All products made by SHG women, reviewed & approved by Admin before going live\n");
        p.append("- Member product upload: Login as Member → My Products → Add Product → Fill details → Submit\n\n");

        // Role context
        p.append("CURRENT USER ROLE: ").append(role).append("\n");
        if ("member".equals(role)) {
            p.append("(This user is an SHG member seller — focus on product upload, approval, and listing management)\n\n");
        } else if ("admin".equals(role)) {
            p.append("(This user is Admin — provide platform management information)\n\n");
        } else {
            p.append("(This user is a customer/guest — focus on product discovery, ordering, and support)\n\n");
        }

        // FAQ knowledge from DB
        if (faqText != null && !faqText.trim().isEmpty()) {
            p.append("FREQUENTLY ASKED QUESTIONS (use these exact answers when relevant):\n");
            p.append(faqText).append("\n");
        }

        // Live product data from DB
        if (products != null && !products.isEmpty()) {
            p.append("LIVE PRODUCTS AVAILABLE IN STORE:\n");
            int limit = Math.min(products.size(), 6);
            for (int i = 0; i < limit; i++) {
                Product pr = products.get(i);
                p.append("  • ").append(safe(pr.getP_name()))
                 .append(" | Category: ").append(safe(pr.getP_category()))
                 .append(" | Price: Rs.").append(String.format("%.0f", pr.getP_price()))
                 .append(" | ID: ").append(pr.getP_id()).append("\n");
            }
            p.append("(Mention specific product names and prices when relevant)\n\n");
        }

        // Customer order info
        if (orderSummary != null) {
            p.append("CUSTOMER'S LATEST ORDER INFO:\n").append(orderSummary).append("\n\n");
        }

        // Rules
        p.append("IMPORTANT RULES:\n");
        p.append("- Never make up products not listed above\n");
        p.append("- For order issues you cannot resolve, guide to My Orders page\n");
        p.append("- For off-topic questions, politely redirect to SakhiMart shopping\n\n");

        // The actual question
        p.append("USER MESSAGE: ").append(userMsg).append("\n\n");
        p.append("YOUR REPLY AS SAKHI:");

        return p.toString();
    }

    // ══════════════════════════════════════════════════════════════════
    //  GEMINI API CALL  (pure Java, no external JARs)
    // ══════════════════════════════════════════════════════════════════
    private String callGeminiAPI(String prompt) throws IOException {
        // Build Gemini request JSON
        String requestBody = "{"
            + "\"contents\":[{"
            + "\"parts\":[{\"text\":" + toJson(prompt) + "}]"
            + "}],"
            + "\"generationConfig\":{"
            + "\"maxOutputTokens\":250,"
            + "\"temperature\":0.75,"
            + "\"topP\":0.9"
            + "}"
            + "}";

        URL url = new URL(GEMINI_URL + GEMINI_API_KEY.trim());
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(30000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json");

        byte[] bytes = requestBody.getBytes(StandardCharsets.UTF_8);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(bytes);
            os.flush();
        }

        int status = conn.getResponseCode();
        System.out.println("[Chatbot] Gemini HTTP status: " + status);

        InputStream is = (status == 200) ? conn.getInputStream() : conn.getErrorStream();
        StringBuilder resp = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) resp.append(line);
        }

        String raw = resp.toString();
        System.out.println("[Chatbot] Gemini raw (300 chars): " + raw.substring(0, Math.min(300, raw.length())));

        if (status != 200) {
            throw new IOException("Gemini API HTTP " + status + ": " + raw.substring(0, Math.min(200, raw.length())));
        }
        return raw;
    }

    // ══════════════════════════════════════════════════════════════════
    //  PARSE GEMINI RESPONSE
    //  Gemini returns:
    //  {"candidates":[{"content":{"parts":[{"text":"reply here"}]}}]}
    // ══════════════════════════════════════════════════════════════════
    private String parseGeminiResponse(String json) {
        try {
            // Find "text": in the response
            int ti = json.indexOf("\"text\":");
            if (ti == -1) {
                System.out.println("[Chatbot] No 'text' field found in Gemini response!");
                return "I am having a little trouble right now. Please try again! 🙏";
            }
            // Find the opening quote of the text value
            int q1 = json.indexOf("\"", ti + 7) + 1;
            // Read characters until closing quote (handle escape sequences)
            StringBuilder result = new StringBuilder();
            boolean esc = false;
            for (int i = q1; i < json.length(); i++) {
                char c = json.charAt(i);
                if (esc) {
                    switch (c) {
                        case 'n':  result.append('\n'); break;
                        case 't':  result.append('\t'); break;
                        case 'r':  result.append('\r'); break;
                        case '"':  result.append('"');  break;
                        case '\\': result.append('\\'); break;
                        case 'u':
                            if (i + 4 < json.length()) {
                                try {
                                    int cp = Integer.parseInt(json.substring(i + 1, i + 5), 16);
                                    result.append((char) cp);
                                    i += 4;
                                } catch (NumberFormatException ex) { result.append(c); }
                            }
                            break;
                        default: result.append(c);
                    }
                    esc = false;
                } else if (c == '\\') {
                    esc = true;
                } else if (c == '"') {
                    break; // end of text value
                } else {
                    result.append(c);
                }
            }
            String text = result.toString().trim();
            return text.isEmpty()
                   ? "Could you rephrase that? I am here to help! 😊"
                   : text;
        } catch (Exception e) {
            System.out.println("[Chatbot] parseGeminiResponse error: " + e.getMessage());
            return "Something went wrong. Please try again!";
        }
    }

    // ══════════════════════════════════════════════════════════════════
    //  SMART FALLBACK REPLY  (works without internet / API key)
    //  Uses your actual product DB data and real FAQ content
    // ══════════════════════════════════════════════════════════════════
    private String buildFallbackReply(String msg, String role,
                                       List<Product> products, String orderSummary) {
        String lower = msg.toLowerCase().trim();

        // Greetings
        if (has(lower, "hello","hi","hey","namaste","namaskar","good morning","good evening")) {
            if ("member".equals(role))
                return "Namaste! 🌸 I'm Sakhi. I can help you upload products, check approval status, or manage your listings. What do you need?";
            return "Namaste! 🌸 I'm Sakhi, your SakhiMart assistant. I can help you find products, track orders, or answer questions. How can I help?";
        }

        // Product browse
        if (has(lower, "product","show","browse","available","what do you have","buy","shop","catalogue","list","sell")) {
            if (products != null && !products.isEmpty()) {
                StringBuilder r = new StringBuilder("Here are some of our handmade products! 🛍️\n\n");
                for (int i = 0; i < Math.min(3, products.size()); i++) {
                    Product p = products.get(i);
                    r.append("• ").append(safe(p.getP_name()))
                     .append(" — Rs.").append(String.format("%.0f", p.getP_price())).append("\n");
                }
                r.append("\nVisit the Products page to browse everything!");
                return r.toString();
            }
            return "SakhiMart offers handmade products by SHG women 🌸 — Pickles & Food, Handicrafts, Textiles, Jewellery, Beauty & Wellness, and Home Decor. Browse the Products page to see all items!";
        }

        // Specific categories
        if (has(lower, "pickle","achar","mango","lime pickle","lemon"))
            return "We have delicious homemade pickles! 🫙 Mango Pickle (Rs.120) and Lime Pickle (Rs.90) — both made fresh by our SHG members. Check the Products page for all varieties!";
        if (has(lower, "food","snack","ghee","honey","laddu","papad","millet","spice","organic"))
            return "Our food range includes: 🍯 Organic Honey (Rs.250), Pure Ghee (Rs.320), Millet Laddu (Rs.180), Papad (Rs.80), and Masala Powder (Rs.150) — all handmade by SHG women!";
        if (has(lower, "handicraft","basket","jute","bamboo","craft","bag"))
            return "Our SHG women make beautiful handicrafts! 🧺 Handmade Jute Bag (Rs.350) and Bamboo Basket (Rs.300) are available. Visit the Products page for more!";
        if (has(lower, "cloth","saree","textile","fabric","shawl","cotton","silk","wear"))
            return "We have handwoven clothing! 🧣 Cotton Saree (Rs.850) and Woolen Shawl (Rs.650) — made by our talented SHG artisans. Check the Products page!";
        if (has(lower, "soap","beauty","herbal","wellness","cream","oil","skincare","personal care"))
            return "Our beauty products are 100% natural! 🌿 Herbal Soap with neem & aloe vera (Rs.90) — handmade by SHG women. See more on the Products page!";
        if (has(lower, "jewel","necklace","bead","ornament"))
            return "We have beautiful handcrafted jewellery! 💍 Beaded Necklace with traditional design (Rs.150) — made with care by SHG members. Visit the Products page!";
        if (has(lower, "cushion","decor","home","embroid"))
            return "Our home decor range includes handmade items! 🏡 Embroidered Cushion Cover (Rs.280) — hand-stitched by SHG women. Browse our Products page for more!";

        // Orders
        if (has(lower, "my order","track order","order status","where is my order")) {
            if (orderSummary != null)
                return "Here's your latest order 📦\n\n" + orderSummary + "\n\nFor full details go to My Orders in the menu.";
            return "To view and track your orders 📦 — Login → click My Orders in the menu. You will see full delivery status there!";
        }
        if (has(lower, "order","how to order","place order","checkout")) {
            if (has(lower, "how","place","checkout","step"))
                return "Ordering is easy! 🛒\n1. Browse products\n2. Click Add to Cart\n3. Go to Cart → Checkout\n4. Enter delivery address\n5. Choose payment & confirm\n\nDelivery in 3–7 business days!";
            if (orderSummary != null)
                return "Your latest order: 📦\n\n" + orderSummary + "\n\nSee full details in My Orders.";
            return "To track your orders → Login → My Orders in the menu. 📦 Need help placing an order? Just ask!";
        }

        // Payment
        if (has(lower, "payment","pay","cod","upi","card","how to pay"))
            return "We accept these payment methods 💳\n• COD (Cash on Delivery)\n• UPI (GPay, PhonePe, Paytm)\n• Credit/Debit Card\n\nChoose at checkout!";

        // Return / refund
        if (has(lower, "return","refund","exchange","damaged","wrong product"))
            return "Returns are accepted within 7 days of delivery 🔄 Contact support with your Order ID. Refunds processed in 5–7 business days after approval.";

        // Cancel
        if (has(lower, "cancel","cancellation"))
            return "To cancel an order ❌ — go to My Orders within 24 hours of placing it and click Cancel. After 24 hours please contact support.";

        // Delivery / track
        if (has(lower, "delivery","track","shipping","how long","when will","days"))
            return "We deliver in 3 to 7 business days 🚚 Track your order: Login → My Orders → click on your order to see current status!";

        // Member: upload product
        if (has(lower, "upload","add product","how to sell","list product","post product","submit product"))
            return "To upload your product 📦\n1. Login as Member\n2. Click My Products in menu\n3. Click Add Product\n4. Fill name, category, price, description & photo\n5. Click Submit\n\nAdmin will approve in 1–2 days. Then it goes live! 🌸";

        // Approval
        if (has(lower, "approv","pending","review","reject","not live","not showing"))
            return "Products go through Admin review before going live 🔍 This takes 1–2 days. If rejected, you'll get a reason and can resubmit. Check My Products to see status!";

        // About
        if (has(lower, "about","what is sakhimart","sakhimart","shg","self help","women"))
            return "SakhiMart is an online marketplace run by Women Self-Help Groups (SHGs) 🌸 We empower women by helping them sell handmade products — pickles, handicrafts, textiles, food, and beauty items — to customers across India!";

        // Contact
        if (has(lower, "contact","support","help desk","phone","email","call"))
            return "Need help? 📩 Email us at support@sakhimart.com — our team is happy to assist with orders, products, or payments!";

        // Discount
        if (has(lower, "discount","offer","coupon","promo","sale","deal"))
            return "We don't currently offer discount codes, but our products are already very affordable! 🌸 Watch the homepage for seasonal offers!";

        // Register / login
        if (has(lower, "register","signup","sign up","create account","join","login","sign in"))
            return "To register, click Register in the top menu 🌸 You can sign up as a Customer (to shop) or Member (to sell). Login is available on the Login page!";

        // Thank you
        if (has(lower, "thank","thanks","dhanyawad"))
            return "You're most welcome! 🌸 Happy to help. Feel free to ask anything about SakhiMart anytime!";

        // Bye
        if (has(lower, "bye","goodbye","see you","take care"))
            return "Goodbye! 🌸 Thank you for visiting SakhiMart. Happy shopping and support our SHG women artisans!";

        // Member default
        if ("member".equals(role))
            return "I'm here to help with your SakhiMart member account! 🌸 Ask me about uploading products, approval process, editing listings, or anything else. What do you need?";

        // Generic default
        return "Thank you for your message! 🌸 I'm Sakhi, your SakhiMart assistant. I can help with:\n• Finding products\n• Placing & tracking orders\n• Payments & delivery\n• Returns\n\nWhat would you like to know?";
    }

    // ══════════════════════════════════════════════════════════════════
    //  JSON RESPONSE BUILDER
    // ══════════════════════════════════════════════════════════════════
    private String buildJsonResponse(String reply, List<Product> products) {
        StringBuilder j = new StringBuilder();
        j.append("{");
        j.append("\"reply\":").append(toJson(reply)).append(",");
        j.append("\"products\":[");
        if (products != null && !products.isEmpty()) {
            int limit = Math.min(products.size(), 4);
            for (int i = 0; i < limit; i++) {
                Product p = products.get(i);
                if (i > 0) j.append(",");
                j.append("{")
                 .append("\"id\":").append(p.getP_id()).append(",")
                 .append("\"name\":").append(toJson(safe(p.getP_name()))).append(",")
                 .append("\"category\":").append(toJson(safe(p.getP_category()))).append(",")
                 .append("\"price\":").append(p.getP_price()).append(",")
                 .append("\"image\":").append(toJson(safe(p.getP_image_path())))
                 .append("}");
            }
        }
        j.append("]}");
        return j.toString();
    }

    // ══════════════════════════════════════════════════════════════════
    //  UTILITY HELPERS
    // ══════════════════════════════════════════════════════════════════

    /** Check if API key is set and not a placeholder */
    private boolean isKeySet() {
        return GEMINI_API_KEY != null
            && !GEMINI_API_KEY.isEmpty()
            && !GEMINI_API_KEY.equals("PASTE_YOUR_GEMINI_KEY_HERE")
            && GEMINI_API_KEY.length() > 15;
    }

    /** Check if message is about orders */
    private boolean isOrderQuery(String msg) {
        if (msg == null) return false;
        String l = msg.toLowerCase();
        return l.contains("order") || l.contains("delivery") || l.contains("track")
            || l.contains("status") || l.contains("shipped");
    }

    /** Check if input string contains any of the keywords */
    private boolean has(String input, String... keywords) {
        for (String kw : keywords) {
            if (input.contains(kw)) return true;
        }
        return false;
    }

    /** Convert Java String to JSON string literal with proper escaping */
    private String toJson(String v) {
        if (v == null) return "\"\"";
        StringBuilder sb = new StringBuilder("\"");
        for (char c : v.toCharArray()) {
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else          sb.append(c);
            }
        }
        return sb.append("\"").toString();
    }

    /** Extract a string value from a JSON body by key */
    private String extractStr(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx == -1) return null;
        int colon = json.indexOf(":", idx + search.length());
        if (colon == -1) return null;
        int q1 = json.indexOf("\"", colon + 1);
        if (q1 == -1) return null;
        StringBuilder sb = new StringBuilder();
        boolean esc = false;
        for (int i = q1 + 1; i < json.length(); i++) {
            char c = json.charAt(i);
            if (esc) {
                if      (c == 'n')  sb.append('\n');
                else if (c == '"')  sb.append('"');
                else if (c == '\\') sb.append('\\');
                else                sb.append(c);
                esc = false;
            } else if (c == '\\') { esc = true; }
            else if   (c == '"')  { break; }
            else                  { sb.append(c); }
        }
        return sb.toString();
    }

    /** Extract a JSON array value from a JSON body by key */
    private String extractArr(String json, String key) {
        int idx = json.indexOf("\"" + key + "\"");
        if (idx == -1) return "[]";
        int br = json.indexOf("[", idx);
        if (br == -1) return "[]";
        int depth = 0, end = br;
        for (int i = br; i < json.length(); i++) {
            char c = json.charAt(i);
            if      (c == '[') depth++;
            else if (c == ']') { depth--; if (depth == 0) { end = i; break; } }
        }
        return json.substring(br, end + 1);
    }

    private String safe(String s) { return s != null ? s : ""; }

    private String err(String msg) {
        return "{\"reply\":" + toJson(msg) + ",\"products\":[]}";
    }

    private void writeJson(HttpServletResponse res, String json) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = res.getWriter()) {
            out.print(json);
            out.flush();
        }
    }
}