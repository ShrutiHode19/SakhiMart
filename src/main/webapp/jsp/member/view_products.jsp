<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Product" %>
<%
    if (session.getAttribute("m_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");
    String memberName = (String) session.getAttribute("m_fullname");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Products – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">

    <div class="page-header">
        <h2>My Products
            <% if (memberName != null) { %>
                <span class="sub-head">(<%= memberName %>)</span>
            <% } %>
        </h2>
        <a href="<%= request.getContextPath() %>/jsp/member/add_product.jsp"
           class="btn btn-primary">&#43; Add New Product</a>
    </div>

    <% if (message != null) { %>
        <div class="alert <%= message.contains("success") || message.contains("approved") ? "alert-success" : "alert-error" %>">
            <%= message %>
        </div>
    <% } %>

    <% if (products == null || products.isEmpty()) { %>
        <div class="empty-state">
            <p>You have not added any products yet.</p>
            <a href="<%= request.getContextPath() %>/jsp/member/add_product.jsp"
               class="btn btn-primary">Add Your First Product</a>
        </div>
    <% } else { %>
        <div class="table-wrapper">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Sr.</th>
                        <th>Image</th>
                        <th>Product Name</th>
                        <th>Category</th>
                        <th>Price (&#8377;)</th>
                        <th>Quantity</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% int sr = 1; for (Product p : products) { %>
                    <tr>
                        <td><%= sr++ %></td>
                        <td>
                            <img src="<%= request.getContextPath() %>/<%= p.getP_image_path() %>"
                                 alt="<%= p.getP_name() %>" class="thumb">
                        </td>
                        <td><strong><%= p.getP_name() %></strong></td>
                        <td><%= p.getP_category() %></td>
                        <td>&#8377;<%= String.format("%.2f", p.getP_price()) %></td>
                        <td><%= p.getP_quantity() %></td>
                        <td>
                            <span class="badge status-<%= p.getP_status() %>">
                                <%= p.getP_status().substring(0,1).toUpperCase() + p.getP_status().substring(1) %>
                            </span>
                        </td>
                        <td>
                            <a href="<%= request.getContextPath() %>/ProductServlet?action=editForm&p_id=<%= p.getP_id() %>"
                               class="btn btn-sm btn-warning">Edit</a>

                            <form action="<%= request.getContextPath() %>/ProductServlet"
                                  method="post" style="display:inline;"
                                  onsubmit="return confirm('Delete \'<%= p.getP_name() %>\'? This cannot be undone.')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="p_id"   value="<%= p.getP_id() %>">
                                <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Legend -->
       <!--  <div class="legend">
            <span class="badge status-pending">Pending</span> &ndash; Awaiting admin approval &nbsp;|&nbsp;
            <span class="badge status-approved">Approved</span> &ndash; Visible to customers &nbsp;|&nbsp;
            <span class="badge status-rejected">Rejected</span> &ndash; Not visible
        </div>-->
    <% } %>
</div>

<%@ include file="../common/footer.jsp" %>
</body>
</html>
