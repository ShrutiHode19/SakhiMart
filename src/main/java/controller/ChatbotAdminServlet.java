package controller;

import dao.ChatbotDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * ChatbotAdminServlet.java  –  SakhiMart AI Chatbot Admin Actions
 * Place at: src/main/java/controller/ChatbotAdminServlet.java
 *
 * Handles POST form submissions from admin_chatbot.jsp:
 *   addFAQ    → insert a new FAQ row into chatbot_faq
 *   deleteFAQ → soft-delete FAQ by ID
 *   addRule   → insert a new keyword rule into chatbot_rules
 *   deleteRule→ soft-delete rule by ID
 *
 * All actions redirect back to admin_chatbot.jsp with a session message.
 */
@WebServlet("/ChatbotAdminServlet")
public class ChatbotAdminServlet extends HttpServlet {

    private ChatbotDAO chatbotDAO;

    @Override
    public void init() throws ServletException {
        chatbotDAO = new ChatbotDAO();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // ── Auth guard: admin only ────────────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("a_id") == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";
        String redirectUrl = req.getContextPath() + "/jsp/admin/admin_chatbot.jsp";
        String msg;

        switch (action) {

            // ── Add FAQ ───────────────────────────────────────────────────────
            case "addFAQ": {
                String question = req.getParameter("faq_question");
                String answer   = req.getParameter("faq_answer");
                String category = req.getParameter("faq_category");

                if (question == null || question.trim().isEmpty() ||
                    answer   == null || answer.trim().isEmpty()) {
                    msg = "Error: Question and Answer are required.";
                } else {
                    boolean ok = chatbotDAO.addFAQ(question.trim(), answer.trim(), category);
                    msg = ok ? "FAQ added successfully!" : "Error: Could not add FAQ.";
                }
                break;
            }

            // ── Delete FAQ ────────────────────────────────────────────────────
            case "deleteFAQ": {
                int faqId = parseSafe(req.getParameter("faq_id"));
                boolean ok = chatbotDAO.deleteFAQ(faqId);
                msg = ok ? "FAQ deleted." : "Error: Could not delete FAQ.";
                break;
            }

            // ── Add Keyword Rule ──────────────────────────────────────────────
            case "addRule": {
                String keyword  = req.getParameter("keyword");
                String response = req.getParameter("response");
                int    priority = parseSafe(req.getParameter("priority"));
                if (priority < 1) priority = 5;

                if (keyword  == null || keyword.trim().isEmpty() ||
                    response == null || response.trim().isEmpty()) {
                    msg = "Error: Keyword and Response are required.";
                } else {
                    boolean ok = chatbotDAO.addRule(keyword.trim(), response.trim(), priority);
                    msg = ok ? "Keyword rule added!" : "Error: Could not add rule.";
                }
                break;
            }

            // ── Delete Keyword Rule ───────────────────────────────────────────
            case "deleteRule": {
                int ruleId = parseSafe(req.getParameter("rule_id"));
                boolean ok = chatbotDAO.deleteRule(ruleId);
                msg = ok ? "Rule deleted." : "Error: Could not delete rule.";
                break;
            }

            default:
                msg = "Unknown action.";
        }

        session.setAttribute("adminChatMsg", msg);
        res.sendRedirect(redirectUrl);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.sendRedirect(req.getContextPath() + "/jsp/admin/admin_chatbot.jsp");
    }

    private int parseSafe(String val) {
        try { return (val != null) ? Integer.parseInt(val.trim()) : 0; }
        catch (NumberFormatException e) { return 0; }
    }
}