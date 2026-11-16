package controller;

import dao.PaymentDAO;
import model.Payment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * PaymentServlet.java
 * Handles Payment & Delivery Module.
 *
 * Customer:
 *   GET  /PaymentServlet?action=myPayments        → my payment history
 *   GET  /PaymentServlet?action=paymentDetail&id= → single payment + delivery status
 *
 * Admin:
 *   GET  /PaymentServlet?action=allPayments        → all payments dashboard
 *   POST /PaymentServlet  action=confirmPayment    → confirm payment
 *   POST /PaymentServlet  action=rejectPayment     → reject payment
 *   POST /PaymentServlet  action=updateDelivery    → update delivery status
 *   POST /PaymentServlet  action=cancelOrder       → cancel order
 *   POST /PaymentServlet  action=updateTxnId       → update transaction ID
 *
 * Member:
 *   GET  /PaymentServlet?action=memberDelivery       → member delivery view
 *   POST /PaymentServlet  action=memberUpdateDelivery→ member updates delivery
 */
@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    private PaymentDAO paymentDAO;

    @Override
    public void init() {
        paymentDAO = new PaymentDAO();
    }

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "myPayments": {
                if (!isCustomer(session)) { redirectLogin(req, res); return; }
                int c_id = (Integer) session.getAttribute("c_id");
                List<Payment> payments = paymentDAO.getPaymentsByCustomer(c_id);
                req.setAttribute("payments", payments);
                req.getRequestDispatcher("/jsp/customer/my_payments.jsp").forward(req, res);
                break;
            }

            case "paymentDetail": {
                if (!isCustomer(session)) { redirectLogin(req, res); return; }
                int o_id = parseIntSafe(req.getParameter("id"), 0);
                Payment pay = paymentDAO.getPaymentByOrderId(o_id);
                if (pay == null) {
                    res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=myPayments&msg=notfound");
                    return;
                }
                req.setAttribute("payment", pay);
                req.getRequestDispatcher("/jsp/customer/my_payments.jsp").forward(req, res);
                break;
            }

            case "allPayments": {
                if (!isAdmin(session)) { redirectLogin(req, res); return; }
                List<Payment> payments = paymentDAO.getAllPayments();
                double totalRevenue    = paymentDAO.getTotalRevenue();
                int completedCount     = paymentDAO.countByStatus("Completed");
                int pendingCount       = paymentDAO.countByStatus("Pending");
                int failedCount        = paymentDAO.countByStatus("Failed");
                req.setAttribute("payments",       payments);
                req.setAttribute("totalRevenue",   totalRevenue);
                req.setAttribute("completedCount", completedCount);
                req.setAttribute("pendingCount",   pendingCount);
                req.setAttribute("failedCount",    failedCount);
                req.getRequestDispatcher("/jsp/admin/manage_payments.jsp").forward(req, res);
                break;
            }

            case "memberDelivery": {
                if (!isMember(session)) { redirectLogin(req, res); return; }
                int m_id = (Integer) session.getAttribute("m_id");
                List<Payment> payments = paymentDAO.getPaymentsForMember(m_id);
                req.setAttribute("payments", payments);
                req.getRequestDispatcher("/jsp/member/member_delivery.jsp").forward(req, res);
                break;
            }

            default:
                res.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    // ── POST ─────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "confirmPayment": {
                if (!isAdmin(session)) { redirectLogin(req, res); return; }
                int payment_id = parseIntSafe(req.getParameter("payment_id"), 0);
                boolean ok = paymentDAO.confirmPayment(payment_id);
                res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=allPayments&msg=" + (ok ? "pay_confirmed" : "error"));
                break;
            }

            case "rejectPayment": {
                if (!isAdmin(session)) { redirectLogin(req, res); return; }
                int payment_id = parseIntSafe(req.getParameter("payment_id"), 0);
                boolean ok = paymentDAO.rejectPayment(payment_id);
                res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=allPayments&msg=" + (ok ? "pay_rejected" : "error"));
                break;
            }

            case "updateDelivery": {
                if (!isAdmin(session)) { redirectLogin(req, res); return; }
                int    o_id      = parseIntSafe(req.getParameter("o_id"), 0);
                String newStatus = req.getParameter("o_status");
                if (newStatus == null || newStatus.trim().isEmpty()) {
                    res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=allPayments&msg=invalid");
                    return;
                }
                boolean ok = paymentDAO.updateDeliveryStatus(o_id, newStatus.trim());
                res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=allPayments&msg=" + (ok ? "delivery_updated" : "error"));
                break;
            }

            case "cancelOrder": {
                if (!isAdmin(session)) { redirectLogin(req, res); return; }
                int o_id = parseIntSafe(req.getParameter("o_id"), 0);
                boolean ok = paymentDAO.cancelOrderWithPayment(o_id);
                res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=allPayments&msg=" + (ok ? "order_cancelled" : "error"));
                break;
            }

            case "updateTxnId": {
                if (!isAdmin(session)) { redirectLogin(req, res); return; }
                int    payment_id    = parseIntSafe(req.getParameter("payment_id"), 0);
                String transaction_id = req.getParameter("transaction_id");
                if (transaction_id != null && !transaction_id.trim().isEmpty()) {
                    paymentDAO.updateTransactionId(payment_id, transaction_id.trim());
                }
                res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=allPayments&msg=txn_updated");
                break;
            }

            case "memberUpdateDelivery": {
                if (!isMember(session)) { redirectLogin(req, res); return; }
                int    o_id      = parseIntSafe(req.getParameter("o_id"), 0);
                String newStatus = req.getParameter("o_status");
                if ("Shipped".equals(newStatus) && o_id > 0) {
                    paymentDAO.updateDeliveryStatus(o_id, "Shipped");
                }
                res.sendRedirect(req.getContextPath() + "/PaymentServlet?action=memberDelivery&msg=updated");
                break;
            }

            default:
                res.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    private boolean isCustomer(HttpSession s) { return s != null && s.getAttribute("c_id") != null; }
    private boolean isAdmin   (HttpSession s) { return s != null && s.getAttribute("a_id") != null; }
    private boolean isMember  (HttpSession s) { return s != null && s.getAttribute("m_id") != null; }

    private void redirectLogin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp?msg=login_required");
    }

    private int parseIntSafe(String value, int fallback) {
        try { return (value != null) ? Integer.parseInt(value.trim()) : fallback; }
        catch (NumberFormatException e) { return fallback; }
    }
}