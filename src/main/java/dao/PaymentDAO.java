package dao;

import model.Payment;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentDAO.java
 * All database operations for the Payment & Delivery Module.
 *
 * payment table: payment_id, payment_amount, payment_method, payment_status,
 *                payment_date, transaction_id, o_id (FK → orders.order_id)
 *
 * Delivery status is stored in orders.delivery_status
 */
public class PaymentDAO {

    // ── Get payment record by order ID ─────────────────────────────────────
    public Payment getPaymentByOrderId(int o_id) {
        String sql = "SELECT p.*, o.delivery_status AS o_status, "
                   + "o.order_date AS delivery_date, "
                   + "c.c_fullname, c.c_email, c.c_contact "
                   + "FROM payment p "
                   + "JOIN orders o ON p.o_id = o.order_id "
                   + "JOIN customer c ON o.c_id = c.c_id "
                   + "WHERE p.o_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, o_id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Payment pay = mapRow(rs);
                pay.setO_status(rs.getString("o_status"));
                pay.setDelivery_date(rs.getString("delivery_date"));
                pay.setC_fullname(rs.getString("c_fullname"));
                pay.setC_email(rs.getString("c_email"));
                pay.setC_contact(String.valueOf(rs.getLong("c_contact")));
                return pay;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Get payment by payment_id ──────────────────────────────────────────
    public Payment getPaymentByPaymentId(int payment_id) {
        String sql = "SELECT p.*, o.delivery_status AS o_status, "
                   + "o.order_date AS delivery_date, "
                   + "c.c_fullname, c.c_email, c.c_contact "
                   + "FROM payment p "
                   + "JOIN orders o ON p.o_id = o.order_id "
                   + "JOIN customer c ON o.c_id = c.c_id "
                   + "WHERE p.payment_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, payment_id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Payment pay = mapRow(rs);
                pay.setO_status(rs.getString("o_status"));
                pay.setDelivery_date(rs.getString("delivery_date"));
                pay.setC_fullname(rs.getString("c_fullname"));
                pay.setC_email(rs.getString("c_email"));
                pay.setC_contact(String.valueOf(rs.getLong("c_contact")));
                return pay;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Admin: All payments dashboard ─────────────────────────────────────
    public List<Payment> getAllPayments() {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.*, o.delivery_status AS o_status, "
                   + "o.order_date AS delivery_date, "
                   + "c.c_fullname, c.c_email, c.c_contact "
                   + "FROM payment p "
                   + "JOIN orders o ON p.o_id = o.order_id "
                   + "JOIN customer c ON o.c_id = c.c_id "
                   + "ORDER BY p.payment_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Payment pay = mapRow(rs);
                pay.setO_status(rs.getString("o_status"));
                pay.setDelivery_date(rs.getString("delivery_date"));
                pay.setC_fullname(rs.getString("c_fullname"));
                pay.setC_email(rs.getString("c_email"));
                pay.setC_contact(String.valueOf(rs.getLong("c_contact")));
                list.add(pay);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Customer: My Payments ──────────────────────────────────────────────
    public List<Payment> getPaymentsByCustomer(int c_id) {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.*, o.delivery_status AS o_status, o.order_date AS delivery_date "
                   + "FROM payment p "
                   + "JOIN orders o ON p.o_id = o.order_id "
                   + "WHERE o.c_id = ? "
                   + "ORDER BY p.payment_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c_id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Payment pay = mapRow(rs);
                pay.setO_status(rs.getString("o_status"));
                pay.setDelivery_date(rs.getString("delivery_date"));
                list.add(pay);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Admin: Confirm payment ─────────────────────────────────────────────
    public boolean confirmPayment(int payment_id) {
        String txn = "TXN" + System.currentTimeMillis();
        String sql = "UPDATE payment "
                   + "SET payment_status = 'Completed', "
                   + "    transaction_id = COALESCE(NULLIF(transaction_id,''), ?) "
                   + "WHERE payment_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, txn);
            ps.setInt(2, payment_id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ── Admin: Reject payment ──────────────────────────────────────────────
    public boolean rejectPayment(int payment_id) {
        String sql = "UPDATE payment SET payment_status = 'Failed' WHERE payment_id = ?";
        return runSingleUpdate(sql, payment_id);
    }

    // ── Admin: Update transaction ID ───────────────────────────────────────
    public boolean updateTransactionId(int payment_id, String transaction_id) {
        String sql = "UPDATE payment SET transaction_id = ? WHERE payment_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, transaction_id);
            ps.setInt(2, payment_id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ── Admin/Member: Update delivery status ───────────────────────────────
    public boolean updateDeliveryStatus(int o_id, String newStatus) {
        String sql = "UPDATE orders SET delivery_status = ? WHERE order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, o_id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ── Admin: Cancel order + fail payment ────────────────────────────────
    public boolean cancelOrderWithPayment(int o_id) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            PreparedStatement ps1 = con.prepareStatement(
                "UPDATE orders SET delivery_status = 'Cancelled' WHERE order_id = ?");
            ps1.setInt(1, o_id);
            ps1.executeUpdate();

            PreparedStatement ps2 = con.prepareStatement(
                "UPDATE payment SET payment_status = 'Failed' WHERE o_id = ?");
            ps2.setInt(1, o_id);
            ps2.executeUpdate();

            con.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { if (con != null) { con.setAutoCommit(true); con.close(); } }
            catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ── Member: payments for their products ───────────────────────────────
    public List<Payment> getPaymentsForMember(int m_id) {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT DISTINCT p.*, o.delivery_status AS o_status, "
                   + "o.order_date AS delivery_date, "
                   + "c.c_fullname, c.c_contact "
                   + "FROM payment p "
                   + "JOIN orders o ON p.o_id = o.order_id "
                   + "JOIN order_items oi ON o.order_id = oi.order_id "
                   + "JOIN product pr ON oi.p_id = pr.p_id "
                   + "JOIN customer c ON o.c_id = c.c_id "
                   + "WHERE pr.m_id = ? "
                   + "ORDER BY p.payment_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, m_id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Payment pay = mapRow(rs);
                pay.setO_status(rs.getString("o_status"));
                pay.setDelivery_date(rs.getString("delivery_date"));
                pay.setC_fullname(rs.getString("c_fullname"));
                pay.setC_contact(String.valueOf(rs.getLong("c_contact")));
                list.add(pay);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Stats ─────────────────────────────────────────────────────────────
    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(payment_amount), 0) FROM payment WHERE payment_status = 'Completed'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0.0;
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM payment WHERE payment_status = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private boolean runSingleUpdate(String sql, int param) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPayment_id(rs.getInt("payment_id"));
        p.setPayment_amount(rs.getDouble("payment_amount"));
        p.setPayment_method(rs.getString("payment_method"));
        p.setPayment_status(rs.getString("payment_status"));
        p.setPayment_date(rs.getString("payment_date"));
        p.setTransaction_id(rs.getString("transaction_id"));
        p.setO_id(rs.getInt("o_id"));
        return p;
    }
}