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

    double shipping = order.getTotal_amount() < 500 ? 50.0 : 0.0;
    double grandTotal = order.getTotal_amount() + shipping;

    String payMethod = order.getPayment_method();
    boolean isCOD = "COD".equalsIgnoreCase(payMethod);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
 

        .confirm-wrap {
            max-width: 840px;
            margin: 28px auto;
            padding: 0 18px 48px;
        }

        /* ── Steps ── */
        .checkout-steps {
            display: flex;
            align-items: center;
            max-width: 840px;
            margin: 20px auto 0;
            padding: 0 18px;
        }
        .step {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.85rem; font-weight: 700; color: var(--text-light);
        }
        .step.active { color: var(--primary); }
        .step.done   { color: var(--success); }
        .step-num {
            width: 30px; height: 30px;
            border-radius: 50%;
            background: var(--border-light);
            border: 2px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            font-weight: 800; font-size: 0.82rem;
        }
        .step.active .step-num {
            background: var(--primary); border-color: var(--primary); color: #fff;
            box-shadow: 0 2px 10px rgba(139,21,32,0.35);
        }
        .step.done .step-num {
            background: var(--success); border-color: var(--success); color: #fff;
        }
        .step-line {
            flex: 1; height: 2px;
            background: linear-gradient(90deg, var(--border), var(--border-light));
            margin: 0 8px; min-width: 36px;
        }

        /* ── Success Banner ── */
        .success-banner {
            background: linear-gradient(135deg, #14602e 0%, var(--success) 60%, #27ae72 100%);
            border-radius: var(--radius-lg);
            padding: 36px 28px;
            text-align: center;
            color: #fff;
            margin-bottom: 24px;
            margin-top: 24px;
            box-shadow: 0 8px 32px rgba(30,132,73,0.35);
            position: relative;
            overflow: hidden;
        }
        .success-banner::before {
            content: '';
            position: absolute;
            top: -60px; right: -60px;
            width: 180px; height: 180px;
            border-radius: 50%;
            background: rgba(255,255,255,0.07);
        }
        .success-banner .check-icon {
            font-size: 3.8rem;
            margin-bottom: 12px;
            display: block;
        }
        .success-banner h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.9rem;
            color: #fff;
            margin-bottom: 8px;
            font-weight: 800;
        }
        .success-banner p { color: rgba(255,255,255,0.9); font-size: 0.97rem; }
        .order-id-badge {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            border: 2px solid rgba(255,255,255,0.45);
            border-radius: var(--radius-pill);
            padding: 7px 26px;
            margin-top: 16px;
            font-weight: 900;
            font-size: 1.05rem;
            letter-spacing: 1.5px;
        }

        /* ── Receipt Card ── */
        .receipt-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            overflow: hidden;
            margin-bottom: 20px;
            border: 1px solid var(--border-light);
        }
        .receipt-header {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 60%, var(--primary-light) 100%);
            padding: 20px 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid rgba(201,144,32,0.4);
        }
        .receipt-header h3 {
            font-family: 'Playfair Display', serif;
            color: #fff;
            font-size: 1.2rem;
            font-weight: 800;
        }
        .receipt-header .receipt-date {
            color: rgba(255,255,255,0.75);
            font-size: 0.8rem;
            margin-top: 3px;
        }

        /* ── Receipt Body ── */
        .receipt-body { padding: 26px 28px; }

        /* Meta info grid */
        .receipt-meta {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 28px;
        }
        @media (max-width: 600px) { .receipt-meta { grid-template-columns: 1fr; } }

        .meta-box {
            background: var(--primary-bg);
            border-radius: var(--radius-md);
            padding: 14px 16px;
            border-left: 4px solid var(--primary);
            border: 1px solid var(--border-light);
            border-left: 4px solid var(--primary);
        }
        .meta-box.delivery-box { border-left-color: var(--gold); }
        .meta-box.payment-box  { border-left-color: var(--success); }

        .meta-label {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.9px;
            color: var(--text-light);
            font-weight: 800;
            margin-bottom: 6px;
        }
        .meta-value {
            font-size: 0.93rem;
            font-weight: 700;
            color: var(--text-dark);
        }

        /* ── Items Table ── */
        .items-section-title {
            font-weight: 800;
            font-size: 0.88rem;
            color: var(--text-dark);
            text-transform: uppercase;
            letter-spacing: 0.6px;
            margin-bottom: 14px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--gold-border);
        }
        .receipt-table { width: 100%; border-collapse: collapse; }
        .receipt-table th {
            text-align: left;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-light);
            font-weight: 800;
            padding: 10px 8px;
            border-bottom: 2px solid var(--border);
            background: var(--bg-page);
        }
        .receipt-table td {
            padding: 14px 8px;
            font-size: 0.88rem;
            border-bottom: 1px solid var(--border-light);
            color: var(--text-dark);
            vertical-align: middle;
        }
        .receipt-table tr:last-child td { border-bottom: none; }
        .receipt-table tr:hover td { background: var(--primary-bg); }

        .receipt-table .product-img {
            width: 52px; height: 52px;
            object-fit: cover;
            border-radius: var(--radius-sm);
            border: 2px solid var(--border);
            box-shadow: var(--shadow-xs);
        }
        .receipt-table .product-name { font-weight: 700; color: var(--text-dark); }
        .receipt-table .product-cat {
            display: inline-block;
            font-size: 0.7rem;
            color: var(--gold-dark);
            background: var(--gold-bg);
            border: 1px solid var(--gold-border);
            text-transform: uppercase;
            letter-spacing: 0.4px;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: var(--radius-pill);
        }
        .receipt-table .text-right { text-align: right; }
        .receipt-table .price-col  { font-weight: 800; color: var(--primary); }

        /* ── Totals ── */
        .receipt-totals {
            margin-top: 18px;
            border-top: 2px solid var(--gold-border);
            padding-top: 18px;
        }
        .total-row {
            display: flex;
            justify-content: space-between;
            padding: 6px 0;
            font-size: 0.88rem;
            color: var(--text-mid);
        }
        .total-row .t-label { font-weight: 600; }
        .total-row .t-value { font-weight: 700; color: var(--text-dark); }
        .grand-row {
            display: flex;
            justify-content: space-between;
            padding: 14px 18px;
            background: var(--primary-bg);
            border-radius: var(--radius-md);
            border: 1px solid var(--primary-border);
            margin-top: 10px;
        }
        .grand-row .t-label { font-size: 1.05rem; font-weight: 800; color: var(--text-dark); }
        .grand-row .t-value { font-size: 1.3rem; font-weight: 900; color: var(--primary); }

        /* ── Payment instruction ── */
        .payment-instruction {
            background: var(--gold-bg);
            border: 1px solid var(--gold-border);
            border-left: 4px solid var(--gold);
            border-radius: var(--radius-md);
            padding: 14px 18px;
            margin-top: 20px;
            font-size: 0.87rem;
            color: var(--gold-dark);
            font-weight: 600;
        }
        .payment-instruction strong { display: block; margin-bottom: 5px; color: var(--gold-dark); font-weight: 800; }

        /* ── Status Badges ── */
        .status-badge {
            display: inline-block;
            padding: 3px 12px;
            border-radius: var(--radius-pill);
            font-size: 0.76rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .badge-pending    { background: var(--warning-bg);  color: var(--warning);  border: 1px solid var(--warning-border); }
        .badge-confirmed  { background: var(--success-bg);  color: var(--success);  border: 1px solid var(--success-border); }
        .badge-shipped    { background: var(--info-bg);     color: var(--info);     border: 1px solid var(--info-border); }
        .badge-delivered  { background: var(--success-bg);  color: var(--success);  border: 1px solid var(--success-border); }
        .badge-cancelled  { background: var(--danger-bg);   color: var(--danger);   border: 1px solid var(--danger-border); }
        .badge-processing { background: var(--gold-bg);     color: var(--gold-dark);border: 1px solid var(--gold-border); }
        .badge-paid       { background: var(--success-bg);  color: var(--success);  border: 1px solid var(--success-border); }

        /* ── Action Buttons ── */
        .action-row {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 22px;
        }
        .btn-download {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, var(--gold-dark), var(--gold));
            color: #fff;
            padding: 11px 22px;
            border-radius: var(--radius-pill);
            font-weight: 700;
            font-size: 0.9rem;
            text-decoration: none;
            border: none;
            cursor: pointer;
            box-shadow: var(--shadow-gold);
            transition: all var(--tr);
        }
        .btn-download:hover {
            transform: translateY(-2px);
            filter: brightness(1.1);
            box-shadow: 0 8px 24px rgba(201,144,32,0.45);
            color: #fff;
        }
        .btn-print {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: var(--bg-card);
            color: var(--text-dark);
            padding: 11px 22px;
            border-radius: var(--radius-pill);
            font-weight: 700;
            font-size: 0.9rem;
            text-decoration: none;
            border: 2px solid var(--border);
            cursor: pointer;
            transition: all var(--tr);
        }
        .btn-print:hover {
            border-color: var(--primary);
            color: var(--primary);
            background: var(--primary-bg);
            transform: translateY(-2px);
        }

        /* ── Print Styles ── */
        @media print {
            body * { visibility: hidden; }
            .receipt-card, .receipt-card * { visibility: visible; }
            .receipt-card { position: absolute; left: 0; top: 0; width: 100%; box-shadow: none; border: none; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<!-- Page Header -->
<div class="page-header no-print">
    <h2>&#9989; Order Confirmed</h2>
</div>

<!-- Steps -->
<div class="checkout-steps no-print">
    <div class="step done"><div class="step-num">&#10003;</div> Cart</div>
    <div class="step-line"></div>
    <div class="step done"><div class="step-num">&#10003;</div> Checkout</div>
    <div class="step-line"></div>
    <div class="step active"><div class="step-num">3</div> Confirmation</div>
</div>

<div class="confirm-wrap">

    <!-- ── Success Banner ── -->
    <div class="success-banner no-print" style="margin-top:24px;">
        <span class="check-icon">&#127881;</span>
        <h2>Order Placed Successfully!</h2>
        <p>Thank you for shopping at SakhiMart. Your order has been received.</p>
        <div class="order-id-badge">Order #<%= order.getOrder_id() %></div>
    </div>

    <!-- 
         RECEIPT CARD (this is what gets printed / downloaded)
   -->
    <div class="receipt-card" id="receiptCard">
        <div class="receipt-header">
            <div>
                <h3>&#128203; Order Receipt</h3>
                <div class="receipt-date">
                    SakhiMart &bull; <%= order.getOrder_date() != null ? order.getOrder_date().toString().substring(0,16) : "N/A" %>
                </div>
            </div>
            <div style="text-align:right;">
                <div style="color:#fff; font-weight:800; font-size:1.05rem;">
                    Order #<%= order.getOrder_id() %>
                </div>
                <div class="receipt-date">Women Self-Help Group</div>
            </div>
        </div>

        <div class="receipt-body">

            <!-- Meta Info Grid -->
            <div class="receipt-meta">

                <!-- Customer Info -->
                <div class="meta-box">
                    <div class="meta-label">&#128100; Customer Details</div>
                    <div class="meta-value"><%= order.getC_fullname() != null ? order.getC_fullname() : session.getAttribute("c_name") %></div>
                    <% if (order.getC_contact() != null && !order.getC_contact().equals("0")) { %>
                        <div style="font-size:0.82rem; color:var(--text-light); margin-top:3px;">&#128222; <%= order.getC_contact() %></div>
                    <% } %>
                    <% if (order.getC_email() != null) { %>
                        <div style="font-size:0.82rem; color:var(--text-light);">&#9993; <%= order.getC_email() %></div>
                    <% } %>
                </div>

                <!-- Order Info -->
                <div class="meta-box">
                    <div class="meta-label">&#128203; Order Info</div>
                    <div class="meta-value">Order Date: <%= order.getOrder_date() != null ? order.getOrder_date().toString().substring(0,10) : "N/A" %></div>
                    <div style="margin-top:5px;">
                        Payment Status:
                        <span class="status-badge badge-<%= order.getPayment_status().toLowerCase() %>">
                            <%= order.getPayment_status() %>
                        </span>
                    </div>
                    <div style="margin-top:5px;">
                        Delivery:
                        <span class="status-badge badge-<%= order.getDelivery_status().toLowerCase() %>">
                            <%= order.getDelivery_status() %>
                        </span>
                    </div>
                </div>

                <!-- Delivery Address -->
                <div class="meta-box delivery-box">
                    <div class="meta-label">&#128205; Delivery Address</div>
                    <div class="meta-value"><%= order.getDelivery_address() %></div>
                </div>

                <!-- Payment Method -->
                <div class="meta-box payment-box">
                    <div class="meta-label">&#128179; Payment Method</div>
                    <div class="meta-value"><%= order.getPayment_method() %></div>
                    <div style="font-size:0.82rem; color:var(--text-light); margin-top:4px;">
                        <% if ("COD".equals(order.getPayment_method())) { %>
                            Pay at the time of delivery
                        <% } else if ("UPI".equals(order.getPayment_method())) { %>
                            UPI transfer – confirm with admin
                        <% } else { %>
                            Online / Card payment
                        <% } %>
                    </div>
                </div>

            </div><!-- /.receipt-meta -->

            <!-- ── Ordered Items ── -->
            <div class="items-section-title">&#128722; Items Ordered</div>
            <table class="receipt-table">
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Category</th>
                        <th class="text-right">Unit Price</th>
                        <th class="text-right">Qty</th>
                        <th class="text-right">Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (orderItems != null) {
                       for (OrderItem item : orderItems) { %>
                    <tr>
                        <td>
                            <div style="display:flex; align-items:center; gap:12px;">
                                <img src="<%= request.getContextPath() %>/<%= item.getP_image_path() %>"
                                     alt="<%= item.getP_name() %>"
                                     class="product-img"
                                     onerror="this.src='<%= request.getContextPath() %>/images/no-image.png'">
                                <div>
                                    <div class="product-name"><%= item.getP_name() %></div>
                                </div>
                            </div>
                        </td>
                        <td><span class="product-cat"><%= item.getP_category() %></span></td>
                        <td class="text-right">&#8377;<%= String.format("%.2f", item.getUnit_price()) %></td>
                        <td class="text-right"><%= item.getQuantity() %></td>
                        <td class="text-right price-col">&#8377;<%= String.format("%.2f", item.getSubtotal()) %></td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>

            <!-- ── Totals ── -->
            <div class="receipt-totals">
                <div class="total-row">
                    <span class="t-label">Subtotal</span>
                    <span class="t-value">&#8377;<%= String.format("%.2f", order.getTotal_amount()) %></span>
                </div>
                <div class="total-row">
                    <span class="t-label">Shipping</span>
                    <span class="t-value">
                        <% if (shipping == 0) { %>
                            <span style="color:var(--success);">FREE</span>
                        <% } else { %>
                            &#8377;<%= String.format("%.2f", shipping) %>
                        <% } %>
                    </span>
                </div>
                <div class="grand-row">
                    <span class="t-label">Grand Total</span>
                    <span class="t-value">&#8377;<%= String.format("%.2f", grandTotal) %></span>
                </div>
            </div>

            <!-- Payment instruction for pending methods -->
            <% if (isCOD) { %>
            <div class="payment-instruction">
                <strong>&#128181; Cash on Delivery Instructions</strong>
                Please keep &#8377;<%= String.format("%.2f", grandTotal) %> ready at the time of delivery.
                Our delivery partner will collect the payment.
            </div>
            <% } else if ("UPI".equals(payMethod)) { %>
            <div class="payment-instruction">
                <strong>&#128242; UPI Payment Instructions</strong>
                Transfer &#8377;<%= String.format("%.2f", grandTotal) %> to our UPI ID:
                <strong>sakhimart@upi</strong> and share the transaction reference.
                Payment will be confirmed within 24 hours.
            </div>
            <% } %>

            <!-- Footer on receipt -->
            <div style="margin-top:28px; padding-top:18px; border-top:1px dashed var(--border);
                        text-align:center; font-size:0.78rem; color:var(--text-light);">
                &#10084; Thank you for supporting Women Self-Help Group members! |
                SakhiMart &bull; support@sakhimart.com
            </div>

        </div><!-- /.receipt-body -->
    </div><!-- /.receipt-card -->

    <!-- ── Action Buttons ── -->
    <div class="action-row no-print">
        <button class="btn-download" onclick="downloadReceiptAsPDF()">
            &#128229; Download Receipt (PDF)
        </button>
        <button class="btn-print" onclick="window.print()">
            &#128438; Print Receipt
        </button>
        <a href="<%= request.getContextPath() %>/OrderServlet?action=myOrders"
           class="btn btn-secondary">
            &#128203; My Orders
        </a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
           class="btn btn-primary">
            &#128722; Continue Shopping
        </a>
    </div>

</div><!-- /.confirm-wrap -->

<%@ include file="../common/footer.jsp" %>

<!-- jsPDF for client-side PDF generation -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script>
async function downloadReceiptAsPDF() {
    const btn = document.querySelector('.btn-download');
    btn.textContent = '⏳ Generating PDF...';
    btn.disabled = true;

    try {
        const { jsPDF } = window.jspdf;
        const receipt = document.getElementById('receiptCard');

        const canvas = await html2canvas(receipt, {
            scale: 2,
            useCORS: true,
            backgroundColor: '#ffffff',
            logging: false
        });

        const imgData = canvas.toDataURL('image/png');
        const pdf = new jsPDF({
            orientation: 'portrait',
            unit: 'mm',
            format: 'a4'
        });

        const pageWidth  = pdf.internal.pageSize.getWidth();
        const pageHeight = pdf.internal.pageSize.getHeight();
        const imgWidth   = pageWidth - 20; // 10mm margin each side
        const imgHeight  = (canvas.height * imgWidth) / canvas.width;

        let yPos = 10;

     
        if (imgHeight <= pageHeight - 20) {
            pdf.addImage(imgData, 'PNG', 10, yPos, imgWidth, imgHeight);
        } else {
            let remaining = imgHeight;
            let srcY = 0;
            while (remaining > 0) {
                const sliceH = Math.min(pageHeight - 20, remaining);
                const srcH   = (sliceH * canvas.height) / imgHeight;
                const sliceCanvas = document.createElement('canvas');
                sliceCanvas.width  = canvas.width;
                sliceCanvas.height = srcH;
                const ctx = sliceCanvas.getContext('2d');
                ctx.drawImage(canvas, 0, srcY, canvas.width, srcH, 0, 0, canvas.width, srcH);
                if (srcY > 0) pdf.addPage();
                pdf.addImage(sliceCanvas.toDataURL('image/png'), 'PNG', 10, 10, imgWidth, sliceH);
                srcY      += srcH;
                remaining -= sliceH;
            }
        }

        pdf.save('SakhiMart_Order_<%= order.getOrder_id() %>_Receipt.pdf');
        btn.innerHTML = '&#128229; Download Receipt (PDF)';
        btn.disabled = false;

    } catch (err) {
        console.error('PDF error:', err);
        btn.innerHTML = '&#128229; Download Receipt (PDF)';
        btn.disabled = false;
        alert('PDF download failed. Please use the Print option instead.');
    }
}


</script>

</body>
</html>
