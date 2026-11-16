<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Product" %>
<%
    if (session.getAttribute("a_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    int totalCount = 0, pendingCount = 0, approvedCount = 0, rejectedCount = 0;
    if (products != null) {
        totalCount = products.size();
        for (Product p : products) {
            if ("pending".equals(p.getP_status()))       pendingCount++;
            else if ("approved".equals(p.getP_status())) approvedCount++;
            else if ("rejected".equals(p.getP_status())) rejectedCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Products &#8211; SakhiMart Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">

    <div class="page-header">
        <h2>Manage Products</h2>
        <%-- FIX: admin_dashboard.jsp does not exist — removed broken link --%>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=adminProducts"
           class="btn btn-secondary">&#8635; Refresh</a>
    </div>

    <% if (message != null) { %>
        <div class="alert <%= message.contains("approved") || message.contains("success") ? "alert-success" : "alert-error" %>">
            <%= message %>
        </div>
    <% } %>

    <!-- Summary Cards -->
    <div class="summary-cards">
        <div class="summary-card card-total">
            <h3><%= totalCount %></h3><p>Total</p>
        </div>
        <div class="summary-card card-pending">
            <h3><%= pendingCount %></h3><p>Pending</p>
        </div>
        <div class="summary-card card-approved">
            <h3><%= approvedCount %></h3><p>Approved</p>
        </div>
        <div class="summary-card card-rejected">
            <h3><%= rejectedCount %></h3><p>Rejected</p>
        </div>
    </div>

    <!-- Filter Tabs -->
    <div class="filter-tabs">
        <button class="tab-btn active" onclick="filterRows('all',      this)">All (<%= totalCount %>)</button>
        <button class="tab-btn"        onclick="filterRows('pending',   this)">Pending (<%= pendingCount %>)</button>
        <button class="tab-btn"        onclick="filterRows('approved',  this)">Approved (<%= approvedCount %>)</button>
        <button class="tab-btn"        onclick="filterRows('rejected',  this)">Rejected (<%= rejectedCount %>)</button>
    </div>

    <% if (products == null || products.isEmpty()) { %>
        <div class="empty-state"><p>No products found in the system.</p></div>
    <% } else { %>
        <div class="table-wrapper">
            <table class="data-table" id="productTable">
                <thead>
                    <tr>
                        <th>Sr.</th>
                        <th>Image</th>
                        <th>Product Name</th>
                        <th>Category</th>
                        <th>Member ID</th>
                        <th>Price (&#8377;)</th>
                        <th>Quantity</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% int sr = 1; for (Product p : products) { %>
                    <tr data-status="<%= p.getP_status() %>">
                        <td><%= sr++ %></td>
                        <td>
                            <img src="<%= request.getContextPath() %>/<%= p.getP_image_path() %>"
                                 alt="<%= p.getP_name() %>" class="thumb">
                        </td>
                        <td>
                            <strong><%= p.getP_name() %></strong><br>
                            <small class="muted">
                                <%= p.getP_description() != null && p.getP_description().length() > 50
                                    ? p.getP_description().substring(0, 50) + "..."
                                    : p.getP_description() %>
                            </small>
                        </td>
                        <td><%= p.getP_category() %></td>
                        <td><%= p.getM_id() %></td>
                        <td>&#8377;<%= String.format("%.2f", p.getP_price()) %></td>
                        <td><%= p.getP_quantity() %></td>
                        <td>
                            <span class="badge status-<%= p.getP_status() %>">
                                <%= p.getP_status().substring(0,1).toUpperCase()
                                  + p.getP_status().substring(1) %>
                            </span>
                        </td>
                        <td class="action-col">
                            <% if ("pending".equals(p.getP_status()) || "rejected".equals(p.getP_status())) { %>
                                <a href="<%= request.getContextPath() %>/ProductServlet?action=approve&p_id=<%= p.getP_id() %>"
                                   class="btn btn-sm btn-success"
                                   onclick="return confirm('Approve product: <%= p.getP_name() %>?')">
                                   Approve
                                </a>
                            <% } %>
                            <% if ("pending".equals(p.getP_status()) || "approved".equals(p.getP_status())) { %>
                                <a href="<%= request.getContextPath() %>/ProductServlet?action=reject&p_id=<%= p.getP_id() %>"
                                   class="btn btn-sm btn-warning"
                                   onclick="return confirm('Reject product: <%= p.getP_name() %>?')">
                                   Reject
                                </a>
                            <% } %>
                            <a href="<%= request.getContextPath() %>/ProductServlet?action=adminDelete&p_id=<%= p.getP_id() %>"
                               class="btn btn-sm btn-danger"
                               onclick="return confirm('Permanently delete \'<%= p.getP_name() %>\'?')">
                               Remove
                            </a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</div>

<%@ include file="../common/footer.jsp" %>
<script>
function filterRows(status, btn) {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.querySelectorAll('#productTable tbody tr').forEach(row => {
        row.style.display = (status === 'all' || row.dataset.status === status) ? '' : 'none';
    });
}
</script>
</body>
</html>