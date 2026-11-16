<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    /* ── Session: use unique variable names to avoid conflict with navbar.jsp ── */
    String chatRole    = "";
    String chatName    = "Guest";
    int    chatUserId  = 0;

    if (session.getAttribute("c_id") != null) {
        chatRole   = "customer";
        chatName   = (String) session.getAttribute("c_fullname");
        chatUserId = (Integer) session.getAttribute("c_id");
    } else if (session.getAttribute("m_id") != null) {
        chatRole   = "member";
        chatName   = (String) session.getAttribute("m_fullname");
        chatUserId = (Integer) session.getAttribute("m_id");
    } else if (session.getAttribute("a_id") != null) {
        chatRole   = "admin";
        chatName   = (String) session.getAttribute("a_fullname");
    }

    if (chatName == null || chatName.isEmpty()) chatName = "Guest";
    String chatFirst = chatName.contains(" ") ? chatName.substring(0, chatName.indexOf(" ")) : chatName;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sakhi AI<% if(!chatFirst.equals("Guest")){ %> · <%= chatFirst %><% } %> – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
    /* ═══════════════════════════════════════════════
       CHATBOT PAGE — full viewport, maroon-gold theme
    ═══════════════════════════════════════════════ */
    html, body { height: 100%; overflow: hidden; }

    .chat-page {
        display: flex;
        height: calc(100vh - var(--nav-height));
        background: var(--bg-page);
        overflow: hidden;
    }

    /* ── Sidebar ── */
    .chat-sidebar {
        width: 270px;
        flex-shrink: 0;
        background: var(--nav-grad);
        display: flex;
        flex-direction: column;
        padding: 20px 14px 16px;
        gap: 16px;
        overflow-y: auto;
        border-right: 1px solid rgba(255,255,255,0.08);
    }
    .chat-sidebar::-webkit-scrollbar { width: 4px; }
    .chat-sidebar::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 4px; }

    .sb-bot-card {
        text-align: center;
        padding-bottom: 16px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }
    .sb-bot-ring {
        width: 62px; height: 62px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--gold-dark), var(--gold-light));
        display: flex; align-items: center; justify-content: center;
        font-size: 1.7rem;
        margin: 0 auto 10px;
        box-shadow: 0 0 0 4px rgba(201,144,32,0.25), var(--shadow-gold);
        animation: botPulse 3s ease-in-out infinite;
    }
    @keyframes botPulse {
        0%,100% { box-shadow: 0 0 0 4px rgba(201,144,32,0.25), var(--shadow-gold); }
        50%      { box-shadow: 0 0 0 8px rgba(201,144,32,0.1),  var(--shadow-gold); }
    }
    .sb-bot-name  { font-size: .98rem; font-weight: 800; color: #fff; margin-bottom: 2px; }
    .sb-bot-tag   { font-size: .7rem;  color: rgba(255,255,255,0.6); font-weight: 600; letter-spacing: .05em; margin-bottom: 8px; }
    .sb-online    { display: inline-flex; align-items: center; gap: 5px; font-size: .7rem; color: #6effa0; font-weight: 700;
                    background: rgba(30,132,73,0.2); border: 1px solid rgba(30,132,73,0.4); border-radius: 50px; padding: 3px 10px; }
    .sb-dot       { width: 6px; height: 6px; border-radius: 50%; background: #3efb76; animation: blink 1.4s infinite; }
    @keyframes blink { 0%,100%{opacity:1} 50%{opacity:.25} }

    .sb-section-label {
        font-size: .65rem; font-weight: 800; color: rgba(255,255,255,0.4);
        text-transform: uppercase; letter-spacing: .1em; margin-bottom: 4px;
    }

    .sb-quick-btn {
        display: flex; align-items: center; gap: 8px;
        width: 100%; text-align: left;
        background: rgba(255,255,255,0.07);
        border: 1px solid rgba(255,255,255,0.09);
        border-radius: var(--radius-md);
        color: rgba(255,255,255,0.88);
        font-size: .8rem; font-weight: 600;
        padding: 9px 12px; cursor: pointer;
        transition: background var(--tr), transform var(--tr), border-color var(--tr);
        margin-bottom: 5px; font-family: inherit;
    }
    .sb-quick-btn:hover {
        background: rgba(255,255,255,0.14);
        border-color: rgba(201,144,32,0.4);
        transform: translateX(3px);
    }
    .sb-quick-btn .qb-icon { font-size: 1rem; flex-shrink: 0; }

    /* Member-specific quick buttons */
    .sb-quick-btn.member-btn { border-color: rgba(201,144,32,0.2); }
    .sb-quick-btn.member-btn:hover { border-color: rgba(201,144,32,0.6); }

    .sb-disclaimer {
        margin-top: auto;
        font-size: .7rem; color: rgba(255,255,255,0.45); line-height: 1.6;
        background: rgba(255,255,255,0.04);
        border: 1px solid rgba(255,255,255,0.07);
        border-radius: var(--radius-md); padding: 10px 12px;
    }

    /* ── Chat Main ── */
    .chat-main {
        flex: 1; display: flex; flex-direction: column;
        min-width: 0; background: var(--bg-page);
    }

    /* Top bar */
    .chat-topbar {
        background: var(--bg-card);
        border-bottom: 1px solid var(--border-light);
        padding: 12px 20px;
        display: flex; align-items: center; justify-content: space-between;
        gap: 12px; flex-shrink: 0;
        box-shadow: var(--shadow-xs);
    }
    .ct-left { display: flex; align-items: center; gap: 10px; }
    .ct-avatar {
        width: 38px; height: 38px; border-radius: 50%;
        background: linear-gradient(135deg, var(--primary-dark), var(--primary));
        display: flex; align-items: center; justify-content: center;
        font-size: 1rem; box-shadow: var(--shadow-xs);
    }
    .ct-info strong { display: block; font-size: .88rem; font-weight: 800; color: var(--text-dark); }
    .ct-info span   { font-size: .73rem; color: var(--text-light); }
    .ct-right { display: flex; gap: 8px; }
    .ct-btn {
        background: var(--bg-page); border: 1px solid var(--border);
        border-radius: var(--radius-pill);
        padding: 5px 14px; font-size: .76rem; font-weight: 700;
        color: var(--text-mid); cursor: pointer;
        transition: all var(--tr); font-family: inherit;
    }
    .ct-btn:hover { background: var(--primary-bg); border-color: var(--primary-border); color: var(--primary); }

    /* Messages window */
    .chat-messages {
        flex: 1; overflow-y: auto;
        padding: 20px 18px; display: flex;
        flex-direction: column; gap: 14px;
        scroll-behavior: smooth;
    }
    .chat-messages::-webkit-scrollbar { width: 5px; }
    .chat-messages::-webkit-scrollbar-thumb { background: var(--border); border-radius: 10px; }

    /* Message rows */
    .msg-row { display: flex; align-items: flex-end; gap: 8px; animation: msgIn .28s ease both; }
    @keyframes msgIn { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
    .msg-row.user-row { flex-direction: row-reverse; }

    .msg-av {
        width: 32px; height: 32px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: .85rem; flex-shrink: 0;
    }
    .msg-av.bot  { background: linear-gradient(135deg,var(--gold-dark),var(--gold-light)); box-shadow: var(--shadow-gold); }
    .msg-av.user { background: linear-gradient(135deg,var(--primary-dark),var(--primary)); box-shadow: var(--shadow-primary); }

    .msg-bubble {
        max-width: 68%; padding: 11px 16px;
        border-radius: 16px; font-size: .86rem; line-height: 1.65; position: relative;
    }
    .msg-bubble.bot  {
        background: var(--bg-card); border: 1px solid var(--border-light);
        border-bottom-left-radius: 4px; box-shadow: var(--shadow-xs); color: var(--text-dark);
    }
    .msg-bubble.user {
        background: linear-gradient(135deg,var(--primary-dark),var(--primary));
        color: #fff; border-bottom-right-radius: 4px; box-shadow: var(--shadow-primary);
    }
    .msg-time { font-size: .65rem; opacity: .5; margin-top: 4px; display: block; }
    .user-row .msg-time { text-align: right; }

    /* Typing */
    .typing-row { display: none; }
    .typing-row.show { display: flex; }
    .typing-dots {
        display: flex; gap: 4px; padding: 12px 16px;
        background: var(--bg-card); border: 1px solid var(--border-light);
        border-radius: 16px; border-bottom-left-radius: 4px; box-shadow: var(--shadow-xs);
    }
    .typing-dots span {
        width: 7px; height: 7px; border-radius: 50%; background: var(--gold);
        animation: typeBounce 1.2s ease-in-out infinite;
    }
    .typing-dots span:nth-child(2) { animation-delay: .18s; }
    .typing-dots span:nth-child(3) { animation-delay: .36s; }
    @keyframes typeBounce { 0%,60%,100%{transform:translateY(0);opacity:.5;} 30%{transform:translateY(-7px);opacity:1;} }

    /* Welcome card */
    .welcome-card {
        background: var(--bg-card); border: 1.5px solid var(--border);
        border-radius: var(--radius-xl); padding: 22px 20px;
        text-align: center; box-shadow: var(--shadow-sm); max-width: 440px;
    }
    .wc-emoji { font-size: 2.4rem; margin-bottom: 8px; display: block; }
    .welcome-card h3 { font-family: 'Playfair Display', serif; font-size: 1.15rem; color: var(--primary); margin-bottom: 6px; }
    .welcome-card p  { font-size: .83rem; color: var(--text-light); line-height: 1.65; margin-bottom: 14px; }
    .wc-chips { display: flex; flex-wrap: wrap; gap: 7px; justify-content: center; }
    .wc-chip {
        background: var(--primary-bg); border: 1px solid var(--primary-border);
        color: var(--primary); font-size: .76rem; font-weight: 700;
        padding: 5px 13px; border-radius: var(--radius-pill); cursor: pointer;
        transition: all var(--tr);
    }
    .wc-chip:hover { background: var(--primary); color: #fff; transform: translateY(-2px); }

    /* Product card in chat */
    .chat-product-card {
        background: var(--bg-card); border: 1px solid var(--border);
        border-radius: var(--radius-lg); overflow: hidden;
        margin-top: 6px; box-shadow: var(--shadow-xs);
        display: flex; gap: 0;
    }
    .cpc-img {
        width: 72px; height: 72px; object-fit: cover; flex-shrink: 0;
        background: var(--primary-bg);
    }
    .cpc-info { padding: 10px 12px; flex: 1; min-width: 0; }
    .cpc-name { font-size: .84rem; font-weight: 800; color: var(--text-dark); margin-bottom: 2px;
                white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .cpc-cat  { font-size: .72rem; color: var(--text-muted); margin-bottom: 4px; }
    .cpc-price{ font-size: .92rem; font-weight: 900; color: var(--primary); }
    .cpc-link {
        display: inline-flex; align-items: center; gap: 4px;
        margin-top: 6px; font-size: .72rem; font-weight: 700;
        color: var(--gold-dark); background: var(--gold-bg);
        border: 1px solid var(--gold-border);
        border-radius: var(--radius-pill); padding: 3px 10px;
        text-decoration: none; transition: all var(--tr);
    }
    .cpc-link:hover { background: var(--gold); color: #fff; text-decoration: none; }

    /* Input area */
    .chat-input-area {
        background: var(--bg-card); border-top: 1px solid var(--border-light);
        padding: 12px 16px; flex-shrink: 0;
    }
    .chat-input-wrap {
        display: flex; align-items: flex-end; gap: 10px;
    }
    .ci-box {
        flex: 1; background: var(--bg-page);
        border: 1.5px solid var(--border); border-radius: var(--radius-lg);
        padding: 9px 14px; transition: border-color var(--tr), box-shadow var(--tr);
    }
    .ci-box:focus-within { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-glow); }
    #chatInput {
        width: 100%; border: none; background: transparent; resize: none;
        font-family: inherit; font-size: .88rem; color: var(--text-dark);
        outline: none; min-height: 22px; max-height: 110px; overflow-y: auto;
        line-height: 1.5;
    }
    #chatInput::placeholder { color: var(--text-muted); }

    .ci-hints { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 5px; }
    .ci-hint {
        font-size: .7rem; font-weight: 700; color: var(--text-light);
        background: var(--border-light); border-radius: var(--radius-pill);
        padding: 3px 9px; cursor: pointer; transition: all var(--tr);
        border: 1px solid transparent;
    }
    .ci-hint:hover { color: var(--primary); background: var(--primary-bg); border-color: var(--primary-border); }

    .ci-right { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; flex-shrink: 0; }
    .chat-send-btn {
        width: 44px; height: 44px; border-radius: 50%;
        background: linear-gradient(135deg,var(--primary-dark),var(--primary));
        border: none; color: #fff; font-size: 1rem;
        cursor: pointer; display: flex; align-items: center; justify-content: center;
        transition: transform var(--tr), box-shadow var(--tr);
        box-shadow: var(--shadow-primary);
    }
    .chat-send-btn:hover:not(:disabled) { transform: scale(1.1) translateY(-2px); box-shadow: 0 6px 20px rgba(139,21,32,0.45); }
    .chat-send-btn:disabled { opacity: .45; cursor: not-allowed; transform: none; }
    .char-count { font-size: .65rem; color: var(--text-muted); }
    .char-count.warn  { color: var(--warning); }
    .char-count.over  { color: var(--danger);  }

    /* Responsive */
    @media(max-width:768px) {
        html,body { overflow: auto; }
        .chat-page { flex-direction: column; height: auto; }
        .chat-sidebar { width: 100%; flex-direction: row; flex-wrap: wrap; padding: 12px; gap: 8px; }
        .sb-bot-card { display: none; }
        .chat-messages { min-height: 50vh; }
        .msg-bubble { max-width: 82%; }
    }
    @media(max-width:480px) {
        .ct-right { display: none; }
        .msg-bubble { font-size: .82rem; padding: 9px 12px; }
        .chat-input-area { padding: 10px 10px; }
    }
    </style>

    <%-- ═══════════════════════════════════════════════════════════════
         FIX: All JS is declared HERE in <head> so that onclick=""
         attributes on sidebar buttons (rendered after navbar include)
         can find qSend(), hint(), clearChat(), sendMessage() etc.
         Previously the <script> block was at the bottom of <body>
         which caused: "Uncaught ReferenceError: qSend is not defined"
    ════════════════════════════════════════════════════════════════ --%>
    <script>
    // ══════════════════════════════════════════════════════════════
    //  SakhiMart Chatbot — Client Controller
    //  NOTE: Declared in <head> so sidebar onclick handlers resolve.
    // ══════════════════════════════════════════════════════════════
    const CTX      = "<%= request.getContextPath() %>";
    const ROLE     = "<%= chatRole %>";
    const USERNAME = "<%= chatFirst %>";

    // DOM refs resolved after DOMContentLoaded
    let $msgs, $input, $sendBtn, $typing, $charCnt;
    let history = [];
    let busy    = false;

    document.addEventListener('DOMContentLoaded', function () {
        $msgs    = document.getElementById('chatMessages');
        $input   = document.getElementById('chatInput');
        $sendBtn = document.getElementById('sendBtn');
        $typing  = document.getElementById('typingRow');
        $charCnt = document.getElementById('charCount');

        // Set welcome time
        document.getElementById('welcomeTime').textContent = now();
        $input.focus();
    });

    // ── Helpers ──────────────────────────────────────────────────
    function now() {
        return new Date().toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit',hour12:true});
    }
    function scrollDown() {
        $msgs.scrollTo({ top: $msgs.scrollHeight, behavior: 'smooth' });
    }
    function setTyping(show) {
        $typing.classList.toggle('show', show);
        if (show) scrollDown();
    }

    // ── Input handlers ────────────────────────────────────────────
    function handleInput(el) {
        el.style.height = 'auto';
        el.style.height = Math.min(el.scrollHeight, 110) + 'px';
        const len = el.value.length;
        $charCnt.textContent = len + '/500';
        $charCnt.className = 'char-count' + (len > 450 ? ' warn' : '') + (len >= 500 ? ' over' : '');
    }
    function handleKey(e) {
        if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
    }

    // ── Quick-send / hint (called by sidebar & chip onclick) ──────
    function qSend(text) {
        // $input may not exist yet if called before DOMContentLoaded
        // (shouldn't happen for clicks, but guard anyway)
        if (!$input) {
            $input   = document.getElementById('chatInput');
            $sendBtn = document.getElementById('sendBtn');
            $msgs    = document.getElementById('chatMessages');
            $typing  = document.getElementById('typingRow');
            $charCnt = document.getElementById('charCount');
        }
        $input.value = text;
        handleInput($input);
        sendMessage();
    }
    function hint(text) {
        if (!$input) $input = document.getElementById('chatInput');
        $input.value = text;
        $input.focus();
        handleInput($input);
    }

    // ── Clear chat ────────────────────────────────────────────────
    function clearChat() {
        history = [];
        document.querySelectorAll('.msg-row:not(#welcomeRow):not(#typingRow)').forEach(r => r.remove());
        document.getElementById('welcomeRow').style.display = 'flex';
    }

    // ── Append bubble ─────────────────────────────────────────────
    function addBubble(role, content, isHTML) {
        const row = document.createElement('div');
        row.className = 'msg-row' + (role === 'user' ? ' user-row' : '');

        const av = document.createElement('div');
        av.className = 'msg-av ' + (role === 'user' ? 'user' : 'bot');
        av.textContent = role === 'user'
            ? (USERNAME ? USERNAME[0].toUpperCase() : 'U') : '\uD83C\uDF38';

        const bubble = document.createElement('div');
        bubble.className = 'msg-bubble ' + (role === 'user' ? 'user' : 'bot');
        if (isHTML) bubble.innerHTML = content;
        else bubble.innerHTML = fmtText(content);

        const t = document.createElement('span');
        t.className = 'msg-time';
        t.textContent = now();
        bubble.appendChild(t);

        row.appendChild(av);
        row.appendChild(bubble);
        $msgs.insertBefore(row, $typing);
        scrollDown();
    }

    function fmtText(text) {
        return '<p>' + text
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/\n\n/g, '</p><p>')
            .replace(/\n/g, '<br>') + '</p>';
    }

    // ── Product cards ─────────────────────────────────────────────
    function addProductCards(products) {
        if (!products || !products.length) return;
        const row = document.createElement('div');
        row.className = 'msg-row';

        const av = document.createElement('div');
        av.className = 'msg-av bot';
        av.textContent = '\uD83C\uDF38';

        const wrap = document.createElement('div');
        wrap.style.cssText = 'display:flex;flex-direction:column;gap:7px;max-width:68%';

        products.slice(0, 4).forEach(function (p) {
            const card = document.createElement('div');
            card.className = 'chat-product-card';
            const imgSrc = p.image
                ? CTX + '/images/products/' + p.image.replace(/.*[\\\/]/, '')
                : CTX + '/images/products/default.jpg';
            card.innerHTML =
                '<img class="cpc-img" src="' + imgSrc + '" alt="' + esc(p.name) + '" onerror="this.style.display=\'none\'">' +
                '<div class="cpc-info">' +
                  '<div class="cpc-name">' + esc(p.name) + '</div>' +
                  '<div class="cpc-cat">&#127808; ' + esc(p.category) + '</div>' +
                  '<div class="cpc-price">&#8377; ' + parseFloat(p.price).toFixed(2) + '</div>' +
                  '<a href="' + CTX + '/ProductServlet?action=detail&id=' + p.id + '" class="cpc-link">View &#8594;</a>' +
                '</div>';
            wrap.appendChild(card);
        });

        const t = document.createElement('span');
        t.className = 'msg-time';
        t.textContent = now();
        wrap.appendChild(t);

        row.appendChild(av);
        row.appendChild(wrap);
        $msgs.insertBefore(row, $typing);
        scrollDown();
    }

    function esc(str) {
        const d = document.createElement('div');
        d.appendChild(document.createTextNode(str || ''));
        return d.innerHTML;
    }

    // ── Send message ──────────────────────────────────────────────
    async function sendMessage() {
        const text = $input.value.trim();
        if (!text || busy) return;

        busy = true;
        $sendBtn.disabled = true;
        document.getElementById('welcomeRow').style.display = 'none';

        addBubble('user', text);
        $input.value = '';
        $input.style.height = 'auto';
        $charCnt.textContent = '0/500';

        history.push({ role: 'user', content: text });
        setTyping(true);

        try {
            const res = await fetch(CTX + '/ChatbotServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message:  text,
                    history:  history.slice(-10),
                    userRole: ROLE
                })
            });

            if (!res.ok) throw new Error('HTTP ' + res.status);
            const data = await res.json();
            setTyping(false);

            if (data.reply) {
                history.push({ role: 'assistant', content: data.reply });
                addBubble('assistant', data.reply);
            }
            if (data.products && data.products.length > 0) {
                addProductCards(data.products);
            }

        } catch (err) {
            setTyping(false);
            addBubble('assistant',
                '&#128561; Something went wrong. Please ' +
                '<a href="' + CTX + '/jsp/chatbot/chatbot.jsp" style="color:var(--primary);font-weight:700">try again</a>' +
                ' or browse ' +
                '<a href="' + CTX + '/ProductServlet?action=list" style="color:var(--primary);font-weight:700">products directly</a>.',
                true);
            console.error('Chat error:', err);
        }

        busy = false;
        $sendBtn.disabled = false;
        $input.focus();
    }
    </script>
