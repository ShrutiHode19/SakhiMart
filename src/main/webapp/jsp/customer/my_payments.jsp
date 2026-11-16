<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Payment" %>
<%
    if (session.getAttribute("c_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    String msg = request.getParameter("msg");
    boolean isEmpty = (payments == null || payments.isEmpty());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Payments &amp; Delivery – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        /* ── Page Layout ── */
        .pay-wrap {
            max-width: 1000px;
            margin: 28px auto;
            padding: 0 18px;
        }

        /* ── Summary Pills ── */
        .pay-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 14px;
            margin-bottom: 26px;
        }
        .pay-pill {
            background: var(--bg-card);
            border-radius: var(--radius-md);
            padding: 18px 16px;
            text-align: center;
            box-shadow: var(--shadow-xs);
            border-top: 4px solid var(--border);
        }
        .pay-pill.green  { border-top-color: var(--success); }
        .pay-pill.orange { border-top-color: var(--accent); }
        .pay-pill.red    { border-top-color: var(--danger); }
        .pay-pill.blue   { border-top-color: var(--info); }
        .pill-val  { font-size: 1.8rem; font-weight: 900; color: var(--text-dark); line-height: 1; }
        .pill-lbl  { font-size: 0.74rem; text-transform: uppercase; letter-spacing: 0.5px;
                     color: var(--text-light); font-weight: 700; margin-top: 5px; }
        .pay-pill.green .pill-val  { color: var(--success); }
        .pay-pill.orange .pill-val { color: var(--accent); }
        .pay-pill.red .pill-val    { color: var(--danger); }

        /* ── Card container ── */
        .pay-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            margin-bottom: 16px;
            border: 1px solid var(--border-light);
            transition: box-shadow var(--transition), transform var(--transition);
        }
        .pay-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); }

        /* ── Card header ribbon ── */
        .pay-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            padding: 14px 22px;
            background: var(--primary-bg);
            border-bottom: 1px solid var(--border-light);
        }
        .pay-order-id {
            font-weight: 900;
            font-size: 1rem;
            color: var(--primary);
        }
        .pay-date {
            font-size: 0.8rem;
            color: var(--text-light);
        }

        /* ── Card body grid ── */
        .pay-card-body {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 0;
            align-items: center;
        }
        @media (max-width: 700px) {
            .pay-card-body { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 420px) {
            .pay-card-body { grid-template-columns: 1fr; }
        }

        .pay-cell {
            padding: 16px 22px;
            border-right: 1px solid var(--border-light);
        }
        .pay-cell:last-child { border-right: none; }
        .pay-cell-label {
            font-size: 0.72rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
            font-weight: 700;
            margin-bottom: 5px;
        }
        .pay-cell-value {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--text-dark);
        }
        .pay-amount { font-size: 1.15rem; color: var(--primary); font-weight: 900; }

        /* ── Status Badges ── */
        .badge-completed { background: var(--success-bg);  color: var(--success); border: 1px solid var(--success-border); }
        .badge-pending   { background: var(--warning-bg);  color: var(--warning); border: 1px solid var(--warning-border); }
        .badge-failed    { background: var(--danger-bg);   color: var(--danger);  border: 1px solid var(--danger-border);  }
        .badge-delivered { background: var(--success-bg);  color: var(--success); border: 1px solid var(--success-border); }
        .badge-shipped   { background: var(--accent-bg);   color: var(--accent);  border: 1px solid #f5cba7; }
        .badge-confirmed { background: var(--info-bg);     color: var(--info);    border: 1px solid var(--info-border);    }
        .badge-cancelled { background: var(--danger-bg);   color: var(--danger);  border: 1px solid var(--danger-border);  }
        .badge-pending-order { background: var(--warning-bg); color: var(--warning); border: 1px solid var(--warning-border); }

        /* ── Delivery mini-timeline inside card ── */
        .delivery-track {
            display: flex;
            align-items: center;
            gap: 0;
            padding: 10px 22px 14px;
            border-top: 1px solid var(--border-light);
            overflow-x: auto;
        }
        .track-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 4px;
            min-width: 70px;
        }
        .track-dot {
            width: 22px; height: 22px;
            border-radius: 50%;
            background: var(--border);
            border: 2px solid #fff;
            box-shadow: 0 0 0 2px var(--border);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.6rem;
            color: #fff;
            font-weight: 900;
            transition: background 0.3s;
        }
        .track-dot.done   { background: var(--success); box-shadow: 0 0 0 2px var(--success); }
        .track-dot.active { background: var(--primary); box-shadow: 0 0 0 2px var(--primary);
                            animation: pulse 1.8s infinite; }
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 2px var(--primary); }
            50%       { box-shadow: 0 0 0 5px rgba(192,57,43,0.25); }
        }
        .track-label {
            font-size: 0.64rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            color: var(--text-light);
            text-align: center;
        }
        .track-label.done-lbl   { color: var(--success); }
        .track-label.active-lbl { color: var(--primary); }
        .track-line {
            flex: 1;
            height: 2px;
            background: var(--border-light);
            min-width: 20px;
            margin-bottom: 18px;
        }
        .track-line.done { background: var(--success); }

        /* ── Txn ID display ── */
        .txn-chip {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: var(--bg-page);
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 4px 10px;
            font-size: 0.76rem;
            font-family: monospace;
            color: var(--text-mid);
            max-width: 180px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* ── Empty state ── */
        .empty-pay {
            text-align: center;
            padding: 60px 20px;
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-xs);
        }
        .empty-pay .empty-icon { font-size: 3rem; margin-bottom: 12px; }
        .empty-pay h3 { font-family: 'Playfair Display', serif; color: var(--text-dark); margin-bottom: 8px; }
        .empty-pay p  { color: var(--text-light); font-size: 0.9rem; margin-bottom: 20px; }

        /* ── Section heading ── */
        .section-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .section-head h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.35rem;
            color: var(--text-dark);
        }

        .flash-bar { max-width: 1000px; margin: 16px auto 0; padding: 0 18px; }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128179; My Payments &amp; Delivery</h2>
