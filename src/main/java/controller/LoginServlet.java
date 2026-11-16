package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import dao.AdminDAO;
import dao.MemberDAO;
import dao.CustomerDAO;
import model.Admin;
import model.Member;
import model.Customer;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty() ||
            password == null || password.isEmpty()) {
            req.getSession().setAttribute("loginError", "Username and password are required.");
            res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        HttpSession session = req.getSession();

        // ── Step 1 : Admin ───────────────────────────────────────────────────
        AdminDAO adminDAO = new AdminDAO();
        Admin a = adminDAO.loginAdmin(username.trim(), password);
        if (a != null) {
            session.setAttribute("admin",      a);
            session.setAttribute("a_id",       a.getA_id());
            session.setAttribute("a_fullname", a.getA_fullname());
            res.sendRedirect(req.getContextPath() + "/ProductServlet?action=adminProducts");
            return;
        }

        // ── Step 2 : Member ──────────────────────────────────────────────────
        MemberDAO memberDAO = new MemberDAO();
        Member m = memberDAO.loginMember(username.trim(), password);
        if (m != null) {
            // Check approval status before creating session
            if ("pending".equals(m.getM_status())) {
                session.setAttribute("loginError",
                    "Your account is pending admin approval. Please wait.");
                res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
                return;
            }
            if ("rejected".equals(m.getM_status())) {
                session.setAttribute("loginError",
                    "Your account has been rejected. Please contact admin.");
                res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
                return;
            }
            // status == approved
            session.setAttribute("member",     m);
            session.setAttribute("m_id",       m.getM_id());
            session.setAttribute("m_fullname", m.getM_fullname());
            res.sendRedirect(req.getContextPath() + "/ProductServlet?action=memberProducts");
            return;
        }

        // ── Step 3 : Customer ────────────────────────────────────────────────
        CustomerDAO customerDAO = new CustomerDAO();
        Customer c = customerDAO.loginCustomer(username.trim(), password);
        if (c != null) {
            session.setAttribute("user",       c);
            session.setAttribute("c_id",       c.getC_id());
            session.setAttribute("c_fullname", c.getC_fullname());
            res.sendRedirect(req.getContextPath() + "/jsp/customer/home.jsp");
            return;
        }

        // ── Step 4 : No match ────────────────────────────────────────────────
        session.setAttribute("loginError", "Invalid username or password. Please try again.");
        res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
    }
}