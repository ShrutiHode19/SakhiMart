package dao;

import model.CartItem;
import model.Order;
import model.OrderItem;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * OrderDAO.java
 * All database operations for the Order module.
 *
 * Works with tables: orders, order_items
 * After placing order, also inserts into payment table.
 */
public class OrderDAO {

    // ── Place Order: insert orders + order_items + payment, reduce stock ──────
    public int placeOrder(int c_id, String deliveryAddress, String paymentMethod,
                          List<CartItem> cartItems, double totalAmount) {

        String orderSql = "INSERT INTO orders (c_id, total_amount, payment_method, "
                        + "payment_status, delivery_status, delivery_address) "
                        + "VALUES (?, ?, ?, 'Pending', 'Processing', ?)";

        String itemSql  = "INSERT INTO order_items (order_id, p_id, quantity, unit_price) "
                        + "VALUES (?, ?, ?, ?)";

        String stockSql = "UPDATE product SET p_quantity = p_quantity - ? "
                        + "WHERE p_id = ? AND p_quantity >= ?";

        String paymentSql = "INSERT INTO payment (payment_amount, payment_method, "
                          + "payment_status, payment_date, o_id) "
                          + "VALUES (?, ?, 'Pending', NOW(), ?)";

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // 1. Insert order header
            PreparedStatement orderPs = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, c_id);
            orderPs.setDouble(2, totalAmount);
            orderPs.setString(3, paymentMethod);
            orderPs.setString(4, deliveryAddress);
            orderPs.executeUpdate();

            ResultSet keys = orderPs.getGeneratedKeys();
            if (!keys.next()) { con.rollback(); return -1; }
            int orderId = keys.getInt(1);

            // 2. Insert each order item + reduce product stock
            for (CartItem item : cartItems) {
                PreparedStatement itemPs = con.prepareStatement(itemSql);
                itemPs.setInt(1, orderId);
                itemPs.setInt(2, item.getP_id());
                itemPs.setInt(3, item.getQuantity());
                itemPs.setDouble(4, item.getP_price());
                itemPs.executeUpdate();

                PreparedStatement stockPs = con.prepareStatement(stockSql);
                stockPs.setInt(1, item.getQuantity());
                stockPs.setInt(2, item.getP_id());
                stockPs.setInt(3, item.getQuantity());
                int updated = stockPs.executeUpdate();
                if (updated == 0) {
                    con.rollback();
                    return -2; // insufficient stock
                }
            }

            // 3. Create payment record automatically
            PreparedStatement payPs = con.prepareStatement(paymentSql);
            payPs.setDouble(1, totalAmount);
            payPs.setString(2, paymentMethod);
            payPs.setInt(3, orderId);
            payPs.executeUpdate();

            con.commit();
            return orderId;

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return -1;
        } finally {
            try { if (con != null) { con.setAutoCommit(true); con.close(); } }
            catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ── Customer: get all their orders ───────────────────────────────────────
    public List<Order> getOrdersByCustomer(int c_id) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE c_id=? ORDER BY order_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c_id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapOrder(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Get a single order by ID ─────────────────────────────────────────────
    public Order getOrderById(int orderId) {
        String sql = "SELECT o.*, c.c_fullname, c.c_email, c.c_contact "
                   + "FROM orders o JOIN customer c ON o.c_id = c.c_id "
                   + "WHERE o.order_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order o = mapOrder(rs);
                o.setC_fullname(rs.getString("c_fullname"));
                o.setC_email(rs.getString("c_email"));
                o.setC_contact(String.valueOf(rs.getLong("c_contact")));
                return o;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Get order items for a specific order ─────────────────────────────────
    public List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = "SELECT oi.*, p.p_name, p.p_image_path, p.p_category "
                   + "FROM order_items oi JOIN product p ON oi.p_id = p.p_id "
                   + "WHERE oi.order_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem oi = new OrderItem();
                oi.setOrder_item_id(rs.getInt("order_item_id"));
                oi.setOrder_id(rs.getInt("order_id"));
                oi.setP_id(rs.getInt("p_id"));
                oi.setQuantity(rs.getInt("quantity"));
                oi.setUnit_price(rs.getDouble("unit_price"));
                oi.setP_name(rs.getString("p_name"));
                oi.setP_image_path(rs.getString("p_image_path"));
                oi.setP_category(rs.getString("p_category"));
                list.add(oi);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Admin: get all orders ─────────────────────────────────────────────────
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, c.c_fullname, c.c_email, c.c_contact "
                   + "FROM orders o JOIN customer c ON o.c_id = c.c_id "
                   + "ORDER BY o.order_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapOrder(rs);
                o.setC_fullname(rs.getString("c_fullname"));
                o.setC_email(rs.getString("c_email"));
                o.setC_contact(String.valueOf(rs.getLong("c_contact")));
                list.add(o);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Admin: confirm payment ────────────────────────────────────────────────
    public boolean confirmPayment(int orderId) {
        String sql = "UPDATE orders SET payment_status='Confirmed' WHERE order_id=?";
        return runUpdate(sql, orderId);
    }

    // ── Admin: update delivery status ─────────────────────────────────────────
    public boolean updateDeliveryStatus(int orderId, String status) {
        String sql = "UPDATE orders SET delivery_status=? WHERE order_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ── Admin: cancel order ───────────────────────────────────────────────────
    public boolean cancelOrder(int orderId) {
        String sql = "UPDATE orders SET delivery_status='Cancelled', payment_status='Failed' "
                   + "WHERE order_id=?";
        return runUpdate(sql, orderId);
    }

    // ── Member: orders for their products ────────────────────────────────────
    public List<Order> getOrdersForMember(int m_id) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT DISTINCT o.*, c.c_fullname, c.c_email, c.c_contact "
                   + "FROM orders o "
                   + "JOIN order_items oi ON o.order_id = oi.order_id "
                   + "JOIN product p ON oi.p_id = p.p_id "
                   + "JOIN customer c ON o.c_id = c.c_id "
                   + "WHERE p.m_id = ? "
                   + "ORDER BY o.order_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, m_id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapOrder(rs);
                o.setC_fullname(rs.getString("c_fullname"));
                o.setC_email(rs.getString("c_email"));
                o.setC_contact(String.valueOf(rs.getLong("c_contact")));
                list.add(o);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Helper ───────────────────────────────────────────────────────────────
    private boolean runUpdate(String sql, int param) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrder_id(rs.getInt("order_id"));
        o.setC_id(rs.getInt("c_id"));
        o.setOrder_date(rs.getString("order_date"));
        o.setTotal_amount(rs.getDouble("total_amount"));
        o.setPayment_method(rs.getString("payment_method"));
        o.setPayment_status(rs.getString("payment_status"));
        o.setDelivery_status(rs.getString("delivery_status"));
        o.setDelivery_address(rs.getString("delivery_address"));
        return o;
    }
}