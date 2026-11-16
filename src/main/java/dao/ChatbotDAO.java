package dao;

import model.Product;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * ChatbotDAO.java  —  SakhiMart AI Chatbot  (FIXED v2)
 * src/main/java/dao/ChatbotDAO.java
 *
 * KEY FIX: Every DB method is wrapped so a missing table or SQL error
 * never crashes the servlet. The chatbot will still call Claude AI
 * even if the chatbot tables don't exist yet.
 */
public class ChatbotDAO {

    private static final List<String> PICKLE  = Arrays.asList("pickle","achar","mango pickle","lime pickle","lemon pickle");
    private static final List<String> FOOD    = Arrays.asList("food","snack","papad","chakli","laddu","millet","ghee","honey","spice","organic");
    private static final List<String> CRAFT   = Arrays.asList("handicraft","basket","jute","cushion","decor","bamboo","craft");
    private static final List<String> TEXTILE = Arrays.asList("textile","cloth","saree","shawl","fabric","handwoven","cotton","silk");
    private static final List<String> BEAUTY  = Arrays.asList("beauty","soap","herbal","wellness","cream","oil","skincare","necklace","jewel");

    // ── 1. RULE MATCHING ────────────────────────────────────────────────────────
    /** Returns admin-defined reply if keyword matches, else null. Never crashes. */
    public String matchRule(String userMessage) {
        if (userMessage == null || userMessage.trim().isEmpty()) return null;
        String lower = userMessage.toLowerCase();
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return null;
            String sql = "SELECT keyword, response FROM chatbot_rules WHERE is_active=1 ORDER BY priority DESC";
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kw = rs.getString("keyword");
                    if (kw != null && lower.contains(kw.toLowerCase().trim())) {
                        return rs.getString("response");
                    }
                }
            }
        } catch (Exception e) {
            // Table may not exist yet — silently return null, let Claude handle it
            System.out.println("[ChatbotDAO] matchRule skipped: " + e.getMessage());
        }
        return null;
    }

    // ── 2. PRODUCT SEARCH ────────────────────────────────────────────────────────
    /** Smart product search — returns empty list on any error. */
    public List<Product> searchProductsForChat(String message) {
        List<Product> results = new ArrayList<>();
        if (message == null || message.trim().isEmpty()) return results;
        String lower = message.toLowerCase().trim();
        String detectedCategory = detectCategory(lower);
        String keyword = extractKeyword(lower);
        String sql = "SELECT * FROM product WHERE p_status='approved' "
                   + "AND (p_name LIKE ? OR p_category LIKE ? OR p_description LIKE ?) "
                   + "ORDER BY p_id DESC LIMIT 5";
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return results;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                String catPat = "%" + (detectedCategory != null ? detectedCategory : keyword) + "%";
                String kwPat  = "%" + keyword + "%";
                ps.setString(1, catPat);
                ps.setString(2, kwPat);
                ps.setString(3, kwPat);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) results.add(mapProduct(rs));
            }
        } catch (Exception e) {
            System.out.println("[ChatbotDAO] searchProductsForChat error: " + e.getMessage());
        }
        return results;
    }

    /** Returns top N approved products. Returns empty list on error. */
    public List<Product> getTopApprovedProducts(int limit) {
        List<Product> results = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return results;
            String sql = "SELECT * FROM product WHERE p_status='approved' ORDER BY p_id DESC LIMIT ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, limit);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) results.add(mapProduct(rs));
            }
        } catch (Exception e) {
            System.out.println("[ChatbotDAO] getTopApprovedProducts error: " + e.getMessage());
        }
        return results;
    }

    // ── 3. FAQ ────────────────────────────────────────────────────────────────────
    /** Returns FAQs as a text block for the AI system prompt. Returns "" on error. */
    public String getFAQsForPrompt() {
        StringBuilder sb = new StringBuilder();
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return "";
            String sql = "SELECT faq_question, faq_answer FROM chatbot_faq WHERE is_active=1 ORDER BY faq_id ASC";
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    sb.append("Q: ").append(rs.getString("faq_question"))
                      .append("\nA: ").append(rs.getString("faq_answer"))
                      .append("\n\n");
                }
            }
        } catch (Exception e) {
            System.out.println("[ChatbotDAO] getFAQsForPrompt skipped: " + e.getMessage());
        }
        return sb.toString();
    }

    /** Returns all active FAQs for admin UI. Returns empty list on error. */
    public List<String[]> getAllFAQs() {
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return list;
            String sql = "SELECT faq_id, faq_question, faq_answer, faq_category FROM chatbot_faq WHERE is_active=1 ORDER BY faq_id ASC";
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{
                        String.valueOf(rs.getInt("faq_id")),
                        rs.getString("faq_question"),
                        rs.getString("faq_answer"),
                        rs.getString("faq_category")
                    });
                }
            }
        } catch (Exception e) {
            System.out.println("[ChatbotDAO] getAllFAQs skipped: " + e.getMessage());
        }
        return list;
    }

    /** Admin: add FAQ. Returns false on error. */
    public boolean addFAQ(String question, String answer, String category) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return false;
            String sql = "INSERT INTO chatbot_faq (faq_question, faq_answer, faq_category) VALUES (?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, question.trim());
                ps.setString(2, answer.trim());
                ps.setString(3, category != null ? category.trim() : "General");
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) { System.out.println("[ChatbotDAO] addFAQ error: " + e.getMessage()); return false; }
    }

    /** Admin: soft-delete FAQ. Returns false on error. */
    public boolean deleteFAQ(int faqId) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return false;
            try (PreparedStatement ps = con.prepareStatement("UPDATE chatbot_faq SET is_active=0 WHERE faq_id=?")) {
                ps.setInt(1, faqId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) { return false; }
    }

    // ── 4. RULES ────────────────────────────────────────────────────────────────
    /** Returns all active rules for admin UI. Returns empty list on error. */
    public List<String[]> getAllRules() {
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return list;
            String sql = "SELECT rule_id, keyword, response, priority FROM chatbot_rules WHERE is_active=1 ORDER BY priority DESC";
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{
                        String.valueOf(rs.getInt("rule_id")),
                        rs.getString("keyword"),
                        rs.getString("response"),
                        String.valueOf(rs.getInt("priority"))
                    });
                }
            }
        } catch (Exception e) { System.out.println("[ChatbotDAO] getAllRules skipped: " + e.getMessage()); }
        return list;
    }

    /** Admin: add rule. Returns false on error. */
    public boolean addRule(String keyword, String response, int priority) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return false;
            String sql = "INSERT INTO chatbot_rules (keyword, response, priority) VALUES (?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, keyword.trim().toLowerCase());
                ps.setString(2, response.trim());
                ps.setInt(3, priority);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) { System.out.println("[ChatbotDAO] addRule error: " + e.getMessage()); return false; }
    }

    /** Admin: soft-delete rule. */
    public boolean deleteRule(int ruleId) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return false;
            try (PreparedStatement ps = con.prepareStatement("UPDATE chatbot_rules SET is_active=0 WHERE rule_id=?")) {
                ps.setInt(1, ruleId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) { return false; }
    }

    // ── 5. CHAT LOG ─────────────────────────────────────────────────────────────
    /** Saves chat to log. Silently skips on error (never crashes servlet). */
    public void saveChatLog(String userType, int userId, String userMsg, String botReply) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return;
            String sql = "INSERT INTO chatbot_log (user_type, user_id, user_msg, bot_reply) VALUES (?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, userType != null ? userType : "guest");
                ps.setInt(2, userId);
                ps.setString(3, userMsg != null && userMsg.length() > 1000 ? userMsg.substring(0, 1000) : userMsg);
                ps.setString(4, botReply != null && botReply.length() > 2000 ? botReply.substring(0, 2000) : botReply);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            System.out.println("[ChatbotDAO] saveChatLog skipped: " + e.getMessage());
        }
    }

    /** Returns recent chat logs for admin. Returns empty list on error. */
    public List<String[]> getRecentLogs(int limit) {
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return list;
            String sql = "SELECT log_id, user_type, user_id, user_msg, bot_reply, created_at FROM chatbot_log ORDER BY log_id DESC LIMIT ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, limit);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    list.add(new String[]{
                        String.valueOf(rs.getInt("log_id")),
                        rs.getString("user_type"),
                        String.valueOf(rs.getInt("user_id")),
                        rs.getString("user_msg"),
                        rs.getString("bot_reply"),
                        rs.getString("created_at")
                    });
                }
            }
        } catch (Exception e) { System.out.println("[ChatbotDAO] getRecentLogs skipped: " + e.getMessage()); }
        return list;
    }

    // ── 6. ORDER LOOKUP ──────────────────────────────────────────────────────────
    /** Returns latest order summary string for a customer. Returns null on error. */
    public String getLatestOrderSummary(int customerId) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return null;
            String sql = "SELECT order_id, total_amount, payment_status, delivery_status, order_date FROM orders WHERE c_id=? ORDER BY order_id DESC LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, customerId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    return "Order #" + rs.getInt("order_id")
                         + " | Total: Rs." + String.format("%.2f", rs.getDouble("total_amount"))
                         + " | Payment: " + rs.getString("payment_status")
                         + " | Delivery: " + rs.getString("delivery_status")
                         + " | Date: " + rs.getString("order_date");
                }
            }
        } catch (Exception e) { System.out.println("[ChatbotDAO] getLatestOrderSummary error: " + e.getMessage()); }
        return null;
    }

    // ── HELPERS ──────────────────────────────────────────────────────────────────
    public boolean isGeneralProductQuery(String message) {
        if (message == null) return false;
        String l = message.toLowerCase();
        return l.contains("product") || l.contains("shop") || l.contains("buy")
            || l.contains("browse") || l.contains("item") || l.contains("available")
            || l.contains("show")   || l.contains("what") || l.contains("sell")
            || l.contains("list")   || l.contains("catalogue");
    }

    private String detectCategory(String lower) {
        for (String k : PICKLE)  if (lower.contains(k)) return "Pickle";
        for (String k : FOOD)    if (lower.contains(k)) return "Food";
        for (String k : CRAFT)   if (lower.contains(k)) return "Handicraft";
        for (String k : TEXTILE) if (lower.contains(k)) return "Cloth";
        for (String k : BEAUTY)  if (lower.contains(k)) return "Beauty";
        return null;
    }

    private String extractKeyword(String message) {
        String[] stop = {"show","find","get","what","which","tell","me","about","any","all","the",
            "is","are","have","do","does","can","i","want","need","looking","for","buy","purchase",
            "available","products","items","please","how","much","does","cost","costs","list","a","and"};
        for (String word : message.split("\\s+")) {
            String clean = word.replaceAll("[^a-z0-9]", "");
            if (clean.length() < 3) continue;
            boolean isStop = false;
            for (String s : stop) { if (s.equals(clean)) { isStop = true; break; } }
            if (!isStop) return clean;
        }
        return message.length() > 30 ? message.substring(0, 30) : message;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setP_id(rs.getInt("p_id"));
        p.setP_name(rs.getString("p_name"));
        p.setP_description(rs.getString("p_description"));
        p.setP_category(rs.getString("p_category"));
        p.setP_price(rs.getDouble("p_price"));
        p.setP_quantity(rs.getInt("p_quantity"));
        p.setP_image_path(rs.getString("p_image_path"));
        p.setP_status(rs.getString("p_status"));
        p.setM_id(rs.getInt("m_id"));
        return p;
    }
}