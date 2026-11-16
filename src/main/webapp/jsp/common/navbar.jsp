<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String role        = "";
    String displayName = "";

    if (session.getAttribute("a_id") != null) {
        role        = "admin";
        displayName = (String) session.getAttribute("a_fullname");
    } else if (session.getAttribute("m_id") != null) {
        role        = "member";
        displayName = (String) session.getAttribute("m_fullname");
    } else if (session.getAttribute("c_id") != null) {
        role        = "customer";
        displayName = (String) session.getAttribute("c_fullname");
    }
    if (displayName == null) displayName = "";
%>

<style>
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800;900&display=swap');
:root { --nav-height: 68px; }

.navbar {
    position: sticky;
    top: 0;
    z-index: 1000;
    height: var(--nav-height);
    background: linear-gradient(135deg, #4a0810 0%, #8B1520 55%, #6b0d18 100%);
    display: flex;
    align-items: center;
    padding: 0 28px;
    box-shadow: 0 3px 20px rgba(0,0,0,0.28);
    border-bottom: 2px solid rgba(201,144,32,0.4);
}

.nav-brand { flex-shrink: 0; }

.brand-link {
    display: flex;
    align-items: center;
    gap: 10px;
    text-decoration: none;
    transition: transform 0.22s ease;
}
.brand-link:hover { transform: translateY(-1px); text-decoration: none; }

.brand-logo-full {
    height: 52px;
    width: auto;
    object-fit: contain;
    display: block;
    filter: drop-shadow(0 2px 10px rgba(201,144,32,0.5));
    transition: filter 0.22s ease;
}
.brand-link:hover .brand-logo-full {
    filter: drop-shadow(0 4px 18px rgba(201,144,32,0.75));
}

.brand-name { display: flex; flex-direction: column; line-height: 1; }
.brand-name-main {
    font-family: 'Playfair Display', 'Georgia', serif;
    font-size: 1.45rem;
    font-weight: 800;
    color: #ffffff;
    letter-spacing: .01em;
    text-shadow: 0 2px 8px rgba(0,0,0,0.3);
    line-height: 1.1;
}
.brand-name-main span { color: #e8c44e; }
.brand-name-tagline {
    font-size: .63rem;
    font-weight: 600;
    color: rgba(232,196,78,0.8);
    letter-spacing: .16em;
    text-transform: uppercase;
    margin-top: 2px;
}

.nav-toggle {
    display: none;
    flex-direction: column;
    gap: 5px;
    background: none;
    border: none;
    cursor: pointer;
    padding: 7px;
    margin-left: auto;
    border-radius: 8px;
    transition: background 0.2s;
}
.nav-toggle:hover { background: rgba(255,255,255,0.1); }
.nav-toggle span {
    display: block;
    width: 24px; height: 2px;
    background: rgba(255,255,255,0.9);
    border-radius: 2px;
    transition: transform 0.28s, opacity 0.28s;
}
.nav-toggle.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
.nav-toggle.open span:nth-child(2) { opacity: 0; }
.nav-toggle.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }

.nav-links {
    list-style: none;
    margin: 0 0 0 auto;
    padding: 0;
    display: flex;
    align-items: center;
    gap: 2px;
}

.nav-links a,
.nav-user {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 7px 13px;
    font-size: .83rem;
    font-weight: 700;
    color: rgba(255,255,255,0.88);
    text-decoration: none;
    border-radius: 8px;
    white-space: nowrap;
    transition: background 0.18s, color 0.18s;
    letter-spacing: .01em;
}
.nav-links a:hover { background: rgba(255,255,255,0.11); color: #fff; text-decoration: none; }

.nav-user {
    color: #e8c44e;
    font-size: .81rem;
    background: rgba(201,144,32,0.15);
    border: 1px solid rgba(201,144,32,0.3);
    border-radius: 20px;
    cursor: default;
}

.nav-gold {
    color: #e8c44e !important;
    background: rgba(201,144,32,0.12) !important;
    border: 1px solid rgba(201,144,32,0.28) !important;
}
.nav-gold:hover { background: rgba(201,144,32,0.26) !important; color: #fff !important; }

.nav-cta {
    background: linear-gradient(135deg, #a07010, #c99020) !important;
    color: #fff !important;
    border-radius: 8px !important;
    padding: 7px 18px !important;
    box-shadow: 0 2px 8px rgba(0,0,0,0.18);
}
.nav-cta:hover { filter: brightness(1.1); }

.nav-cta-outline {
    background: transparent !important;
    border: 1.5px solid rgba(255,255,255,0.42) !important;
    border-radius: 8px !important;
    color: rgba(255,255,255,0.9) !important;
    padding: 6px 16px !important;
}
.nav-cta-outline:hover {
    background: rgba(255,255,255,0.12) !important;
    border-color: rgba(255,255,255,0.7) !important;
    color: #fff !important;
}

.nav-logout { color: rgba(255,160,160,0.85) !important; }
.nav-logout:hover { background: rgba(255,80,80,0.1) !important; color: #ffaaaa !important; }

@media (max-width: 860px) {
    .nav-toggle { display: flex; }
    .nav-links {
        display: none;
        position: absolute;
        top: var(--nav-height);
        left: 0; right: 0;
        background: #5a0a12;
        flex-direction: column;
        align-items: stretch;
        padding: 10px 16px 18px;
        gap: 4px;
        box-shadow: 0 10px 28px rgba(0,0,0,0.3);
        border-bottom: 2px solid rgba(201,144,32,0.3);
    }
    .nav-links.open { display: flex; }
    .nav-links a, .nav-user { padding: 11px 14px; font-size: .9rem; }
    .brand-logo-full { height: 44px; }
    .brand-name-main { font-size: 1.2rem; }
    .brand-name-tagline { display: none; }
    .navbar { padding: 0 16px; }
}
</style>

<nav class="navbar">

    <div class="nav-brand">
        <a href="<%= request.getContextPath() %>/index.jsp" class="brand-link">
            <img src="<%= request.getContextPath() %>/images/sakhilogo.png"
                 alt="SakhiMart"
                 class="brand-logo-full">
            <div class="brand-name">
                <span class="brand-name-main">Sakhi<span>Mart</span></span>
                <span class="brand-name-tagline">Handmade with Love</span>
            </div>
        </a>
    </div>

    <button class="nav-toggle" id="navToggle" aria-label="Toggle menu">
        <span></span><span></span><span></span>
    </button>

    <ul class="nav-links" id="navLinks">

        <%-- ══ ADMIN ══ --%>
        <% if ("admin".equals(role)) { %>
            <li><span class="nav-user">&#128272; <%= displayName %></span></li>
            <li><a href="<%= request.getContextPath() %>/ProductServlet?action=adminProducts">&#128717; Products</a></li>
            <li><a href="<%= request.getContextPath() %>/OrderServlet?action=allOrders">&#128203; Orders</a></li>
            <li><a href="<%= request.getContextPath() %>/ProfileServlet?action=manageUsers">&#128101; Manage Users</a></li>
            <li><a href="<%= request.getContextPath() %>/ProfileServlet?action=editProfile">&#9998; Profile</a></li>
            <li><a href="<%= request.getContextPath() %>/jsp/admin/admin_chatbot.jsp" class="nav-gold">&#10024; Sakhi AI</a></li>
            <li><a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-logout">&#8594; Logout</a></li>

        <%-- ══ MEMBER ══ --%>
        <% } else if ("member".equals(role)) { %>
            <li><span class="nav-user">&#128100; <%= displayName %></span></li>
            <li><a href="<%= request.getContextPath() %>/ProductServlet?action=memberProducts">&#128717; My Products</a></li>
            <li><a href="<%= request.getContextPath() %>/OrderServlet?action=memberOrders">&#128203; Orders</a></li>
            <li><a href="<%= request.getContextPath() %>/jsp/member/add_product.jsp">&#43; Add Product</a></li>
            <li><a href="<%= request.getContextPath() %>/ProfileServlet">&#128100; Profile</a></li>
            <li><a href="<%= request.getContextPath() %>/jsp/chatbot/chatbot.jsp" class="nav-gold">&#10024; Sakhi AI</a></li>
            <li><a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-logout">&#8594; Logout</a></li>

        <%-- ══ CUSTOMER ══ --%>
        <% } else if ("customer".equals(role)) { %>
            <li><span class="nav-user">&#128100; <%= displayName %></span></li>
            <li><a href="<%= request.getContextPath() %>/ProductServlet?action=list">&#128717; Shop</a></li>
            <li><a href="<%= request.getContextPath() %>/CartServlet?action=view">&#128722; My Cart</a></li>
            <li><a href="<%= request.getContextPath() %>/OrderServlet?action=myOrders">&#128203; My Orders</a></li>
            <li><a href="<%= request.getContextPath() %>/ProfileServlet">&#128100; Profile</a></li>
            <li><a href="<%= request.getContextPath() %>/jsp/chatbot/chatbot.jsp" class="nav-gold">&#10024; Sakhi AI</a></li>
            <li><a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-logout">&#8594; Logout</a></li>

        <%-- ══ GUEST ══ --%>
        <% } else { %>
            <li><a href="<%= request.getContextPath() %>/ProductServlet?action=list">&#128717; Shop</a></li>
            <li><a href="<%= request.getContextPath() %>/jsp/chatbot/chatbot.jsp" class="nav-gold">&#10024; Sakhi AI</a></li>
            <li><a href="<%= request.getContextPath() %>/jsp/auth/login.jsp" class="nav-cta">Login</a></li>
            <li><a href="<%= request.getContextPath() %>/jsp/auth/register.jsp" class="nav-cta-outline">Register</a></li>
        <% } %>

    </ul>
</nav>

<script>
(function () {
    var toggle = document.getElementById('navToggle');
    var links  = document.getElementById('navLinks');
    if (toggle && links) {
        toggle.addEventListener('click', function () {
            links.classList.toggle('open');
            toggle.classList.toggle('open');
        });
        links.querySelectorAll('a').forEach(function (a) {
            a.addEventListener('click', function () {
                links.classList.remove('open');
                toggle.classList.remove('open');
            });
        });
    }
})();
</script>
