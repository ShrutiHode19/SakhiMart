<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Product" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) keyword = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">

    <!-- Page Hero -->
    <div class="shop-hero">
        <h2>&#127873; Handmade with Love</h2>
        <p>Authentic products made by Women Self-Help Group members</p>
    </div>

    <!-- Search Bar -->
    <form action="<%= request.getContextPath() %>/ProductServlet" method="get" class="search-form">
        <input type="hidden" name="action" value="search">
        <div class="search-bar">
            <input type="text" name="keyword"
                   value="<%= keyword %>"
                   placeholder="Search by product name or category...">
            <button type="submit" class="btn btn-primary">&#128269; Search</button>
            <% if (!keyword.isEmpty()) { %>
                <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
                   class="btn btn-secondary">&#10005; Clear</a>
            <% } %>
        </div>
    </form>

    <% if (!keyword.isEmpty()) { %>
        <p class="search-result-info">
            Results for: <strong>"<%= keyword %>"</strong> &mdash;
            <%= products != null ? products.size() : 0 %> product(s) found
        </p>
    <% } %>

    <!-- Category Filter (client-side) -->
    <div class="cat-filter">
        <button class="cat-btn active" onclick="filterCategory('all', this)">All</button>
        <button class="cat-btn" onclick="filterCategory('Food',       this)">Food &amp; Snacks</button>
        <button class="cat-btn" onclick="filterCategory('Pickle',     this)">Pickles</button>
        <button class="cat-btn" onclick="filterCategory('Handicraft', this)">Handicrafts</button>
        <button class="cat-btn" onclick="filterCategory('Clothing',      this)">Clothing</button>
        <button class="cat-btn" onclick="filterCategory('Beauty',     this)">Beauty</button>
        <button class="cat-btn" onclick="filterCategory('Other',      this)">Other</button>
    </div>

    <% if (products == null || products.isEmpty()) { %>
        <div class="empty-state">
            <p>No products found<%= keyword.isEmpty() ? "." : " for \"" + keyword + "\"." %></p>
        </div>
    <% } else { %>
        <div class="product-grid" id="productGrid">
            <% for (Product p : products) { %>
            <div class="product-card" data-category="<%= p.getP_category() %>">
                <a href="<%= request.getContextPath() %>/ProductServlet?action=details&p_id=<%= p.getP_id() %>">
                    <img src="<%= request.getContextPath() %>/<%= p.getP_image_path() %>"
                         alt="<%= p.getP_name() %>" class="card-img">
                </a>
                <div class="card-body">
                    <span class="cat-tag"><%= p.getP_category() %></span>
                    <h3>
                        <a href="<%= request.getContextPath() %>/ProductServlet?action=details&p_id=<%= p.getP_id() %>">
                            <%= p.getP_name() %>
                        </a>
                    </h3>
                    <p class="card-desc">
                        <%= p.getP_description() != null && p.getP_description().length() > 70
                            ? p.getP_description().substring(0, 70) + "..."
                            : (p.getP_description() != null ? p.getP_description() : "") %>
                    </p>
                    <div class="card-footer">
                        <span class="price">&#8377;<%= String.format("%.2f", p.getP_price()) %></span>
                        <a href="<%= request.getContextPath() %>/ProductServlet?action=details&p_id=<%= p.getP_id() %>"
                           class="btn btn-sm btn-primary">View Details</a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>
</div>

<%@ include file="../common/footer.jsp" %>
<script>
function filterCategory(cat, btn) {
    document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.querySelectorAll('.product-card').forEach(card => {
        card.style.display = (cat === 'all' || card.dataset.category === cat) ? '' : 'none';
    });
}
</script>
</body>
</html>
