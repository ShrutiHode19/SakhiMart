<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Payment" %>
<%
    if (session.getAttribute("a_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<Payment> payments   = (List<Payment>) request.getAttribute("payments");
    double totalRevenue      = (double)  request.getAttribute("totalRevenue");
    int    completedCount    = (int)     request.getAttribute("completedCount");
    int    pendingCount      = (int)     request.getAttribute("pendingCount");
    int    failedCount       = (int)     request.getAttribute("failedCount");
    String msg               = request.getParameter("msg");
    boolean isEmpty          = (payments == null || payments.isEmpty());
    int totalPayments        = isEmpty ? 0 : payments.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Payments &amp; Delivery – SakhiMart Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        /* ── Page Layout ── */
        .admin-pay-wrap {
            max-width: 1240px;
            margin: 28px auto;
            padding: 0 18px;
        }

        /* ── Stats Row ── */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(155px, 1fr));
            gap: 14px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: var(--bg-card);
            border-radius: var(--radius-md);
            padding: 18px 16px;
            box-shadow: var(--shadow-xs);
            border-left: 4px solid var(--border);
        }
        .stat-card.green  { border-left-color: var(--success); }
        .stat-card.orange { border-left-color: var(--accent); }
        .stat-card.red    { border-left-color: var(--danger); }
        .stat-card.blue   { border-left-color: var(--info); }
        .stat-card.primary{ border-left-color: var(--primary); }
        .stat-label { font-size: 0.73rem; text-transform: uppercase; letter-spacing: 0.5px;
                      color: var(--text-light); font-weight: 700; margin-bottom: 5px; }
        .stat-value { font-size: 1.8rem; font-weight: 900; color: var(--text-dark); line-height: 1; }
        .stat-card.green .stat-value  { color: var(--success); }
        .stat-card.red .stat-value    { color: var(--danger); }
        .stat-card.primary .stat-value{ color: var(--primary); }

        /* ── Filter Bar ── */
        .filter-bar {
            background: var(--bg-card);
            border-radius: var(--radius-md);
            padding: 14px 20px;
            margin-bottom: 20px;
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
            box-shadow: var(--shadow-xs);
        }
        .filter-bar label { font-size: 0.84rem; font-weight: 700; color: var(--text-mid); }
        .filter-select {
            padding: 7px 12px;
            border: 2px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 0.84rem;
            cursor: pointer;
            color: var(--text-dark);
            background: var(--bg-card);
        }
        .filter-select:focus { border-color: var(--primary); outline: none; }
        #searchInput {
            flex: 1;
            min-width: 180px;
            padding: 8px 14px;
            border: 2px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            color: var(--text-dark);
        }
        #searchInput:focus { border-color: var(--primary); outline: none; }

        /* ── Payment Table Card ── */
        .table-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .table-card-header {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .table-card-header h2 {
            font-family: 'Playfair Display', serif;
            color: #fff;
            font-size: 1.15rem;
        }
        .table-card-header span {
            color: rgba(255,255,255,0.8);
            font-size: 0.84rem;
        }

        .table-scroll { overflow-x: auto; }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th {
            background: var(--primary-bg);
            color: var(--primary);
            font-size: 0.76rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 11px 14px;
            text-align: left;
            white-space: nowrap;
            font-weight: 800;
        }
        .data-table td {
            padding: 11px 14px;
            border-bottom: 1px solid var(--border-light);
            font-size: 0.87rem;
            color: var(--text-dark);
            vertical-align: middle;
        }
        .data-table tbody tr:hover { background: var(--primary-bg); transition: background 0.15s; }
        .data-table tbody tr:last-child td { border-bottom: none; }

        /* ── Inline action forms ── */
        .actions-cell { display: flex; flex-direction: column; gap: 6px; min-width: 210px; }
        .inline-form  { display: flex; gap: 5px; align-items: center; flex-wrap: wrap; }

        .mini-select {
            padding: 5px 9px;
            border: 2px solid var(--border);
            border-radius: var(--radius-xs);
            font-size: 0.79rem;
            cursor: pointer;
            color: var(--text-dark);
            max-width: 130px;
            background: var(--bg-card);
        }
        .mini-select:focus { border-color: var(--primary); outline: none; }

        .txn-input {
            padding: 5px 9px;
            border: 2px solid var(--border);
            border-radius: var(--radius-xs);
            font-size: 0.79rem;
            max-width: 130px;
            font-family: monospace;
            color: var(--text-dark);
        }
        .txn-input:focus { border-color: var(--primary); outline: none; }

        /* ── Status Badges (payment) ── */
        .badge-completed { background: var(--success-bg);  color: var(--success); border: 1px solid var(--success-border); }
        .badge-pending   { background: var(--warning-bg);  color: var(--warning); border: 1px solid var(--warning-border); }
        .badge-failed    { background: var(--danger-bg);   color: var(--danger);  border: 1px solid var(--danger-border); }

        /* ── Status Badges (delivery) ── */
        .badge-Pending    { background: var(--warning-bg);  color: var(--warning); border: 1px solid var(--warning-border); }
        .badge-Confirmed  { background: var(--info-bg);     color: var(--info);    border: 1px solid var(--info-border); }
        .badge-Shipped    { background: var(--accent-bg);   color: var(--accent);  border: 1px solid #f5cba7; }
        .badge-Delivered  { background: var(--success-bg);  color: var(--success); border: 1px solid var(--success-border); }
        .badge-Cancelled  { background: var(--danger-bg);   color: var(--danger);  border: 1px solid var(--danger-border); }

        /* ── Amount ── */
        .pay-amount { font-weight: 900; color: var(--primary); }

        /* ── Customer info ── */
        .c-name    { font-weight: 700; }
        .c-email   { font-size: 0.77rem; color: var(--text-light); }
        .c-contact { font-size: 0.77rem; color: var(--text-light); }

        /* ── TXN chip ── */
        .txn-chip {
            display: inline-block;
            background: var(--bg-page);
            border: 1px solid var(--border);
            border-radius: 5px;
            padding: 2px 8px;
            font-size: 0.72rem;
            font-family: monospace;
            color: var(--text-mid);
            max-width: 160px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            vertical-align: middle;
        }

        /* ── Empty ── */
        .empty-row td {
            text-align: center;
            padding: 50px;
            color: var(--text-light);
            font-size: 1rem;
        }

        /* ── Flash ── */
        .flash-bar { max-width: 1240px; margin: 14px auto 0; padding: 0 18px; }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128179; Manage Payments &amp; Delivery</h2>
    <span style="color:rgba(255,255,255,0.85); font-size:0.88rem;"><%= totalPayments %> total records</span>
</div>

<!-- Flash Messages -->
<div class="flash-bar">
    <% if ("pay_confirmed".equals(msg)) { %>
        <div class="alert alert-success">&#10003; Payment confirmed successfully.</div>
    <% } else if ("pay_rejected".equals(msg)) { %>
        <div class="alert alert-warning">&#9888; Payment marked as failed.</div>
    <% } else if ("delivery_updated".equals(msg)) { %>
        <div class="alert alert-success">&#128666; Delivery status updated.</div>
    <% } else if ("order_cancelled".equals(msg)) { %>
        <div class="alert alert-info">&#128465; Order cancelled and payment marked failed.</div>
    <% } else if ("txn_updated".equals(msg)) { %>
        <div class="alert alert-success">&#128203; Transaction ID updated.</div>
    <% } else if ("error".equals(msg)) { %>
        <div class="alert alert-error">&#10005; Operation failed. Please try again.</div>
    <% } %>
</div>

<div class="admin-pay-wrap">

    <!-- ── Stats Row ── -->
    <div class="stats-row">
        <div class="stat-card blue">
            <div class="stat-label">Total Transactions</div>
            <div class="stat-value"><%= totalPayments %></div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">Payments Completed</div>
            <div class="stat-value"><%= completedCount %></div>
        </div>
        <div class="stat-card orange">
            <div class="stat-label">Payments Pending</div>
            <div class="stat-value"><%= pendingCount %></div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">Payments Failed</div>
            <div class="stat-value"><%= failedCount %></div>
        </div>
        <div class="stat-card primary">
            <div class="stat-label">Total Revenue</div>
            <div class="stat-value" style="font-size:1.25rem;">&#8377;<%= String.format("%.0f", totalRevenue) %></div>
        </div>
    </div>

    <!-- ── Filter + Search Bar ── -->
    <div class="filter-bar">
        <label for="filterPay">Payment:</label>
        <select class="filter-select" id="filterPay" onchange="applyFilters()">
            <option value="all">All</option>
            <option value="Completed">Completed</option>
            <option value="Pending">Pending</option>
            <option value="Failed">Failed</option>
        </select>

        <label for="filterDel">Delivery:</label>
        <select class="filter-select" id="filterDel" onchange="applyFilters()">
            <option value="all">All</option>
            <option value="Pending">Pending</option>
            <option value="Confirmed">Confirmed</option>
            <option value="Shipped">Shipped</option>
            <option value="Delivered">Delivered</option>
            <option value="Cancelled">Cancelled</option>
        </select>

        <label for="filterMethod">Method:</label>
        <select class="filter-select" id="filterMethod" onchange="applyFilters()">
            <option value="all">All</option>
            <option value="UPI">UPI</option>
            <option value="Online">Online</option>
            <option value="Cash on Delivery">Cash on Delivery</option>
        </select>

        <input type="text" id="searchInput" placeholder="&#128269; Search customer name or order..." onkeyup="applyFilters()">
    </div>

    <!-- ── Payments Table ── -->
    <div class="table-card">
        <div class="table-card-header">
            <h2>All Payment Records</h2>
            <span>Revenue from completed: &#8377;<%= String.format("%.2f", totalRevenue) %></span>
        </div>
        <div class="table-scroll">
        <table class="data-table" id="payTable">
            <thead>
                <tr>
                    <th>Pay ID</th>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Amount</th>
                    <th>Method</th>
                    <th>Transaction ID</th>
                    <th>Payment Status</th>
                    <th>Delivery Status</th>
                    <th>Delivery Date</th>
                    <th>Payment Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (isEmpty) { %>
                <tr class="empty-row"><td colspan="11">&#128179; No payment records found.</td></tr>
            <% } else { %>
                <% for (Payment pay : payments) {
                    String ps = pay.getPayment_status() != null ? pay.getPayment_status() : "Pending";
                    String ds = pay.getO_status()        != null ? pay.getO_status()        : "Pending";
                    boolean isCancelled  = "Cancelled".equals(ds);
                    boolean isDelivered  = "Delivered".equals(ds);
                    boolean payCompleted = "Completed".equals(ps);
                    boolean payFailed    = "Failed".equals(ps);
                %>
                <tr data-pay="<%= ps %>" data-del="<%= ds %>" data-method="<%= pay.getPayment_method() %>"
                    data-search="<%= (pay.getC_fullname() != null ? pay.getC_fullname().toLowerCase() : "") + " order#" + pay.getO_id() %>">

                    <td><strong>#<%= pay.getPayment_id() %></strong></td>

                    <td>
                        <a href="<%= request.getContextPath() %>/OrderServlet?action=allOrders"
                           style="font-weight:700; color:var(--primary);">#<%= pay.getO_id() %></a>
                    </td>

                    <td>
                        <div class="c-name"><%= pay.getC_fullname()  != null ? pay.getC_fullname()  : "—" %></div>
                        <div class="c-email"><%= pay.getC_email()    != null ? pay.getC_email()    : "" %></div>
                        <div class="c-contact"><%= pay.getC_contact() != null ? pay.getC_contact() : "" %></div>
                    </td>

                    <td><span class="pay-amount">&#8377;<%= String.format("%.2f", pay.getPayment_amount()) %></span></td>

                    <td>
                        <% if ("UPI".equals(pay.getPayment_method())) { %>
                            &#128242; UPI
                        <% } else if ("Online".equals(pay.getPayment_method())) { %>
                            &#128179; Online
                        <% } else { %>
                            &#128181; CoD
                        <% } %>
                    </td>

                    <td>
                        <% if (pay.getTransaction_id() != null && !pay.getTransaction_id().isEmpty()) { %>
                            <span class="txn-chip" title="<%= pay.getTransaction_id() %>">
                                <%= pay.getTransaction_id() %>
                            </span>
                        <% } else { %>
                            <span style="color:var(--text-muted); font-size:0.8rem;">—</span>
                        <% } %>
                    </td>

                    <td>
                        <span class="badge badge-<%= ps.toLowerCase() %>">
                            <%= payCompleted ? "&#10003;" : (payFailed ? "&#10005;" : "&#9679;") %>
                            <%= ps %>
                        </span>
                    </td>

                    <td>
                        <span class="badge badge-<%= ds %>"><%= ds %></span>
                    </td>

                    <td style="font-size:0.78rem; color:var(--text-light); white-space:nowrap;">
                        <%= pay.getDelivery_date() != null ? pay.getDelivery_date() : "—" %>
                    </td>

                    <td style="font-size:0.78rem; color:var(--text-light); white-space:nowrap;">
                        <%= pay.getPayment_date() != null ? pay.getPayment_date() : "—" %>
                    </td>

                    <!-- ── ACTIONS ── -->
                    <td>
                        <div class="actions-cell">

                            <!-- 1. Confirm Payment (only if Pending) -->
                            <% if ("Pending".equals(ps)) { %>
                            <form action="<%= request.getContextPath() %>/PaymentServlet" method="post" class="inline-form">
                                <input type="hidden" name="action"     value="confirmPayment">
                                <input type="hidden" name="payment_id" value="<%= pay.getPayment_id() %>">
                                <button type="submit" class="btn btn-success btn-sm"
                                        onclick="return confirm('Confirm payment #<%= pay.getPayment_id() %>?')">
                                    &#10003; Confirm Pay
                                </button>
                            </form>
                            <% } %>

                            <!-- 2. Reject Payment (only if Pending) -->
                            <% if ("Pending".equals(ps)) { %>
                            <form action="<%= request.getContextPath() %>/PaymentServlet" method="post" class="inline-form">
                                <input type="hidden" name="action"     value="rejectPayment">
                                <input type="hidden" name="payment_id" value="<%= pay.getPayment_id() %>">
                                <button type="submit" class="btn btn-danger btn-sm"
                                        onclick="return confirm('Mark payment #<%= pay.getPayment_id() %> as failed?')">
                                    &#10005; Reject
                                </button>
                            </form>
                            <% } %>

                            <!-- 3. Update Delivery Status -->
                            <% if (!isCancelled && !isDelivered) { %>
                            <form action="<%= request.getContextPath() %>/PaymentServlet" method="post" class="inline-form">
                                <input type="hidden" name="action" value="updateDelivery">
                                <input type="hidden" name="o_id"   value="<%= pay.getO_id() %>">
                                <select name="o_status" class="mini-select">
                                    <option value="Pending"   <%= "Pending".equals(ds)   ? "selected" : "" %>>Pending</option>
                                    <option value="Confirmed" <%= "Confirmed".equals(ds) ? "selected" : "" %>>Confirmed</option>
                                    <option value="Shipped"   <%= "Shipped".equals(ds)   ? "selected" : "" %>>Shipped</option>
                                    <option value="Delivered" <%= "Delivered".equals(ds) ? "selected" : "" %>>Delivered</option>
                                </select>
                                <button type="submit" class="btn btn-warning btn-sm">&#128666; Update</button>
                            </form>
                            <% } %>

                            <!-- 4. Set Transaction ID (for UPI/Online if missing) -->
                            <% if (!payCompleted || (pay.getTransaction_id() == null || pay.getTransaction_id().isEmpty())) { %>
                            <form action="<%= request.getContextPath() %>/PaymentServlet" method="post" class="inline-form">
                                <input type="hidden" name="action"     value="updateTxnId">
                                <input type="hidden" name="payment_id" value="<%= pay.getPayment_id() %>">
                                <input type="text" name="transaction_id" class="txn-input"
                                       placeholder="TXN ID..."
                                       value="<%= pay.getTransaction_id() != null ? pay.getTransaction_id() : "" %>">
                                <button type="submit" class="btn btn-info btn-sm">&#128203; Set</button>
                            </form>
                            <% } %>

                            <!-- 5. Cancel Order (only if not already cancelled/delivered) -->
                            <% if (!isCancelled && !isDelivered) { %>
                            <form action="<%= request.getContextPath() %>/PaymentServlet" method="post" class="inline-form">
                                <input type="hidden" name="action" value="cancelOrder">
                                <input type="hidden" name="o_id"   value="<%= pay.getO_id() %>">
                                <button type="submit" class="btn btn-danger btn-sm"
                                        onclick="return confirm('Cancel Order #<%= pay.getO_id() %>? Payment will be marked failed.')">
                                    &#128465; Cancel Order
                                </button>
                            </form>
                            <% } %>

                            <!-- 6. No actions if final state -->
                            <% if ((isCancelled || isDelivered) && payCompleted) { %>
                            <span style="font-size:0.78rem; color:var(--text-light); font-weight:600;">
                                &#10003; Finalized
                            </span>
                            <% } %>

                        </div>
                    </td>
                </tr>
                <% } %>
            <% } %>
            </tbody>
        </table>
        </div><!-- /.table-scroll -->
    </div><!-- /.table-card -->

    <!-- ── Back to manage_orders ── -->
    <div style="margin: 20px 0 40px; display:flex; gap:14px; flex-wrap:wrap;">
        <a href="<%= request.getContextPath() %>/OrderServlet?action=allOrders"
           class="btn btn-secondary">&#128203; View Orders</a>
        <a href="<%= request.getContextPath() %>/ProductServlet?action=adminProducts"
           class="btn btn-secondary">&#128722; Products</a>
    </div>

</div><!-- /.admin-pay-wrap -->

<%@ include file="../common/footer.jsp" %>

<script>
// ── Client-side filter & search ──────────────────────────────────────
function applyFilters() {
    const payF    = document.getElementById('filterPay').value;
    const delF    = document.getElementById('filterDel').value;
    const methodF = document.getElementById('filterMethod').value;
    const searchV = document.getElementById('searchInput').value.toLowerCase();

    document.querySelectorAll('#payTable tbody tr[data-pay]').forEach(row => {
        const pay    = row.dataset.pay    || '';
        const del    = row.dataset.del    || '';
        const method = row.dataset.method || '';
        const search = row.dataset.search || '';

        const okPay    = payF    === 'all' || pay    === payF;
        const okDel    = delF    === 'all' || del    === delF;
        const okMethod = methodF === 'all' || method === methodF;
        const okSearch = !searchV         || search.includes(searchV);

        row.style.display = (okPay && okDel && okMethod && okSearch) ? '' : 'none';
    });
}

// ── Auto-dismiss flash alerts ──────────────────────────────────────
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
