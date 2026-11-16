package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import dao.CustomerDAO;
import model.Customer;
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {

        HttpSession session = req.getSession();

        // ── Read parameters ──────────────────────────────────────────────────
        String name     = req.getParameter("name");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String email    = req.getParameter("email");
        String address  = req.getParameter("address");
        String gender   = req.getParameter("gender");
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
        Customer c = new Customer();
        c.setC_fullname(name.trim());
        c.setC_login_id(username.trim());
        c.setC_password(password);
        c.setC_email(email.trim());
        c.setC_address(address.trim());
        c.setC_gender(gender.trim());
        c.setC_contact(contact);

        CustomerDAO dao = new CustomerDAO();
        boolean status = dao.registerCustomer(c);

        if (status) {
            session.setAttribute("registerSuccess", "Customer account created successfully! Please login.");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
        } else {
            session.setAttribute("registerError", "Registration failed. Username or email may already be taken. Please try again.");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/register.jsp");
        }
    }
}
