<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Order" %>
<%
    if (session.getAttribute("a_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Orders – SakhiMart Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .admin-wrap { max-width: 1200px; margin: 28px auto; padding: 0 18px 40px; }
        .orders-card {
            background: var(--bg-card); border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm); overflow: hidden;
        }
        .orders-card-header {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 18px 24px; color: #fff;
            display: flex; justify-content: space-between; align-items: center;
        }
        .orders-card-header h2 { font-family:'Playfair Display',serif; color:#fff; font-size:1.2rem; }
        .admin-table { width:100%; border-collapse:collapse; }
        .admin-table th {
            text-align:left; padding:12px 14px;
            background:var(--primary-bg); font-size:0.78rem;
            text-transform:uppercase; letter-spacing:0.5px; color:var(--text-light);
            border-bottom:2px solid var(--border-light);
        }
        .admin-table td {
            padding:12px 14px; font-size:0.87rem; color:var(--text-dark);
            border-bottom:1px solid var(--border-light); vertical-align:middle;
        }
        .admin-table tr:hover td { background:var(--primary-bg); }
        .status-badge {
            display:inline-block; padding:3px 10px; border-radius:20px;
            font-size:0.72rem; font-weight:700; text-transform:uppercase;
        }
        .badge-pending    { background:#fff3cd; color:#856404; }
        .badge-confirmed  { background:#d1ecf1; color:#0c5460; }
        .badge-processing { background:#e2e3e5; color:#383d41; }
        .badge-shipped    { background:#cce5ff; color:#004085; }
        .badge-delivered  { background:#d4edda; color:#155724; }
        .badge-cancelled  { background:#f8d7da; color:#721c24; }
        .badge-failed     { background:#f8d7da; color:#721c24; }
        .action-form { display:inline-flex; gap:6px; align-items:center; }
        .action-form select {
            font-size:0.8rem; padding:4px 8px; border:1px solid var(--border);
            border-radius:var(--radius-xs); color:var(--text-dark);
        }
        .flash-bar { max-width:1200px; margin:14px auto 0; padding:0 18px; }
    </style>
</head>
<body>
<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128203; Manage Orders</h2>
</div>

<div class="flash-bar">
<% if ("payment_confirmed".equals(msg)) { %><div class="alert alert-success">&#10003; Payment confirmed.</div>
<% } else if ("delivery_updated".equals(msg)) { %><div class="alert alert-success">&#10003; Delivery status updated.</div>
<% } else if ("cancelled".equals(msg)) { %><div class="alert alert-info">&#128465; Order cancelled.</div>
<% } %>
</div>

<div class="admin-wrap">
    <div class="orders-card">
        <div class="orders-card-header">
            <h2>All Orders</h2>
            <span style="background:rgba(255,255,255,0.2);border-radius:20px;padding:3px 12px;font-size:0.82rem;font-weight:700;">
                <%= orders != null ? orders.size() : 0 %> total
            </span>
        </div>

        <div style="overflow-x:auto;">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Order #</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Amount</th>
                    <th>Payment</th>
                    <th>Delivery</th>
                    <th>Method</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (orders != null) { for (Order o : orders) {
                String payBadge = o.getPayment_status() != null ? o.getPayment_status().toLowerCase() : "pending";
                String delBadge = o.getDelivery_status() != null ? o.getDelivery_status().toLowerCase() : "processing";
            %>
            <tr>
                <td><strong>#<%= o.getOrder_id() %></strong></td>
                <td>
                    <div><%= o.getC_fullname() != null ? o.getC_fullname() : "C#" + o.getC_id() %></div>
                    <div style="font-size:0.75rem;color:var(--text-light);"><%= o.getC_email() != null ? o.getC_email() : "" %></div>
                </td>
                <td style="font-size:0.82rem;"><%= o.getOrder_date() != null ? o.getOrder_date().toString().substring(0,10) : "-" %></td>
                <td><strong>&#8377;<%= String.format("%.2f", o.getTotal_amount()) %></strong></td>
                <td><span class="status-badge badge-<%= payBadge %>"><%= o.getPayment_status() %></span></td>
                <td><span class="status-badge badge-<%= delBadge %>"><%= o.getDelivery_status() %></span></td>
                <td style="font-size:0.82rem;"><%= o.getPayment_method() %></td>
                <td>
                    <!-- Confirm payment -->
                    <% if (!"Confirmed".equalsIgnoreCase(o.getPayment_status()) && !"Failed".equalsIgnoreCase(o.getPayment_status())) { %>
                    <form action="<%= request.getContextPath() %>/OrderServlet" method="post" class="action-form" style="margin-bottom:4px;">
                        <input type="hidden" name="action" value="confirmPayment">
                        <input type="hidden" name="order_id" value="<%= o.getOrder_id() %>">
                        <button type="submit" class="btn btn-secondary btn-sm"
                                onclick="return confirm('Confirm payment for order #<%= o.getOrder_id() %>?')">
                            &#10003; Confirm Pay
                        </button>
                    </form>
                    <% } %>

                    <!-- Update delivery -->
                    <form action="<%= request.getContextPath() %>/OrderServlet" method="post" class="action-form" style="margin-bottom:4px;">
                        <input type="hidden" name="action" value="updateDelivery">
                        <input type="hidden" name="order_id" value="<%= o.getOrder_id() %>">
                        <select name="delivery_status">
                            <option value="Processing">Processing</option>
                            <option value="Shipped">Shipped</option>
                            <option value="Delivered">Delivered</option>
                        </select>
                        <button type="submit" class="btn btn-primary btn-sm">Update</button>
                    </form>

                    <!-- Cancel -->
                    <% if (!"Cancelled".equalsIgnoreCase(o.getDelivery_status())) { %>
                    <form action="<%= request.getContextPath() %>/OrderServlet" method="post" class="action-form">
                        <input type="hidden" name="action" value="cancelOrder">
                        <input type="hidden" name="order_id" value="<%= o.getOrder_id() %>">
                        <button type="submit" class="btn btn-danger btn-sm"
                                onclick="return confirm('Cancel order #<%= o.getOrder_id() %>?')">
                            Cancel
                        </button>
                    </form>
                    <% } %>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>

<script>
setTimeout(() => {
    document.querySelectorAll('.alert').forEach(el => {
        el.style.transition = 'opacity 0.5s';
        el.style.opacity = '0';
        setTimeout(() => el.remove(), 500);
    });
}, 4000);
</script>
</body>
</html>
