<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ── Already logged-in guard ──────────────────────────────────────────────

    if (session.getAttribute("admin") != null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=adminProducts");
        return;
    }
    if (session.getAttribute("member") != null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=memberProducts");
        return;
    }
    if (session.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/jsp/customer/home.jsp");
        return;
    }

    // ── Flash messages (consumed once) ──────────────────────────────────────
    String errorMsg   = (String) session.getAttribute("loginError");
    String successMsg = (String) session.getAttribute("registerSuccess");
    if (errorMsg   != null) session.removeAttribute("loginError");
    if (successMsg != null) session.removeAttribute("registerSuccess");

    // logout=true comes as URL param (session is already destroyed by LogoutServlet)
    if (successMsg == null && "true".equals(request.getParameter("logout"))) {
        successMsg = "You have been logged out successfully. See you soon!";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login &#8211; SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .invalid-feedback { display:none; color:#dc3545; font-size:0.82rem; margin-top:4px; }
        .form-control.is-invalid { border-color:#dc3545 !important; }
        .req { color:#dc3545; }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="auth-wrapper">
    <div class="auth-card">

        <div class="auth-header">
            <div class="logo">&#127873;</div>
            <h2>Welcome Back!</h2>
            <p>Sign in to your SakhiMart account</p>
        </div>

        <div class="auth-body">

            <!-- SUCCESS: shown after successful registration redirect -->
            <% if (successMsg != null) { %>
                <div class="alert alert-success">&#10003; <%= successMsg %></div>
            <% } %>

            <!-- ERROR: server-side wrong credentials message -->
            <% if (errorMsg != null) { %>
                <div class="alert alert-error">&#9888; <%= errorMsg %></div>
            <% } %>

            <!-- Client-side summary (only appears on submit, never on page load) -->
            <div class="alert alert-error" id="formError" style="display:none;">
                &#9888; Please fill in all required fields before signing in.
            </div>

            <!-- FIXED: onsubmit on form tag, NOT onclick on button -->
            <form action="<%= request.getContextPath() %>/LoginServlet"
                  method="post"
                  id="loginForm"
                  novalidate
                  onsubmit="return validateLoginForm()">

                <!-- Username -->
                <div class="form-group">
                    <label for="username">Username <span class="req">*</span></label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#128100;</span>
                        <input type="text"
                               id="username"
                               name="username"
                               class="form-control"
                               maxlength="25"
                               placeholder="Enter your username"
                               required
                               autofocus>
                    </div>
                    <div class="invalid-feedback" id="usernameError">Username is required.</div>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="password">Password <span class="req">*</span></label>
                    <div class="input-wrapper" style="position:relative;">
                        <span class="input-icon">&#128274;</span>
                        <input type="password"
                               id="password"
                               name="password"
                               class="form-control"
                               maxlength="15"
                               placeholder="Enter your password"
                               required>
                        <button type="button"
                                onclick="togglePassword()"
                                title="Show / Hide password"
                                style="position:absolute;right:12px;top:50%;transform:translateY(-50%);
                                       background:none;border:none;cursor:pointer;font-size:1rem;color:#aaa;">
                            &#128065;
                        </button>
                    </div>
                    <div class="invalid-feedback" id="passwordError">Password is required.</div>
                </div>

                <!-- Submit -->
                <div class="form-actions" style="margin-top:14px;">
                    <button type="submit"
                            class="btn btn-primary"
                            style="width:100%;justify-content:center;">
                        &#128274; Sign In
                    </button>
                </div>

            </form>

            <div class="auth-footer-link" style="margin-top:14px;text-align:center;">
                Don't have an account?
                <a href="<%= request.getContextPath() %>/jsp/auth/register.jsp">Register here</a>
            </div>

        </div><!-- /auth-body -->
    </div><!-- /auth-card -->
</div><!-- /auth-wrapper -->

<%@ include file="../common/footer.jsp" %>

<script>
    /* Runs only on form submit - never prematurely */
    function validateLoginForm() {
        var valid = true;

        function setError(fieldId, errorId, condition) {
            var field = document.getElementById(fieldId);
            var err   = document.getElementById(errorId);
            if (condition) {
                field.classList.add('is-invalid');
                err.style.display = 'block';
                valid = false;
            } else {
                field.classList.remove('is-invalid');
                err.style.display = 'none';
            }
        }

        setError('username', 'usernameError', document.getElementById('username').value.trim() === '');
        setError('password', 'passwordError', document.getElementById('password').value === '');

        document.getElementById('formError').style.display = valid ? 'none' : 'block';
        return valid;
    }

    /* Clear error as soon as the user starts typing a correction */
    ['username', 'password'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) {
            el.addEventListener('input', function() {
                if (this.value.trim() !== '') {
                    this.classList.remove('is-invalid');
                    var e = document.getElementById(id + 'Error');
                    if (e) e.style.display = 'none';
                    document.getElementById('formError').style.display = 'none';
                }
            });
        }
    });

    function togglePassword() {
        var pwd = document.getElementById('password');
        pwd.type = pwd.type === 'password' ? 'text' : 'password';
    }
</script>

</body>
</html>
