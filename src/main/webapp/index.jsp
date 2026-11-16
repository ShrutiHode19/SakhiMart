<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("a_id") != null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=adminProducts"); return;
    }
    if (session.getAttribute("m_id") != null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=memberProducts"); return;
    }
    if (session.getAttribute("c_id") != null) {
        response.sendRedirect(request.getContextPath() + "/jsp/customer/home.jsp"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SakhiMart &ndash; Handmade with Love</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,800;0,900;1,700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
    /* ═══════════════════════════════════════════════════════════════
       SAKHIMART INDEX — Rich, warm, premium landing page
    ═══════════════════════════════════════════════════════════════ */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
        --maroon:       #8B1520;
        --maroon-dark:  #5a0a12;
        --maroon-deep:  #3d0609;
        --gold:         #c99020;
        --gold-light:   #e8c44e;
        --gold-pale:    #fdf6e3;
        --green:        #1d7a3a;
        --green-light:  #d4edda;
        --cream:        #fdf8f2;
        --white:        #ffffff;
        --text-dark:    #1a0508;
        --text-mid:     #4a2530;
        --text-light:   #7a5560;
        --shadow-gold:  0 4px 20px rgba(201,144,32,0.25);
        --shadow-card:  0 8px 40px rgba(90,10,18,0.10);
        --radius-xl:    20px;
        --radius-pill:  100px;
        --tr:           0.22s ease;
    }

    body {
        font-family: 'DM Sans', sans-serif;
        background: var(--cream);
        color: var(--text-dark);
        overflow-x: hidden;
    }

    /* ════════════════════════════════════
       HERO
    ════════════════════════════════════ */
    .lp-hero {
        position: relative;
        overflow: hidden;
        padding: 0;
        min-height: 88vh;
        display: flex;
        align-items: center;
        background: linear-gradient(145deg, #fdf8f2 0%, #fff5e6 45%, #fdf2f3 100%);
    }

    /* Decorative background shapes */
    .hero-shape-1 {
        position: absolute;
        top: -120px; right: -120px;
        width: 520px; height: 520px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(201,144,32,0.13) 0%, transparent 70%);
        pointer-events: none;
    }
    .hero-shape-2 {
        position: absolute;
        bottom: -80px; left: -100px;
        width: 400px; height: 400px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(139,21,32,0.08) 0%, transparent 70%);
        pointer-events: none;
    }
    .hero-shape-3 {
        position: absolute;
        top: 50%; left: 55%;
        transform: translate(-50%,-50%);
        width: 700px; height: 700px;
        border-radius: 50%;
        border: 1.5px dashed rgba(201,144,32,0.18);
        pointer-events: none;
        animation: spinRing 40s linear infinite;
    }
    @keyframes spinRing { to { transform: translate(-50%,-50%) rotate(360deg); } }

    .hero-inner {
        max-width: 1180px;
        margin: 0 auto;
        padding: 80px 32px 64px;
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 60px;
        align-items: center;
        position: relative;
        z-index: 1;
        width: 100%;
    }

    /* Left col */
    .hero-left { display: flex; flex-direction: column; gap: 0; }

    .hero-eyebrow {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: linear-gradient(135deg, rgba(29,122,58,0.1), rgba(29,122,58,0.05));
        border: 1.5px solid rgba(29,122,58,0.25);
        color: var(--green);
        font-size: .76rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: .12em;
        padding: 5px 16px;
        border-radius: var(--radius-pill);
        margin-bottom: 22px;
        width: fit-content;
        animation: fadeUp 0.7s ease both;
    }
    .eyebrow-dot {
        width: 7px; height: 7px;
        border-radius: 50%;
        background: var(--green);
        animation: pulse 2s ease infinite;
    }
    @keyframes pulse { 0%,100%{transform:scale(1);opacity:1} 50%{transform:scale(1.4);opacity:.6} }

    .hero-title {
        font-family: 'Playfair Display', serif;
        font-size: 3.8rem;
        font-weight: 900;
        line-height: 1.08;
        color: var(--text-dark);
        margin-bottom: 22px;
        animation: fadeUp 0.7s 0.1s ease both;
    }
    .hero-title .line2 { color: var(--maroon); display: block; }
    .hero-title .line3 {
        color: var(--gold);
        font-style: italic;
        display: block;
        font-size: 3.2rem;
    }

    .hero-sub {
        font-size: 1.06rem;
        color: var(--text-mid);
        line-height: 1.78;
        margin-bottom: 36px;
        max-width: 480px;
        animation: fadeUp 0.7s 0.2s ease both;
    }

    .hero-cta-row {
        display: flex;
        gap: 14px;
        flex-wrap: wrap;
        margin-bottom: 40px;
        animation: fadeUp 0.7s 0.3s ease both;
    }

    .btn-hero-primary {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: linear-gradient(135deg, var(--maroon-dark), var(--maroon));
        color: #fff;
        font-weight: 700;
        font-size: .95rem;
        padding: 14px 30px;
        border-radius: var(--radius-pill);
        text-decoration: none;
        box-shadow: 0 6px 24px rgba(139,21,32,0.35);
        transition: transform var(--tr), box-shadow var(--tr), filter var(--tr);
        border: none; cursor: pointer; font-family: inherit;
    }
    .btn-hero-primary:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 32px rgba(139,21,32,0.45);
        filter: brightness(1.08);
        text-decoration: none; color: #fff;
    }

    .btn-hero-gold {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: linear-gradient(135deg, #a07010, var(--gold));
        color: #fff;
        font-weight: 700;
        font-size: .95rem;
        padding: 14px 28px;
        border-radius: var(--radius-pill);
        text-decoration: none;
        box-shadow: var(--shadow-gold);
        transition: transform var(--tr), box-shadow var(--tr), filter var(--tr);
    }
    .btn-hero-gold:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 30px rgba(201,144,32,0.45);
        filter: brightness(1.08);
        text-decoration: none; color: #fff;
    }

    .btn-hero-outline {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: transparent;
        color: var(--maroon);
        font-weight: 700;
        font-size: .92rem;
        padding: 12px 24px;
        border-radius: var(--radius-pill);
        text-decoration: none;
        border: 2px solid rgba(139,21,32,0.3);
        transition: all var(--tr);
    }
    .btn-hero-outline:hover {
        background: rgba(139,21,32,0.06);
        border-color: var(--maroon);
        transform: translateY(-2px);
        text-decoration: none; color: var(--maroon);
    }

    /* Trust pills */
    .trust-row {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        animation: fadeUp 0.7s 0.4s ease both;
    }
    .trust-pill {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: #fff;
        border: 1.5px solid rgba(201,144,32,0.25);
        border-radius: var(--radius-pill);
        padding: 5px 14px;
        font-size: .78rem;
        font-weight: 700;
        color: var(--text-mid);
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }
    .trust-icon { font-size: .9rem; }

    /* Right col — logo showcase */
    .hero-right {
        display: flex;
        justify-content: center;
        align-items: center;
        position: relative;
        animation: fadeUp 0.8s 0.15s ease both;
    }
    .hero-logo-ring {
        position: relative;
        width: 380px;
        height: 380px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .hero-ring-outer {
        position: absolute;
        inset: 0;
        border-radius: 50%;
        border: 2px dashed rgba(201,144,32,0.3);
        animation: spinRing 30s linear infinite reverse;
    }
    .hero-ring-inner {
        position: absolute;
        inset: 28px;
        border-radius: 50%;
        border: 1.5px solid rgba(139,21,32,0.15);
        animation: spinRing 20s linear infinite;
    }
    .hero-logo-bg {
        width: 300px;
        height: 300px;
        border-radius: 50%;
        background: radial-gradient(circle at 40% 40%, #fff 60%, #fdf6e3 100%);
        box-shadow:
            0 20px 60px rgba(139,21,32,0.15),
            0 4px 20px rgba(201,144,32,0.2),
            inset 0 0 0 2px rgba(201,144,32,0.15);
        display: flex;
        align-items: center;
        justify-content: center;
        animation: heroFloat 5s ease-in-out infinite;
          overflow: hidden;    
          inset box-shadow strengthened to 3px gold;
    }
    @keyframes heroFloat {
        0%,100% { transform: translateY(0); }
        50%      { transform: translateY(-14px); }
    }
    .hero-logo-img {
        width: 100%; height: 100%;     
       object-fit: cover; border-radius: 50%;
       filter: drop-shadow(0 4px 12px rgba(139,21,32,0.15));
    }

    /* Floating badge on logo */
    .hero-badge {
        position: absolute;
        bottom: 40px;
        right: 10px;
        background: linear-gradient(135deg, var(--maroon-dark), var(--maroon));
        color: #fff;
        border-radius: 14px;
        padding: 10px 16px;
        text-align: center;
        box-shadow: 0 8px 24px rgba(139,21,32,0.3);
        animation: heroFloat 5s 1s ease-in-out infinite;
    }
    .hero-badge-num { font-size: 1.4rem; font-weight: 900; display: block; color: var(--gold-light); }
    .hero-badge-lbl { font-size: .68rem; font-weight: 700; opacity: .9; letter-spacing: .06em; text-transform: uppercase; }

    .hero-badge-2 {
        position: absolute;
        top: 50px;
        left: 10px;
        background: #fff;
        border: 2px solid rgba(201,144,32,0.3);
        border-radius: 14px;
        padding: 10px 16px;
        text-align: center;
        box-shadow: 0 6px 20px rgba(0,0,0,0.08);
        animation: heroFloat 5s 2.5s ease-in-out infinite;
    }
    .hero-badge-2 .badge2-num { font-size: 1.3rem; font-weight: 900; display: block; color: var(--green); }
    .hero-badge-2 .badge2-lbl { font-size: .68rem; font-weight: 700; color: var(--text-light); letter-spacing: .05em; text-transform: uppercase; }

    @keyframes fadeUp {
        from { opacity:0; transform:translateY(22px); }
        to   { opacity:1; transform:translateY(0); }
    }

    /* ════════════════════════════════════
       STATS STRIP
    ════════════════════════════════════ */
    .stats-strip {
        background: linear-gradient(135deg, var(--maroon-deep) 0%, var(--maroon-dark) 50%, #6b0d18 100%);
        display: flex;
        justify-content: center;
        border-top: 2px solid rgba(201,144,32,0.3);
        border-bottom: 2px solid rgba(201,144,32,0.3);
    }
    .stat-item {
        flex: 1;
        min-width: 120px;
        text-align: center;
        padding: 28px 16px;
        border-right: 1px solid rgba(255,255,255,0.1);
        color: #fff;
        transition: background var(--tr);
    }
    .stat-item:last-child { border-right: none; }
    .stat-item:hover { background: rgba(255,255,255,0.05); }
    .stat-num {
        font-family: 'Playfair Display', serif;
        font-size: 2.4rem;
        font-weight: 900;
        color: var(--gold-light);
        display: block;
        line-height: 1;
        margin-bottom: 4px;
    }
    .stat-num em { font-size: 1.4rem; color: rgba(232,196,78,0.7); font-style: normal; }
    .stat-label {
        font-size: .72rem;
        opacity: .7;
        text-transform: uppercase;
        letter-spacing: .1em;
        font-weight: 700;
    }

    /* ════════════════════════════════════
       SECTION SHELL
    ════════════════════════════════════ */
    .lp-section { padding: 80px 24px; }
    .lp-inner { max-width: 1160px; margin: 0 auto; }

    .sec-eyebrow {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: var(--gold-pale);
        border: 1.5px solid rgba(201,144,32,0.3);
        color: var(--gold);
        font-size: .72rem;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: .12em;
        padding: 4px 14px;
        border-radius: var(--radius-pill);
        margin-bottom: 12px;
    }
    .sec-head {
        font-family: 'Playfair Display', serif;
        font-size: 2.1rem;
        color: var(--text-dark);
        font-weight: 800;
        margin-bottom: 8px;
        line-height: 1.2;
    }
    .sec-head .ac { color: var(--maroon); }
    .sec-sub { color: var(--text-light); font-size: .96rem; line-height: 1.7; max-width: 520px; margin-bottom: 44px; }
    .tc { text-align: center; }
    .tc .sec-sub { margin-left: auto; margin-right: auto; }

    /* ════════════════════════════════════
       HOW IT WORKS
    ════════════════════════════════════ */
    .hiw-bg { background: #fff; }

    .steps-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 24px;
    }
    .step-card {
        background: var(--cream);
        border-radius: var(--radius-xl);
        padding: 36px 24px 28px;
        text-align: center;
        border: 1.5px solid rgba(201,144,32,0.15);
        transition: transform var(--tr), box-shadow var(--tr), border-color var(--tr);
        position: relative;
        overflow: hidden;
    }
    .step-card::after {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 4px;
        background: linear-gradient(90deg, var(--gold), var(--gold-light));
        transform: scaleX(0);
        transform-origin: left;
        transition: transform 0.35s ease;
        border-radius: 4px 4px 0 0;
    }
    .step-card:hover { transform: translateY(-8px); box-shadow: var(--shadow-card); border-color: rgba(201,144,32,0.35); }
    .step-card:hover::after { transform: scaleX(1); }

    .step-num {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 38px; height: 38px;
        background: linear-gradient(135deg, var(--maroon-dark), var(--maroon));
        color: #fff;
        border-radius: 50%;
        font-size: .85rem;
        font-weight: 900;
        margin: 0 auto 16px;
        box-shadow: 0 4px 14px rgba(139,21,32,0.3);
    }
    .step-icon { font-size: 2.6rem; display: block; margin-bottom: 14px; }
    .step-card h3 { font-size: 1.05rem; color: var(--text-dark); margin-bottom: 10px; font-weight: 800; }
    .step-card p { font-size: .87rem; color: var(--text-light); line-height: 1.65; }

    /* ════════════════════════════════════
       CATEGORIES
    ════════════════════════════════════ */
    .cats-bg {
        background: linear-gradient(160deg, #fdf8f2 0%, #fff9ee 60%, #fdf4f4 100%);
        position: relative;
        overflow: hidden;
    }
    .cats-bg::before {
        content: '';
        position: absolute;
        top: -100px; right: -100px;
        width: 360px; height: 360px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(201,144,32,0.1) 0%, transparent 70%);
    }

    .cat-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
        gap: 18px;
    }
    .lp-cat {
        background: #fff;
        border-radius: var(--radius-xl);
        padding: 30px 16px 24px;
        text-align: center;
        text-decoration: none;
        border: 1.5px solid rgba(201,144,32,0.15);
        transition: transform var(--tr), box-shadow var(--tr), border-color var(--tr);
        display: block;
        box-shadow: 0 4px 16px rgba(0,0,0,0.05);
        position: relative;
        overflow: hidden;
    }
    .lp-cat::before {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(135deg, rgba(139,21,32,0.04), rgba(201,144,32,0.04));
        opacity: 0;
        transition: opacity var(--tr);
    }
    .lp-cat:hover { transform: translateY(-6px); box-shadow: 0 16px 40px rgba(139,21,32,0.12); border-color: var(--maroon); text-decoration: none; }
    .lp-cat:hover::before { opacity: 1; }
    .lp-cat:hover .cat-name { color: var(--maroon); }

    .cat-emoji { font-size: 2.6rem; display: block; margin-bottom: 12px; transition: transform var(--tr); }
    .lp-cat:hover .cat-emoji { transform: scale(1.15) rotate(-5deg); }
    .cat-name { font-size: .9rem; font-weight: 800; color: var(--text-dark); display: block; margin-bottom: 4px; transition: color var(--tr); }
    .cat-hint { font-size: .75rem; color: var(--text-light); font-weight: 500; }

    /* ════════════════════════════════════
       TESTIMONIALS / WHY SAKHIMART
    ════════════════════════════════════ */
    .why-bg { background: #fff; }

    .why-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        gap: 24px;
    }
    .why-card {
        background: var(--cream);
        border-radius: var(--radius-xl);
        padding: 30px 26px;
        border: 1.5px solid rgba(201,144,32,0.15);
        display: flex;
        gap: 18px;
        align-items: flex-start;
        transition: transform var(--tr), box-shadow var(--tr);
    }
    .why-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-card); }
    .why-icon-wrap {
        width: 52px; height: 52px;
        border-radius: 14px;
        background: linear-gradient(135deg, var(--maroon-dark), var(--maroon));
        display: flex; align-items: center; justify-content: center;
        font-size: 1.5rem;
        flex-shrink: 0;
        box-shadow: 0 4px 14px rgba(139,21,32,0.25);
    }
    .why-text h3 { font-size: 1rem; font-weight: 800; color: var(--text-dark); margin-bottom: 6px; }
    .why-text p  { font-size: .86rem; color: var(--text-light); line-height: 1.65; }

    /* ════════════════════════════════════
       MISSION BANNER
    ════════════════════════════════════ */
    .mission-sec {
        background: linear-gradient(145deg, var(--maroon-deep) 0%, var(--maroon-dark) 50%, #7a1020 100%);
        padding: 90px 24px;
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    .mission-sec::before {
        content: '';
        position: absolute;
        top: -120px; left: -120px;
        width: 400px; height: 400px;
        border-radius: 50%;
        background: rgba(201,144,32,0.07);
    }
    .mission-sec::after {
        content: '';
        position: absolute;
        bottom: -80px; right: -80px;
        width: 300px; height: 300px;
        border-radius: 50%;
        background: rgba(255,255,255,0.03);
    }
    .mission-inner { max-width: 680px; margin: 0 auto; position: relative; z-index: 1; }

    .mission-logo {
        width: 100px;
        height: auto;
        margin: 0 auto 28px;
        display: block;
        border-radius: 50%;
        background: rgba(255,255,255,0.08);
        padding: 12px;
        box-shadow: 0 0 0 8px rgba(201,144,32,0.12);
        animation: heroFloat 5s ease-in-out infinite;
    }
    .mission-title {
        font-family: 'Playfair Display', serif;
        font-size: 2.3rem;
        color: #fff;
        margin-bottom: 16px;
        font-weight: 800;
        line-height: 1.2;
    }
    .mission-title .mg { color: var(--gold-light); font-style: italic; }
    .mission-text {
        color: rgba(255,255,255,0.85);
        line-height: 1.85;
        font-size: .98rem;
        margin-bottom: 36px;
    }
    .mission-cta { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }

    .btn-white {
        display: inline-flex; align-items: center; gap: 8px;
        background: #fff; color: var(--maroon);
        font-weight: 800; font-size: .95rem;
        padding: 13px 30px; border-radius: var(--radius-pill);
        text-decoration: none;
        box-shadow: 0 6px 20px rgba(0,0,0,0.2);
        transition: all var(--tr);
    }
    .btn-white:hover { transform: translateY(-3px); box-shadow: 0 10px 28px rgba(0,0,0,0.25); text-decoration: none; color: var(--maroon); }

    .btn-outline-white {
        display: inline-flex; align-items: center; gap: 8px;
        background: transparent;
        border: 2px solid rgba(255,255,255,0.5);
        color: rgba(255,255,255,0.92);
        font-weight: 700; font-size: .93rem;
        padding: 11px 26px; border-radius: var(--radius-pill);
        text-decoration: none;
        transition: all var(--tr);
    }
    .btn-outline-white:hover { background: rgba(255,255,255,0.14); border-color: #fff; color: #fff; transform: translateY(-2px); text-decoration: none; }

    /* ════════════════════════════════════
       MEMBER CTA
    ════════════════════════════════════ */
    .mem-bg { background: var(--cream); }

    .mem-card {
        background: linear-gradient(145deg, #fff 0%, var(--gold-pale) 100%);
        border: 2px solid rgba(201,144,32,0.25);
        border-radius: 28px;
        padding: 56px 48px;
        text-align: center;
        max-width: 760px;
        margin: 0 auto;
        box-shadow: 0 20px 60px rgba(201,144,32,0.12), 0 4px 16px rgba(0,0,0,0.05);
        position: relative;
        overflow: hidden;
    }
    .mem-card::before {
        content: '';
        position: absolute;
        top: -60px; right: -60px;
        width: 200px; height: 200px;
        border-radius: 50%;
        background: rgba(201,144,32,0.1);
    }
    .mem-icon { font-size: 3.5rem; display: block; margin-bottom: 18px; }
    .mem-card h2 {
        font-family: 'Playfair Display', serif;
        font-size: 1.9rem;
        color: var(--text-dark);
        margin-bottom: 12px;
        font-weight: 800;
    }
    .mem-card p { color: var(--text-mid); margin-bottom: 30px; font-size: .97rem; line-height: 1.75; max-width: 500px; margin-left: auto; margin-right: auto; }
    .mem-btns { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }

    .btn-maroon {
        display: inline-flex; align-items: center; gap: 8px;
        background: linear-gradient(135deg, var(--maroon-dark), var(--maroon));
        color: #fff; font-weight: 700; font-size: .95rem;
        padding: 13px 28px; border-radius: var(--radius-pill);
        text-decoration: none;
        box-shadow: 0 6px 20px rgba(139,21,32,0.3);
        transition: all var(--tr);
    }
    .btn-maroon:hover { transform: translateY(-3px); box-shadow: 0 10px 28px rgba(139,21,32,0.4); text-decoration: none; color: #fff; }

    .btn-gold {
        display: inline-flex; align-items: center; gap: 8px;
        background: linear-gradient(135deg, #a07010, var(--gold));
        color: #fff; font-weight: 700; font-size: .93rem;
        padding: 11px 24px; border-radius: var(--radius-pill);
        text-decoration: none;
        box-shadow: var(--shadow-gold);
        transition: all var(--tr);
    }
    .btn-gold:hover { transform: translateY(-2px); filter: brightness(1.08); text-decoration: none; color: #fff; }

    /* ════════════════════════════════════
       FLOATING CHATBOT
    ════════════════════════════════════ */
    .chatbot-container {
        position: fixed;
        bottom: 24px; right: 24px;
        z-index: 9999;
    }
    .chatbot-fab {
        width: 62px; height: 62px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--maroon-dark), var(--maroon));
        border: none; color: #fff; font-size: 1.6rem;
        cursor: pointer;
        box-shadow: 0 6px 24px rgba(139,21,32,0.4);
        transition: transform 0.25s, box-shadow 0.25s;
        display: flex; align-items: center; justify-content: center;
    }
    .chatbot-fab:hover { transform: scale(1.1) translateY(-3px); box-shadow: 0 12px 32px rgba(139,21,32,0.5); }

    .chatbox {
        width: 330px;
        background: #fff;
        border-radius: 20px;
        box-shadow: 0 16px 48px rgba(0,0,0,0.18);
        overflow: hidden;
        display: none;
        margin-bottom: 14px;
        border: 1px solid rgba(201,144,32,0.2);
        animation: chatSlideUp 0.28s ease;
    }
    @keyframes chatSlideUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
    .chatbox.open { display: block; }

    .chat-header {
        background: linear-gradient(135deg, var(--maroon-dark), var(--maroon));
        color: #fff;
        padding: 16px 18px;
        font-weight: 800;
        font-size: .95rem;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .chat-header-icon { font-size: 1.3rem; }
    .chat-header-sub { font-size: .72rem; opacity: .75; font-weight: 500; display: block; }

    .chat-body { padding: 18px; }
    .chat-body select {
        width: 100%;
        padding: 10px 14px;
        border-radius: 10px;
        border: 1.5px solid rgba(201,144,32,0.3);
        margin-bottom: 14px;
        font-size: .86rem;
        font-family: inherit;
        color: var(--text-dark);
        background: var(--cream);
        outline: none;
        cursor: pointer;
        transition: border-color var(--tr);
    }
    .chat-body select:focus { border-color: var(--maroon); }
    .chat-response {
        background: var(--cream);
        padding: 14px 16px;
        border-radius: 12px;
        min-height: 72px;
        font-size: .87rem;
        color: var(--text-mid);
        line-height: 1.6;
        border: 1.5px solid rgba(201,144,32,0.15);
    }

    /* ════════════════════════════════════
       FOOTER
    ════════════════════════════════════ */
    .footer {
        background: var(--maroon-deep);
        color: rgba(255,255,255,0.6);
        text-align: center;
        padding: 22px;
        font-size: .82rem;
        border-top: 2px solid rgba(201,144,32,0.25);
    }

    /* ════════════════════════════════════
       RESPONSIVE
    ════════════════════════════════════ */
    @media (max-width: 900px) {
        .hero-inner {
            grid-template-columns: 1fr;
            text-align: center;
            padding: 60px 24px 50px;
        }
        .hero-right { order: -1; }
        .hero-logo-ring { width: 300px; height: 300px; }
        .hero-logo-bg { width: 240px; height: 240px; }
        .hero-logo-img { width: 175px; }
        .hero-badge { bottom: 20px; right: 0; }
        .hero-badge-2 { top: 20px; left: 0; }
        .hero-eyebrow, .trust-row, .hero-cta-row { justify-content: center; }
        .hero-sub { margin: 0 auto 28px; }
        .hero-title { font-size: 2.8rem; }
        .hero-title .line3 { font-size: 2.4rem; }
    }
    @media (max-width: 600px) {
        .hero-title { font-size: 2.2rem; }
        .hero-title .line3 { font-size: 1.9rem; }
        .lp-section { padding: 56px 16px; }
        .stats-strip { flex-wrap: wrap; }
        .stat-item { min-width: 50%; border-right: 1px solid rgba(255,255,255,0.1); }
        .stat-item:nth-child(2n) { border-right: none; }
        .stat-item:nth-child(n+3) { border-top: 1px solid rgba(255,255,255,0.1); }
        .cat-grid { grid-template-columns: repeat(2, 1fr); }
        .mem-card { padding: 36px 22px; }
        .sec-head { font-size: 1.65rem; }
        .hero-logo-ring { width: 240px; height: 240px; }
        .hero-logo-bg { width: 190px; height: 190px; }
        .hero-logo-img { width: 140px; }
    }
    </style>
</head>
<body>

<%@ include file="jsp/common/navbar.jsp" %>

<!-- ════ HERO ════ -->
<section class="lp-hero">
    <div class="hero-shape-1"></div>
    <div class="hero-shape-2"></div>
    <div class="hero-shape-3"></div>

    <div class="hero-inner">

        <!-- Left: Text -->
        <div class="hero-left">
            <div class="hero-eyebrow">
                <span class="eyebrow-dot"></span>
                Women Self-Help Group Marketplace
            </div>

            <h1 class="hero-title">
                Shop Handmade.<br>
                <span class="line2">Support Women.</span>
                <span class="line3">Celebrate India.</span>
            </h1>

            <p class="hero-sub">
                Authentic pickles, snacks, handicrafts &amp; textiles crafted with love by local SHG women.
                Every purchase directly empowers a woman entrepreneur and her family.
            </p>

            <div class="hero-cta-row">
                <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="btn-hero-primary">
                    &#128717; Shop Now
                </a>
                <a href="<%= request.getContextPath() %>/jsp/auth/register.jsp" class="btn-hero-gold">
                    &#128101; Join Free
                </a>
                <a href="<%= request.getContextPath() %>/jsp/auth/login.jsp" class="btn-hero-outline">
                    &#128274; Sign In
                </a>
            </div>

            <div class="trust-row">
                <div class="trust-pill"><span class="trust-icon">&#9989;</span> 100% Handmade</div>
                <div class="trust-pill"><span class="trust-icon">&#127800;</span> Direct from Makers</div>
                <div class="trust-pill"><span class="trust-icon">&#10084;</span> Empowers Women</div>
                <div class="trust-pill"><span class="trust-icon">&#128664;</span> Easy Delivery</div>
            </div>
        </div>

        <!-- Right: Logo showcase -->
        <div class="hero-right">
            <div class="hero-logo-ring">
                <div class="hero-ring-outer"></div>
                <div class="hero-ring-inner"></div>
                <div class="hero-logo-bg">
                    <img src="<%= request.getContextPath() %>/images/sakhilogo.png"
                         alt="SakhiMart"
                         class="hero-logo-img">
                </div>
                <div class="hero-badge">
                    <span class="hero-badge-num">100<em>+</em></span>
                    <span class="hero-badge-lbl">Products</span>
                </div>
                <div class="hero-badge-2">
                    <span class="badge2-num">50+</span>
                    <span class="badge2-lbl">SHG Members</span>
                </div>
            </div>
        </div>

    </div>
</section>

<!-- ════ STATS STRIP ════ -->
<div class="stats-strip">
    <div class="stat-item">
        <span class="stat-num">100<em>+</em></span>
        <span class="stat-label">Products</span>
    </div>
    <div class="stat-item">
        <span class="stat-num">50<em>+</em></span>
        <span class="stat-label">SHG Members</span>
    </div>
    <div class="stat-item">
        <span class="stat-num">6</span>
        <span class="stat-label">Categories</span>
    </div>
    <div class="stat-item">
        <span class="stat-num">100<em>%</em></span>
        <span class="stat-label">Authentic</span>
    </div>
</div>

<!-- ════ HOW IT WORKS ════ -->
<div class="lp-section hiw-bg">
    <div class="lp-inner tc">
        <div class="sec-eyebrow">&#128218; How It Works</div>
        <h2 class="sec-head">Simple, Transparent &amp; <span class="ac">Community-Driven</span></h2>
        <p class="sec-sub">Get started in minutes and directly support women entrepreneurs near you.</p>
        <div class="steps-grid">
            <div class="step-card">
                <div class="step-num">1</div>
                <span class="step-icon">&#128101;</span>
                <h3>Register Free</h3>
                <p>Create your account in seconds — no credit card needed to browse our full catalogue of handmade goods.</p>
            </div>
            <div class="step-card">
                <div class="step-num">2</div>
                <span class="step-icon">&#128269;</span>
                <h3>Browse &amp; Discover</h3>
                <p>Explore authentic products across six curated categories made by skilled SHG women artisans.</p>
            </div>
            <div class="step-card">
                <div class="step-num">3</div>
                <span class="step-icon">&#128722;</span>
                <h3>Shop with Ease</h3>
                <p>Pick your favourites, add to cart and checkout with simple, secure payment options.</p>
            </div>
            <div class="step-card">
                <div class="step-num">4</div>
                <span class="step-icon">&#10084;</span>
                <h3>Empower Lives</h3>
                <p>Every rupee you spend supports a woman's livelihood and builds a brighter future for her family.</p>
            </div>
        </div>
    </div>
</div>

<!-- ════ CATEGORIES ════ -->
<div class="lp-section cats-bg">
    <div class="lp-inner tc">
        <div class="sec-eyebrow">&#127873; Our Catalogue</div>
        <h2 class="sec-head">Shop by <span class="ac">Category</span></h2>
        <p class="sec-sub">From kitchen staples to beautiful handicrafts — discover what our members lovingly make.</p>
        <div class="cat-grid">
            <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Food" class="lp-cat">
                <span class="cat-emoji">&#127857;</span>
                <span class="cat-name">Food &amp; Snacks</span>
                <span class="cat-hint">Papads, chakli &amp; more</span>
            </a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Pickle" class="lp-cat">
                <span class="cat-emoji">&#129748;</span>
                <span class="cat-name">Pickles</span>
                <span class="cat-hint">Mango, lime &amp; mixed</span>
            </a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Handicraft" class="lp-cat">
                <span class="cat-emoji">&#127912;</span>
                <span class="cat-name">Handicrafts</span>
                <span class="cat-hint">Bags, cushions &amp; decor</span>
            </a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Cloth" class="lp-cat">
                <span class="cat-emoji">&#129525;</span>
                <span class="cat-name">Cloth &amp; Textiles</span>
                <span class="cat-hint">Handwoven &amp; stitched</span>
            </a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=search&keyword=Beauty" class="lp-cat">
                <span class="cat-emoji">&#128144;</span>
                <span class="cat-name">Beauty &amp; Wellness</span>
                <span class="cat-hint">Natural &amp; organic</span>
            </a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="lp-cat">
                <span class="cat-emoji">&#127800;</span>
                <span class="cat-name">All Products</span>
                <span class="cat-hint">Browse everything</span>
            </a>
        </div>
    </div>
</div>

<!-- ════ WHY SAKHIMART ════ -->
<div class="lp-section why-bg">
    <div class="lp-inner">
        <div class="tc" style="margin-bottom:44px">
            <div class="sec-eyebrow">&#11088; Why SakhiMart</div>
            <h2 class="sec-head">What Makes Us <span class="ac">Different</span></h2>
            <p class="sec-sub" style="margin-bottom:0">We're not just a marketplace — we're a movement for women's economic empowerment.</p>
        </div>
        <div class="why-grid">
            <div class="why-card">
                <div class="why-icon-wrap">&#127800;</div>
                <div class="why-text">
                    <h3>100% Authentic &amp; Handmade</h3>
                    <p>Every product on SakhiMart is crafted by hand with traditional skills passed down through generations. No mass production, ever.</p>
                </div>
            </div>
            <div class="why-card">
                <div class="why-icon-wrap">&#128105;</div>
                <div class="why-text">
                    <h3>Direct from the Maker</h3>
                    <p>You buy directly from SHG members — no middlemen. More of your money reaches the women who make these beautiful products.</p>
                </div>
            </div>
            <div class="why-card">
                <div class="why-icon-wrap">&#128664;</div>
                <div class="why-text">
                    <h3>Simple &amp; Secure Shopping</h3>
                    <p>Browse, order and track — all from one place. With easy checkout, order tracking and reliable delivery.</p>
                </div>
            </div>
            <div class="why-card">
                <div class="why-icon-wrap">&#10024;</div>
                <div class="why-text">
                    <h3>AI Shopping Assistant</h3>
                    <p>Meet Sakhi — our AI chatbot powered by Claude. Get instant help with product discovery, order queries and more, 24/7.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ════ MISSION ════ -->
<section class="mission-sec">
    <div class="mission-inner">
        <img src="<%= request.getContextPath() %>/images/sakhilogo.png"
             alt="SakhiMart" class="mission-logo">
        <h2 class="mission-title">Our <span class="mg">Mission &amp; Heart</span></h2>
        <p class="mission-text">
            SakhiMart was born from a simple belief — every woman in a Self-Help Group deserves a platform to share her skills and build a sustainable livelihood.
            We connect passionate makers with buyers who value authenticity, quality, and social impact.
            Your purchase is more than a transaction; it is a step toward a better future for a family.
        </p>
        <div class="mission-cta">
            <a href="<%= request.getContextPath() %>/ProductServlet?action=list" class="btn-white">&#128717; Explore Products</a>
            <a href="<%= request.getContextPath() %>/jsp/auth/register.jsp" class="btn-outline-white">&#128101; Join SakhiMart</a>
        </div>
    </div>
</section>

<!-- ════ MEMBER CTA ════ -->
<div class="lp-section mem-bg">
    <div class="lp-inner">
        <div class="mem-card">
            <span class="mem-icon">&#128105;&#127995;</span>
            <h2>Are You an SHG Member?</h2>
            <p>Join SakhiMart as a seller and start listing your handmade products to reach customers across the community. Your craft deserves to be seen, celebrated and rewarded.</p>
            <div class="mem-btns">
                <a href="<%= request.getContextPath() %>/jsp/auth/register.jsp" class="btn-maroon">&#128640; Register as Member</a>
                <a href="<%= request.getContextPath() %>/jsp/auth/login.jsp" class="btn-gold">&#128274; Member Login</a>
            </div>
        </div>
    </div>
</div>

<%@ include file="jsp/common/footer.jsp" %>

<!-- ════ FLOATING CHATBOT ════ -->
<div class="chatbot-container">
    <div class="chatbox" id="chatbox">
        <div class="chat-header">
            <span class="chat-header-icon">&#127800;</span>
            <div>
               Quick Help 
                <span class="chat-header-sub">Ask me anything about SakhiMart</span>
            </div>
        </div>
        <div class="chat-body">
            <select id="questionSelect" onchange="showAnswer()">
                <option value="">&#128172; Select a question…</option>
                <option value="products">What products are available?</option>
                <option value="register">How can I register?</option>
                <option value="seller">How to become a seller?</option>
                <option value="login">How do I login?</option>
                <option value="payment">What payment methods are available?</option>
                <option value="mission">What is SakhiMart's mission?</option>
                <option value="ai">What is Sakhi AI?</option>
            </select>
            <div class="chat-response" id="chatResponse">
                &#128075; Hello! Select a question above to get started.
            </div>
        </div>
    </div>
    <button class="chatbot-fab" onclick="toggleChatbot()" title="Chat with us">&#128172;</button>
</div>

<script>
function toggleChatbot() {
    var box = document.getElementById('chatbox');
    box.classList.toggle('open');
}
function showAnswer() {
    var q = document.getElementById('questionSelect').value;
    var r = document.getElementById('chatResponse');
    var answers = {
        products: '&#127800; SakhiMart offers handmade snacks, pickles, handicrafts, textiles, beauty products, and more — all crafted by SHG women.',
        register: '&#128101; Click <strong>Join Free</strong> on the homepage or go to the Register page. It\'s completely free!',
        seller:   '&#128105; SHG members can register and start listing handmade products for sale. Choose the <em>Member</em> role when registering.',
        login:    '&#128274; Click the <strong>Sign In</strong> button on the homepage or in the navbar.',
        payment:  '&#128179; Cash on delivery and online payment options are currently available at checkout.',
        mission:  '&#10084; SakhiMart empowers women entrepreneurs by connecting SHG handmade products directly with customers — no middlemen.',
        ai:       '&#10024; Sakhi AI is our intelligent assistant powered by Claude. Log in and visit <strong>Sakhi AI</strong> in the navbar for smart product search and order help!'
    };
    r.innerHTML = answers[q] || '&#128172; Please select a question above.';
}
</script>

</body>
</html>
