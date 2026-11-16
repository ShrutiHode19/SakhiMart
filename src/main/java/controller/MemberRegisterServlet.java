package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import dao.MemberDAO;
import model.Member;
@WebServlet("/MemberRegisterServlet")
public class MemberRegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession();

        // ── Read parameters ──────────────────────────────────────────────────
        String name       = req.getParameter("name");
        String username   = req.getParameter("username");
        String password   = req.getParameter("password");
        String email      = req.getParameter("email");
        String address    = req.getParameter("address");
        String gender     = req.getParameter("gender");
        String contactStr = req.getParameter("contact");

        // ── Server-side validation (guards against JS bypass) ───────────────
        if (name == null || name.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            password == null || password.length() < 6 ||
            email == null || email.trim().isEmpty() ||
            address == null || address.trim().isEmpty() ||
            gender == null || gender.trim().isEmpty() ||
            contactStr == null || !contactStr.matches("\\d{10}")) {

            session.setAttribute("registerError", "Please fill all fields correctly. Contact must be 10 digits and password at least 6 characters.");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/register.jsp");
            return;
        }

        // ── Gender restriction: SHG Membership is open to women only ────────
        if ("M".equalsIgnoreCase(gender.trim())) {
            session.setAttribute("registerError", "SakhiMart SHG Membership is exclusively for women. Male registrations are not accepted.");
            session.setAttribute("registerTab", "member");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/register.jsp");
            return;
        }

        // ── Parse contact safely ─────────────────────────────────────────────
        long contact;
        try {
            contact = Long.parseLong(contactStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("registerError", "Invalid contact number. Please enter a 10-digit number.");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/register.jsp");
            return;
        }

        // ── Build model and persist ──────────────────────────────────────────
        Member m = new Member();
        m.setM_fullname(name.trim());
        m.setM_login_id(username.trim());
        m.setM_password(password);
        m.setM_email(email.trim());
        m.setM_address(address.trim());
        m.setM_gender(gender.trim());
        m.setM_contact(contact);

        MemberDAO dao    = new MemberDAO();
        boolean   status = dao.registerMember(m);

        if (status) {
            session.setAttribute("registerSuccess", "Member account created successfully! Please login.");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
        } else {
            session.setAttribute("registerError", "Registration failed. Username or email may already be taken. Please try again.");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/register.jsp");
        }
    }
}
