<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Customer" %>
<%
    // ── Session Guard ──────────────────────────────────────────────────────
    Customer c = (Customer) session.getAttribute("user");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    String fullName  = c.getC_fullname() != null ? c.getC_fullname() : "Customer";
    String firstName = fullName.contains(" ")
                       ? fullName.substring(0, fullName.indexOf(" ")) : fullName;

    java.util.Calendar cal = java.util.Calendar.getInstance();
    int hour = cal.get(java.util.Calendar.HOUR_OF_DAY);
    String greeting;
    if (hour < 12)      greeting = "Good Morning";
    else if (hour < 17) greeting = "Good Afternoon";
    else                greeting = "Good Evening";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home &#8211; SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">

    <!-- Welcome Banner -->
    <div class="welcome-banner">
        <div class="banner-icon">&#127873;</div>
        <div>
            <h2><%= greeting %>, <%= firstName %>!</h2>
            <p>Welcome to SakhiMart &mdash; handmade with love by Women Self-Help Group members.</p>
        </div>
    </div>

    <!-- Hero Section -->
    <div class="hero-section" style="padding:30px 20px 24px;">
        <h1>Shop Handmade. Support Women.</h1>
        <p>
            Discover authentic homemade products &mdash; pickles, snacks, handicrafts,
            textiles, and more &mdash; crafted with care by local SHG members.
        </p>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
           class="btn btn-primary" style="font-size:1rem; padding:12px 32px;">
            &#128717; Browse All Products
        </a>
    </div>

    <!-- Quick Action Cards -->
    <div class="summary-cards"
         style="grid-template-columns:repeat(auto-fit,minmax(170px,1fr)); margin-bottom:36px;">

        <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
           class="summary-card card-total" style="text-decoration:none; cursor:pointer;">
            <h3>&#127873;</h3>
            <p>Browse Products</p>
        </a>

        <%-- FIX: CartServlet does not exist yet — link to product list instead of 404 --%>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
           class="summary-card card-pending" style="text-decoration:none; cursor:pointer;">
            <h3>&#128722;</h3>
            <p>My Cart</p>
        </a>

        <%-- FIX: OrderServlet does not exist yet — link to profile instead of 404 --%>
        <a href="<%= request.getContextPath() %>/ProfileServlet"
           class="summary-card card-approved" style="text-decoration:none; cursor:pointer;">
            <h3>&#128196;</h3>
            <p>My Orders</p>
        </a>

        <a href="<%= request.getContextPath() %>/ProfileServlet"
           class="summary-card card-rejected" style="text-decoration:none; cursor:pointer;">
            <h3>&#128100;</h3>
            <p>My Profile</p>
        </a>

    </div>

    <!-- Categories Strip -->
    <h3 style="font-size:1.1rem; color:#555; margin-bottom:14px; font-weight:600;">
        &#127808; Shop by Category
    </h3>
    <div class="cat-filter" style="justify-content:flex-start; margin-bottom:36px;">
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
           class="cat-btn active">All</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Food"
           class="cat-btn">&#127857; Food &amp; Snacks</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Pickle"
           class="cat-btn">&#129748; Pickles</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Handicraft"
           class="cat-btn">&#127912; Handicrafts</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Cloth"
           class="cat-btn">&#129525; Cloth &amp; Textiles</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Beauty"
           class="cat-btn">&#128144; Beauty &amp; Wellness</a>
    </div>

    <!-- About Strip -->
    <div class="alert alert-info" style="align-items:flex-start; gap:14px;">
        <span style="font-size:1.4rem;">&#8505;</span>
        <div>
            <strong>About SakhiMart</strong><br>
            SakhiMart is a dedicated platform for a Women Self-Help Group to sell their
            homemade products online. Every purchase directly supports the livelihoods
            of our group members. Thank you for shopping with us!
        </div>
    </div>

</div><!-- /container -->

<%@ include file="../common/footer.jsp" %>

</body>
</html>