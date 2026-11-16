<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Order" %>
<%
    /* ── Session guard ── */
    if (session.getAttribute("m_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    List<Order> orders = (List<Order>) request.getAttribute("orders");
    boolean isEmpty = (orders == null || orders.isEmpty());

    String m_fullname = (String) session.getAttribute("m_fullname");
    if (m_fullname == null) m_fullname = "Member";

    /* ── Compute summary counts ── */
    int total      = isEmpty ? 0 : orders.size();
    int pending    = 0, confirmed = 0, shipped = 0, delivered = 0, cancelled = 0;
    double revenue = 0;
    if (!isEmpty) {
        for (Order o : orders) {
            String ds = o.getDelivery_status() != null ? o.getDelivery_status() : "Pending";
            if ("Pending".equals(ds))   pending++;
            if ("Confirmed".equals(ds)) confirmed++;
            if ("Shipped".equals(ds))   shipped++;
            if ("Delivered".equals(ds)) { delivered++; revenue += o.getTotal_amount(); }
            if ("Cancelled".equals(ds)) cancelled++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Product Orders – SakhiMart Member</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
    /* ════════════════════════════════════════════════════
       MEMBER ORDERS PAGE — Maroon & Gold Theme
    ════════════════════════════════════════════════════ */

        .orders-wrap {
            max-width: 1060px;
            margin: 28px auto;
            padding: 0 18px 48px;
        }

        /* ── Welcome Banner ── */
        .member-banner {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 60%, var(--primary-light) 100%);
            border-radius: var(--radius-lg);
            padding: 26px 30px;
            color: #fff;
            margin-bottom: 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            box-shadow: var(--shadow-primary);
            border-bottom: 3px solid rgba(201,144,32,0.5);
            position: relative;
            overflow: hidden;
        }
        .member-banner::after {
            content: '📦';
            position: absolute;
            right: 180px; top: 50%;
            transform: translateY(-50%);
            font-size: 5rem;
            opacity: 0.07;
        }
        .member-banner h2 {
            font-family: 'Playfair Display', serif;
            color: #fff;
            font-size: 1.45rem;
            margin-bottom: 5px;
            font-weight: 800;
        }
        .member-banner p { color: rgba(255,255,255,0.82); font-size: 0.88rem; line-height: 1.5; }

        .banner-stats { display: flex; gap: 26px; flex-wrap: wrap; flex-shrink: 0; }
        .banner-stat  { text-align: center; }
        .banner-stat .bval {
            font-size: 2rem; font-weight: 900; color: #fff;
            display: block; line-height: 1; margin-bottom: 3px;
        }
        .banner-stat .blbl {
            font-size: 0.68rem; opacity: 0.75;
            text-transform: uppercase; letter-spacing: 0.6px; font-weight: 700;
        }

        /* ── Summary Pills ── */
        .ord-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 12px;
            margin-bottom: 24px;
        }
        .ord-pill {
            background: var(--bg-card);
            border-radius: var(--radius-md);
            padding: 16px 12px;
            text-align: center;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-light);
            border-top: 4px solid var(--border);
            transition: transform var(--tr), box-shadow var(--tr);
        }
        .ord-pill:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
        .ord-pill.maroon { border-top-color: var(--primary); }
        .ord-pill.gold   { border-top-color: var(--gold); }
        .ord-pill.green  { border-top-color: var(--success); }
        .ord-pill.orange { border-top-color: var(--warning); }
        .ord-pill.blue   { border-top-color: var(--info); }
        .ord-pill.red    { border-top-color: var(--danger); }

        .pill-v {
            font-size: 1.7rem; font-weight: 900;
            color: var(--text-dark); line-height: 1; margin-bottom: 4px;
        }
        .pill-l {
            font-size: 0.68rem; text-transform: uppercase;
            letter-spacing: 0.5px; color: var(--text-light); font-weight: 700;
        }
        .ord-pill.maroon .pill-v { color: var(--primary); }
        .ord-pill.gold   .pill-v { color: var(--gold-dark); }
        .ord-pill.green  .pill-v { color: var(--success); }
        .ord-pill.orange .pill-v { color: var(--warning); }
        .ord-pill.blue   .pill-v { color: var(--info); }
        .ord-pill.red    .pill-v { color: var(--danger); }

        /* ── Section header ── */
        .section-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--gold-border);
        }
        .section-head h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.2rem;
            color: var(--text-dark);
            font-weight: 800;
        }
        .order-count-badge {
            background: var(--primary-bg);
            border: 1px solid var(--primary-border);
            color: var(--primary);
            border-radius: var(--radius-pill);
            padding: 3px 14px;
            font-size: 0.78rem;
            font-weight: 800;
        }

        /* ── Order Card ── */
        .ord-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-light);
            margin-bottom: 14px;
            overflow: hidden;
            transition: box-shadow var(--tr), transform var(--tr);
        }
        .ord-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); }

        /* Status top strip */
        .ord-card.status-Pending   { border-top: 4px solid var(--warning); }
        .ord-card.status-Confirmed { border-top: 4px solid var(--info); }
        .ord-card.status-Shipped   { border-top: 4px solid var(--gold); }
        .ord-card.status-Delivered { border-top: 4px solid var(--success); }
        .ord-card.status-Cancelled { border-top: 4px solid var(--danger); }

        /* Card Header */
        .ord-card-header {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 70%, var(--primary-light) 100%);
            padding: 12px 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
            border-bottom: 2px solid rgba(201,144,32,0.35);
        }
        .ord-id {
            font-weight: 900;
            font-size: 1rem;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .ord-date {
            font-size: 0.76rem;
            color: rgba(255,255,255,0.72);
            font-weight: 600;
        }

        /* Card Body Grid */
        .ord-card-body {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            align-items: stretch;
        }
        @media (max-width: 720px) { .ord-card-body { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 440px) { .ord-card-body { grid-template-columns: 1fr; } }

        .ord-cell {
            padding: 16px 20px;
            border-right: 1px solid var(--border-light);
        }
        .ord-cell:last-child { border-right: none; }
        .ord-cell-label {
            font-size: 0.67rem;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--text-light);
            font-weight: 800;
            margin-bottom: 6px;
        }
        .ord-cell-val {
            font-size: 0.92rem;
            font-weight: 700;
            color: var(--text-dark);
        }
        .ord-amount {
            font-size: 1.15rem;
            color: var(--primary);
            font-weight: 900;
        }

        /* ── Status Badges ── */
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 12px;
            border-radius: var(--radius-pill);
            font-size: 0.74rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .badge-Pending   { background: var(--warning-bg);  color: var(--warning);  border: 1px solid var(--warning-border); }
        .badge-Confirmed { background: var(--info-bg);     color: var(--info);     border: 1px solid var(--info-border); }
        .badge-Shipped   { background: var(--gold-bg);     color: var(--gold-dark);border: 1px solid var(--gold-border); }
        .badge-Delivered { background: var(--success-bg);  color: var(--success);  border: 1px solid var(--success-border); }
        .badge-Cancelled { background: var(--danger-bg);   color: var(--danger);   border: 1px solid var(--danger-border); }
        .badge-Completed { background: var(--success-bg);  color: var(--success);  border: 1px solid var(--success-border); }
        .badge-Paid      { background: var(--success-bg);  color: var(--success);  border: 1px solid var(--success-border); }
        .badge-Failed    { background: var(--danger-bg);   color: var(--danger);   border: 1px solid var(--danger-border); }

        /* ── Payment method pill ── */
        .pay-method {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: var(--primary-bg);
            border: 1px solid var(--primary-border);
            color: var(--primary);
            font-size: 0.78rem;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: var(--radius-pill);
        }

        /* ── Empty State ── */
        .empty-orders {
            text-align: center;
            padding: 72px 24px;
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-light);
        }
        .empty-orders .empty-icon { font-size: 3.8rem; margin-bottom: 16px; display: block; }
        .empty-orders h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            color: var(--text-dark);
            margin-bottom: 8px;
        }
        .empty-orders p { color: var(--text-light); font-size: 0.9rem; margin-bottom: 24px; line-height: 1.6; }

        /* ── Bottom Nav ── */
        .bottom-nav {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 20px;
        }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128203; My Product Orders</h2>
