package controller;

import dao.CartDAO;
import dao.OrderDAO;
import model.CartItem;
import model.Order;
import model.OrderItem;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * OrderServlet.java
 *
 * Flow:
 *   Cart → checkout (GET) → placeOrder (POST) → confirmation page
 *
 * Customer:
 *   GET  /OrderServlet?action=checkout         → show checkout page
 *   POST /OrderServlet  action=placeOrder      → place order → redirect to confirmation
 *   GET  /OrderServlet?action=myOrders         → order history
 *   GET  /OrderServlet?action=orderDetail&id=X → order detail / receipt
 *   GET  /OrderServlet?action=confirmation&id=X→ order confirmation page (after place)
 *
 * Admin:
 *   GET  /OrderServlet?action=allOrders        → all orders
 *   POST /OrderServlet  action=confirmPayment  → confirm payment
 *   POST /OrderServlet  action=updateDelivery  → update delivery
 *   POST /OrderServlet  action=cancelOrder     → cancel order
 *
 * Member:
 *   GET  /OrderServlet?action=memberOrders     → member's product orders
 */
@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private CartDAO  cartDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
        cartDAO  = new CartDAO();
    }

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            // ── Customer: checkout page ──────────────────────────────────
            case "checkout": {
                if (!isCustomer(session)) { redirectLogin(req, res); return; }
                int c_id = (Integer) session.getAttribute("c_id");
                List<CartItem> cartItems = cartDAO.getCartItems(c_id);
                if (cartItems.isEmpty()) {
                    res.sendRedirect(req.getContextPath() + "/CartServlet?action=view&msg=empty");
                    return;
                }
                double total = cartDAO.getCartTotal(c_id);
                req.setAttribute("cartItems", cartItems);
                req.setAttribute("cartTotal",  total);
                req.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(req, res);
                break;
            }

            // ── Customer: confirmation page (shown after placing order) ──
            case "confirmation": {
                if (!isCustomer(session)) { redirectLogin(req, res); return; }
                int orderId = parseIntSafe(req.getParameter("id"), 0);
                int c_id    = (Integer) session.getAttribute("c_id");
                Order order = orderDAO.getOrderById(orderId);
                if (order == null || order.getC_id() != c_id) {
                    res.sendRedirect(req.getContextPath() + "/OrderServlet?action=myOrders");
                    return;
                }
                List<OrderItem> items = orderDAO.getOrderItems(orderId);
                req.setAttribute("order",      order);
                req.setAttribute("orderItems", items);
                req.getRequestDispatcher("/jsp/customer/order_confirmation.jsp").forward(req, res);
                break;
            }

            // ── Customer: my orders list ─────────────────────────────────
            case "myOrders": {
                if (!isCustomer(session)) { redirectLogin(req, res); return; }
                int c_id = (Integer) session.getAttribute("c_id");
                List<Order> orders = orderDAO.getOrdersByCustomer(c_id);
                req.setAttribute("orders", orders);
                req.getRequestDispatcher("/jsp/customer/my_orders.jsp").forward(req, res);
                break;
            }

            // ── Customer: order detail / receipt ─────────────────────────
            case "orderDetail": {
                if (!isCustomer(session)) { redirectLogin(req, res); return; }
                int orderId = parseIntSafe(req.getParameter("id"), 0);
                int c_id    = (Integer) session.getAttribute("c_id");
                Order order = orderDAO.getOrderById(orderId);
                if (order == null || order.getC_id() != c_id) {
                    res.sendRedirect(req.getContextPath() + "/OrderServlet?action=myOrders&msg=notfound");
                    return;
                }
                List<OrderItem> items = orderDAO.getOrderItems(orderId);
                req.setAttribute("order",      order);
                req.setAttribute("orderItems", items);
                req.getRequestDispatcher("/jsp/customer/order_detail.jsp").forward(req, res);
                break;
            }

            // ── Admin: all orders dashboard ──────────────────────────────
            case "allOrders": {
                if (!isAdmin(session)) { res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp"); return; }
                List<Order> orders = orderDAO.getAllOrders();
                req.setAttribute("orders", orders);
                req.getRequestDispatcher("/jsp/admin/manage_orders.jsp").forward(req, res);
                break;
            }

            // ── Member: orders for their products ────────────────────────
            case "memberOrders": {
                if (!isMember(session)) { redirectLogin(req, res); return; }
                int m_id = (Integer) session.getAttribute("m_id");
                List<Order> orders = orderDAO.getOrdersForMember(m_id);
                req.setAttribute("orders", orders);
                req.getRequestDispatcher("/jsp/member/member_orders.jsp").forward(req, res);
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

            // ── Customer: place order ─────────────────────────────────────
            case "placeOrder": {
                if (!isCustomer(session)) { redirectLogin(req, res); return; }
                int    c_id            = (Integer) session.getAttribute("c_id");
                String deliveryAddress = req.getParameter("delivery_address");
                String paymentMethod   = req.getParameter("payment_method");

                if (deliveryAddress == null || deliveryAddress.trim().isEmpty()
                    || paymentMethod == null || paymentMethod.trim().isEmpty()) {
                    res.sendRedirect(req.getContextPath() + "/OrderServlet?action=checkout&msg=fill_all");
                    return;
                }

                List<CartItem> cartItems = cartDAO.getCartItems(c_id);
                if (cartItems.isEmpty()) {
                    res.sendRedirect(req.getContextPath() + "/CartServlet?action=view&msg=empty");
                    return;
                }

                double total   = cartDAO.getCartTotal(c_id);
                int    orderId = orderDAO.placeOrder(c_id, deliveryAddress.trim(),
                                                     paymentMethod, cartItems, total);

                if (orderId == -2) {
                    res.sendRedirect(req.getContextPath() + "/OrderServlet?action=checkout&msg=stock_error");
                    return;
                }
                if (orderId <= 0) {
                    res.sendRedirect(req.getContextPath() + "/OrderServlet?action=checkout&msg=error");
                    return;
                }

                // Clear cart after successful order
                cartDAO.clearCart(c_id);

                // Redirect to confirmation page (NOT orderDetail)
                res.sendRedirect(req.getContextPath() +
                    "/OrderServlet?action=confirmation&id=" + orderId);
                break;
            }

            // ── Admin: confirm payment ────────────────────────────────────
            case "confirmPayment": {
                if (!isAdmin(session)) { res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp"); return; }
                int orderId = parseIntSafe(req.getParameter("order_id"), 0);
                orderDAO.confirmPayment(orderId);
                res.sendRedirect(req.getContextPath() + "/OrderServlet?action=allOrders&msg=payment_confirmed");
                break;
            }

            // ── Admin: update delivery ────────────────────────────────────
            case "updateDelivery": {
                if (!isAdmin(session)) { res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp"); return; }
                int    orderId = parseIntSafe(req.getParameter("order_id"), 0);
                String status  = req.getParameter("delivery_status");
                if (status != null && !status.isEmpty()) {
                    orderDAO.updateDeliveryStatus(orderId, status);
                }
                res.sendRedirect(req.getContextPath() + "/OrderServlet?action=allOrders&msg=delivery_updated");
                break;
            }

            // ── Admin: cancel order ───────────────────────────────────────
            case "cancelOrder": {
                if (!isAdmin(session)) { res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp"); return; }
                int orderId = parseIntSafe(req.getParameter("order_id"), 0);
                orderDAO.cancelOrder(orderId);
                res.sendRedirect(req.getContextPath() + "/OrderServlet?action=allOrders&msg=cancelled");
                break;
            }

            default:
                res.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    // ── Session Helpers ───────────────────────────────────────────────────────
    private boolean isCustomer(HttpSession s) { return s != null && s.getAttribute("c_id") != null; }
    private boolean isAdmin(HttpSession s)    { return s != null && s.getAttribute("a_id") != null; }
    private boolean isMember(HttpSession s)   { return s != null && s.getAttribute("m_id") != null; }

    private void redirectLogin(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp?msg=login_required");
    }

    private int parseIntSafe(String value, int fallback) {
        try { return (value != null) ? Integer.parseInt(value.trim()) : fallback; }
        catch (NumberFormatException e) { return fallback; }
    }
}