<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Admin" %>
<%
    /* ── Session Guard ── */
    if (session.getAttribute("a_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    /* Profile forwarded by ProfileServlet; fall back to session values */
    Admin admin = (Admin) request.getAttribute("adminProfile");
    if (admin == null) {
        admin = new Admin();
        admin.setA_fullname((String) session.getAttribute("a_fullname"));
        admin.setA_login_id((String) session.getAttribute("a_login_id"));
        admin.setA_email   ((String) session.getAttribute("a_email"));
        admin.setA_address ((String) session.getAttribute("a_address"));
        admin.setA_gender  ((String) session.getAttribute("a_gender"));
        Object contactObj = session.getAttribute("a_contact");
        if (contactObj != null) {
            try { admin.setA_contact(Long.parseLong(contactObj.toString())); } catch (Exception ignored) {}
        }
    }

    String gender    = admin.getA_gender() != null ? admin.getA_gender() : "";
    String errorMsg  = (String) request.getAttribute("errorMsg");
    String successMsg = (String) session.getAttribute("profileSuccess");
    if (successMsg != null) session.removeAttribute("profileSuccess");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Admin Profile &ndash; SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        /* ── Page layout ── */
        .ep-wrapper {
            max-width: 640px;
            margin: 40px auto;
            padding: 0 16px 60px;
        }

        /* ── Breadcrumb ── */
        .ep-breadcrumb {
            font-size: .82rem;
            color: var(--text-light);
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .ep-breadcrumb a { color: var(--primary); font-weight: 600; text-decoration: none; }
        .ep-breadcrumb a:hover { text-decoration: underline; }

        /* ── Card ── */
        .ep-card {
            background: var(--bg-card, #fff);
            border: 1.5px solid var(--border, #e5dada);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(139,21,32,0.08);
            overflow: hidden;
        }

        /* ── Card header ── */
        .ep-header {
            background: linear-gradient(135deg, #5a0a12, #8B1520);
            padding: 28px 32px;
            display: flex;
            align-items: center;
            gap: 18px;
        }
        .ep-avatar {
            width: 64px; height: 64px;
            border-radius: 50%;
            background: rgba(255,255,255,0.15);
            border: 2px solid rgba(201,144,32,0.5);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem;
            box-shadow: 0 4px 16px rgba(0,0,0,0.2);
            flex-shrink: 0;
        }
        .ep-header-text { flex: 1; }
        .ep-header-text h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.35rem;
            color: #fff;
            margin-bottom: 3px;
        }
        .ep-header-text p { font-size: .82rem; color: rgba(255,255,255,0.7); }
        .ep-admin-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: rgba(201,144,32,0.2);
            border: 1px solid rgba(201,144,32,0.4);
            color: #e8c44e;
            font-size: .72rem;
            font-weight: 800;
            letter-spacing: .08em;
            text-transform: uppercase;
            padding: 3px 12px;
            border-radius: 50px;
            margin-top: 6px;
        }

        /* ── Card body ── */
        .ep-body { padding: 32px; }

        /* ── Alerts ── */
        .ep-alert {
            padding: 12px 16px;
            border-radius: 10px;
            font-size: .88rem;
            font-weight: 600;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .ep-alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }
        .ep-alert-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }

        /* ── Form rows ── */
        .ep-row { margin-bottom: 20px; }
        .ep-label {
            display: block;
            font-size: .84rem;
            font-weight: 700;
            color: var(--text-dark, #1a0508);
            margin-bottom: 6px;
        }
        .ep-label .req { color: #dc2626; }

        .ep-input {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid var(--border, #ddd);
            border-radius: 10px;
            font-size: .9rem;
            font-family: inherit;
            color: var(--text-dark, #1a0508);
            background: var(--bg-page, #fdf8f2);
            transition: border-color .2s, box-shadow .2s;
            outline: none;
        }
        .ep-input:focus {
            border-color: #8B1520;
            box-shadow: 0 0 0 3px rgba(139,21,32,0.1);
        }
        .ep-input[readonly] {
            background: #f3f3f3;
            color: #888;
            cursor: not-allowed;
        }
        .ep-input.is-invalid { border-color: #dc2626 !important; }

        .ep-hint { font-size: .76rem; color: var(--text-muted, #999); margin-top: 4px; }

        /* ── Gender radio ── */
        .ep-gender-row {
            display: flex;
            gap: 18px;
            flex-wrap: wrap;
        }
        .ep-radio {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: .88rem;
            font-weight: 600;
            color: var(--text-mid);
            cursor: pointer;
        }
        .ep-radio input[type="radio"] { accent-color: #8B1520; width: 16px; height: 16px; cursor: pointer; }

        /* ── Two-col grid ── */
        .ep-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
        @media (max-width: 540px) { .ep-grid { grid-template-columns: 1fr; } }

        /* ── Divider ── */
        .ep-divider {
            border: none;
            border-top: 1.5px solid var(--border-light, #f0e8e8);
            margin: 24px 0;
        }

        /* ── Buttons ── */
        .ep-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 28px;
        }
        .ep-btn-save {
            flex: 1;
            min-width: 160px;
            background: linear-gradient(135deg, #5a0a12, #8B1520);
            color: #fff;
            font-weight: 800;
            font-size: .93rem;
            padding: 13px 24px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-family: inherit;
            box-shadow: 0 4px 16px rgba(139,21,32,0.3);
            transition: transform .2s, box-shadow .2s, filter .2s;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .ep-btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(139,21,32,0.4);
            filter: brightness(1.08);
        }
        .ep-btn-cancel {
            padding: 13px 24px;
            background: transparent;
            border: 1.5px solid var(--border, #ddd);
            border-radius: 10px;
            font-size: .9rem;
            font-weight: 700;
            color: var(--text-mid);
            cursor: pointer;
            font-family: inherit;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all .2s;
        }
        .ep-btn-cancel:hover {
            background: var(--bg-page);
            border-color: var(--text-mid);
            color: var(--text-dark);
            text-decoration: none;
        }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="ep-wrapper">

    <!-- Breadcrumb -->
    <div class="ep-breadcrumb">
        <a href="<%= request.getContextPath() %>/ProductServlet?action=adminProducts">&#128196; Dashboard</a>
        <span>&#8250;</span>
        <span>Edit Profile</span>
    </div>

    <div class="ep-card">

        <!-- Header -->
        <div class="ep-header">
            <div class="ep-avatar">&#128272;</div>
            <div class="ep-header-text">
                <h2><%= admin.getA_fullname() != null ? admin.getA_fullname() : "Admin" %></h2>
                <p>@<%= admin.getA_login_id() != null ? admin.getA_login_id() : "" %></p>
                <div class="ep-admin-badge">&#9733; Administrator</div>
            </div>
        </div>

        <!-- Body -->
        <div class="ep-body">

            <!-- Alerts -->
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="ep-alert ep-alert-error">&#9888; <%= errorMsg %></div>
            <% } %>
            <% if (successMsg != null && !successMsg.isEmpty()) { %>
                <div class="ep-alert ep-alert-success">&#10003; <%= successMsg %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/ProfileServlet" method="post" id="editForm" novalidate>
                <input type="hidden" name="role" value="admin">
                <input type="hidden" name="username" value="<%= admin.getA_login_id() != null ? admin.getA_login_id() : "" %>">

                <!-- Full Name + Username -->
                <div class="ep-grid">
                    <div class="ep-row">
                        <label class="ep-label" for="name">Full Name <span class="req">*</span></label>
                        <input class="ep-input" type="text" id="name" name="name"
                               value="<%= admin.getA_fullname() != null ? admin.getA_fullname() : "" %>"
                               maxlength="25" required>
                    </div>
                    <div class="ep-row">
                        <label class="ep-label" for="loginId">Username</label>
                        <input class="ep-input" type="text" id="loginId"
                               value="<%= admin.getA_login_id() != null ? admin.getA_login_id() : "" %>"
                               readonly>
                        <div class="ep-hint">Username cannot be changed.</div>
                    </div>
                </div>

                <!-- Email + Contact -->
                <div class="ep-grid">
                    <div class="ep-row">
                        <label class="ep-label" for="email">Email <span class="req">*</span></label>
                        <input class="ep-input" type="email" id="email" name="email"
                               value="<%= admin.getA_email() != null ? admin.getA_email() : "" %>"
                               maxlength="30" required>
                    </div>
                    <div class="ep-row">
                        <label class="ep-label" for="contact">Contact No. <span class="req">*</span></label>
                        <input class="ep-input" type="tel" id="contact" name="contact"
                               value="<%= admin.getA_contact() > 0 ? admin.getA_contact() : "" %>"
                               maxlength="10" pattern="\d{10}" required>
                        <div class="ep-hint">10-digit mobile number.</div>
                    </div>
                </div>

                <!-- Address -->
                <div class="ep-row">
                    <label class="ep-label" for="address">Address <span class="req">*</span></label>
                    <input class="ep-input" type="text" id="address" name="address"
                           value="<%= admin.getA_address() != null ? admin.getA_address() : "" %>"
                           maxlength="100" required>
                </div>

                <!-- Gender -->
                <div class="ep-row">
                    <label class="ep-label">Gender</label>
                    <div class="ep-gender-row">
                        <label class="ep-radio">
                            <input type="radio" name="gender" value="M" <%= "M".equalsIgnoreCase(gender) ? "checked" : "" %>>
                            &#128104; Male
                        </label>
                        <label class="ep-radio">
                            <input type="radio" name="gender" value="F" <%= "F".equalsIgnoreCase(gender) ? "checked" : "" %>>
                            &#128105; Female
                        </label>
                        <label class="ep-radio">
                            <input type="radio" name="gender" value="" <%= gender.isEmpty() ? "checked" : "" %>>
                            Prefer not to say
                        </label>
                    </div>
                </div>

                <hr class="ep-divider">

                <div class="ep-actions">
                    <button type="submit" class="ep-btn-save" id="saveBtn">
                        &#10003; Save Changes
                    </button>
                    <a href="<%= request.getContextPath() %>/ProductServlet?action=adminProducts"
                       class="ep-btn-cancel">&#8592; Cancel</a>
                </div>

            </form>
        </div>
    </div>
</div>

<script>
(function () {
    var form    = document.getElementById('editForm');
    var saveBtn = document.getElementById('saveBtn');

    form.addEventListener('submit', function (e) {
        var valid   = true;
        var contact = document.getElementById('contact').value.trim();

        /* contact validation */
        if (!/^\d{10}$/.test(contact)) {
            document.getElementById('contact').classList.add('is-invalid');
            valid = false;
        } else {
            document.getElementById('contact').classList.remove('is-invalid');
        }

        /* required fields */
        ['name','email','address'].forEach(function(id) {
            var el = document.getElementById(id);
            if (!el.value.trim()) {
                el.classList.add('is-invalid');
                valid = false;
            } else {
                el.classList.remove('is-invalid');
            }
        });

        if (!valid) {
            e.preventDefault();
            return;
        }

        saveBtn.disabled = true;
        saveBtn.textContent = 'Saving…';
    });

    /* Live: remove is-invalid on input */
    form.querySelectorAll('.ep-input').forEach(function(el) {
        el.addEventListener('input', function () {
            el.classList.remove('is-invalid');
        });
    });
})();
</script>

<%@ include file="../common/footer.jsp" %>
</body>
</html>