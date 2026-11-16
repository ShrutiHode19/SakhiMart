package controller;

import dao.CartDAO;
import model.CartItem;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * CartServlet.java
 * Handles all Cart module actions for customers.
 *
 * GET  /CartServlet?action=view          → show cart page
 * POST /CartServlet  action=add          → add item to cart
 * POST /CartServlet  action=update       → update item quantity
 * POST /CartServlet  action=remove       → remove one item
 * POST /CartServlet  action=clear        → clear entire cart
 */
@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    private CartDAO cartDAO;

    @Override
    public void init() {
        cartDAO = new CartDAO();
    }

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("c_id") == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp?msg=login_required");
            return;
        }

        int c_id = (Integer) session.getAttribute("c_id");
        List<CartItem> cartItems = cartDAO.getCartItems(c_id);

        double total    = 0;
        int    itemCount = 0;
        for (CartItem item : cartItems) {
            total     += item.getSubtotal();
            itemCount += item.getQuantity();
        }

        req.setAttribute("cartItems",  cartItems);
        req.setAttribute("cartTotal",  total);
        req.setAttribute("itemCount",  itemCount);
        req.getRequestDispatcher("/jsp/customer/cart.jsp").forward(req, res);
    }

    // ── POST ─────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("c_id") == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp?msg=login_required");
            return;
        }

        int    c_id   = (Integer) session.getAttribute("c_id");
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "add": {
                int p_id     = parseIntSafe(req.getParameter("p_id"),  0);
                int quantity = parseIntSafe(req.getParameter("qty"),    1);

                if (p_id <= 0 || quantity <= 0) {
                    res.sendRedirect(req.getContextPath() +
                        "/CartServlet?action=view&msg=invalid");
                    return;
                }

                boolean added = cartDAO.addToCart(c_id, p_id, quantity);
                String  msg   = added ? "added" : "error";
                res.sendRedirect(req.getContextPath() +
                    "/CartServlet?action=view&msg=" + msg);
                break;
            }

            case "update": {
                int cart_id  = parseIntSafe(req.getParameter("cart_id"), 0);
                int quantity = parseIntSafe(req.getParameter("qty"),      1);

                if (cart_id <= 0 || quantity <= 0) {
                    res.sendRedirect(req.getContextPath() +
                        "/CartServlet?action=view&msg=invalid");
                    return;
                }

                cartDAO.updateQuantity(cart_id, c_id, quantity);
                res.sendRedirect(req.getContextPath() +
                    "/CartServlet?action=view&msg=updated");
                break;
            }

            case "remove": {
                int cart_id = parseIntSafe(req.getParameter("cart_id"), 0);
                if (cart_id > 0) cartDAO.removeFromCart(cart_id, c_id);
                res.sendRedirect(req.getContextPath() +
                    "/CartServlet?action=view&msg=removed");
                break;
            }

            case "clear": {
                cartDAO.clearCart(c_id);
                res.sendRedirect(req.getContextPath() +
                    "/CartServlet?action=view&msg=cleared");
                break;
            }

            default:
                res.sendRedirect(req.getContextPath() + "/CartServlet?action=view");
        }
    }

    // ── Utility ──────────────────────────────────────────────────────────────
    private int parseIntSafe(String value, int fallback) {
        try { return (value != null) ? Integer.parseInt(value.trim()) : fallback; }
        catch (NumberFormatException e) { return fallback; }
    }
}