</head>
<body>
<%@ include file="../common/navbar.jsp" %>

<div class="chat-page">

    <!-- ════ SIDEBAR ════ -->
    <aside class="chat-sidebar">
        <div class="sb-bot-card">
            <div class="sb-bot-ring">&#127800;</div>
            <div class="sb-bot-name">Sakhi Assistant</div>
            <div class="sb-bot-tag">AI Shopping Helper</div>
            <div class="sb-online"><span class="sb-dot"></span>Online</div>
            <% if (!chatFirst.equals("Guest")) { %>
            <div style="margin-top:12px; padding:10px 12px; background:rgba(255,255,255,0.07); border:1px solid rgba(255,255,255,0.12); border-radius:var(--radius-md); text-align:left;">
                <div style="font-size:.65rem; color:rgba(255,255,255,0.45); text-transform:uppercase; letter-spacing:.08em; font-weight:800; margin-bottom:4px;">Signed in as</div>
                <div style="font-size:.88rem; font-weight:800; color:#fff;">&#128100; <%= chatName %></div>
                <div style="font-size:.7rem; color:rgba(255,255,255,0.55); margin-top:2px; text-transform:capitalize;">
                    <% if("customer".equals(chatRole)){ %>&#128722; Customer<% } else if("member".equals(chatRole)){ %>&#127800; SHG Member<% } else if("admin".equals(chatRole)){ %>&#9989; Admin<% } %>
                </div>
            </div>
            <% } else { %>
            <div style="margin-top:10px;">
                <a href="<%= request.getContextPath() %>/jsp/auth/login.jsp"
                   style="display:block; text-align:center; font-size:.75rem; font-weight:700;
                          background:rgba(201,144,32,0.2); border:1px solid rgba(201,144,32,0.4);
                          color:var(--gold-light); border-radius:var(--radius-pill); padding:6px 14px;
                          text-decoration:none; transition:all var(--tr);">
                    &#128274; Sign in for full access
                </a>
            </div>
            <% } %>
        </div>

        <% if ("member".equals(chatRole)) { %>
        <!-- Member-specific quick buttons -->
        <div>
            <div class="sb-section-label">&#9889; Member Help</div>
            <button class="sb-quick-btn member-btn" onclick="qSend('How do I upload a product?')">
                <span class="qb-icon">&#128229;</span> Upload a product
            </button>
            <button class="sb-quick-btn member-btn" onclick="qSend('Why is my product not approved yet?')">
                <span class="qb-icon">&#9203;</span> Approval status
            </button>
            <button class="sb-quick-btn member-btn" onclick="qSend('How do I update my product price?')">
                <span class="qb-icon">&#9999;</span> Edit product
            </button>
            <button class="sb-quick-btn member-btn" onclick="qSend('What categories can I sell in?')">
                <span class="qb-icon">&#127873;</span> Product categories
            </button>
            <button class="sb-quick-btn member-btn" onclick="qSend('How do I track my sales and orders?')">
                <span class="qb-icon">&#128202;</span> Sales &amp; orders
            </button>
        </div>
        <% } else { %>
        <!-- Customer / Guest quick buttons -->
        <div>
            <div class="sb-section-label">&#9889; Quick Ask</div>
            <button class="sb-quick-btn" onclick="qSend('What products do you have?')">
                <span class="qb-icon">&#127873;</span> Browse products
            </button>
            <button class="sb-quick-btn" onclick="qSend('Show me pickle products')">
                <span class="qb-icon">&#129748;</span> Pickles &amp; food
            </button>
            <button class="sb-quick-btn" onclick="qSend('Show me handicraft items')">
                <span class="qb-icon">&#127912;</span> Handicrafts
            </button>
            <button class="sb-quick-btn" onclick="qSend('How do I place an order?')">
                <span class="qb-icon">&#128717;</span> How to order
            </button>
            <button class="sb-quick-btn" onclick="qSend('How do I track my order?')">
                <span class="qb-icon">&#128202;</span> Track order
            </button>
            <button class="sb-quick-btn" onclick="qSend('Can I return a product?')">
                <span class="qb-icon">&#128504;</span> Returns
            </button>
        </div>
        <% } %>

        <div class="sb-disclaimer">
            &#128274; Sakhi AI uses the Anthropic Claude model. Product data is fetched live from our database.
        </div>
    </aside>

    <!-- ════ CHAT MAIN ════ -->
    <main class="chat-main">

        <!-- Top bar -->
        <div class="chat-topbar">
            <div class="ct-left">
                <div class="ct-avatar">&#127800;</div>
                <div class="ct-info">
                    <strong>Sakhi AI Assistant</strong>
                    <% if (!chatFirst.equals("Guest")) { %>
                    <span>
                        Hi <strong style="color:var(--primary)"><%= chatFirst %></strong>
                        &nbsp;&middot;&nbsp;
                        <% if("customer".equals(chatRole)){ %>&#128722; Customer<% } else if("member".equals(chatRole)){ %>&#127800; SHG Member<% } else if("admin".equals(chatRole)){ %>&#9989; Admin<% } %>
                    </span>
                    <% } else { %>
                    <span>You're chatting as a <strong>Guest</strong> &mdash; <a href="<%= request.getContextPath() %>/jsp/auth/login.jsp" style="color:var(--primary);font-weight:700;">sign in</a> for more</span>
                    <% } %>
                </div>
            </div>
            <div class="ct-right">
                <button class="ct-btn" onclick="clearChat()">&#128465; Clear</button>
                <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="ct-btn">&#127873; Shop</a>
            </div>
        </div>

        <!-- Messages -->
        <div class="chat-messages" id="chatMessages">
            <!-- Welcome bubble -->
            <div class="msg-row" id="welcomeRow">
                <div class="msg-av bot">&#127800;</div>
                <div>
                    <div class="msg-bubble bot">
                        <div class="welcome-card">
                            <span class="wc-emoji">&#128522;</span>
                            <% if (chatFirst.equals("Guest")) { %>
                            <h3>Namaste, Guest! &#128075;</h3>
                            <p>I'm <strong>Sakhi</strong>, your AI shopping assistant.
                               <a href="<%= request.getContextPath() %>/jsp/auth/login.jsp" style="color:var(--primary);font-weight:700;">Sign in</a>
                               to get a personalised experience — track orders, get tailored recommendations, and more!
                            </p>
                            <% } else if ("member".equals(chatRole)) { %>
                            <h3>Welcome back, <%= chatFirst %>! &#127800;</h3>
                            <p>Great to see you, <strong><%= chatName %></strong>! I'm <strong>Sakhi</strong>, your AI assistant.
                               I can guide you on uploading products, understanding approval, managing your listings, and more!
                            </p>
                            <% } else if ("admin".equals(chatRole)) { %>
                            <h3>Hello, <%= chatFirst %>! &#9989;</h3>
                            <p>Welcome, <strong>Admin <%= chatName %></strong>! I'm <strong>Sakhi</strong>. Ask me anything about managing products, users, orders, or platform queries.</p>
                            <% } else { %>
                            <h3>Namaste, <%= chatFirst %>! &#128591;</h3>
                            <p>Good to see you, <strong><%= chatName %></strong>! I'm <strong>Sakhi</strong>, your AI shopping assistant.
                               Ask me about handmade products, your orders, delivery, payments — I'm here to help!
                            </p>
                            <% } %>
                            <div class="wc-chips">
                                <% if ("member".equals(chatRole)) { %>
                                <span class="wc-chip" onclick="qSend('How do I upload a product?')">&#128229; Upload</span>
                                <span class="wc-chip" onclick="qSend('Why is my product pending approval?')">&#9203; Approval</span>
                                <span class="wc-chip" onclick="qSend('What is the product approval process?')">&#9989; Process</span>
                                <% } else { %>
                                <span class="wc-chip" onclick="qSend('Show popular products')">&#11088; Popular</span>
                                <span class="wc-chip" onclick="qSend('I want to buy pickles')">&#129748; Pickles</span>
                                <span class="wc-chip" onclick="qSend('Show textile products')">&#129525; Textiles</span>
                                <span class="wc-chip" onclick="qSend('How does SakhiMart work?')">&#10067; About</span>
                                <% } %>
                            </div>
                        </div>
                        <span class="msg-time" id="welcomeTime"></span>
                    </div>
                </div>
            </div>

            <!-- Typing indicator -->
            <div class="msg-row typing-row" id="typingRow">
                <div class="msg-av bot">&#127800;</div>
                <div class="typing-dots"><span></span><span></span><span></span></div>
            </div>
        </div><!-- /chat-messages -->

        <!-- Input area -->
        <div class="chat-input-area">
            <div class="chat-input-wrap">
                <div style="flex:1">
                    <div class="ci-box">
                        <textarea id="chatInput" rows="1" maxlength="500"
                            placeholder="<% if("member".equals(chatRole)){%>Hi <%= chatFirst %>, ask about uploading, approval or listings...<%}else if("admin".equals(chatRole)){%>Ask about users, products, orders...<%}else if(chatFirst.equals("Guest")){%>Ask about products, sign in to track your orders...<%}else{%>Hi <%= chatFirst %>, ask about products, orders, delivery...<%}%>"
                            onkeydown="handleKey(event)" oninput="handleInput(this)"></textarea>
                    </div>
                    <div class="ci-hints">
                        <% if ("member".equals(chatRole)) { %>
                        <span class="ci-hint" onclick="hint('How do I upload a product?')">Upload</span>
                        <span class="ci-hint" onclick="hint('What are the product categories?')">Categories</span>
                        <span class="ci-hint" onclick="hint('My product is rejected, what do I do?')">Rejected?</span>
                        <% } else { %>
                        <span class="ci-hint" onclick="hint('Show food products')">&#127857; Food</span>
                        <span class="ci-hint" onclick="hint('Show handicraft items')">&#127912; Crafts</span>
                        <span class="ci-hint" onclick="hint('How to track my order?')">Track order</span>
                        <span class="ci-hint" onclick="hint('What payment modes are accepted?')">Payments</span>
                        <% } %>
                    </div>
                </div>
                <div class="ci-right">
                    <button class="chat-send-btn" id="sendBtn" onclick="sendMessage()" title="Send">&#10148;</button>
                    <span class="char-count" id="charCount">0/500</span>
                </div>
            </div>
        </div>

    </main>
</div>

<%@ include file="../common/footer.jsp" %>

</body>
</html>
