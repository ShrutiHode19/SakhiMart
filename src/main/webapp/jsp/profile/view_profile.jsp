<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Customer" %>
<%
    // ── Session Guard ──────────────────────────────────────────────────
    Customer sessionUser = (Customer) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    // ── Profile data forwarded by ProfileServlet (doGet) ──────────────
    Customer c = (Customer) request.getAttribute("profile");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/ProfileServlet");
        return;
    }

    // Derive gender display label
    String genderLabel = "Not specified";
    if ("M".equalsIgnoreCase(c.getC_gender()))      genderLabel = "Male";
    else if ("F".equalsIgnoreCase(c.getC_gender())) genderLabel = "Female";

    // Read flash message set by ProfileServlet after a successful update
    String successMsg = (String) session.getAttribute("profileSuccess");
    if (successMsg != null) session.removeAttribute("profileSuccess");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile &#8211; SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">

    <div class="profile-card">

        <!-- ── Card Header ─────────────────────────────────────────── -->
        <div class="card-header" style="text-align:center; padding:30px 30px 20px;">
            <div class="avatar-circle">&#128100;</div>
            <h2><%= c.getC_fullname() != null ? c.getC_fullname() : "SakhiMart User" %></h2>
            <p>@<%= c.getC_login_id() %></p>
        </div>

        <!-- ── Card Body ───────────────────────────────────────────── -->
        <div class="card-body">

            <!-- Flash success message after a successful update -->
            <% if (successMsg != null) { %>
                <div class="alert alert-success">&#10003; <%= successMsg %></div>
            <% } %>

            <!-- Full Name -->
            <div class="profile-field">
                <div class="field-icon">&#128100;</div>
                <div class="field-info">
                    <div class="field-label">Full Name</div>
                    <div class="field-value">
                        <%= c.getC_fullname() != null ? c.getC_fullname() : "&mdash;" %>
                    </div>
                </div>
            </div>

            <!-- Username -->
            <div class="profile-field">
                <div class="field-icon">&#128273;</div>
                <div class="field-info">
                    <div class="field-label">Username</div>
                    <div class="field-value">
                        <%= c.getC_login_id() != null ? c.getC_login_id() : "&mdash;" %>
                    </div>
                </div>
            </div>

            <!-- Email -->
            <div class="profile-field">
                <div class="field-icon">&#128231;</div>
                <div class="field-info">
                    <div class="field-label">Email Address</div>
                    <div class="field-value">
                        <%= c.getC_email() != null ? c.getC_email() : "&mdash;" %>
                    </div>
                </div>
            </div>

            <!-- Gender -->
            <div class="profile-field">
                <div class="field-icon">&#9786;</div>
                <div class="field-info">
                    <div class="field-label">Gender</div>
                    <div class="field-value">
                        <span class="badge-gender"><%= genderLabel %></span>
                    </div>
                </div>
            </div>

            <!-- Contact -->
            <div class="profile-field">
                <div class="field-icon">&#128222;</div>
                <div class="field-info">
                    <div class="field-label">Contact Number</div>
                    <div class="field-value">
                        <%= c.getC_contact() > 0 ? c.getC_contact() : "&mdash;" %>
                    </div>
                </div>
            </div>

            <!-- Address -->
            <div class="profile-field">
                <div class="field-icon">&#127968;</div>
                <div class="field-info">
                    <div class="field-label">Residential Address</div>
                    <div class="field-value">
                        <%= c.getC_address() != null ? c.getC_address() : "&mdash;" %>
                    </div>
                </div>
            </div>

        </div><!-- /card-body -->

        <!-- ── Action Buttons ──────────────────────────────────────── -->
        <div class="card-actions">
            <a href="<%= request.getContextPath() %>/jsp/profile/edit_profile.jsp"
               class="btn btn-primary">&#9998; Edit Profile</a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
               class="btn btn-secondary">&#128717; Browse Products</a>
        </div>

    </div><!-- /profile-card -->

</div><!-- /container -->

<%@ include file="../common/footer.jsp" %>

</body>
</html>
