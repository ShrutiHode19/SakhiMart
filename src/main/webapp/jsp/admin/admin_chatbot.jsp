<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.ChatbotDAO" %>
<%
    /* ── Auth guard ── */
    if (session.getAttribute("a_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    String adminName = (String) session.getAttribute("a_fullname");
    if (adminName == null) adminName = "Admin";

    ChatbotDAO adminChatDAO = new ChatbotDAO();
    List<String[]> faqs    = adminChatDAO.getAllFAQs();
    List<String[]> rules   = adminChatDAO.getAllRules();
    List<String[]> logs    = adminChatDAO.getRecentLogs(20);

    String adminMsg = (String) session.getAttribute("adminChatMsg");
    session.removeAttribute("adminChatMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Chatbot – SakhiMart Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
    /* ─── Admin Chatbot Page ─── */
    .admin-chat-page { display: flex; gap: 0; min-height: calc(100vh - var(--nav-height) - 58px); }

    /* Left: live chat */
    .admin-chat-panel {
        width: 380px; flex-shrink: 0;
        display: flex; flex-direction: column;
        border-right: 1px solid var(--border-light);
        background: var(--bg-page);
    }
    .acp-header {
        background: var(--nav-grad); padding: 16px 18px;
        display: flex; align-items: center; gap: 10px;
    }
    .acp-header .bot-av {
        width: 36px; height: 36px; border-radius: 50%;
        background: linear-gradient(135deg,var(--gold-dark),var(--gold-light));
        display: flex; align-items: center; justify-content: center; font-size: .9rem;
    }
    .acp-header strong { color: #fff; font-size: .92rem; font-weight: 800; }
    .acp-header span   { color: rgba(255,255,255,0.65); font-size: .73rem; display: block; }
    .acp-msgs {
        flex: 1; overflow-y: auto; padding: 14px 14px;
        display: flex; flex-direction: column; gap: 12px; min-height: 300px;
    }
    .acp-msgs::-webkit-scrollbar { width: 4px; }
    .acp-msgs::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }
    .acp-input-wrap {
        background: var(--bg-card); border-top: 1px solid var(--border-light);
        padding: 10px 12px; display: flex; gap: 8px; align-items: flex-end;
    }
    .acp-textarea-box {
        flex: 1; background: var(--bg-page);
        border: 1.5px solid var(--border); border-radius: var(--radius-lg);
        padding: 8px 12px; transition: border-color var(--tr), box-shadow var(--tr);
    }
    .acp-textarea-box:focus-within { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-glow); }
    #adminChatInput {
        width: 100%; border: none; background: transparent; resize: none;
        font-family: inherit; font-size: .85rem; color: var(--text-dark);
        outline: none; min-height: 20px; max-height: 80px; overflow-y: auto;
    }
    #adminChatInput::placeholder { color: var(--text-muted); }
    .acp-send-btn {
        width: 40px; height: 40px; border-radius: 50%;
        background: linear-gradient(135deg,var(--primary-dark),var(--primary));
        border: none; color: #fff; font-size: .95rem;
        cursor: pointer; display: flex; align-items: center; justify-content: center;
        box-shadow: var(--shadow-primary); transition: transform var(--tr);
    }
    .acp-send-btn:hover { transform: scale(1.1); }

    /* Bubbles (reuse chatbot styles) */
    .adm-msg-row { display: flex; align-items: flex-end; gap: 7px; animation: msgIn .25s ease both; }
    @keyframes msgIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:none; } }
    .adm-msg-row.ur { flex-direction: row-reverse; }
    .adm-av {
        width: 28px; height: 28px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center; font-size: .75rem;
    }
    .adm-av.bot  { background: linear-gradient(135deg,var(--gold-dark),var(--gold-light)); }
    .adm-av.user { background: linear-gradient(135deg,var(--primary-dark),var(--primary)); }
    .adm-bubble { max-width: 76%; padding: 9px 13px; border-radius: 14px; font-size: .82rem; line-height: 1.6; }
    .adm-bubble.bot  { background: var(--bg-card); border: 1px solid var(--border-light); border-bottom-left-radius: 3px; box-shadow: var(--shadow-xs); color: var(--text-dark); }
    .adm-bubble.user { background: linear-gradient(135deg,var(--primary-dark),var(--primary)); color: #fff; border-bottom-right-radius: 3px; }
    .adm-time { font-size: .62rem; opacity: .45; margin-top: 3px; display: block; }
    .ur .adm-time { text-align: right; }
    .adm-typing { display: none; }
    .adm-typing.show { display: flex; }
    .adm-dots { display: flex; gap: 3px; padding: 9px 13px; background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 14px; }
    .adm-dots span { width: 6px; height: 6px; border-radius: 50%; background: var(--gold); animation: tBounce 1.2s ease-in-out infinite; }
    .adm-dots span:nth-child(2) { animation-delay: .18s; }
    .adm-dots span:nth-child(3) { animation-delay: .36s; }
    @keyframes tBounce { 0%,60%,100%{transform:translateY(0);opacity:.5} 30%{transform:translateY(-6px);opacity:1} }

    /* Right: management panels */
    .admin-manage-panel {
        flex: 1; overflow-y: auto; padding: 24px;
        display: flex; flex-direction: column; gap: 24px;
    }

    /* Section cards */
    .manage-card {
        background: var(--bg-card); border: 1px solid var(--border-light);
        border-radius: var(--radius-xl); overflow: hidden; box-shadow: var(--shadow-xs);
    }
    .manage-card-header {
        background: var(--nav-grad); padding: 14px 20px;
        display: flex; align-items: center; justify-content: space-between;
    }
    .manage-card-header h3 { color: #fff; font-size: .96rem; font-weight: 800; margin: 0; }
    .manage-card-header span { color: rgba(255,255,255,0.65); font-size: .78rem; }
    .manage-card-body { padding: 18px 20px; }

    /* Add form rows */
    .add-row { display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-end; margin-bottom: 14px; }
    .add-row input, .add-row select { flex: 1; min-width: 140px; }
    .add-row textarea { flex: 2; min-width: 200px; min-height: 60px; }

    /* FAQ / Rule list */
    .faq-list, .rule-list { display: flex; flex-direction: column; gap: 8px; }
    .faq-item, .rule-item {
        background: var(--bg-page); border: 1px solid var(--border-light);
        border-radius: var(--radius-md); padding: 12px 14px;
        display: flex; gap: 12px; align-items: flex-start;
    }
    .faq-item-content, .rule-item-content { flex: 1; min-width: 0; }
    .faq-q   { font-size: .86rem; font-weight: 800; color: var(--text-dark); margin-bottom: 3px; }
    .faq-a   { font-size: .8rem;  color: var(--text-light); line-height: 1.55; }
    .faq-cat { font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em;
               color: var(--gold-dark); background: var(--gold-bg); border: 1px solid var(--gold-border);
               border-radius: var(--radius-pill); padding: 2px 8px; margin-top: 5px; display: inline-block; }
    .rule-kw { font-size: .8rem; font-weight: 800; color: var(--primary);
               background: var(--primary-bg); border: 1px solid var(--primary-border);
               border-radius: var(--radius-pill); padding: 2px 10px; margin-bottom: 4px; display: inline-block; }
    .rule-resp { font-size: .8rem; color: var(--text-light); line-height: 1.55; }
    .del-btn {
        background: var(--danger-bg); border: 1px solid var(--danger-border);
        color: var(--danger); border-radius: var(--radius-md);
        padding: 4px 10px; font-size: .74rem; font-weight: 700;
        cursor: pointer; flex-shrink: 0; font-family: inherit; transition: all var(--tr);
    }
    .del-btn:hover { background: var(--danger); color: #fff; }

    /* Log table */
    .log-table-wrap { overflow-x: auto; }
    .log-table { width: 100%; border-collapse: collapse; font-size: .8rem; }
    .log-table th { background: var(--primary-bg); color: var(--primary); font-size: .72rem;
                    text-transform: uppercase; letter-spacing: .06em; padding: 8px 10px; text-align: left;
                    border-bottom: 1.5px solid var(--border); font-weight: 800; }
    .log-table td { padding: 9px 10px; border-bottom: 1px solid var(--border-light);
                    color: var(--text-mid); vertical-align: top; }
    .log-table tbody tr:hover { background: var(--primary-bg); }
    .log-user-badge { display: inline-block; padding: 2px 8px; border-radius: var(--radius-pill);
                      font-size: .68rem; font-weight: 700; text-transform: uppercase; }
    .log-user-badge.customer { background: var(--info-bg);    color: var(--info);    border: 1px solid var(--info-border); }
    .log-user-badge.member   { background: var(--success-bg); color: var(--success); border: 1px solid var(--success-border); }
    .log-user-badge.admin    { background: var(--warning-bg); color: var(--warning); border: 1px solid var(--warning-border); }
    .log-user-badge.guest    { background: var(--border-light); color: var(--text-muted); }
    .log-msg  { max-width: 180px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: var(--text-dark); font-weight: 600; }
    .log-reply{ max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    /* Empty state */
    .empty-manage { text-align: center; padding: 24px 16px; color: var(--text-muted); font-size: .86rem; font-weight: 600; }

    @media(max-width:900px) {
        .admin-chat-page { flex-direction: column; }
        .admin-chat-panel { width: 100%; min-height: 300px; }
    }
    </style>
</head>
<body>
<%@ include file="../common/navbar.jsp" %>

<div class="container" style="padding-top:20px;padding-bottom:20px;max-width:100%">

    <% if (adminMsg != null) { %>
    <div class="alert alert-<%= adminMsg.startsWith("Error") ? "error" : "success" %>" style="margin-bottom:14px">
        <%= adminMsg %>
    </div>
    <% } %>

    <div class="page-header">
        <h2>&#129302; Chatbot Management</h2>
        <span class="sub-head">Define rules, manage FAQs, view conversation logs</span>
    </div>

    <div class="admin-chat-page">

        <!-- ════ LEFT: LIVE ADMIN CHAT ════ -->
        <div class="admin-chat-panel">
            <div class="acp-header">
                <div class="bot-av">&#127800;</div>
                <div>
                    <strong>Sakhi AI Assistant</strong>
                    <span>Test chatbot as admin</span>
                </div>
            </div>
            <div class="acp-msgs" id="acpMsgs">
                <!-- Welcome -->
                <div class="adm-msg-row">
                    <div class="adm-av bot">&#127800;</div>
                    <div>
                        <div class="adm-bubble bot">
                            Hello <%= adminName.split(" ")[0] %>! &#128075; I'm Sakhi. You can test the chatbot here and see how it responds to different queries.
                        </div>
                        <span class="adm-time" id="admWelcomeTime"></span>
                    </div>
                </div>
                <!-- Typing -->
                <div class="adm-msg-row adm-typing" id="admTyping">
                    <div class="adm-av bot">&#127800;</div>
                    <div class="adm-dots"><span></span><span></span><span></span></div>
                </div>
            </div>
            <div class="acp-input-wrap">
                <div class="acp-textarea-box">
                    <textarea id="adminChatInput" rows="1" maxlength="500"
                        placeholder="Test the chatbot..."
                        onkeydown="admKey(event)" oninput="admResize(this)"></textarea>
                </div>
                <button class="acp-send-btn" onclick="admSend()" title="Send">&#10148;</button>
            </div>
        </div>

        <!-- ════ RIGHT: MANAGEMENT PANELS ════ -->
        <div class="admin-manage-panel">

            <!-- ── FAQ Management ── -->
            <div class="manage-card">
                <div class="manage-card-header">
                    <h3>&#10067; Frequently Asked Questions</h3>
                    <span><%= faqs.size() %> active FAQs</span>
                </div>
                <div class="manage-card-body">
                    <!-- Add FAQ form -->
                    <form method="post" action="<%= request.getContextPath() %>/ChatbotAdminServlet">
                        <input type="hidden" name="action" value="addFAQ">
                        <div class="add-row">
                            <input type="text" name="faq_question" class="form-control"
                                   placeholder="FAQ Question *" required style="flex:2">
                            <select name="faq_category" class="form-control">
                                <option value="General">General</option>
                                <option value="Orders">Orders</option>
                                <option value="Payments">Payments</option>
                                <option value="Delivery">Delivery</option>
                                <option value="Returns">Returns</option>
                                <option value="About">About</option>
                            </select>
                        </div>
                        <div class="add-row" style="margin-bottom:0">
                            <textarea name="faq_answer" class="form-control"
                                      placeholder="FAQ Answer *" required style="min-height:54px"></textarea>
                            <button type="submit" class="btn btn-primary btn-sm" style="height:38px;align-self:flex-end">
                                &#43; Add FAQ
                            </button>
                        </div>
                    </form>
                    <hr class="divider" style="margin-top:14px">
                    <!-- FAQ list -->
                    <% if (faqs.isEmpty()) { %>
                    <div class="empty-manage">No FAQs added yet. Add your first FAQ above.</div>
                    <% } else { %>
                    <div class="faq-list">
                        <% for (String[] faq : faqs) { %>
                        <div class="faq-item">
                            <div class="faq-item-content">
                                <div class="faq-q">&#10067; <%= faq[1] %></div>
                                <div class="faq-a"><%= faq[2] %></div>
                                <span class="faq-cat"><%= faq[3] %></span>
                            </div>
                            <form method="post" action="<%= request.getContextPath() %>/ChatbotAdminServlet"
                                  onsubmit="return confirm('Delete this FAQ?')">
                                <input type="hidden" name="action"  value="deleteFAQ">
                                <input type="hidden" name="faq_id"  value="<%= faq[0] %>">
                                <button type="submit" class="del-btn">&#128465; Del</button>
                            </form>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- ── Keyword Rules ── -->
            <div class="manage-card">
                <div class="manage-card-header">
                    <h3>&#9889; Keyword Rules</h3>
                    <span><%= rules.size() %> active rules</span>
                </div>
                <div class="manage-card-body">
                    <!-- Add rule form -->
                    <form method="post" action="<%= request.getContextPath() %>/ChatbotAdminServlet">
                        <input type="hidden" name="action" value="addRule">
                        <div class="add-row">
                            <input type="text" name="keyword" class="form-control"
                                   placeholder="Keyword (e.g. return, payment) *" required>
                            <input type="number" name="priority" class="form-control"
                                   placeholder="Priority (1-10)" value="5" min="1" max="10" style="max-width:120px">
                        </div>
                        <div class="add-row" style="margin-bottom:0">
                            <textarea name="response" class="form-control"
                                      placeholder="Auto-reply when this keyword is detected *"
                                      required style="min-height:54px"></textarea>
                            <button type="submit" class="btn btn-gold btn-sm" style="height:38px;align-self:flex-end">
                                &#43; Add Rule
                            </button>
                        </div>
                    </form>
                    <hr class="divider" style="margin-top:14px">
                    <!-- Rules list -->
                    <% if (rules.isEmpty()) { %>
                    <div class="empty-manage">No rules added yet.</div>
                    <% } else { %>
                    <div class="rule-list">
                        <% for (String[] rule : rules) { %>
                        <div class="rule-item">
                            <div class="rule-item-content">
                                <span class="rule-kw">&#9889; <%= rule[1] %></span>
                                <span style="font-size:.7rem;color:var(--text-muted);margin-left:6px">
                                    Priority: <%= rule[3] %>
                                </span>
                                <div class="rule-resp"><%= rule[2] %></div>
                            </div>
                            <form method="post" action="<%= request.getContextPath() %>/ChatbotAdminServlet"
                                  onsubmit="return confirm('Delete this rule?')">
                                <input type="hidden" name="action"  value="deleteRule">
                                <input type="hidden" name="rule_id" value="<%= rule[0] %>">
                                <button type="submit" class="del-btn">&#128465; Del</button>
                            </form>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- ── Chat Logs ── -->
            <div class="manage-card">
                <div class="manage-card-header">
                    <h3>&#128221; Recent Chat Logs</h3>
                    <span>Last 20 conversations</span>
                </div>
                <div class="manage-card-body" style="padding:0">
                    <% if (logs.isEmpty()) { %>
                    <div class="empty-manage" style="padding:24px">No conversations yet.</div>
                    <% } else { %>
                    <div class="log-table-wrap">
                        <table class="log-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Role</th>
                                    <th>User Message</th>
                                    <th>Bot Reply</th>
                                    <th>Time</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (String[] log : logs) { %>
                                <tr>
                                    <td style="color:var(--text-muted);font-size:.75rem"><%= log[0] %></td>
                                    <td><span class="log-user-badge <%= log[1] %>"><%= log[1] %></span></td>
                                    <td><div class="log-msg" title="<%= log[3] != null ? log[3].replace("\"","&quot;") : "" %>">
                                        <%= log[3] != null ? log[3] : "" %>
                                    </div></td>
                                    <td><div class="log-reply" title="<%= log[4] != null ? log[4].replace("\"","&quot;") : "" %>">
                                        <%= log[4] != null ? log[4] : "" %>
                                    </div></td>
                                    <td style="font-size:.72rem;color:var(--text-muted);white-space:nowrap">
                                        <%= log[5] != null ? log[5].substring(0, Math.min(16,log[5].length())) : "" %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </div>

        </div><!-- /admin-manage-panel -->
    </div>
</div>

<%@ include file="../common/footer.jsp" %>

<script>
// Admin chat controller
const CTX_ADMIN = "<%= request.getContextPath() %>";
let admHistory  = [];
let admBusy     = false;

document.getElementById('admWelcomeTime').textContent = admNow();

function admNow() {
    return new Date().toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit',hour12:true});
}
function admScroll() {
    const m = document.getElementById('acpMsgs');
    m.scrollTo({top:m.scrollHeight,behavior:'smooth'});
}
function admTypingShow(show) {
    document.getElementById('admTyping').classList.toggle('show', show);
    if (show) admScroll();
}
function admResize(el) {
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 80) + 'px';
}
function admKey(e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); admSend(); }
}
function admAddBubble(role, text) {
    const msgs = document.getElementById('acpMsgs');
    const typing = document.getElementById('admTyping');
    const row = document.createElement('div');
    row.className = 'adm-msg-row' + (role==='user' ? ' ur' : '');
    row.innerHTML = `
        <div class="adm-av ${role==='user'?'user':'bot'}">${role==='user'?'A':'🌸'}</div>
        <div>
            <div class="adm-bubble ${role==='user'?'user':'bot'}">${text.replace(/\n/g,'<br>')}</div>
            <span class="adm-time">${admNow()}</span>
        </div>`;
    msgs.insertBefore(row, typing);
    admScroll();
}
async function admSend() {
    const input = document.getElementById('adminChatInput');
    const text = input.value.trim();
    if (!text || admBusy) return;
    admBusy = true;
    admAddBubble('user', text);
    input.value = ''; input.style.height = 'auto';
    admHistory.push({role:'user',content:text});
    admTypingShow(true);
    try {
        const res  = await fetch(CTX_ADMIN + '/ChatbotServlet', {
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({message:text, history:admHistory.slice(-8), userRole:'admin'})
        });
        const data = await res.json();
        admTypingShow(false);
        if (data.reply) {
            admHistory.push({role:'assistant',content:data.reply});
            admAddBubble('bot', data.reply);
        }
    } catch(e) {
        admTypingShow(false);
        admAddBubble('bot','Error connecting to AI. Check your API key and Tomcat logs.');
    }
    admBusy = false;
}
</script>
</body>
</html>
