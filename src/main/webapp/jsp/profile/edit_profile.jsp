<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Customer" %>
<%
    // ── Session Guard ──────────────────────────────────────────────────────
    Customer c = (Customer) session.getAttribute("user");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    // Fresh DB data forwarded by ProfileServlet; fall back to session if direct access
    Customer profile = (Customer) request.getAttribute("profile");
    if (profile == null) profile = c;

    String gender   = profile.getC_gender() != null ? profile.getC_gender() : "";

    // Error set by ProfileServlet doPost on validation failure (request scope)
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile &#8211; SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .invalid-feedback { display:none; color:#dc3545; font-size:0.82rem; margin-top:4px; }
        .form-control.is-invalid { border-color:#dc3545 !important; }
        .req { color:#dc3545; }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">

    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/ProfileServlet">My Profile</a>
        &nbsp;&rsaquo;&nbsp; Edit Profile
    </div>

    <div class="form-card">

        <div class="card-header" style="display:flex; align-items:center; gap:14px; padding:22px 30px;">
            <span style="font-size:1.8rem;">&#9998;</span>
            <div>
                <h2>Edit Profile</h2>
                <p>Update your personal information below</p>
            </div>
        </div>

        <div class="card-body">

            <!-- Server-side error forwarded by ProfileServlet -->
            <% if (errorMsg != null) { %>
                <div class="alert alert-error">&#9888; <%= errorMsg %></div>
            <% } %>

            <!-- Client-side summary — shown only on submit attempt, never on page load -->
            <div class="alert alert-error" id="formError" style="display:none;">
                &#9888; Please fix the errors below before submitting.
            </div>

            <%-- FIX: onsubmit on the form tag, NOT onclick on button.
                 onclick is bypassed when user presses Enter key. --%>
            <form action="<%= request.getContextPath() %>/ProfileServlet"
                  method="post"
                  id="editProfileForm"
                  novalidate
                  onsubmit="return validateForm()">

                <!-- Hidden: username is the WHERE key for ProfileDAO.updateProfile -->
                <input type="hidden" name="username" value="<%= profile.getC_login_id() %>">

                <!-- Full Name -->
                <div class="form-group">
                    <label for="name">Full Name <span class="req">*</span></label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#128100;</span>
                        <input type="text"
                               id="name" name="name"
                               class="form-control"
                               maxlength="25"
                               placeholder="Enter your full name"
                               value="<%= profile.getC_fullname() != null ? profile.getC_fullname() : "" %>"
                               required>
                    </div>
                    <div class="invalid-feedback" id="nameError">Full name is required.</div>
                </div>

                <!-- Username — read-only, never submitted, just for display -->
                <div class="form-group">
                    <label for="usernameDisplay">Username</label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#128273;</span>
                        <input type="text"
                               id="usernameDisplay"
                               class="form-control"
                               value="<%= profile.getC_login_id() %>"
                               readonly>
                    </div>
                    <div class="hint">Username cannot be changed.</div>
                </div>

                <hr class="divider">

                <!-- Email -->
                <div class="form-group">
                    <label for="email">Email Address <span class="req">*</span></label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#128231;</span>
                        <input type="email"
                               id="email" name="email"
                               class="form-control"
                               maxlength="30"
                               placeholder="Enter your email address"
                               value="<%= profile.getC_email() != null ? profile.getC_email() : "" %>"
                               required>
                    </div>
                    <div class="invalid-feedback" id="emailError">Please enter a valid email address.</div>
                </div>

                <!-- Contact -->
                <div class="form-group">
                    <label for="contact">Contact Number <span class="req">*</span></label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#128222;</span>
                        <input type="tel"
                               id="contact" name="contact"
                               class="form-control"
                               maxlength="10"
                               placeholder="10-digit mobile number"
                               value="<%= profile.getC_contact() > 0 ? profile.getC_contact() : "" %>"
                               required>
                    </div>
                    <div class="invalid-feedback" id="contactError">Enter a valid 10-digit mobile number.</div>
                </div>

                <!-- Gender -->
                <div class="form-group">
                    <label>Gender</label>
                    <div class="radio-group">
                        <label class="radio-option">
                            <input type="radio" name="gender" value="M"
                                   <%= "M".equals(gender) ? "checked" : "" %>> Male
                        </label>
                        <label class="radio-option">
                            <input type="radio" name="gender" value="F"
                                   <%= "F".equals(gender) ? "checked" : "" %>> Female
                        </label>
                    </div>
                </div>

                <!-- Address -->
                <div class="form-group">
                    <label for="address">Residential Address <span class="req">*</span></label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#127968;</span>
                        <input type="text"
                               id="address" name="address"
                               class="form-control"
                               maxlength="100"
                               placeholder="Enter your address"
                               value="<%= profile.getC_address() != null ? profile.getC_address() : "" %>"
                               required>
                    </div>
                    <div class="invalid-feedback" id="addressError">Address is required.</div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">&#128190; Save Changes</button>
                    <a href="<%= request.getContextPath() %>/ProfileServlet"
                       class="btn btn-secondary">&#10006; Cancel</a>
                </div>

            </form>

        </div><!-- /card-body -->
    </div><!-- /form-card -->
</div><!-- /container -->

<%@ include file="../common/footer.jsp" %>

<script>
    /* FIX: Called only by onsubmit — never prematurely */
    function validateForm() {
        var valid      = true;
        var emailReg   = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        var contactReg = /^\d{10}$/;

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

        setError('name',    'nameError',
                 document.getElementById('name').value.trim() === '');
        setError('email',   'emailError',
                 !emailReg.test(document.getElementById('email').value.trim()));
        setError('contact', 'contactError',
                 !contactReg.test(document.getElementById('contact').value.trim()));
        setError('address', 'addressError',
                 document.getElementById('address').value.trim() === '');

        document.getElementById('formError').style.display = valid ? 'none' : 'block';
        return valid;
    }

    /* FIX: Clear each field's error as the user actively corrects it (input event).
       Old code used 'blur' which re-ran ALL validations on every field-leave,
       causing errors to appear on untouched fields. */
    ['name', 'email', 'contact', 'address'].forEach(function(id) {
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
</script>

</body>
</html>