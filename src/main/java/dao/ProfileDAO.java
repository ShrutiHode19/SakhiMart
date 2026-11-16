package dao;

import java.sql.*;
import model.Customer;
import util.DBConnection;

public class ProfileDAO {

    // GET PROFILE
    public Customer getProfile(String username) {
        Customer c = null;
        String sql = "SELECT * FROM customer WHERE c_login_id=?";

        // BUG FIX #5: Connection was opened but never closed → resource leak
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    c = new Customer();
                    c.setC_id      (rs.getInt   ("c_id"));
                    c.setC_fullname(rs.getString ("c_fullname"));
                    c.setC_login_id(rs.getString ("c_login_id"));
                    c.setC_email   (rs.getString ("c_email"));
                    c.setC_address (rs.getString ("c_address"));
                    c.setC_gender  (rs.getString ("c_gender"));
                    c.setC_contact (rs.getLong   ("c_contact"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return c;
    }

    // UPDATE PROFILE
    public boolean updateProfile(Customer c) {
        String sql = "UPDATE customer SET c_fullname=?, c_email=?, c_address=?, c_contact=? WHERE c_login_id=?";

        // BUG FIX #5: Connection was opened but never closed → resource leak
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, c.getC_fullname());
            ps.setString(2, c.getC_email());
            ps.setString(3, c.getC_address());
            ps.setLong  (4, c.getC_contact());
            ps.setString(5, c.getC_login_id());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
