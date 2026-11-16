<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Member, model.Customer" %>
<%
    if (session.getAttribute("a_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<Member>   members   = (List<Member>)   request.getAttribute("memberList");
    List<Customer> customers = (List<Customer>) request.getAttribute("customerList");
    if (members   == null) members   = new java.util.ArrayList<>();
    if (customers == null) customers = new java.util.ArrayList<>();

    long pendingCount  = members.stream().filter(x -> "pending".equals(x.getM_status())).count();
    long approvedCount = members.stream().filter(x -> "approved".equals(x.getM_status())).count();
    long rejectedCount = members.stream().filter(x -> "rejected".equals(x.getM_status())).count();

    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "members";

    String successMsg = (String) session.getAttribute("manageUserMsg");
    session.removeAttribute("manageUserMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Users – SakhiMart Admin</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
<style>
/* ── Page wrap ── */
.mu-wrap { max-width:1100px; margin:0 auto; padding:0 18px 48px; }

/* ── Stats row ── */
.mu-stats {
    display:grid; grid-template-columns:repeat(auto-fit,minmax(140px,1fr));
    gap:14px; margin-bottom:26px;
}
.mu-stat {
    background:var(--bg-card); border-radius:var(--radius-md);
    padding:18px 16px; text-align:center;
    box-shadow:var(--shadow-xs); border-top:4px solid var(--border);
}
.mu-stat.blue   { border-top-color:var(--info); }
.mu-stat.green  { border-top-color:var(--success); }
.mu-stat.orange { border-top-color:var(--warning); }
.mu-stat.red    { border-top-color:var(--danger); }
.mu-stat.maroon { border-top-color:var(--primary); }
.stat-val { font-size:2rem; font-weight:900; color:var(--text-dark); line-height:1; }
.stat-lbl { font-size:.72rem; text-transform:uppercase; letter-spacing:.05em; color:var(--text-light); font-weight:700; margin-top:4px; }
.mu-stat.green  .stat-val { color:var(--success); }
.mu-stat.orange .stat-val { color:var(--warning); }
.mu-stat.red    .stat-val { color:var(--danger); }
.mu-stat.blue   .stat-val { color:var(--info); }
.mu-stat.maroon .stat-val { color:var(--primary); }

/* ── Tabs ── */
.mu-tabs {
    display:flex; gap:0; border-bottom:2px solid var(--border);
    margin-bottom:22px;
}
.mu-tab {
    padding:12px 28px; font-size:.9rem; font-weight:700;
    color:var(--text-light); cursor:pointer; border:none;
    background:transparent; font-family:inherit;
    border-bottom:3px solid transparent; margin-bottom:-2px;
    transition:color .2s, border-color .2s;
    display:flex; align-items:center; gap:8px;
}
.mu-tab:hover { color:var(--primary); }
.mu-tab.active { color:var(--primary); border-bottom-color:var(--primary); }
.mu-tab .tab-count {
    font-size:.72rem; padding:2px 8px; border-radius:50px; font-weight:800;
    background:var(--primary-bg); color:var(--primary); border:1px solid var(--primary-border);
}
.mu-tab.active .tab-count { background:var(--primary); color:#fff; border-color:var(--primary); }

/* ── Tab panels ── */
.mu-panel { display:none; }
.mu-panel.active { display:block; }

/* ── Search + filter bar ── */
.mu-toolbar {
    display:flex; gap:10px; align-items:center;
    flex-wrap:wrap; margin-bottom:16px;
}
.mu-search {
    flex:1; min-width:200px;
    background:var(--bg-card); border:1.5px solid var(--border);
    border-radius:var(--radius-pill); padding:8px 16px;
    font-size:.86rem; font-family:inherit; color:var(--text-dark);
    outline:none; transition:border-color .2s, box-shadow .2s;
}
.mu-search:focus { border-color:var(--primary); box-shadow:0 0 0 3px var(--primary-glow); }
.mu-filter {
    background:var(--bg-card); border:1.5px solid var(--border);
    border-radius:var(--radius-pill); padding:8px 14px;
    font-size:.84rem; font-family:inherit; color:var(--text-dark);
    outline:none; cursor:pointer;
}

/* ── Table ── */
.table-wrap { overflow-x:auto; border-radius:var(--radius-lg); box-shadow:var(--shadow-sm); }
table {
    width:100%; border-collapse:collapse; font-size:.88rem;
    background:var(--bg-card);
}
thead { background:linear-gradient(135deg,var(--primary-dark),var(--primary)); }
th {
    padding:13px 16px; text-align:left;
    font-weight:700; color:#fff; font-size:.8rem;
    text-transform:uppercase; letter-spacing:.04em;
    white-space:nowrap;
}
td {
    padding:13px 16px; border-bottom:1px solid var(--border-light);
    color:var(--text-mid); vertical-align:middle;
}
tbody tr:last-child td { border-bottom:none; }
tbody tr:hover td { background:var(--primary-bg); }

/* ── Avatar ── */
.user-av {
    width:34px; height:34px; border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    font-size:.85rem; font-weight:800; color:#fff; flex-shrink:0;
}
.user-av.member   { background:linear-gradient(135deg,var(--primary-dark),var(--primary)); }
.user-av.customer { background:linear-gradient(135deg,var(--gold-dark),var(--gold)); }
.user-cell { display:flex; align-items:center; gap:10px; }
.user-name { font-weight:800; color:var(--text-dark); font-size:.9rem; }
.user-id   { font-size:.74rem; color:var(--text-muted); }

/* ── Status badges ── */
.badge-pending  { background:var(--warning-bg); color:var(--warning); border:1px solid var(--warning-border); }
.badge-approved { background:var(--success-bg); color:var(--success); border:1px solid var(--success-border); }
.badge-rejected { background:var(--danger-bg);  color:var(--danger);  border:1px solid var(--danger-border);  }
.badge-active   { background:var(--success-bg); color:var(--success); border:1px solid var(--success-border); }

/* ── Action buttons ── */
.act-btn {
    padding:5px 13px; border-radius:var(--radius-sm);
    font-size:.78rem; font-weight:700; cursor:pointer;
    border:none; font-family:inherit; text-decoration:none;
    display:inline-block; transition:all .2s;
}
.act-approve { background:var(--success-bg); color:var(--success); border:1px solid var(--success-border); }
.act-approve:hover { background:var(--success); color:#fff; }
.act-reject  { background:var(--danger-bg);  color:var(--danger);  border:1px solid var(--danger-border); }
.act-reject:hover  { background:var(--danger);  color:#fff; }
.act-view    { background:var(--primary-bg); color:var(--primary); border:1px solid var(--primary-border); }
.act-view:hover    { background:var(--primary); color:#fff; }

/* ── Empty state ── */
.mu-empty {
    text-align:center; padding:50px 20px;
    color:var(--text-muted); font-size:.9rem; font-weight:600;
}
.mu-empty .empty-ico { font-size:2.8rem; margin-bottom:12px; display:block; }

/* ── Contact chip ── */
.contact-chip {
    font-size:.76rem; font-family:monospace;
    background:var(--bg-page); border:1px solid var(--border);
    border-radius:var(--radius-sm); padding:2px 8px; color:var(--text-mid);
}
</style>
</head>
<body>
<%@ include file="../common/navbar.jsp" %>

<div class="page-header">
    <h2>&#128100; Manage Users</h2>
</div>

<div class="mu-wrap">

    <!-- Flash -->
    <% if (successMsg != null) { %>
    <div class="alert alert-success" style="margin-bottom:16px">&#10003; <%= successMsg %></div>
    <% } %>

    <!-- ── Stats row ── -->
    <div class="mu-stats">
        <div class="mu-stat maroon">
            <div class="stat-val"><%= members.size() + customers.size() %></div>
            <div class="stat-lbl">Total Users</div>
        </div>
        <div class="mu-stat blue">
            <div class="stat-val"><%= customers.size() %></div>
            <div class="stat-lbl">Customers</div>
        </div>
        <div class="mu-stat green">
            <div class="stat-val"><%= members.size() %></div>
            <div class="stat-lbl">Members</div>
        </div>
        <div class="mu-stat orange">
            <div class="stat-val"><%= pendingCount %></div>
            <div class="stat-lbl">Pending Approval</div>
        </div>
        <div class="mu-stat green">
            <div class="stat-val"><%= approvedCount %></div>
            <div class="stat-lbl">Approved Members</div>
        </div>
        <div class="mu-stat red">
            <div class="stat-val"><%= rejectedCount %></div>
            <div class="stat-lbl">Rejected</div>
        </div>
    </div>

    <!-- ── Tabs ── -->
    <div class="mu-tabs">
        <button class="mu-tab <%= "members".equals(activeTab) ? "active" : "" %>"
                data-tab="members">
            &#128105; SHG Members
            <span class="tab-count"><%= members.size() %></span>
        </button>
        <button class="mu-tab <%= "customers".equals(activeTab) ? "active" : "" %>"
                data-tab="customers">
            &#128722; Customers
            <span class="tab-count"><%= customers.size() %></span>
        </button>
    </div>

    <!-- ══════════════════════════════════════════════
         MEMBERS TAB
    ══════════════════════════════════════════════ -->
    <div class="mu-panel <%= "members".equals(activeTab) ? "active" : "" %>" id="panel-members">

        <!-- Toolbar -->
        <div class="mu-toolbar">
            <input type="text" class="mu-search" id="memberSearch"
                   placeholder="&#128269; Search member by name, email, username...">
            <select class="mu-filter" id="memberStatusFilter">
                <option value="">All Status</option>
                <option value="pending">Pending</option>
                <option value="approved">Approved</option>
                <option value="rejected">Rejected</option>
            </select>
        </div>

        <div class="table-wrap">
        <% if (members.isEmpty()) { %>
            <div class="mu-empty">
                <span class="empty-ico">&#128105;</span>
                No member registrations yet.
            </div>
        <% } else { %>
        <table id="memberTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Member</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Contact</th>
                    <th>Gender</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% int sr = 1; for (Member m : members) {
                String st = m.getM_status() != null ? m.getM_status() : "pending"; %>
            <tr data-name="<%= m.getM_fullname().toLowerCase() %>"
                data-email="<%= m.getM_email() != null ? m.getM_email().toLowerCase() : "" %>"
                data-user="<%= m.getM_login_id().toLowerCase() %>"
                data-status="<%= st %>">
                <td style="color:var(--text-muted);font-weight:700"><%= sr++ %></td>
                <td>
                    <div class="user-cell">
                        <div class="user-av member"><%= m.getM_fullname().charAt(0) %></div>
                        <div>
                            <div class="user-name"><%= m.getM_fullname() %></div>
                            <div class="user-id">ID: <%= m.getM_id() %></div>
                        </div>
                    </div>
                </td>
                <td style="font-family:monospace;font-size:.84rem;color:var(--text-dark)"><%= m.getM_login_id() %></td>
                <td><a href="mailto:<%= m.getM_email() %>" style="color:var(--primary);text-decoration:none;font-size:.84rem"><%= m.getM_email() %></a></td>
                <td><span class="contact-chip">&#128222; <%= m.getM_contact() %></span></td>
                <td style="text-transform:capitalize;font-size:.84rem"><%= m.getM_gender() != null ? m.getM_gender() : "—" %></td>
                <td>
                    <span class="badge badge-<%= st %>">
                        <% if ("approved".equals(st)) { %>&#10003;
                        <% } else if ("rejected".equals(st)) { %>&#10005;
                        <% } else { %>&#9679;<% } %>
                        <%= st.substring(0,1).toUpperCase() + st.substring(1) %>
                    </span>
                </td>
                <td>
                    <div style="display:flex;gap:6px;flex-wrap:wrap">
                        <% if (!"approved".equals(st)) { %>
                        <a href="<%= request.getContextPath() %>/ProfileServlet?action=approve&m_id=<%= m.getM_id() %>"
                           class="act-btn act-approve"
                           onclick="return confirm('Approve <%= m.getM_fullname() %>?')">&#10003; Approve</a>
                        <% } %>
                        <% if (!"rejected".equals(st)) { %>
                        <a href="<%= request.getContextPath() %>/ProfileServlet?action=reject&m_id=<%= m.getM_id() %>"
                           class="act-btn act-reject"
                           onclick="return confirm('Reject <%= m.getM_fullname() %>?')">&#10007; Reject</a>
                        <% } %>
                        <% if ("approved".equals(st) && "rejected".equals(st)) { %>
                        <span style="color:var(--text-muted);font-size:.78rem;padding:5px 6px">No action</span>
                        <% } %>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
        </div>
    </div>

    <!-- ══════════════════════════════════════════════
         CUSTOMERS TAB
    ══════════════════════════════════════════════ -->
    <div class="mu-panel <%= "customers".equals(activeTab) ? "active" : "" %>" id="panel-customers">

        <!-- Toolbar -->
        <div class="mu-toolbar">
            <input type="text" class="mu-search" id="customerSearch"
                   placeholder="&#128269; Search customer by name, email, username...">
        </div>

        <div class="table-wrap">
        <% if (customers.isEmpty()) { %>
            <div class="mu-empty">
                <span class="empty-ico">&#128722;</span>
                No customers registered yet.
            </div>
        <% } else { %>
        <table id="customerTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Customer</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Contact</th>
                    <th>Gender</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
            <% int csr = 1; for (Customer c : customers) { %>
            <tr data-name="<%= c.getC_fullname().toLowerCase() %>"
                data-email="<%= c.getC_email() != null ? c.getC_email().toLowerCase() : "" %>"
                data-user="<%= c.getC_login_id().toLowerCase() %>">
                <td style="color:var(--text-muted);font-weight:700"><%= csr++ %></td>
                <td>
                    <div class="user-cell">
                        <div class="user-av customer"><%= c.getC_fullname().charAt(0) %></div>
                        <div>
                            <div class="user-name"><%= c.getC_fullname() %></div>
                            <div class="user-id">ID: <%= c.getC_id() %></div>
                        </div>
                    </div>
                </td>
                <td style="font-family:monospace;font-size:.84rem;color:var(--text-dark)"><%= c.getC_login_id() %></td>
                <td><a href="mailto:<%= c.getC_email() %>" style="color:var(--primary);text-decoration:none;font-size:.84rem"><%= c.getC_email() %></a></td>
                <td><span class="contact-chip">&#128222; <%= c.getC_contact() %></span></td>
                <td style="text-transform:capitalize;font-size:.84rem"><%= c.getC_gender() != null ? c.getC_gender() : "—" %></td>
                <td><span class="badge badge-active">&#10003; Active</span></td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
        </div>
    </div>

</div><!-- /mu-wrap -->

<%@ include file="../common/footer.jsp" %>

<script>
(function(){
'use strict';

// ── Tab switching ─────────────────────────────────────────────
document.querySelectorAll('.mu-tab').forEach(function(tab) {
    tab.addEventListener('click', function() {
        var target = this.getAttribute('data-tab');
        document.querySelectorAll('.mu-tab').forEach(function(t) { t.classList.remove('active'); });
        document.querySelectorAll('.mu-panel').forEach(function(p) { p.classList.remove('active'); });
        this.classList.add('active');
        document.getElementById('panel-' + target).classList.add('active');
    });
});

// ── Member search + filter ────────────────────────────────────
var memberSearch = document.getElementById('memberSearch');
var memberFilter = document.getElementById('memberStatusFilter');
var memberTable  = document.getElementById('memberTable');

function filterMembers() {
    if (!memberTable) return;
    var q  = memberSearch ? memberSearch.value.toLowerCase() : '';
    var st = memberFilter ? memberFilter.value.toLowerCase() : '';
    memberTable.querySelectorAll('tbody tr').forEach(function(row) {
        var name  = row.getAttribute('data-name')  || '';
        var email = row.getAttribute('data-email') || '';
        var user  = row.getAttribute('data-user')  || '';
        var status= row.getAttribute('data-status')|| '';
        var matchQ  = !q  || name.includes(q) || email.includes(q) || user.includes(q);
        var matchSt = !st || status === st;
        row.style.display = (matchQ && matchSt) ? '' : 'none';
    });
}
if (memberSearch) memberSearch.addEventListener('input', filterMembers);
if (memberFilter) memberFilter.addEventListener('change', filterMembers);

// ── Customer search ───────────────────────────────────────────
var customerSearch = document.getElementById('customerSearch');
var customerTable  = document.getElementById('customerTable');

function filterCustomers() {
    if (!customerTable) return;
    var q = customerSearch ? customerSearch.value.toLowerCase() : '';
    customerTable.querySelectorAll('tbody tr').forEach(function(row) {
        var name  = row.getAttribute('data-name')  || '';
        var email = row.getAttribute('data-email') || '';
        var user  = row.getAttribute('data-user')  || '';
        var match = !q || name.includes(q) || email.includes(q) || user.includes(q);
        row.style.display = match ? '' : 'none';
    });
}
if (customerSearch) customerSearch.addEventListener('input', filterCustomers);

// ── Auto-dismiss alerts ───────────────────────────────────────
setTimeout(function() {
    document.querySelectorAll('.alert').forEach(function(el) {
        el.style.transition = 'opacity .5s';
        el.style.opacity = '0';
        setTimeout(function() { el.remove(); }, 500);
    });
}, 5000);

})();
</script>
</body>
</html>
