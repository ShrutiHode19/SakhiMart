<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Order, model.OrderItem" %>
<%
    if (session.getAttribute("c_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    Order order = (Order) request.getAttribute("order");
    List<OrderItem> orderItems = (List<OrderItem>) request.getAttribute("orderItems");

    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/OrderServlet?action=myOrders");
        return;
    }

    double shipping   = order.getTotal_amount() < 500 ? 50.0 : 0.0;
    double grandTotal = order.getTotal_amount() + shipping;
    String msg        = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order #<%= order.getOrder_id() %> – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .detail-wrap { max-width: 820px; margin: 28px auto; padding: 0 18px 40px; }
        .receipt-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            margin-bottom: 20px;
        }
        .receipt-header {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 18px 28px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .receipt-header h3 { font-family:'Playfair Display',serif; color:#fff; font-size:1.15rem; }
        .receipt-header .receipt-date { color:rgba(255,255,255,0.8); font-size:0.82rem; }
        .receipt-body { padding: 24px 28px; }
        .receipt-meta {
            display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px;
        }
        @media(max-width:600px){ .receipt-meta{ grid-template-columns:1fr; } }
        .meta-box {
            background: var(--primary-bg); border-radius: var(--radius-md);
            padding: 14px 18px; border-left: 4px solid var(--primary);
        }
        .meta-box.delivery-box { border-left-color: var(--accent); }
        .meta-box.payment-box  { border-left-color: #27ae60; }
        .meta-label { font-size:0.72rem; text-transform:uppercase; letter-spacing:0.8px; color:var(--text-light); font-weight:700; margin-bottom:5px; }
        .meta-value { font-size:0.92rem; font-weight:600; color:var(--text-dark); }
        .status-badge {
            display:inline-block; padding:3px 12px; border-radius:20px;
            font-size:0.78rem; font-weight:700; text-transform:uppercase; letter-spacing:0.5px;
        }
        .badge-pending    { background:#fff3cd; color:#856404; }
        .badge-confirmed  { background:#d1ecf1; color:#0c5460; }
        .badge-processing { background:#e2e3e5; color:#383d41; }
        .badge-shipped    { background:#cce5ff; color:#004085; }
        .badge-delivered  { background:#d4edda; color:#155724; }
        .badge-cancelled  { background:#f8d7da; color:#721c24; }
        .badge-failed     { background:#f8d7da; color:#721c24; }
        .items-section-title {
            font-weight:800; font-size:0.92rem; color:var(--text-dark);
            text-transform:uppercase; letter-spacing:0.5px;
            margin-bottom:12px; padding-bottom:8px; border-bottom:2px solid var(--border-light);
        }
        .receipt-table { width:100%; border-collapse:collapse; }
        .receipt-table th {
            text-align:left; font-size:0.78rem; text-transform:uppercase; letter-spacing:0.5px;
            color:var(--text-light); padding:10px 8px; border-bottom:2px solid var(--border-light);
        }
        .receipt-table td {
            padding:12px 8px; font-size:0.88rem; border-bottom:1px solid var(--border-light);
            color:var(--text-dark); vertical-align:middle;
        }
        .receipt-table tr:last-child td { border-bottom:none; }
        .product-img { width:50px; height:50px; object-fit:cover; border-radius:var(--radius-xs); }
        .text-right { text-align:right; }
        .price-col { font-weight:700; color:var(--primary); }
        .receipt-totals { margin-top:16px; border-top:2px solid var(--border); padding-top:16px; }
        .total-row { display:flex; justify-content:space-between; padding:5px 0; font-size:0.88rem; color:var(--text-mid); }
        .total-row .t-label { font-weight:500; }
        .total-row .t-value { font-weight:700; color:var(--text-dark); }
        .grand-row { display:flex; justify-content:space-between; padding:12px 0 4px; border-top:2px solid var(--border); margin-top:8px; }
        .grand-row .t-label { font-size:1.05rem; font-weight:800; color:var(--text-dark); }
        .grand-row .t-value { font-size:1.2rem; font-weight:900; color:var(--primary); }
        .action-row { display:flex; gap:14px; flex-wrap:wrap; margin-top:20px; }
        .btn-download {
            display:inline-flex; align-items:center; gap:8px;
            background:linear-gradient(135deg,#2c3e50,#34495e); color:#fff;
            padding:12px 24px; border-radius:var(--radius-md); font-weight:700; font-size:0.9rem;
            border:none; cursor:pointer; transition:all 0.2s;
        }
        .btn-download:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(44,62,80,.35); color:#fff; }
        .btn-print {
            display:inline-flex; align-items:center; gap:8px;
            background:var(--bg-card); color:var(--text-dark);
            padding:12px 24px; border-radius:var(--radius-md); font-weight:700; font-size:0.9rem;
            border:2px solid var(--border); cursor:pointer; transition:all 0.2s;
        }
        .btn-print:hover { border-color:var(--primary); color:var(--primary); }
        @media print {
            body * { visibility:hidden; }
            .receipt-card, .receipt-card * { visibility:visible; }
            .receipt-card { position:absolute; left:0; top:0; width:100%; box-shadow:none; }
            .no-print { display:none !important; }
        }
    </style>
</head>
<body>
<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128203; Order #<%= order.getOrder_id() %></h2>
</div>

<% if ("placed".equals(msg)) { %>
<div style="max-width:820px; margin:14px auto 0; padding:0 18px;">
    <div class="alert alert-success">&#10003; Order placed successfully! Your receipt is below.</div>
</div>
<% } %>

<div class="detail-wrap">

    <div class="receipt-card" id="receiptCard">
        <div class="receipt-header">
            <div>
                <h3>&#128203; Order Receipt</h3>
                <div class="receipt-date">
                    SakhiMart &bull; <%= order.getOrder_date() != null ? order.getOrder_date().toString().substring(0,16) : "" %>
                </div>
            </div>
            <div style="text-align:right;">
                <div style="color:#fff; font-weight:800; font-size:1.05rem;">Order #<%= order.getOrder_id() %></div>
            </div>
        </div>

        <div class="receipt-body">
            <div class="receipt-meta">
                <div class="meta-box">
                    <div class="meta-label">&#128100; Customer</div>
                    <div class="meta-value"><%= order.getC_fullname() != null ? order.getC_fullname() : "-" %></div>
                    <% if (order.getC_contact() != null) { %><div style="font-size:0.82rem;color:var(--text-light);">&#128222; <%= order.getC_contact() %></div><% } %>
                </div>
                <div class="meta-box">
                    <div class="meta-label">&#128203; Order Status</div>
                    <div style="margin-bottom:6px;">Payment:
                        <span class="status-badge badge-<%= order.getPayment_status().toLowerCase() %>"><%= order.getPayment_status() %></span>
                    </div>
                    <div>Delivery:
                        <span class="status-badge badge-<%= order.getDelivery_status().toLowerCase() %>"><%= order.getDelivery_status() %></span>
                    </div>
                </div>
                <div class="meta-box delivery-box">
                    <div class="meta-label">&#128205; Delivery Address</div>
                    <div class="meta-value"><%= order.getDelivery_address() %></div>
                </div>
                <div class="meta-box payment-box">
                    <div class="meta-label">&#128179; Payment Method</div>
                    <div class="meta-value"><%= order.getPayment_method() %></div>
                    <div style="font-size:0.82rem;color:var(--text-light);margin-top:4px;">
                        Order Date: <%= order.getOrder_date() != null ? order.getOrder_date().toString().substring(0,10) : "" %>
                    </div>
                </div>
            </div>

            <div class="items-section-title">&#128722; Items Ordered</div>
            <table class="receipt-table">
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Category</th>
                        <th class="text-right">Price</th>
                        <th class="text-right">Qty</th>
                        <th class="text-right">Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (orderItems != null) { for (OrderItem item : orderItems) { %>
                    <tr>
                        <td>
                            <div style="display:flex;align-items:center;gap:12px;">
                                <img src="<%= request.getContextPath() %>/<%= item.getP_image_path() %>"
                                     alt="<%= item.getP_name() %>" class="product-img"
                                     onerror="this.src='<%= request.getContextPath() %>/images/no-image.png'">
                                <strong><%= item.getP_name() %></strong>
                            </div>
                        </td>
                        <td style="font-size:0.78rem;color:var(--text-light);text-transform:uppercase;"><%= item.getP_category() %></td>
                        <td class="text-right">&#8377;<%= String.format("%.2f", item.getUnit_price()) %></td>
                        <td class="text-right"><%= item.getQuantity() %></td>
                        <td class="text-right price-col">&#8377;<%= String.format("%.2f", item.getSubtotal()) %></td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>

            <div class="receipt-totals">
                <div class="total-row">
                    <span class="t-label">Subtotal</span>
                    <span class="t-value">&#8377;<%= String.format("%.2f", order.getTotal_amount()) %></span>
                </div>
                <div class="total-row">
                    <span class="t-label">Shipping</span>
                    <span class="t-value">
                        <% if (shipping == 0) { %><span style="color:var(--success);">FREE</span>
                        <% } else { %>&#8377;<%= String.format("%.2f", shipping) %><% } %>
                    </span>
                </div>
                <div class="grand-row">
                    <span class="t-label">Grand Total</span>
                    <span class="t-value">&#8377;<%= String.format("%.2f", grandTotal) %></span>
                </div>
            </div>

            <div style="margin-top:24px;padding-top:14px;border-top:1px dashed var(--border);
                        text-align:center;font-size:0.78rem;color:var(--text-light);">
                &#10084; Thank you for supporting Women SHG members! | SakhiMart &bull; support@sakhimart.com
            </div>
        </div>
    </div>

    <div class="action-row no-print">
        <button class="btn-download" onclick="downloadReceiptAsPDF()">&#128229; Download Receipt (PDF)</button>
        <button class="btn-print" onclick="window.print()">&#128438; Print Receipt</button>
        <a href="<%= request.getContextPath() %>/OrderServlet?action=myOrders" class="btn btn-secondary">&#8592; My Orders</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="btn btn-primary">&#128722; Shop More</a>
    </div>

</div>

<%@ include file="../common/footer.jsp" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script>
async function downloadReceiptAsPDF() {
    const btn = document.querySelector('.btn-download');
    btn.textContent = '⏳ Generating...';
    btn.disabled = true;
    try {
        const { jsPDF } = window.jspdf;
        const receipt = document.getElementById('receiptCard');
        const canvas  = await html2canvas(receipt, { scale: 2, useCORS: true, backgroundColor: '#ffffff' });
        const imgData = canvas.toDataURL('image/png');
        const pdf     = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
        const pw      = pdf.internal.pageSize.getWidth();
        const ph      = pdf.internal.pageSize.getHeight();
        const iw      = pw - 20;
        const ih      = (canvas.height * iw) / canvas.width;
        if (ih <= ph - 20) {
            pdf.addImage(imgData, 'PNG', 10, 10, iw, ih);
        } else {
            let remaining = ih, srcY = 0;
            while (remaining > 0) {
                const sliceH = Math.min(ph - 20, remaining);
                const srcH   = (sliceH * canvas.height) / ih;
                const sc = document.createElement('canvas');
                sc.width = canvas.width; sc.height = srcH;
                sc.getContext('2d').drawImage(canvas, 0, srcY, canvas.width, srcH, 0, 0, canvas.width, srcH);
                if (srcY > 0) pdf.addPage();
                pdf.addImage(sc.toDataURL('image/png'), 'PNG', 10, 10, iw, sliceH);
                srcY += srcH; remaining -= sliceH;
            }
        }
        pdf.save('SakhiMart_Order_<%= order.getOrder_id() %>_Receipt.pdf');
    } catch(e) { alert('PDF failed. Use Print instead.'); }
    btn.innerHTML = '&#128229; Download Receipt (PDF)';
    btn.disabled = false;
}
</script>
</body>
</html>
