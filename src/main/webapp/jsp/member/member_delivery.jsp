<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Payment" %>
<%
    if (session.getAttribute("m_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    String msg = request.getParameter("msg");
    boolean isEmpty = (payments == null || payments.isEmpty());
    String m_fullname = (String) session.getAttribute("m_fullname");
    if (m_fullname == null) m_fullname = "Member";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Deliveries – SakhiMart Member</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .member-del-wrap {
            max-width: 1000px;
            margin: 28px auto;
            padding: 0 18px;
        }

        /* ── Welcome Banner ── */
        .member-banner {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 60%, var(--accent) 100%);
            border-radius: var(--radius-lg);
            padding: 24px 28px;
            color: #fff;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }
        .member-banner h2 {
            font-family: 'Playfair Display', serif;
            color: #fff;
            font-size: 1.4rem;
            margin-bottom: 4px;
        }
        .member-banner p { color: rgba(255,255,255,0.85); font-size: 0.9rem; }
        .banner-stats { display: flex; gap: 24px; flex-wrap: wrap; }
        .banner-stat { text-align: center; }
        .banner-stat .bval { font-size: 1.8rem; font-weight: 900; color: #fff; display: block; line-height: 1; }
        .banner-stat .blbl { font-size: 0.72rem; opacity: 0.8; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700; }

        /* ── Summary pills ── */
        .del-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
            gap: 12px;
            margin-bottom: 22px;
        }
        .del-pill {
            background: var(--bg-card);
            border-radius: var(--radius-md);
            padding: 14px 14px;
            text-align: center;
            box-shadow: var(--shadow-xs);
            border-top: 3px solid var(--border);
        }
        .del-pill.green  { border-top-color: var(--success); }
        .del-pill.blue   { border-top-color: var(--info); }
        .del-pill.orange { border-top-color: var(--accent); }
        .del-pill.red    { border-top-color: var(--danger); }
        .pill-v { font-size: 1.6rem; font-weight: 900; color: var(--text-dark); line-height: 1; }
        .pill-l { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.4px;
                  color: var(--text-light); font-weight: 700; margin-top: 4px; }
        .del-pill.green .pill-v  { color: var(--success); }
        .del-pill.blue .pill-v   { color: var(--info); }
        .del-pill.orange .pill-v { color: var(--accent); }
        .del-pill.red .pill-v    { color: var(--danger); }

        /* ── Order card ── */
        .del-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-xs);
            border: 1.5px solid var(--border-light);
            margin-bottom: 14px;
            overflow: hidden;
            transition: box-shadow var(--transition), transform var(--transition);
        }
        .del-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); }

        /* Card top strip color by status */
        .del-card.status-Pending   { border-top: 4px solid var(--warning); }
        .del-card.status-Confirmed { border-top: 4px solid var(--info); }
        .del-card.status-Shipped   { border-top: 4px solid var(--accent); }
        .del-card.status-Delivered { border-top: 4px solid var(--success); }
        .del-card.status-Cancelled { border-top: 4px solid var(--danger); }

        .del-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            padding: 12px 20px;
            background: var(--bg-page);
            border-bottom: 1px solid var(--border-light);
        }
        .del-order-id { font-weight: 900; font-size: 0.96rem; color: var(--primary); }
        .del-date     { font-size: 0.78rem; color: var(--text-light); }

        .del-card-body {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 1fr;
            gap: 0;
        }
        @media (max-width: 700px) { .del-card-body { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 420px) { .del-card-body { grid-template-columns: 1fr; } }

        .del-cell {
            padding: 14px 20px;
            border-right: 1px solid var(--border-light);
        }
        .del-cell:last-child { border-right: none; }
        .del-cell-label {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            color: var(--text-muted);
            font-weight: 700;
            margin-bottom: 5px;
        }
        .del-cell-val { font-size: 0.92rem; font-weight: 700; color: var(--text-dark); }
        .del-amount   { color: var(--primary); font-size: 1.1rem; font-weight: 900; }

        /* ── Badges ── */
        .badge-Pending   { background: var(--warning-bg); color: var(--warning); border: 1px solid var(--warning-border); }
        .badge-Confirmed { background: var(--info-bg);    color: var(--info);    border: 1px solid var(--info-border); }
        .badge-Shipped   { background: var(--accent-bg);  color: var(--accent);  border: 1px solid #f5cba7; }
        .badge-Delivered { background: var(--success-bg); color: var(--success); border: 1px solid var(--success-border); }
        .badge-Cancelled { background: var(--danger-bg);  color: var(--danger);  border: 1px solid var(--danger-border); }
        .badge-Completed { background: var(--success-bg); color: var(--success); border: 1px solid var(--success-border); }
        .badge-Failed    { background: var(--danger-bg);  color: var(--danger);  border: 1px solid var(--danger-border); }

        /* ── Action area ── */
        .del-card-footer {
            padding: 12px 20px;
            border-top: 1px solid var(--border-light);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            background: var(--bg-page);
        }
        .inline-form { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
        .ship-note {
            font-size: 0.78rem;
            color: var(--text-light);
            font-style: italic;
        }

        /* ── Empty state ── */
        .empty-del {
            text-align: center;
            padding: 60px 20px;
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-xs);
        }
        .empty-del .empty-icon { font-size: 3rem; margin-bottom: 14px; }
        .empty-del h3 { font-family: 'Playfair Display', serif; color: var(--text-dark); margin-bottom: 8px; }
        .empty-del p  { color: var(--text-light); font-size: 0.9rem; }

        .flash-bar { max-width: 1000px; margin: 14px auto 0; padding: 0 18px; }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128666; My Deliveries</h2>
</div>

<!-- Flash -->
<div class="flash-bar">
    <% if ("updated".equals(msg)) { %>
        <div class="alert alert-success">&#10003; Delivery status updated to Shipped.</div>
    <% } %>
</div>

<div class="member-del-wrap">

    <!-- Banner -->
    <%
        int totalDel = isEmpty ? 0 : payments.size();
        int pendingD = 0, shippedD = 0, deliveredD = 0, confirmedD = 0;
        if (!isEmpty) {
            for (Payment p : payments) {
                String ds = p.getO_status() != null ? p.getO_status() : "Pending";
                if ("Pending".equals(ds))   pendingD++;
                if ("Confirmed".equals(ds)) confirmedD++;
                if ("Shipped".equals(ds))   shippedD++;
                if ("Delivered".equals(ds)) deliveredD++;
            }
        }
    %>
    <div class="member-banner">
        <div>
            <h2>&#128105; Hello, <%= m_fullname %>!</h2>
            <p>Orders containing your products are listed below.<br>
               You can mark orders as <strong>Shipped</strong> once you hand over items for delivery.</p>
        </div>
        <div class="banner-stats">
            <div class="banner-stat">
                <span class="bval"><%= totalDel %></span>
                <span class="blbl">Total Orders</span>
            </div>
            <div class="banner-stat">
                <span class="bval"><%= confirmedD %></span>
                <span class="blbl">To Ship</span>
            </div>
            <div class="banner-stat">
                <span class="bval"><%= shippedD %></span>
                <span class="blbl">Shipped</span>
            </div>
            <div class="banner-stat">
                <span class="bval"><%= deliveredD %></span>
                <span class="blbl">Delivered</span>
            </div>
        </div>
    </div>

    <!-- Summary pills -->
    <div class="del-summary">
        <div class="del-pill blue">
            <div class="pill-v"><%= pendingD %></div>
            <div class="pill-l">Pending</div>
        </div>
        <div class="del-pill blue" style="border-top-color:var(--info);">
            <div class="pill-v"><%= confirmedD %></div>
            <div class="pill-l">Confirmed</div>
        </div>
        <div class="del-pill orange">
            <div class="pill-v"><%= shippedD %></div>
            <div class="pill-l">Shipped</div>
        </div>
        <div class="del-pill green">
            <div class="pill-v"><%= deliveredD %></div>
            <div class="pill-l">Delivered</div>
        </div>
    </div>

    <!-- ── Order Cards ── -->
    <% if (isEmpty) { %>
        <div class="empty-del">
            <div class="empty-icon">&#128666;</div>
            <h3>No Orders Yet</h3>
            <p>When customers order your products, they will appear here.<br>
               Make sure your products are approved and available.</p>
        </div>
    <% } else { %>
        <% for (Payment pay : payments) {
            String ds = pay.getO_status() != null ? pay.getO_status() : "Pending";
            String ps = pay.getPayment_status() != null ? pay.getPayment_status() : "Pending";
            boolean canShip    = "Confirmed".equals(ds);
            boolean isFinal    = "Delivered".equals(ds) || "Cancelled".equals(ds);
        %>
        <div class="del-card status-<%= ds %>">

            <!-- Header -->
            <div class="del-card-header">
                <div>
                    <span class="del-order-id">&#128203; Order #<%= pay.getO_id() %></span>
                    &nbsp;
                    <span class="badge badge-<%= ds %>" style="font-size:0.78rem; padding:3px 10px;"><%= ds %></span>
                </div>
                <span class="del-date">&#128336; <%= pay.getPayment_date() != null ? pay.getPayment_date() : "—" %></span>
            </div>

            <!-- Body Grid -->
            <div class="del-card-body">

                <div class="del-cell">
                    <div class="del-cell-label">&#128181; Amount</div>
                    <div class="del-amount">&#8377;<%= String.format("%.2f", pay.getPayment_amount()) %></div>
                </div>

                <div class="del-cell">
                    <div class="del-cell-label">&#128242; Payment Method</div>
                    <div class="del-cell-val"><%= pay.getPayment_method() != null ? pay.getPayment_method() : "—" %></div>
                </div>

                <div class="del-cell">
                    <div class="del-cell-label">&#10003; Payment Status</div>
                    <div><span class="badge badge-<%= ps %>"><%= ps %></span></div>
                    <% if (pay.getTransaction_id() != null && !pay.getTransaction_id().isEmpty()) { %>
                    <div style="font-size:0.72rem; color:var(--text-light); margin-top:4px; font-family:monospace;">
                        <%= pay.getTransaction_id() %>
                    </div>
                    <% } %>
                </div>

                <div class="del-cell">
                    <div class="del-cell-label">&#128101; Customer</div>
                    <div class="del-cell-val"><%= pay.getC_fullname() != null ? pay.getC_fullname() : "—" %></div>
                    <div style="font-size:0.77rem; color:var(--text-light);">
                        <%= pay.getC_contact() != null ? "&#128222; " + pay.getC_contact() : "" %>
                    </div>
                </div>

            </div>

            <!-- Footer with action -->
            <div class="del-card-footer">
                <% if (canShip) { %>
                <form action="<%= request.getContextPath() %>/PaymentServlet" method="post" class="inline-form">
                    <input type="hidden" name="action"   value="memberUpdateDelivery">
                    <input type="hidden" name="o_id"     value="<%= pay.getO_id() %>">
                    <input type="hidden" name="o_status" value="Shipped">
                    <button type="submit" class="btn btn-primary"
                            onclick="return confirm('Mark Order #<%= pay.getO_id() %> as Shipped?')">
                        &#128666; Mark as Shipped
                    </button>
                </form>
                <span class="ship-note">&#8505; Click once you have handed over the items for delivery.</span>
                <% } else if ("Shipped".equals(ds)) { %>
                <span style="color:var(--accent); font-weight:700;">&#128666; Items dispatched — awaiting delivery confirmation from admin.</span>
                <% } else if ("Delivered".equals(ds)) { %>
                <span style="color:var(--success); font-weight:700;">&#10003; Delivered on <%= pay.getDelivery_date() != null ? pay.getDelivery_date() : "—" %></span>
                <% } else if ("Cancelled".equals(ds)) { %>
                <span style="color:var(--danger); font-weight:700;">&#10005; This order was cancelled.</span>
                <% } else { %>
                <span class="ship-note">&#9203; Waiting for payment confirmation from admin before shipping.</span>
                <% } %>
            </div>

        </div><!-- /.del-card -->
        <% } %>
    <% } %>

    <!-- Bottom Nav -->
    <div style="display:flex; gap:14px; flex-wrap:wrap; margin: 8px 0 36px;">
        <a href="<%= request.getContextPath() %>/ProductServlet?action=memberProducts"
           class="btn btn-secondary">&#128722; My Products</a>
        <a href="<%= request.getContextPath() %>/jsp/member/add_product.jsp"
           class="btn btn-primary">&#43; Add Product</a>
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
