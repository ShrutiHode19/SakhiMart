<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Product" %>
<%
    Product p = (Product) request.getAttribute("product");
    if (p == null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=list");
        return;
    }
    boolean customerLoggedIn = (session.getAttribute("c_id") != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= p.getP_name() %> – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">

    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list">Products</a>
        &rsaquo; <%= p.getP_category() %>
        &rsaquo; <strong><%= p.getP_name() %></strong>
    </div>

    <div class="detail-card">

        <!-- Product Image -->
        <div class="detail-image">
            <img src="<%= request.getContextPath() %>/<%= p.getP_image_path() %>"
                 alt="<%= p.getP_name() %>">
        </div>

        <!-- Product Info -->
        <div class="detail-info">
            <span class="cat-tag"><%= p.getP_category() %></span>
            <h1><%= p.getP_name() %></h1>
            <p class="detail-price">&#8377;<%= String.format("%.2f", p.getP_price()) %></p>

            <div class="stock-info">
                <% if (p.getP_quantity() > 0) { %>
                    <span class="in-stock">&#10003; In Stock (<%= p.getP_quantity() %> available)</span>
                <% } else { %>
                    <span class="out-stock">&#10007; Out of Stock</span>
                <% } %>
            </div>

            <% if (p.getP_description() != null && !p.getP_description().isEmpty()) { %>
                <div class="detail-desc">
                    <h4>About this product</h4>
                    <p><%= p.getP_description() %></p>
                </div>
            <% } %>

            <!-- Add to Cart Section -->
            <% if (p.getP_quantity() > 0) { %>
                <% if (customerLoggedIn) { %>
                    <form action="<%= request.getContextPath() %>/CartServlet" method="post"
                          class="add-cart-form">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="p_id"   value="<%= p.getP_id() %>">
                        <div class="qty-selector">
                            <label for="qty">Quantity:</label>
                            <input type="number" id="qty" name="qty"
                                   value="1" min="1" max="<%= p.getP_quantity() %>">
                        </div>
                        <button type="submit" class="btn btn-primary btn-large">
                            &#128722; Add to Cart
                        </button>
                    </form>
                <% } else { %>
                    <div class="login-prompt">
                        <p>Please login to add this product to your cart.</p>
                        <a href="<%= request.getContextPath() %>/jsp/auth/login.jsp"
                           class="btn btn-primary btn-large">Login to Buy</a>
                        <a href="<%= request.getContextPath() %>/jsp/auth/register.jsp"
                           class="btn btn-secondary">Register</a>
                    </div>
                <% } %>
            <% } %>

            <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
               class="back-link">&#8592; Back to Products</a>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
</body>
</html>
