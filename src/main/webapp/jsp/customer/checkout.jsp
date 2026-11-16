<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.CartItem" %>
<%
    if (session.getAttribute("c_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    double cartTotal  = (double) request.getAttribute("cartTotal");
    double shipping   = cartTotal < 500 ? 50.0 : 0.0;
    double grandTotal = cartTotal + shipping;
    String msg        = request.getParameter("msg");
    String c_address  = "";
    model.Customer sessionCustomer = (model.Customer) session.getAttribute("user");
    if (sessionCustomer != null && sessionCustomer.getC_address() != null) {
        c_address = sessionCustomer.getC_address();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Checkout – SakhiMart</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
<style>
/* ── Layout ── */
.checkout-wrap {
    max-width: 1100px; margin: 28px auto;
    padding: 0 18px 56px;
    display: grid; grid-template-columns: 1fr 360px;
    gap: 24px; align-items: start;
}
@media(max-width:820px){ .checkout-wrap{ grid-template-columns:1fr; } }

/* ── Steps ── */
.checkout-steps {
    display:flex; align-items:center;
    max-width:1100px; margin:20px auto 0; padding:0 18px;
}
.step { display:flex; align-items:center; gap:8px; font-size:.85rem; font-weight:700; color:var(--text-light); }
.step.active { color:var(--primary); }
.step.done   { color:var(--success); }
.step-num {
    width:30px; height:30px; border-radius:50%;
    background:var(--border-light); border:2px solid var(--border);
    display:flex; align-items:center; justify-content:center;
    font-weight:800; font-size:.82rem;
}
.step.active .step-num { background:var(--primary); border-color:var(--primary); color:#fff; box-shadow:0 2px 10px rgba(139,21,32,.35); }
.step.done   .step-num { background:var(--success);  border-color:var(--success);  color:#fff; }
.step-line { flex:1; height:2px; background:var(--border-light); margin:0 8px; min-width:36px; }

/* ── Cards ── */
.checkout-card {
    background:var(--bg-card); border-radius:var(--radius-lg);
    box-shadow:var(--shadow-md); overflow:hidden;
    border:1px solid var(--border-light);
}
.checkout-card-header {
    background:linear-gradient(135deg,var(--primary-dark),var(--primary),var(--primary-light));
    padding:16px 24px; border-bottom:2px solid rgba(201,144,32,.35);
}
.checkout-card-header h2 {
    font-family:'Playfair Display',serif; color:#fff;
    font-size:1.15rem; font-weight:800; margin:0;
}
.checkout-body { padding:24px 26px; }

/* ── Payment option tiles ── */
.payment-options {
    display:grid; grid-template-columns:repeat(3,1fr);
    gap:12px; margin-bottom:20px;
}
@media(max-width:500px){ .payment-options{ grid-template-columns:1fr; } }

.payment-option { position:relative; }
.payment-option input[type="radio"] { position:absolute; opacity:0; width:0; height:0; }
.payment-label {
    display:flex; flex-direction:column; align-items:center;
    justify-content:center; gap:7px; padding:18px 10px;
    border:2px solid var(--border); border-radius:var(--radius-md);
    cursor:pointer; text-align:center; transition:all .2s;
    font-weight:700; font-size:.84rem; color:var(--text-mid);
    background:var(--bg-page); user-select:none;
}
.payment-label .pay-icon { font-size:1.7rem; }
.payment-option input:checked + .payment-label {
    border-color:var(--primary); background:var(--primary-bg);
    color:var(--primary); box-shadow:0 0 0 3px var(--primary-glow);
}
.payment-label:hover {
    border-color:var(--primary); background:var(--primary-bg);
    transform:translateY(-2px); box-shadow:var(--shadow-sm);
}

/* ── Payment detail forms ── */
.pay-detail-box {
    display:none;
    background:var(--bg-page); border:1.5px solid var(--border);
    border-radius:var(--radius-md); padding:22px 20px;
    margin-top:4px; animation:slideDown .25s ease;
}
.pay-detail-box.active { display:block; }
@keyframes slideDown { from{opacity:0;transform:translateY(-8px)} to{opacity:1;transform:translateY(0)} }

.pay-detail-box h4 {
    font-size:.92rem; font-weight:800; color:var(--primary);
    margin:0 0 14px; display:flex; align-items:center; gap:7px;
}

/* UPI QR mock */
.upi-row { display:flex; gap:20px; align-items:flex-start; flex-wrap:wrap; }
.upi-qr-box {
    flex-shrink:0; width:110px; height:110px;
    background:#fff; border:2px solid var(--border);
    border-radius:var(--radius-sm); display:flex;
    flex-direction:column; align-items:center; justify-content:center;
    gap:4px; font-size:.65rem; color:var(--text-light); font-weight:700;
    box-shadow:var(--shadow-xs);
}
.upi-qr-box .qr-grid {
    display:grid; grid-template-columns:repeat(5,8px);
    grid-template-rows:repeat(5,8px); gap:2px;
}
.qr-cell { border-radius:1px; }
.upi-fields { flex:1; min-width:180px; display:flex; flex-direction:column; gap:10px; }
.upi-id-display {
    background:var(--primary-bg); border:1px solid var(--primary-border);
    border-radius:var(--radius-sm); padding:8px 14px;
    font-size:.82rem; font-weight:800; color:var(--primary);
    display:flex; align-items:center; gap:8px;
}

/* Card form grid */
.card-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
@media(max-width:480px){ .card-grid{ grid-template-columns:1fr; } }
.card-grid .span2 { grid-column:1/-1; }

/* Card preview */
.card-preview {
    background:linear-gradient(135deg,var(--primary-dark),var(--primary),#c0392b);
    border-radius:var(--radius-md); padding:18px 20px;
    color:#fff; margin-bottom:16px; position:relative; overflow:hidden;
    box-shadow:var(--shadow-primary);
}
.card-preview::before {
    content:''; position:absolute; top:-30px; right:-30px;
    width:120px; height:120px; border-radius:50%;
    background:rgba(255,255,255,.08);
}
.card-preview::after {
    content:''; position:absolute; bottom:-20px; left:-10px;
    width:90px; height:90px; border-radius:50%;
    background:rgba(255,255,255,.06);
}
.cp-chip { width:36px; height:26px; background:linear-gradient(135deg,#d4af37,#f5d76e); border-radius:4px; margin-bottom:12px; }
.cp-number { font-size:1.05rem; font-weight:700; letter-spacing:.18em; font-family:monospace; margin-bottom:12px; opacity:.9; }
.cp-row { display:flex; justify-content:space-between; font-size:.72rem; opacity:.8; }
.cp-label { font-size:.6rem; opacity:.65; text-transform:uppercase; letter-spacing:.06em; }

/* COD info box */
.cod-box {
    display:none; background:var(--success-bg);
    border:1.5px solid var(--success-border);
    border-radius:var(--radius-md); padding:16px 18px;
    font-size:.86rem; color:var(--success); font-weight:600;
    display:flex; gap:10px; align-items:flex-start; margin-top:4px;
}
.cod-box .cod-icon { font-size:1.5rem; flex-shrink:0; }

/* ── Summary Card ── */
.summary-card {
    background:var(--bg-card); border-radius:var(--radius-lg);
    box-shadow:var(--shadow-md); overflow:hidden;
    position:sticky; top:84px; border:1px solid var(--border-light);
}
.summary-header {
    background:linear-gradient(135deg,var(--gold-dark),var(--gold),var(--gold-light));
    padding:16px 22px; border-bottom:2px solid rgba(139,21,32,.15);
}
.summary-header h3 {
    font-family:'Playfair Display',serif; color:#fff;
    font-size:1.1rem; font-weight:800; text-shadow:0 1px 4px rgba(0,0,0,.2); margin:0;
}
.summary-items { padding:14px 22px; }
.summary-item {
    display:flex; justify-content:space-between; align-items:center;
    padding:8px 0; border-bottom:1px solid var(--border-light); font-size:.86rem;
}
.summary-item:last-child { border-bottom:none; }
.summary-item-name  { color:var(--text-dark); font-weight:600; flex:1; }
.summary-item-qty   { color:var(--text-light); margin:0 10px; font-weight:600; }
.summary-item-price { color:var(--primary); font-weight:800; }
.summary-divider    { height:2px; background:var(--gold-border); margin:0 22px; }
.summary-totals     { padding:12px 22px; }
.summary-row {
    display:flex; justify-content:space-between;
    font-size:.88rem; color:var(--text-mid); padding:6px 0;
}
.summary-row .lbl { font-weight:600; }
.summary-row .val { font-weight:700; color:var(--text-dark); }
.summary-grand {
    display:flex; justify-content:space-between;
    border-top:2px solid var(--gold-border);
    margin-top:10px; padding-top:14px;
}
.summary-grand .lbl { font-weight:800; color:var(--text-dark); font-size:1rem; }
.summary-grand .val { font-weight:900; color:var(--primary); font-size:1.25rem; }
.btn-place-order {
    display:block; width:calc(100% - 44px); margin:14px 22px 16px;
    background:linear-gradient(135deg,var(--primary-dark),var(--primary),var(--primary-light));
    color:#fff; border:none; padding:15px; border-radius:var(--radius-pill);
    font-size:1rem; font-weight:800; letter-spacing:.4px; cursor:pointer;
    box-shadow:var(--shadow-primary); transition:transform var(--tr),box-shadow var(--tr),filter var(--tr);
}
.btn-place-order:hover { transform:translateY(-2px); box-shadow:0 10px 30px rgba(139,21,32,.4); filter:brightness(1.07); }
.secure-note {
    text-align:center; font-size:.76rem; color:var(--text-light);
    padding:0 22px 18px; font-weight:600;
}
.secure-note span { color:var(--success); }
.flash-bar { max-width:1100px; margin:16px auto 0; padding:0 18px; }
.req { color:var(--danger); }
</style>
</head>
<body>
<%@ include file="../common/navbar.jsp" %>

<div class="page-header"><h2>&#128203; Checkout</h2></div>

<!-- Steps -->
<div class="checkout-steps">
    <div class="step done"><div class="step-num">&#10003;</div> Cart</div>
    <div class="step-line"></div>
    <div class="step active"><div class="step-num">2</div> Checkout</div>
    <div class="step-line"></div>
    <div class="step"><div class="step-num">3</div> Confirmation</div>
</div>

<!-- Flash -->
<div class="flash-bar">
    <% if ("fill_all".equals(msg)) { %>
        <div class="alert alert-error">&#10005; Please fill in all required fields.</div>
    <% } else if ("stock_error".equals(msg)) { %>
        <div class="alert alert-warning">&#9888; Some items are out of stock. Please update your cart.</div>
    <% } else if ("error".equals(msg)) { %>
        <div class="alert alert-error">&#10005; Order failed. Please try again.</div>
    <% } %>
</div>

<form action="<%= request.getContextPath() %>/OrderServlet" method="post" id="checkoutForm">
    <input type="hidden" name="action" value="placeOrder">
    <!-- Hidden fields for UPI / Card details (populated by JS) -->
    <input type="hidden" name="upi_id"       id="h_upi_id">
    <input type="hidden" name="card_number"  id="h_card_number">
    <input type="hidden" name="card_name"    id="h_card_name">
    <input type="hidden" name="card_expiry"  id="h_card_expiry">
    <input type="hidden" name="card_cvv"     id="h_card_cvv">

    <div class="checkout-wrap">

        <!-- ── LEFT ── -->
        <div>
            <!-- Delivery Address -->
            <div class="checkout-card" style="margin-bottom:20px">
                <div class="checkout-card-header"><h2>&#128205; Delivery Address</h2></div>
                <div class="checkout-body">
                    <div class="form-group">
                        <label for="delivery_address">Full Delivery Address <span class="req">*</span></label>
                        <textarea id="delivery_address" name="delivery_address"
                                  class="form-control" rows="4"
                                  placeholder="House No., Street, Area, City, State, PIN Code"
                                  required><%= c_address %></textarea>
                    </div>
                    <p style="font-size:.8rem;color:var(--text-light);margin-top:-8px;">
                        &#8505; Make sure address is complete for accurate delivery.
                    </p>
                </div>
            </div>

            <!-- Payment Method -->
            <div class="checkout-card">
                <div class="checkout-card-header"><h2>&#128179; Payment Method</h2></div>
                <div class="checkout-body">

                    <!-- 3 tiles -->
                    <div class="payment-options">
                        <div class="payment-option">
                            <input type="radio" name="payment_method" id="pay_cod" value="COD" checked>
                            <label class="payment-label" for="pay_cod">
                                <span class="pay-icon">&#128181;</span>
                                Cash on Delivery
                            </label>
                        </div>
                        <div class="payment-option">
                            <input type="radio" name="payment_method" id="pay_upi" value="UPI">
                            <label class="payment-label" for="pay_upi">
                                <span class="pay-icon">&#128242;</span>
                                UPI Payment
                            </label>
                        </div>
                        <div class="payment-option">
                            <input type="radio" name="payment_method" id="pay_card" value="Card">
                            <label class="payment-label" for="pay_card">
                                <span class="pay-icon">&#128179;</span>
                                Debit / Credit Card
                            </label>
                        </div>
                    </div>

                    <!-- ══ COD INFO BOX ══ -->
                    <div id="cod-box" class="cod-box" style="display:flex;">
                        <span class="cod-icon">&#128181;</span>
                        <div>
                            <strong>Cash on Delivery selected</strong><br>
                            Pay in cash when your order arrives at your doorstep. No prepayment needed!
                        </div>
                    </div>

                    <!-- ══ UPI FORM ══ -->
                    <div id="upi-box" class="pay-detail-box">
                        <h4>&#128242; UPI Payment Details</h4>
                        <div class="upi-row">
                            <!-- QR code mock -->
                            <div class="upi-qr-box">
                                <div class="qr-grid">
                                    <% String[] qrCols = {"#1a0a0c","#fff","#1a0a0c","#fff","#1a0a0c","#fff","#1a0a0c","#fff","#1a0a0c","#fff","#1a0a0c","#fff","#fff","#1a0a0c","#fff","#fff","#1a0a0c","#fff","#1a0a0c","#fff","#1a0a0c","#fff","#fff","#1a0a0c","#1a0a0c"}; %>
                                    <% for(String col : qrCols){ %><div class="qr-cell" style="background:<%= col %>"></div><% } %>
                                </div>
                                <span>Scan QR</span>
                            </div>
                            <div class="upi-fields">
                                <div class="upi-id-display">
                                    &#128242; sakhimart@upi
                                </div>
                                <p style="font-size:.78rem;color:var(--text-light);margin:0;">
                                    Scan the QR code or enter our UPI ID in your payment app, then enter your UPI ID below for reference.
                                </p>
                                <div class="form-group" style="margin:0">
                                    <label style="font-size:.82rem;font-weight:700">Your UPI ID <span class="req">*</span></label>
                                    <input type="text" id="upi_id" class="form-control"
                                           placeholder="e.g. yourname@gpay or 9876543210@paytm"
                                           style="margin-top:4px">
                                    <small style="color:var(--text-muted);font-size:.72rem;">GPay, PhonePe, Paytm, BHIM accepted</small>
                                </div>
                                <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:4px;">
                                    <span style="font-size:.7rem;padding:3px 10px;background:var(--bg-page);border:1px solid var(--border);border-radius:50px;color:var(--text-mid);font-weight:700;">&#128241; GPay</span>
                                    <span style="font-size:.7rem;padding:3px 10px;background:var(--bg-page);border:1px solid var(--border);border-radius:50px;color:var(--text-mid);font-weight:700;">&#128178; PhonePe</span>
                                    <span style="font-size:.7rem;padding:3px 10px;background:var(--bg-page);border:1px solid var(--border);border-radius:50px;color:var(--text-mid);font-weight:700;">&#127310; Paytm</span>
                                    <span style="font-size:.7rem;padding:3px 10px;background:var(--bg-page);border:1px solid var(--border);border-radius:50px;color:var(--text-mid);font-weight:700;">&#127984; BHIM</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ══ CARD FORM ══ -->
                    <div id="card-box" class="pay-detail-box">
                        <h4>&#128179; Card Details</h4>

                        <!-- Card Visual Preview -->
                        <div class="card-preview" id="cardPreview">
                            <div class="cp-chip"></div>
                            <div class="cp-number" id="previewNumber">•••• •••• •••• ••••</div>
                            <div class="cp-row">
                                <div>
                                    <div class="cp-label">Card Holder</div>
                                    <div id="previewName" style="font-size:.84rem;font-weight:700;text-transform:uppercase;">YOUR NAME</div>
                                </div>
                                <div style="text-align:right">
                                    <div class="cp-label">Expires</div>
                                    <div id="previewExpiry" style="font-size:.84rem;font-weight:700;">MM/YY</div>
                                </div>
                                <div style="text-align:right">
                                    <div class="cp-label">Type</div>
                                    <div id="previewType" style="font-size:.84rem;font-weight:700;">VISA</div>
                                </div>
                            </div>
                        </div>

                        <!-- Card Input Fields -->
                        <div class="card-grid">
                            <div class="form-group span2" style="margin:0">
                                <label style="font-size:.82rem;font-weight:700">Card Number <span class="req">*</span></label>
                                <input type="text" id="card_number" class="form-control"
                                       placeholder="1234 5678 9012 3456"
                                       maxlength="19" style="font-family:monospace;letter-spacing:.08em;margin-top:4px">
                            </div>
                            <div class="form-group span2" style="margin:0">
                                <label style="font-size:.82rem;font-weight:700">Name on Card <span class="req">*</span></label>
                                <input type="text" id="card_name" class="form-control"
                                       placeholder="As printed on card" style="margin-top:4px;text-transform:uppercase">
                            </div>
                            <div class="form-group" style="margin:0">
                                <label style="font-size:.82rem;font-weight:700">Expiry Date <span class="req">*</span></label>
                                <input type="text" id="card_expiry" class="form-control"
                                       placeholder="MM/YY" maxlength="5" style="margin-top:4px">
                            </div>
                            <div class="form-group" style="margin:0">
                                <label style="font-size:.82rem;font-weight:700">CVV <span class="req">*</span></label>
                                <input type="password" id="card_cvv" class="form-control"
                                       placeholder="•••" maxlength="4" style="margin-top:4px">
                            </div>
                        </div>
                        <p style="font-size:.75rem;color:var(--text-muted);margin-top:10px;margin-bottom:0;">
                            &#128274; Your card details are encrypted and secure. We never store CVV.
                        </p>
                    </div>

                    <div style="margin-top:20px;display:flex;gap:12px;flex-wrap:wrap;">
                        <a href="<%= request.getContextPath() %>/CartServlet?action=view"
                           class="btn btn-secondary">&#8592; Back to Cart</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── RIGHT: Summary ── -->
        <div class="summary-card">
            <div class="summary-header"><h3>&#128203; Order Summary</h3></div>
            <div class="summary-items">
                <% for (CartItem item : cartItems) { %>
                <div class="summary-item">
                    <span class="summary-item-name"><%= item.getP_name() %></span>
                    <span class="summary-item-qty">×<%= item.getQuantity() %></span>
                    <span class="summary-item-price">&#8377;<%= String.format("%.2f", item.getSubtotal()) %></span>
                </div>
                <% } %>
            </div>
            <div class="summary-divider"></div>
            <div class="summary-totals">
                <div class="summary-row">
                    <span class="lbl">Subtotal</span>
                    <span class="val">&#8377;<%= String.format("%.2f", cartTotal) %></span>
                </div>
                <div class="summary-row">
                    <span class="lbl">Shipping</span>
                    <span class="val">
                        <% if (shipping == 0) { %>
                            <span style="color:var(--success)">FREE</span>
                        <% } else { %>
                            &#8377;<%= String.format("%.2f", shipping) %>
                        <% } %>
                    </span>
                </div>
                <div class="summary-grand">
                    <span class="lbl">Grand Total</span>
                    <span class="val">&#8377;<%= String.format("%.2f", grandTotal) %></span>
                </div>
            </div>
            <button type="submit" class="btn-place-order">&#9989; Place Order</button>
            <p class="secure-note">&#128274; <span>Secure</span> &amp; Trusted Checkout</p>
        </div>

    </div>
</form>

<%@ include file="../common/footer.jsp" %>

<script>
(function(){
'use strict';

var codBox  = document.getElementById('cod-box');
var upiBox  = document.getElementById('upi-box');
var cardBox = document.getElementById('card-box');

// ── Show / hide payment forms ──────────────────────────────────
function showPaymentBox(method) {
    codBox.style.display  = 'none';
    upiBox.classList.remove('active');
    cardBox.classList.remove('active');

    if (method === 'COD')  { codBox.style.display = 'flex'; }
    if (method === 'UPI')  { upiBox.classList.add('active'); }
    if (method === 'Card') { cardBox.classList.add('active'); }
}

document.querySelectorAll('input[name="payment_method"]').forEach(function(r) {
    r.addEventListener('change', function() {
        if (this.checked) showPaymentBox(this.value);
    });
});

// Default: show COD
showPaymentBox('COD');

// ── Card number formatting (groups of 4) ──────────────────────
var cardNumEl = document.getElementById('card_number');
cardNumEl.addEventListener('input', function() {
    var v = this.value.replace(/\D/g,'').substring(0,16);
    this.value = v.replace(/(.{4})/g,'$1 ').trim();
    updatePreviewNumber(v);
    detectCardType(v);
    document.getElementById('h_card_number').value = v;
});

function updatePreviewNumber(v) {
    var padded = (v + '0000000000000000').substring(0,16);
    var masked = padded.substring(0,4) + ' ' + padded.substring(4,8) + ' ' + padded.substring(8,12) + ' ' + padded.substring(12,16);
    document.getElementById('previewNumber').textContent = masked;
}

function detectCardType(v) {
    var type = 'VISA';
    if (/^5[1-5]/.test(v))    type = 'MASTERCARD';
    else if (/^4/.test(v))    type = 'VISA';
    else if (/^3[47]/.test(v)) type = 'AMEX';
    else if (/^6/.test(v))    type = 'RUPAY';
    document.getElementById('previewType').textContent = type;
}

// ── Card name ─────────────────────────────────────────────────
document.getElementById('card_name').addEventListener('input', function() {
    document.getElementById('previewName').textContent = this.value.toUpperCase() || 'YOUR NAME';
    document.getElementById('h_card_name').value = this.value;
});

// ── Card expiry (auto slash) ──────────────────────────────────
var expiryEl = document.getElementById('card_expiry');
expiryEl.addEventListener('input', function() {
    var v = this.value.replace(/\D/g,'').substring(0,4);
    if (v.length >= 3) v = v.substring(0,2) + '/' + v.substring(2);
    this.value = v;
    document.getElementById('previewExpiry').textContent = v || 'MM/YY';
    document.getElementById('h_card_expiry').value = v;
});

// ── Card CVV ──────────────────────────────────────────────────
document.getElementById('card_cvv').addEventListener('input', function() {
    document.getElementById('h_card_cvv').value = this.value;
});

// ── UPI ID ────────────────────────────────────────────────────
document.getElementById('upi_id').addEventListener('input', function() {
    document.getElementById('h_upi_id').value = this.value;
});

// ── Form validation before submit ─────────────────────────────
document.getElementById('checkoutForm').addEventListener('submit', function(e) {
    var method = document.querySelector('input[name="payment_method"]:checked').value;

    if (method === 'UPI') {
        var upiVal = document.getElementById('upi_id').value.trim();
        if (!upiVal || !upiVal.includes('@')) {
            e.preventDefault();
            alert('Please enter a valid UPI ID (e.g. name@gpay)');
            document.getElementById('upi_id').focus();
            return;
        }
        document.getElementById('h_upi_id').value = upiVal;
    }

    if (method === 'Card') {
        var num  = document.getElementById('card_number').value.replace(/\s/g,'');
        var name = document.getElementById('card_name').value.trim();
        var exp  = document.getElementById('card_expiry').value.trim();
        var cvv  = document.getElementById('card_cvv').value.trim();

        if (num.length < 13) {
            e.preventDefault(); alert('Please enter a valid card number.'); return;
        }
        if (!name) {
            e.preventDefault(); alert('Please enter the name on your card.'); return;
        }
        if (!/^\d{2}\/\d{2}$/.test(exp)) {
            e.preventDefault(); alert('Please enter expiry in MM/YY format.'); return;
        }
        if (cvv.length < 3) {
            e.preventDefault(); alert('Please enter a valid CVV.'); return;
        }
    }
});

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
