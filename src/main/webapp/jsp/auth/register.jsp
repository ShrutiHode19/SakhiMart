<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ── Already logged-in guard ──────────────────────────────────────────────
    if (session.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/jsp/customer/home.jsp");
        return;
    }
    if (session.getAttribute("member") != null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=memberProducts");
        return;
    }
    if (session.getAttribute("admin") != null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=adminProducts");
        return;
    }

    // ── Flash messages ───────────────────────────────────────────────────────
    String errorMsg    = (String) session.getAttribute("registerError");
    String registerTab = (String) session.getAttribute("registerTab");
    if (errorMsg    != null) session.removeAttribute("registerError");
    if (registerTab != null) session.removeAttribute("registerTab");
    boolean openMemberTab = "member".equals(registerTab);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register &#8211; SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .invalid-feedback { display:none; color:#dc3545; font-size:0.82rem; margin-top:4px; }
        .form-control.is-invalid { border-color:#dc3545 !important; }
        .req { color:#dc3545; }

        /* Tab styles */
        .reg-tabs { display:flex; border-bottom:2px solid #e0d4c8; margin-bottom:20px; }
        .reg-tab  {
            flex:1; padding:10px 0; text-align:center; cursor:pointer;
            font-weight:600; color:#888; border-bottom:3px solid transparent;
            transition:all .2s; margin-bottom:-2px;
        }
        .reg-tab.active { color:#c0392b; border-bottom-color:#c0392b; }
        .reg-tab:hover:not(.active) { color:#333; }
        .reg-panel { display:none; }
        .reg-panel.active { display:block; }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="auth-wrapper">
    <div class="auth-card" style="max-width:520px;">

        <div class="auth-header">
            <div class="logo">&#128722;</div>
            <h2>Create Account</h2>
            <p>Join SakhiMart today</p>
        </div>

        <div class="auth-body">

            <!-- Server-side error (from RegisterServlet or MemberRegisterServlet) -->
            <% if (errorMsg != null) { %>
                <div class="alert alert-error">&#9888; <%= errorMsg %></div>
            <% } %>

            <!-- Client-side summary (shown only on submit attempt) -->
            <div class="alert alert-error" id="formError" style="display:none;">
                &#9888; Please fix the errors below before submitting.
            </div>

            <!-- ── Tabs ── -->
            <div class="reg-tabs">
                <div class="reg-tab active" id="tabCustomer" onclick="switchTab('customer')">
                    &#128101; Customer
                </div>
                <div class="reg-tab" id="tabMember" onclick="switchTab('member')">
                    &#128105; SHG Member
                </div>
            </div>

            <!-- ══════════════════════════════════════
                 PANEL 1 — CUSTOMER REGISTRATION
                 Matches: customer table columns
                 c_fullname, c_login_id, c_password,
                 c_email, c_address, c_gender, c_contact
            ══════════════════════════════════════ -->
            <div class="reg-panel active" id="panelCustomer">
                <form action="<%= request.getContextPath() %>/RegisterServlet"
                      method="post"
                      id="customerForm"
                      novalidate
                      onsubmit="return validateForm('c')">

                    <!-- Full Name -->
                    <div class="form-group">
                        <label for="c_name">Full Name <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#128100;</span>
                            <input type="text" id="c_name" name="name"
                                   class="form-control" maxlength="25"
                                   placeholder="Enter your full name" required autofocus>
                        </div>
                        <div class="invalid-feedback" id="c_nameError">Full name is required.</div>
                    </div>

                    <!-- Username + Password -->
                    <div class="form-row">
                        <div class="form-group half">
                            <label for="c_username">Username <span class="req">*</span></label>
                            <div class="input-wrapper">
                                <span class="input-icon">&#128273;</span>
                                <input type="text" id="c_username" name="username"
                                       class="form-control" maxlength="25"
                                       placeholder="Choose a username" required>
                            </div>
                            <div class="invalid-feedback" id="c_usernameError">Username is required.</div>
                        </div>
                        <div class="form-group half">
                            <label for="c_password">Password <span class="req">*</span></label>
                            <div class="input-wrapper" style="position:relative;">
                                <span class="input-icon">&#128274;</span>
                                <input type="password" id="c_password" name="password"
                                       class="form-control" maxlength="15"
                                       placeholder="Min 6 characters" required>
                                <button type="button" onclick="togglePwd('c_password')"
                                        style="position:absolute;right:10px;top:50%;transform:translateY(-50%);
                                               background:none;border:none;cursor:pointer;font-size:1rem;color:#aaa;">
                                    &#128065;
                                </button>
                            </div>
                            <div class="invalid-feedback" id="c_passwordError">Min 6 characters required.</div>
                        </div>
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <label for="c_email">Email Address <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#128231;</span>
                            <input type="email" id="c_email" name="email"
                                   class="form-control" maxlength="30"
                                   placeholder="Enter your email" required>
                        </div>
                        <div class="invalid-feedback" id="c_emailError">Please enter a valid email address.</div>
                    </div>

                    <!-- Contact -->
                    <div class="form-group">
                        <label for="c_contact">Contact Number <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#128222;</span>
                            <input type="tel" id="c_contact" name="contact"
                                   class="form-control" maxlength="10"
                                   placeholder="10-digit mobile number" required>
                        </div>
                        <div class="invalid-feedback" id="c_contactError">Enter a valid 10-digit mobile number.</div>
                    </div>

                    <!-- Gender -->
                    <div class="form-group">
                        <label>Gender <span class="req">*</span></label>
                        <div class="radio-group">
                            <label class="radio-option">
                                <input type="radio" name="gender" value="M"> Male
                            </label>
                            <label class="radio-option">
                                <input type="radio" name="gender" value="F"> Female
                            </label>
                        </div>
                        <div class="invalid-feedback" id="c_genderError">Please select your gender.</div>
                    </div>

                    <!-- Address -->
                    <div class="form-group">
                        <label for="c_address">Residential Address <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#127968;</span>
                            <input type="text" id="c_address" name="address"
                                   class="form-control" maxlength="100"
                                   placeholder="Enter your address" required>
                        </div>
                        <div class="invalid-feedback" id="c_addressError">Address is required.</div>
                    </div>

                    <div class="form-actions" style="margin-top:12px;">
                        <button type="submit" class="btn btn-primary"
                                style="width:100%;justify-content:center;">
                            &#10003; Create Customer Account
                        </button>
                    </div>
                </form>
            </div><!-- /panelCustomer -->

            <!-- ══════════════════════════════════════
                 PANEL 2 — MEMBER (SHG) REGISTRATION
                 Matches: member table columns
                 m_fullname, m_login_id, m_password,
                 m_email, m_address, m_gender, m_contact
            ══════════════════════════════════════ -->
            <div class="reg-panel" id="panelMember">
                <form action="<%= request.getContextPath() %>/MemberRegisterServlet"
                      method="post"
                      id="memberForm"
                      novalidate
                      onsubmit="return validateForm('m')">

                    <!-- Full Name -->
                    <div class="form-group">
                        <label for="m_name">Full Name <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#128100;</span>
                            <input type="text" id="m_name" name="name"
                                   class="form-control" maxlength="25"
                                   placeholder="Enter your full name" required>
                        </div>
                        <div class="invalid-feedback" id="m_nameError">Full name is required.</div>
                    </div>

                    <!-- Username + Password -->
                    <div class="form-row">
                        <div class="form-group half">
                            <label for="m_username">Username <span class="req">*</span></label>
                            <div class="input-wrapper">
                                <span class="input-icon">&#128273;</span>
                                <input type="text" id="m_username" name="username"
                                       class="form-control" maxlength="25"
                                       placeholder="Choose a username" required>
                            </div>
                            <div class="invalid-feedback" id="m_usernameError">Username is required.</div>
                        </div>
                        <div class="form-group half">
                            <label for="m_password">Password <span class="req">*</span></label>
                            <div class="input-wrapper" style="position:relative;">
                                <span class="input-icon">&#128274;</span>
                                <input type="password" id="m_password" name="password"
                                       class="form-control" maxlength="15"
                                       placeholder="Min 6 characters" required>
                                <button type="button" onclick="togglePwd('m_password')"
                                        style="position:absolute;right:10px;top:50%;transform:translateY(-50%);
                                               background:none;border:none;cursor:pointer;font-size:1rem;color:#aaa;">
                                    &#128065;
                                </button>
                            </div>
                            <div class="invalid-feedback" id="m_passwordError">Min 6 characters required.</div>
                        </div>
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <label for="m_email">Email Address <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#128231;</span>
                            <input type="email" id="m_email" name="email"
                                   class="form-control" maxlength="30"
                                   placeholder="Enter your email" required>
                        </div>
                        <div class="invalid-feedback" id="m_emailError">Please enter a valid email address.</div>
                    </div>

                    <!-- Contact -->
                    <div class="form-group">
                        <label for="m_contact">Contact Number <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#128222;</span>
                            <input type="tel" id="m_contact" name="contact"
                                   class="form-control" maxlength="10"
                                   placeholder="10-digit mobile number" required>
                        </div>
                        <div class="invalid-feedback" id="m_contactError">Enter a valid 10-digit mobile number.</div>
                    </div>

                    <!-- Gender -->
                    <div class="form-group">
                        <label>Gender <span class="req">*</span></label>
                        <div class="radio-group">
                            <label class="radio-option">
                                <input type="radio" name="gender" value="M" id="m_genderM"
                                       onchange="checkMemberGender()"> Male
                            </label>
                            <label class="radio-option">
                                <input type="radio" name="gender" value="F" id="m_genderF"
                                       onchange="checkMemberGender()"> Female
                            </label>
                        </div>
                        <div class="invalid-feedback" id="m_genderError">Please select your gender.</div>
                        <div id="m_genderMaleWarn" style="display:none; margin-top:8px; padding:10px 14px;
                             background:#fff5f5; border:1px solid #f5c6cb; border-left:4px solid #dc3545;
                             border-radius:6px; font-size:0.84rem; color:#721c24; font-weight:600;">
                            &#9888;&nbsp; SakhiMart SHG Membership is exclusively for women.
                            Male registrations are not accepted.
                        </div>
                    </div>

                    <!-- Address -->
                    <div class="form-group">
                        <label for="m_address">Residential Address <span class="req">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">&#127968;</span>
                            <input type="text" id="m_address" name="address"
                                   class="form-control" maxlength="100"
                                   placeholder="Enter your address" required>
                        </div>
                        <div class="invalid-feedback" id="m_addressError">Address is required.</div>
                    </div>

                    <div class="form-actions" style="margin-top:12px;">
                        <button type="submit" class="btn btn-primary"
                                style="width:100%;justify-content:center;">
                            &#10003; Create Member Account
                        </button>
                    </div>
                </form>
            </div><!-- /panelMember -->

            <div class="auth-footer-link" style="margin-top:14px;text-align:center;">
                Already have an account?
                <a href="<%= request.getContextPath() %>/jsp/auth/login.jsp">Sign in here</a>
            </div>

        </div><!-- /auth-body -->
    </div><!-- /auth-card -->
</div><!-- /auth-wrapper -->

<%@ include file="../common/footer.jsp" %>

<script>
    var emailReg   = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    var contactReg = /^\d{10}$/;

    /* ── Auto-open member tab if server bounced a member registration error ── */
    <% if (openMemberTab) { %>
    document.addEventListener('DOMContentLoaded', function() { switchTab('member'); });
    <% } %>

    /* ── Tab switching ── */
    function switchTab(tab) {
        document.getElementById('panelCustomer').classList.remove('active');
        document.getElementById('panelMember').classList.remove('active');
        document.getElementById('tabCustomer').classList.remove('active');
        document.getElementById('tabMember').classList.remove('active');
        document.getElementById('formError').style.display = 'none';

        if (tab === 'customer') {
            document.getElementById('panelCustomer').classList.add('active');
            document.getElementById('tabCustomer').classList.add('active');
        } else {
            document.getElementById('panelMember').classList.add('active');
            document.getElementById('tabMember').classList.add('active');
        }
    }

    /* ── Show/hide male restriction warning in member tab ── */
    function checkMemberGender() {
        var maleSelected = document.getElementById('m_genderM') &&
                           document.getElementById('m_genderM').checked;
        var warn = document.getElementById('m_genderMaleWarn');
        if (warn) warn.style.display = maleSelected ? 'block' : 'none';
    }

    /* ── Single validate function for both forms (prefix = 'c' or 'm') ── */
    function validateForm(prefix) {
        var valid = true;

        function setError(id, condition) {
            var field = document.getElementById(prefix + '_' + id);
            var err   = document.getElementById(prefix + '_' + id + 'Error');
            if (field) {
                if (condition) {
                    field.classList.add('is-invalid');
                    if (err) err.style.display = 'block';
                    valid = false;
                } else {
                    field.classList.remove('is-invalid');
                    if (err) err.style.display = 'none';
                }
            }
        }

        function setRadioError(condition) {
            var err = document.getElementById(prefix + '_genderError');
            if (condition) {
                if (err) err.style.display = 'block';
                valid = false;
            } else {
                if (err) err.style.display = 'none';
            }
        }

        var name     = document.getElementById(prefix + '_name').value.trim();
        var username = document.getElementById(prefix + '_username').value.trim();
        var password = document.getElementById(prefix + '_password').value;
        var email    = document.getElementById(prefix + '_email').value.trim();
        var contact  = document.getElementById(prefix + '_contact').value.trim();
        var address  = document.getElementById(prefix + '_address').value.trim();
        var genderSel= document.querySelector('#' + (prefix==='c'?'customerForm':'memberForm') + ' input[name="gender"]:checked');

        setError('name',     name === '');
        setError('username', username === '');
        setError('password', password.length < 6);
        setError('email',    !emailReg.test(email));
        setError('contact',  !contactReg.test(contact));
        setError('address',  address === '');
        setRadioError(genderSel === null);

        /* ── Member tab: block if Male is selected ── */
        if (prefix === 'm' && genderSel !== null && genderSel.value === 'M') {
            document.getElementById('m_genderMaleWarn').style.display = 'block';
            document.getElementById('m_genderError').style.display    = 'none';
            valid = false;
        }

        document.getElementById('formError').style.display = valid ? 'none' : 'block';
        return valid;
    }

    /* ── Clear error as user corrects each field (input event, not blur) ── */
    ['c','m'].forEach(function(prefix) {
        ['name','username','password','email','contact','address'].forEach(function(id) {
            var el = document.getElementById(prefix + '_' + id);
            if (el) {
                el.addEventListener('input', function() {
                    var val = this.value.trim();
                    var isEmpty = (id === 'password') ? this.value.length < 6 : val === '';
                    var errEl   = document.getElementById(prefix + '_' + id + 'Error');
                    if (!isEmpty) {
                        this.classList.remove('is-invalid');
                        if (errEl) errEl.style.display = 'none';
                    }
                });
            }
        });
    });

    function togglePwd(id) {
        var pwd = document.getElementById(id);
        pwd.type = pwd.type === 'password' ? 'text' : 'password';
    }
</script>

</body>
</html>
