package dao;

import java.sql.*;
import java.util.*;
import model.Customer;
import util.DBConnection;

public class CustomerDAO {

    // ── REGISTER ─────────────────────────────────────────────────────────────
    public boolean registerCustomer(Customer c) {
        String sql = "INSERT INTO customer "
                   + "(c_fullname, c_login_id, c_password, c_email, c_address, c_gender, c_contact) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getC_fullname());
            ps.setString(2, c.getC_login_id());
            ps.setString(3, c.getC_password());
            ps.setString(4, c.getC_email());
            ps.setString(5, c.getC_address());
            ps.setString(6, c.getC_gender());
            ps.setLong  (7, c.getC_contact());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ── LOGIN ─────────────────────────────────────────────────────────────────
    public Customer loginCustomer(String login_id, String password) {
        Customer c = null;
        String sql = "SELECT * FROM customer WHERE c_login_id = ? AND c_password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, login_id);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) c = mapRow(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return c;
    }

    // ── GET ALL CUSTOMERS (for admin manage-users page) ───────────────────────
    public List<Customer> getAllCustomers() {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM customer ORDER BY c_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ── MAP ROW ───────────────────────────────────────────────────────────────
    private Customer mapRow(ResultSet rs) throws SQLException {
        Customer c = new Customer();
        c.setC_id      (rs.getInt   ("c_id"));
        c.setC_fullname(rs.getString("c_fullname"));
        c.setC_login_id(rs.getString("c_login_id"));
        c.setC_password(rs.getString("c_password"));
        c.setC_email   (rs.getString("c_email"));
        c.setC_address (rs.getString("c_address"));
        c.setC_gender  (rs.getString("c_gender"));
        c.setC_contact (rs.getLong  ("c_contact"));
        return c;
    }
}