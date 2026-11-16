package controller;

import java.io.*;
import java.util.List;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import dao.ProfileDAO;
import dao.MemberDAO;
import dao.AdminDAO;
import model.Admin;
import model.Customer;
import model.Member;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    // ════════════════════════════════════════════════════════════════════════
    //  GET  — View / edit profile  OR  Admin manage users
    // ════════════════════════════════════════════════════════════════════════
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        // ── ADMIN ─────────────────────────────────────────────────────────────
        if (session.getAttribute("a_id") != null) {
            handleAdminGet(req, res, session);
            return;
        }

        // ── MEMBER ───────────────────────────────────────────────────────────
        if (session.getAttribute("m_id") != null) {
            handleMemberView(req, res, session);
            return;
        }

        // ── CUSTOMER ─────────────────────────────────────────────────────────
        if (session.getAttribute("c_id") != null) {
            handleCustomerView(req, res, session);
            return;
        }

        res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
    }

    // ════════════════════════════════════════════════════════════════════════
    //  POST — Update profile (Admin, Customer, or Member)
    // ════════════════════════════════════════════════════════════════════════
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        String role = req.getParameter("role");

        if ("admin".equals(role)) {
            handleAdminUpdate(req, res, session);
        } else if ("member".equals(role)) {
            handleMemberUpdate(req, res, session);
        } else {
            handleCustomerUpdate(req, res, session);
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  ADMIN — GET: Manage users list OR show edit-profile form
    // ════════════════════════════════════════════════════════════════════════
    private void handleAdminGet(HttpServletRequest req, HttpServletResponse res,
                                HttpSession session)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        AdminDAO adminDAO = new AdminDAO();

        // ── Approve / Reject member ──────────────────────────────────────────
        if ("approve".equals(action) || "reject".equals(action)) {
            String midParam = req.getParameter("m_id");
            if (midParam != null && !midParam.trim().isEmpty()) {
                try {
                    int m_id = Integer.parseInt(midParam.trim());
                    String newStatus = "approve".equals(action) ? "approved" : "rejected";
                    new MemberDAO().updateMemberStatus(m_id, newStatus);
                } catch (NumberFormatException ignored) { }
            }
            res.sendRedirect(req.getContextPath() + "/ProfileServlet?action=manageUsers");
            return;
        }

        // ── Edit admin profile ───────────────────────────────────────────────
        if ("editProfile".equals(action)) {
            // a_login_id may not be in session; fall back to the stored Admin object
            String loginId = (String) session.getAttribute("a_login_id");
            if (loginId == null) {
                Admin sessionAdmin = (Admin) session.getAttribute("admin");
                if (sessionAdmin != null) loginId = sessionAdmin.getA_login_id();
            }
            Admin admin = loginId != null ? adminDAO.getAdminProfile(loginId) : null;

            // Carry over flash success from a redirect after save
            String successMsg = (String) session.getAttribute("profileSuccess");
            if (successMsg != null) {
                req.setAttribute("successMsg", successMsg);
                session.removeAttribute("profileSuccess");
            }

            if (admin != null) {
                req.setAttribute("adminProfile", admin);
            }
            req.getRequestDispatcher("/jsp/admin/admin_edit_profile.jsp").forward(req, res);
            return;
        }

        // ── Default: Manage Users list ───────────────────────────────────────
        List<Member> members = new MemberDAO().getAllMembers();
        req.setAttribute("memberList", members);
        req.getRequestDispatcher("/jsp/admin/manage_users.jsp").forward(req, res);
    }

    // ════════════════════════════════════════════════════════════════════════
    //  ADMIN — POST: Update admin profile
    // ════════════════════════════════════════════════════════════════════════
    private void handleAdminUpdate(HttpServletRequest req, HttpServletResponse res,
                                   HttpSession session)
            throws ServletException, IOException {

        if (session.getAttribute("a_id") == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        String name       = req.getParameter("name");
        String email      = req.getParameter("email");
        String address    = req.getParameter("address");
        String contactStr = req.getParameter("contact");
        String gender     = req.getParameter("gender");
        String username   = req.getParameter("username");

        // ── Validation ───────────────────────────────────────────────────────
        if (name    == null || name.trim().isEmpty()    ||
            email   == null || email.trim().isEmpty()   ||
            address == null || address.trim().isEmpty() ||
            contactStr == null || !contactStr.matches("\\d{10}")) {

            req.setAttribute("errorMsg",
                "Please fill all required fields correctly. Contact must be exactly 10 digits.");

            AdminDAO adminDAO = new AdminDAO();
            Admin admin = username != null ? adminDAO.getAdminProfile(username) : null;
            if (admin == null) {
                admin = new Admin();
                admin.setA_login_id(username);
                admin.setA_fullname(name != null ? name : "");
                admin.setA_email(email != null ? email : "");
                admin.setA_address(address != null ? address : "");
                admin.setA_gender(gender != null ? gender : "");
            }
            req.setAttribute("adminProfile", admin);
            req.getRequestDispatcher("/jsp/admin/admin_edit_profile.jsp").forward(req, res);
            return;
        }

        long contact;
        try {
            contact = Long.parseLong(contactStr.trim());
        } catch (NumberFormatException e) {
            req.setAttribute("errorMsg", "Invalid contact number. Enter a 10-digit number.");
            req.getRequestDispatcher("/jsp/admin/admin_edit_profile.jsp").forward(req, res);
            return;
        }

        // ── Build Admin model and update ─────────────────────────────────────
        // username comes from the hidden form field; double-check it isn't null
        if (username == null || username.trim().isEmpty()) {
            Admin sessionAdmin = (Admin) session.getAttribute("admin");
            if (sessionAdmin != null) username = sessionAdmin.getA_login_id();
        }
        Admin a = new Admin();
        a.setA_fullname(name.trim());
        a.setA_email   (email.trim());
        a.setA_address (address.trim());
        a.setA_contact (contact);
        a.setA_gender  (gender != null ? gender.trim() : "");
        a.setA_login_id(username);

        AdminDAO adminDAO = new AdminDAO();
        boolean updated = adminDAO.updateAdminProfile(a);

        if (updated) {
            // Refresh session attributes so navbar shows updated name immediately
            Admin fresh = adminDAO.getAdminProfile(username);
            if (fresh != null) {
                session.setAttribute("a_fullname", fresh.getA_fullname());
                session.setAttribute("a_email",    fresh.getA_email());
                session.setAttribute("a_address",  fresh.getA_address());
                session.setAttribute("a_contact",  fresh.getA_contact());
                session.setAttribute("a_gender",   fresh.getA_gender());
            }
            session.setAttribute("profileSuccess", "Profile updated successfully!");
            res.sendRedirect(req.getContextPath() + "/ProfileServlet?action=editProfile");
        } else {
            req.setAttribute("errorMsg", "Update failed. Please try again.");
            req.setAttribute("adminProfile", a);
            req.getRequestDispatcher("/jsp/admin/admin_edit_profile.jsp").forward(req, res);
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  MEMBER — View profile
    // ════════════════════════════════════════════════════════════════════════
    private void handleMemberView(HttpServletRequest req, HttpServletResponse res,
                                  HttpSession session)
            throws ServletException, IOException {

        Member sessionMember = (Member) session.getAttribute("member");
        if (sessionMember == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        MemberDAO dao = new MemberDAO();
        Member m = dao.getMemberProfile(sessionMember.getM_login_id());
        if (m == null) {
            session.invalidate();
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        String successMsg = (String) session.getAttribute("profileSuccess");
        if (successMsg != null) {
            req.setAttribute("successMsg", successMsg);
            session.removeAttribute("profileSuccess");
        }

        req.setAttribute("memberProfile", m);
        req.getRequestDispatcher("/jsp/profile/member_view_profile.jsp").forward(req, res);
    }

    // ════════════════════════════════════════════════════════════════════════
    //  MEMBER — Update profile
    // ════════════════════════════════════════════════════════════════════════
    private void handleMemberUpdate(HttpServletRequest req, HttpServletResponse res,
                                    HttpSession session)
            throws ServletException, IOException {

        if (session.getAttribute("m_id") == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        String name       = req.getParameter("name");
        String email      = req.getParameter("email");
        String address    = req.getParameter("address");
        String contactStr = req.getParameter("contact");
        String username   = req.getParameter("username");

        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            address == null || address.trim().isEmpty() ||
            contactStr == null || !contactStr.matches("\\d{10}")) {

            req.setAttribute("errorMsg",
                "Please fill all fields correctly. Contact must be exactly 10 digits.");
            req.setAttribute("memberProfile", session.getAttribute("member"));
            req.getRequestDispatcher("/jsp/profile/member_edit_profile.jsp").forward(req, res);
            return;
        }

        long contact;
        try {
            contact = Long.parseLong(contactStr.trim());
        } catch (NumberFormatException e) {
            req.setAttribute("errorMsg", "Invalid contact number. Enter a 10-digit number.");
            req.setAttribute("memberProfile", session.getAttribute("member"));
            req.getRequestDispatcher("/jsp/profile/member_edit_profile.jsp").forward(req, res);
            return;
        }

        Member m = new Member();
        m.setM_fullname(name.trim());
        m.setM_email   (email.trim());
        m.setM_address (address.trim());
        m.setM_contact (contact);
        m.setM_login_id(username);

        MemberDAO dao = new MemberDAO();
        boolean status = dao.updateMemberProfile(m);

        if (status) {
            Member updated = dao.getMemberProfile(username);
            if (updated != null) {
                session.setAttribute("member",     updated);
                session.setAttribute("m_id",       updated.getM_id());
                session.setAttribute("m_fullname", updated.getM_fullname());
            }
            session.setAttribute("profileSuccess", "Profile updated successfully.");
            res.sendRedirect(req.getContextPath() + "/ProfileServlet");
        } else {
            req.setAttribute("errorMsg", "Update failed. Please try again.");
            req.setAttribute("memberProfile", m);
            req.getRequestDispatcher("/jsp/profile/member_edit_profile.jsp").forward(req, res);
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  CUSTOMER — View profile
    // ════════════════════════════════════════════════════════════════════════
    private void handleCustomerView(HttpServletRequest req, HttpServletResponse res,
                                    HttpSession session)
            throws ServletException, IOException {

        Customer user = (Customer) session.getAttribute("user");
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        String successMsg = (String) session.getAttribute("profileSuccess");
        if (successMsg != null) {
            req.setAttribute("successMsg", successMsg);
            session.removeAttribute("profileSuccess");
        }

        ProfileDAO dao = new ProfileDAO();
        Customer c = dao.getProfile(user.getC_login_id());
        req.setAttribute("profile", c);
        req.getRequestDispatcher("/jsp/profile/view_profile.jsp").forward(req, res);
    }

    // ════════════════════════════════════════════════════════════════════════
    //  CUSTOMER — Update profile
    // ════════════════════════════════════════════════════════════════════════
    private void handleCustomerUpdate(HttpServletRequest req, HttpServletResponse res,
                                      HttpSession session)
            throws ServletException, IOException {

        Customer user = (Customer) session.getAttribute("user");
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        String name       = req.getParameter("name");
        String email      = req.getParameter("email");
        String address    = req.getParameter("address");
        String contactStr = req.getParameter("contact");
        String username   = req.getParameter("username");

        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            address == null || address.trim().isEmpty() ||
            contactStr == null || !contactStr.matches("\\d{10}")) {

            req.setAttribute("errorMsg",
                "Please fill all fields correctly. Contact must be exactly 10 digits.");
            req.setAttribute("profile", user);
            req.getRequestDispatcher("/jsp/profile/edit_profile.jsp").forward(req, res);
            return;
        }

        long contact;
        try {
            contact = Long.parseLong(contactStr.trim());
        } catch (NumberFormatException e) {
            req.setAttribute("errorMsg", "Invalid contact number. Enter a 10-digit number.");
            req.setAttribute("profile", user);
            req.getRequestDispatcher("/jsp/profile/edit_profile.jsp").forward(req, res);
            return;
        }

        Customer c = new Customer();
        c.setC_fullname(name.trim());
        c.setC_email   (email.trim());
        c.setC_address (address.trim());
        c.setC_contact (contact);
        c.setC_login_id(username);

        ProfileDAO dao = new ProfileDAO();
        boolean updated = dao.updateProfile(c);

        if (updated) {
            Customer fresh = dao.getProfile(username);
            if (fresh != null) {
                session.setAttribute("user",       fresh);
                session.setAttribute("c_id",       fresh.getC_id());
                session.setAttribute("c_fullname", fresh.getC_fullname());
            }
            session.setAttribute("profileSuccess", "Profile updated successfully.");
            res.sendRedirect(req.getContextPath() + "/ProfileServlet");
        } else {
            req.setAttribute("errorMsg", "Update failed. Please try again.");
            req.setAttribute("profile", c);
            req.getRequestDispatcher("/jsp/profile/edit_profile.jsp").forward(req, res);
        }
    }
}