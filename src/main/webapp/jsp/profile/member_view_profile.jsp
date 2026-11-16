<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Member" %>
<%
    // ── Session Guard ──────────────────────────────────────────────────────────
    // Direct URL access without a session must redirect to login.
    if (session.getAttribute("m_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    // ── Profile data forwarded by MemberProfileServlet (doGet) ────────────────
    Member m = (Member) request.getAttribute("memberProfile");
    if (m == null) {
        // Accessed directly without going through the servlet — re-route properly.
        response.sendRedirect(request.getContextPath() + "/MemberProfileServlet");
        return;
    }

    // Gender display label
    String genderLabel = "Not specified";
    if      ("M".equalsIgnoreCase(m.getM_gender())) genderLabel = "Male";
    else if ("F".equalsIgnoreCase(m.getM_gender())) genderLabel = "Female";

    // Flash success message set by MemberProfileServlet after a successful update.
    // Remove it from session immediately so it shows only once.
    String successMsg = (String) session.getAttribute("memberProfileSuccess");
    if (successMsg != null) session.removeAttribute("memberProfileSuccess");
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

        <!-- ── Card Header ──────────────────────────────────────────────── -->
        <div class="card-header" style="text-align:center; padding:30px 30px 20px;">
            <div class="avatar-circle">&#128100;</div>
            <h2><%= m.getM_fullname() != null ? m.getM_fullname() : "SakhiMart Member" %></h2>
            <p>@<%= m.getM_login_id() %>
                <span style="margin-left:8px; background:#e8f5e9; color:#2e7d32;
                             font-size:0.75rem; padding:2px 10px; border-radius:50px;
                             font-weight:600; vertical-align:middle;">
                    &#127800; SHG Member
                </span>
            </p>
        </div>

        <!-- ── Card Body ────────────────────────────────────────────────── -->
        <div class="card-body">

            <!-- Flash success message after a successful profile update -->
            <% if (successMsg != null) { %>
                <div class="alert alert-success">&#10003; <%= successMsg %></div>
            <% } %>

            <!-- Full Name -->
            <div class="profile-field">
                <div class="field-icon">&#128100;</div>
                <div class="field-info">
                    <div class="field-label">Full Name</div>
                    <div class="field-value">
                        <%= m.getM_fullname() != null ? m.getM_fullname() : "&mdash;" %>
                    </div>
                </div>
            </div>

            <!-- Username -->
            <div class="profile-field">
                <div class="field-icon">&#128273;</div>
                <div class="field-info">
                    <div class="field-label">Username</div>
                    <div class="field-value">
                        <%= m.getM_login_id() != null ? m.getM_login_id() : "&mdash;" %>
                    </div>
                </div>
            </div>

            <!-- Email -->
            <div class="profile-field">
                <div class="field-icon">&#128231;</div>
                <div class="field-info">
                    <div class="field-label">Email Address</div>
                    <div class="field-value">
                        <%= m.getM_email() != null ? m.getM_email() : "&mdash;" %>
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
                        <%= m.getM_contact() > 0 ? m.getM_contact() : "&mdash;" %>
                    </div>
                </div>
            </div>

            <!-- Address -->
            <div class="profile-field">
                <div class="field-icon">&#127968;</div>
                <div class="field-info">
                    <div class="field-label">Residential Address</div>
                    <div class="field-value">
                        <%= m.getM_address() != null ? m.getM_address() : "&mdash;" %>
                    </div>
                </div>
            </div>

        </div><!-- /card-body -->

        <!-- ── Action Buttons ────────────────────────────────────────────── -->
        <div class="card-actions">
            <a href="<%= request.getContextPath() %>/jsp/profile/member_edit_profile.jsp"
               class="btn btn-primary">&#9998; Edit Profile</a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=memberProducts"
               class="btn btn-secondary">&#128717; My Products</a>
        </div>

    </div><!-- /profile-card -->

</div><!-- /container -->

<%@ include file="../common/footer.jsp" %>

</body>
</html>