</div>

<!-- Flash Messages -->
<div class="flash-bar">
    <% if ("notfound".equals(msg)) { %>
        <div class="alert alert-error">&#10005; Payment record not found.</div>
    <% } %>
</div>

<div class="pay-wrap">

    <!-- ── Summary Pills ── -->
    <%
        int totalPay = isEmpty ? 0 : payments.size();
        int completedPay = 0, pendingPay = 0, failedPay = 0;
        int deliveredCount = 0;
        double totalSpent = 0;
        if (!isEmpty) {
            for (Payment p : payments) {
                if ("Completed".equals(p.getPayment_status())) { completedPay++; totalSpent += p.getPayment_amount(); }
                else if ("Pending".equals(p.getPayment_status()))  pendingPay++;
                else if ("Failed".equals(p.getPayment_status()))   failedPay++;
                if ("Delivered".equals(p.getO_status())) deliveredCount++;
            }
        }
    %>
    <div class="pay-summary">
        <div class="pay-pill blue">
            <div class="pill-val"><%= totalPay %></div>
            <div class="pill-lbl">Total Orders</div>
        </div>
        <div class="pay-pill green">
            <div class="pill-val"><%= completedPay %></div>
            <div class="pill-lbl">Paid</div>
        </div>
        <div class="pay-pill orange">
            <div class="pill-val"><%= pendingPay %></div>
            <div class="pill-lbl">Pending</div>
        </div>
        <div class="pay-pill green">
            <div class="pill-val"><%= deliveredCount %></div>
            <div class="pill-lbl">Delivered</div>
        </div>
        <div class="pay-pill green" style="border-top-color:var(--primary);">
            <div class="pill-val" style="font-size:1.2rem; color:var(--primary);">&#8377;<%= String.format("%.0f", totalSpent) %></div>
            <div class="pill-lbl">Total Spent</div>
        </div>
    </div>

    <!-- ── Section Heading ── -->
    <div class="section-head">
        <h2>&#128233; Payment History</h2>
        <a href="<%= request.getContextPath() %>/OrderServlet?action=myOrders" class="btn btn-secondary btn-sm">
            &#128203; View Orders
        </a>
    </div>

    <!-- ── Payment Cards ── -->
    <% if (isEmpty) { %>
        <div class="empty-pay">
            <div class="empty-icon">&#128179;</div>
            <h3>No Payments Yet</h3>
            <p>Your payment and delivery records will appear here after you place an order.</p>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="btn btn-primary">
                &#128722; Start Shopping
            </a>
        </div>
    <% } else { %>
        <% for (Payment pay : payments) {
            String ps = pay.getPayment_status() != null ? pay.getPayment_status() : "Pending";
            String ds = pay.getO_status()        != null ? pay.getO_status()        : "Pending";
            String psBadge = ps.toLowerCase();
            String dsBadge = ds.toLowerCase().replace(" ", "-");
            if ("pending".equals(dsBadge)) dsBadge = "pending-order";

            // Track which steps are done
            boolean orderDone     = true;
            boolean confirmedDone = !"Pending".equals(ds);
            boolean shippedDone   = "Shipped".equals(ds) || "Delivered".equals(ds);
            boolean deliveredDone = "Delivered".equals(ds);
            boolean isCancelled   = "Cancelled".equals(ds);

            String confirmedClass = confirmedDone ? "done" : (!"Pending".equals(ds) ? "active" : "");
            String shippedClass   = shippedDone   ? "done" : ("Confirmed".equals(ds) ? "active" : "");
            String deliveredClass = deliveredDone  ? "done" : ("Shipped".equals(ds)   ? "active" : "");

            String line1Class = confirmedDone ? "done" : "";
            String line2Class = shippedDone   ? "done" : "";
            String line3Class = deliveredDone  ? "done" : "";
        %>
        <div class="pay-card">

            <!-- Card Header -->
            <div class="pay-card-header">
                <div>
                    <span class="pay-order-id">&#128179; Order #<%= pay.getO_id() %></span>
                    <span style="margin-left:12px; font-size:0.8rem; color:var(--text-light);">Payment #<%= pay.getPayment_id() %></span>
                </div>
                <span class="pay-date">&#128336; <%= pay.getPayment_date() != null ? pay.getPayment_date() : "—" %></span>
            </div>

            <!-- Card Body Grid -->
            <div class="pay-card-body">

                <!-- Amount -->
                <div class="pay-cell">
                    <div class="pay-cell-label">&#128181; Amount</div>
                    <div class="pay-amount">&#8377;<%= String.format("%.2f", pay.getPayment_amount()) %></div>
                </div>

                <!-- Method -->
                <div class="pay-cell">
                    <div class="pay-cell-label">&#128242; Method</div>
                    <div class="pay-cell-value">
                        <% if ("UPI".equals(pay.getPayment_method())) { %>
                            &#128242; UPI
                        <% } else if ("Online".equals(pay.getPayment_method())) { %>
                            &#128179; Online Transfer
                        <% } else { %>
                            &#128181; Cash on Delivery
                        <% } %>
                    </div>
                </div>

                <!-- Payment Status -->
                <div class="pay-cell">
                    <div class="pay-cell-label">&#10003; Payment Status</div>
                    <div>
                        <span class="badge badge-<%= psBadge %>">
                            <% if ("Completed".equals(ps)) { %>&#10003;<% } else if ("Failed".equals(ps)) { %>&#10005;<% } else { %>&#9679;<% } %>
                            <%= ps %>
                        </span>
                    </div>
                    <% if (pay.getTransaction_id() != null && !pay.getTransaction_id().isEmpty()) { %>
                    <div style="margin-top:6px;">
                        <span class="txn-chip">&#128203; <%= pay.getTransaction_id() %></span>
                    </div>
                    <% } %>
                </div>

                <!-- Delivery Status -->
                <div class="pay-cell">
                    <div class="pay-cell-label">&#128666; Delivery</div>
                    <div>
                        <span class="badge badge-<%= dsBadge %>">
                            <%= isCancelled ? "&#10005;" : (deliveredDone ? "&#10003;" : "&#9679;") %>
                            <%= ds %>
                        </span>
                    </div>
                    <% if (pay.getDelivery_date() != null && deliveredDone) { %>
                    <div style="font-size:0.75rem; color:var(--text-light); margin-top:4px;">
                        Delivered: <%= pay.getDelivery_date() %>
                    </div>
                    <% } %>
                </div>

            </div>

            <!-- Mini Delivery Timeline -->
            <% if (!isCancelled) { %>
            <div class="delivery-track">
                <div class="track-step">
                    <div class="track-dot done">&#10003;</div>
                    <div class="track-label done-lbl">Placed</div>
                </div>
                <div class="track-line <%= confirmedDone ? "done" : "" %>"></div>
                <div class="track-step">
                    <div class="track-dot <%= confirmedDone ? "done" : ("Pending".equals(ds) ? "active" : "") %>">
                        <%= confirmedDone ? "✓" : "2" %>
                    </div>
                    <div class="track-label <%= confirmedDone ? "done-lbl" : ("Pending".equals(ds) ? "active-lbl" : "") %>">Confirmed</div>
                </div>
                <div class="track-line <%= shippedDone ? "done" : "" %>"></div>
                <div class="track-step">
                    <div class="track-dot <%= shippedDone ? "done" : ("Confirmed".equals(ds) ? "active" : "") %>">
                        <%= shippedDone ? "✓" : "3" %>
                    </div>
                    <div class="track-label <%= shippedDone ? "done-lbl" : ("Confirmed".equals(ds) ? "active-lbl" : "") %>">Shipped</div>
                </div>
                <div class="track-line <%= deliveredDone ? "done" : "" %>"></div>
                <div class="track-step">
                    <div class="track-dot <%= deliveredDone ? "done" : ("Shipped".equals(ds) ? "active" : "") %>">
                        <%= deliveredDone ? "✓" : "4" %>
                    </div>
                    <div class="track-label <%= deliveredDone ? "done-lbl" : ("Shipped".equals(ds) ? "active-lbl" : "") %>">Delivered</div>
                </div>
            </div>
            <% } else { %>
            <div class="delivery-track">
                <span style="color:var(--danger); font-size:0.85rem; font-weight:700;">&#10005; This order was cancelled.</span>
            </div>
            <% } %>

        </div><!-- /.pay-card -->
        <% } %>
    <% } %>

    <!-- Bottom nav -->
    <div style="display:flex; gap:14px; flex-wrap:wrap; margin: 8px 0 36px;">
        <a href="<%= request.getContextPath() %>/OrderServlet?action=myOrders"
           class="btn btn-secondary">&#128203; My Orders</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
           class="btn btn-primary">&#128722; Continue Shopping</a>
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
}, 5000);
</script>

</body>
</html>
