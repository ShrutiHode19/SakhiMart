<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Order" %>
<%
    if (session.getAttribute("c_id") == null) {
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
    <title>My Orders – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .orders-wrap { max-width: 1000px; margin: 28px auto; padding: 0 18px 40px; }
        .orders-card {
            background: var(--bg-card); border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm); overflow: hidden; margin-bottom: 16px;
        }
        .orders-card-header {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 18px 24px; color: #fff; display: flex;
            justify-content: space-between; align-items: center;
        }
        .orders-card-header h2 { font-family:'Playfair Display',serif; color:#fff; font-size:1.2rem; }
        .order-row {
            display: grid;
            grid-template-columns: 80px 1fr 1fr 140px 140px 120px;
            gap: 12px; align-items: center;
            padding: 16px 24px; border-bottom: 1px solid var(--border-light);
            transition: background 0.15s;
        }
        .order-row:last-child { border-bottom: none; }
        .order-row:hover { background: var(--primary-bg); }
        @media(max-width:700px){
            .order-row { grid-template-columns: 1fr 1fr; }
        }
        .order-id { font-weight: 800; color: var(--primary); font-size: 0.95rem; }
        .order-date { font-size: 0.82rem; color: var(--text-light); }
        .order-address { font-size: 0.82rem; color: var(--text-mid); }
        .order-amount { font-weight: 800; color: var(--text-dark); font-size: 1rem; }
        .status-badge {
            display:inline-block; padding:4px 12px; border-radius:20px;
            font-size:0.75rem; font-weight:700; text-transform:uppercase;
        }
        .badge-pending    { background:#fff3cd; color:#856404; }
        .badge-confirmed  { background:#d1ecf1; color:#0c5460; }
        .badge-processing { background:#e2e3e5; color:#383d41; }
        .badge-shipped    { background:#cce5ff; color:#004085; }
        .badge-delivered  { background:#d4edda; color:#155724; }
        .badge-cancelled  { background:#f8d7da; color:#721c24; }
        .badge-failed     { background:#f8d7da; color:#721c24; }
        .table-header {
            display: grid;
            grid-template-columns: 80px 1fr 1fr 140px 140px 120px;
            gap: 12px; padding: 10px 24px;
            background: var(--primary-bg);
            font-size: 0.75rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.5px;
            color: var(--text-light); border-bottom: 2px solid var(--border-light);
        }
        .empty-state { text-align: center; padding: 60px 24px; }
        .empty-state .icon { font-size: 3.5rem; margin-bottom: 14px; }
    </style>
</head>
<body>
<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128203; My Orders</h2>
</div>

<% if ("notfound".equals(msg)) { %>
<div style="max-width:1000px;margin:14px auto 0;padding:0 18px;">
    <div class="alert alert-warning">Order not found.</div>
</div>
<% } %>

<div class="orders-wrap">
    <div class="orders-card">
        <div class="orders-card-header">
            <h2>Order History</h2>
            <% if (orders != null && !orders.isEmpty()) { %>
                <span style="background:rgba(255,255,255,0.2);border-radius:20px;padding:3px 12px;font-size:0.82rem;font-weight:700;">
                    <%= orders.size() %> order(s)
                </span>
            <% } %>
        </div>

        <% if (orders == null || orders.isEmpty()) { %>
            <div class="empty-state">
                <div class="icon">&#128203;</div>
                <h3 style="color:var(--text-mid);">No orders yet</h3>
                <p style="color:var(--text-light);margin-bottom:20px;">You haven't placed any orders. Start shopping!</p>
                <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="btn btn-primary">
                    &#128722; Browse Products
                </a>
            </div>
        <% } else { %>

            <div class="table-header">
                <span>Order #</span>
                <span>Date</span>
                <span>Address</span>
                <span>Payment</span>
                <span>Delivery</span>
                <span>Amount</span>
            </div>

            <% for (Order o : orders) {
                String payBadge = o.getPayment_status() != null ? o.getPayment_status().toLowerCase() : "pending";
                String delBadge = o.getDelivery_status() != null ? o.getDelivery_status().toLowerCase() : "processing";
            %>
            <div class="order-row" style="cursor:pointer;"
                 onclick="location.href='<%= request.getContextPath() %>/OrderServlet?action=orderDetail&id=<%= o.getOrder_id() %>'">
                <div class="order-id">#<%= o.getOrder_id() %></div>
                <div>
                    <div class="order-date"><%= o.getOrder_date() != null ? o.getOrder_date().toString().substring(0,10) : "-" %></div>
                    <div style="font-size:0.8rem;color:var(--text-light);"><%= o.getPayment_method() %></div>
                </div>
                <div class="order-address">
                    <%= o.getDelivery_address() != null ?
                        (o.getDelivery_address().length() > 50 ? o.getDelivery_address().substring(0,50) + "..." : o.getDelivery_address())
                        : "-" %>
                </div>
                <div><span class="status-badge badge-<%= payBadge %>"><%= o.getPayment_status() %></span></div>
                <div><span class="status-badge badge-<%= delBadge %>"><%= o.getDelivery_status() %></span></div>
                <div class="order-amount">&#8377;<%= String.format("%.2f", o.getTotal_amount()) %></div>
            </div>
            <% } %>

        <% } %>
    </div>

    <div style="text-align:center; margin-top:10px;">
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="btn btn-secondary">
            &#8592; Continue Shopping
        </a>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
</body>
</html>
