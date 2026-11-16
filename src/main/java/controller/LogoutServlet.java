package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false); // false = don't create new session
        if (session != null) {
            // Invalidate clears ALL attributes:
            // admin, a_id, a_fullname
            // member, m_id, m_fullname
            // user, c_id, c_fullname
            // loginError, registerSuccess, registerError, message, profileSuccess
            session.invalidate();
        }

        // Prevent browser back-button from restoring a cached logged-in page
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma",        "no-cache");
        res.setDateHeader("Expires",   0);

        // Redirect to login with a goodbye flash message
        // Using a URL parameter (not session, since session is gone)
        res.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp?logout=true");
    }

    // Also handle POST in case someone calls it via a form
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doGet(req, res);
    }
}
