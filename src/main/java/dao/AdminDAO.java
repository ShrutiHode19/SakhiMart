package dao;

import java.sql.*;
import model.Admin;
import util.DBConnection;

public class AdminDAO {

    // ── LOGIN ────────────────────────────────────────────────────────────────
    public Admin loginAdmin(String login_id, String password) {
        Admin a = null;
        String sql = "SELECT * FROM admin WHERE a_login_id = ? AND a_password = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, login_id);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    a = mapRow(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return a;
    }

    // ── GET PROFILE BY LOGIN ID ───────────────────────────────────────────────
    public Admin getAdminProfile(String login_id) {
        Admin a = null;
        String sql = "SELECT * FROM admin WHERE a_login_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, login_id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    a = mapRow(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return a;
    }

    // ── UPDATE PROFILE ────────────────────────────────────────────────────────
    public boolean updateAdminProfile(Admin a) {
        String sql = "UPDATE admin SET a_fullname=?, a_email=?, a_address=?, a_contact=?, a_gender=? WHERE a_login_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, a.getA_fullname());
            ps.setString(2, a.getA_email());
            ps.setString(3, a.getA_address());
            ps.setLong  (4, a.getA_contact());
            ps.setString(5, a.getA_gender());
            ps.setString(6, a.getA_login_id());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── HELPER ────────────────────────────────────────────────────────────────
    private Admin mapRow(ResultSet rs) throws SQLException {
        Admin a = new Admin();
        a.setA_id      (rs.getInt   ("a_id"));
        a.setA_fullname(rs.getString("a_fullname"));
        a.setA_login_id(rs.getString("a_login_id"));
        a.setA_email   (rs.getString("a_email"));
        a.setA_address (rs.getString("a_address"));
        a.setA_gender  (rs.getString("a_gender"));
        a.setA_contact (rs.getLong  ("a_contact"));
        return a;
    }
}