</div>

<div class="orders-wrap">

    <!-- ── Welcome Banner ── -->
    <div class="member-banner">
        <div>
            <h2>&#128105; Hello, <%= m_fullname %>!</h2>
            <p>Orders placed by customers for your products are listed below.<br>
               Track order status, customer details, and payment information at a glance.</p>
        </div>
        <div class="banner-stats">
            <div class="banner-stat">
                <span class="bval"><%= total %></span>
                <span class="blbl">Total Orders</span>
            </div>
            <div class="banner-stat">
                <span class="bval"><%= delivered %></span>
                <span class="blbl">Delivered</span>
            </div>
            <div class="banner-stat">
                <span class="bval"><%= shipped %></span>
                <span class="blbl">Shipped</span>
            </div>
            <div class="banner-stat">
                <span class="bval">&#8377;<%= String.format("%.0f", revenue) %></span>
                <span class="blbl">Revenue</span>
            </div>
        </div>
    </div>

    <!-- ── Summary Pills ── -->
    <div class="ord-summary">
        <div class="ord-pill maroon">
            <div class="pill-v"><%= total %></div>
            <div class="pill-l">All Orders</div>
        </div>
        <div class="ord-pill orange">
            <div class="pill-v"><%= pending %></div>
            <div class="pill-l">Pending</div>
        </div>
        <div class="ord-pill blue">
            <div class="pill-v"><%= confirmed %></div>
            <div class="pill-l">Confirmed</div>
        </div>
        <div class="ord-pill gold">
            <div class="pill-v"><%= shipped %></div>
            <div class="pill-l">Shipped</div>
        </div>
        <div class="ord-pill green">
            <div class="pill-v"><%= delivered %></div>
            <div class="pill-l">Delivered</div>
        </div>
        <div class="ord-pill red">
            <div class="pill-v"><%= cancelled %></div>
            <div class="pill-l">Cancelled</div>
        </div>
    </div>

    <!-- ── Orders List ── -->
    <div class="section-head">
        <h3>&#128230; Order Details</h3>
        <% if (!isEmpty) { %>
        <span class="order-count-badge"><%= total %> order<%= total != 1 ? "s" : "" %></span>
        <% } %>
    </div>

    <% if (isEmpty) { %>

        <div class="empty-orders">
            <span class="empty-icon">&#128230;</span>
            <h3>No Orders Yet</h3>
            <p>When customers purchase your products, their orders will appear here.<br>
               Make sure your products are approved and visible in the store.</p>
            <div class="bottom-nav" style="justify-content:center;">
                <a href="<%= request.getContextPath() %>/ProductServlet?action=memberProducts"
                   class="btn btn-secondary">&#128722; My Products</a>
                <a href="<%= request.getContextPath() %>/jsp/member/add_product.jsp"
                   class="btn btn-primary">&#43; Add Product</a>
            </div>
        </div>

    <% } else { %>

        <% for (Order o : orders) {
            String ds = o.getDelivery_status() != null ? o.getDelivery_status() : "Pending";
            String ps = o.getPayment_status()  != null ? o.getPayment_status()  : "Pending";
            String pm = o.getPayment_method()  != null ? o.getPayment_method()  : "—";

            // Choose emoji for payment method
            String pmIcon = "💳";
            if (pm.toLowerCase().contains("cod"))  pmIcon = "💵";
            else if (pm.toLowerCase().contains("upi")) pmIcon = "📱";
        %>

        <div class="ord-card status-<%= ds %>">

            <!-- Header -->
            <div class="ord-card-header">
                <div class="ord-id">
                    &#128203; Order #<%= o.getOrder_id() %>
                    &nbsp;
                    <span class="badge badge-<%= ds %>"><%= ds %></span>
                </div>
                <span class="ord-date">&#128336; <%= o.getOrder_date() != null ? o.getOrder_date() : "—" %></span>
            </div>

            <!-- Body -->
            <div class="ord-card-body">

                <div class="ord-cell">
                    <div class="ord-cell-label">&#128101; Customer</div>
                    <div class="ord-cell-val"><%= o.getC_fullname() != null ? o.getC_fullname() : "—" %></div>
                </div>

                <div class="ord-cell">
                    <div class="ord-cell-label">&#128181; Total Amount</div>
                    <div class="ord-amount">&#8377;<%= String.format("%.2f", o.getTotal_amount()) %></div>
                </div>

                <div class="ord-cell">
                    <div class="ord-cell-label">&#128242; Payment Method</div>
                    <div class="ord-cell-val">
                        <span class="pay-method"><%= pmIcon %> <%= pm %></span>
                    </div>
                </div>

                <div class="ord-cell">
                    <div class="ord-cell-label">&#10003; Payment Status</div>
                    <div><span class="badge badge-<%= ps %>"><%= ps %></span></div>
                </div>

            </div>

        </div><!-- /.ord-card -->

        <% } %>

        <!-- Bottom Nav -->
        <div class="bottom-nav">
            <a href="<%= request.getContextPath() %>/ProductServlet?action=memberProducts"
               class="btn btn-secondary">&#128722; My Products</a>
            <a href="<%= request.getContextPath() %>/jsp/member/add_product.jsp"
               class="btn btn-primary">&#43; Add Product</a>
            <a href="<%= request.getContextPath() %>/jsp/member/member_delivery.jsp"
               class="btn btn-secondary">&#128666; My Deliveries</a>
        </div>

    <% } %>

</div><!-- /.orders-wrap -->

<%@ include file="../common/footer.jsp" %>

<script>
// Auto-dismiss alerts
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
