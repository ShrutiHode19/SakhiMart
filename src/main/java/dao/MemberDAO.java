package dao;

import java.sql.*;
import java.util.*;
import model.Member;
import util.DBConnection;

public class MemberDAO {

    // ── REGISTER (status defaults to 'pending' — admin must approve) ─────────
    public boolean registerMember(Member m) {
        String sql = "INSERT INTO member "
                   + "(m_fullname, m_login_id, m_password, m_email, m_address, m_gender, m_contact, m_status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, m.getM_fullname());
            ps.setString(2, m.getM_login_id());
            ps.setString(3, m.getM_password());
            ps.setString(4, m.getM_email());
            ps.setString(5, m.getM_address());
            ps.setString(6, m.getM_gender());
            ps.setLong  (7, m.getM_contact());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── LOGIN (returns member regardless of status; LoginServlet checks status) 
    public Member loginMember(String login_id, String password) {
        Member m = null;
        String sql = "SELECT * FROM member WHERE m_login_id = ? AND m_password = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, login_id);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m = mapRow(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return m;
    }

    // ── GET MEMBER PROFILE (by login_id) ─────────────────────────────────────
    public Member getMemberProfile(String login_id) {
        Member m = null;
        String sql = "SELECT * FROM member WHERE m_login_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, login_id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) m = mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return m;
    }

    // ── UPDATE MEMBER PROFILE ─────────────────────────────────────────────────
    public boolean updateMemberProfile(Member m) {
        String sql = "UPDATE member "
                   + "SET m_fullname=?, m_email=?, m_address=?, m_contact=? "
                   + "WHERE m_login_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, m.getM_fullname());
            ps.setString(2, m.getM_email());
            ps.setString(3, m.getM_address());
            ps.setLong  (4, m.getM_contact());
            ps.setString(5, m.getM_login_id());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── GET ALL MEMBERS (for admin manage-users page) ─────────────────────────
    public List<Member> getAllMembers() {
        List<Member> list = new ArrayList<>();
        String sql = "SELECT * FROM member ORDER BY register_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapRow(rs));

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── UPDATE MEMBER STATUS (approve / reject) ───────────────────────────────
    public boolean updateMemberStatus(int m_id, String status) {
        String sql = "UPDATE member SET m_status=? WHERE m_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt   (2, m_id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── PRIVATE HELPER: map ResultSet row → Member ────────────────────────────
    private Member mapRow(ResultSet rs) throws SQLException {
        Member m = new Member();
        m.setM_id      (rs.getInt   ("m_id"));
        m.setM_fullname(rs.getString ("m_fullname"));
        m.setM_login_id(rs.getString ("m_login_id"));
        m.setM_password(rs.getString ("m_password"));
        m.setM_email   (rs.getString ("m_email"));
        m.setM_address (rs.getString ("m_address"));
        m.setM_gender  (rs.getString ("m_gender"));
        m.setM_contact (rs.getLong   ("m_contact"));
        m.setM_status  (rs.getString ("m_status"));
        return m;
    }
}