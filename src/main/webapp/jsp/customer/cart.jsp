<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.CartItem" %>
<%
    if (session.getAttribute("c_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    double cartTotal  = (double) request.getAttribute("cartTotal");
    int    itemCount  = (int)    request.getAttribute("itemCount");
    String msg        = request.getParameter("msg");
    boolean isEmpty   = (cartItems == null || cartItems.isEmpty());
    double shipping   = (!isEmpty && cartTotal < 500) ? 50.0 : 0.0;
    double grandTotal = cartTotal + shipping;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Cart – SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
    /* ════════════════════════════════════════════════════
       CART PAGE — Maroon & Gold Theme
    ════════════════════════════════════════════════════ */

        /* ── Page layout ── */
        .cart-wrap {
            max-width: 1140px;
            margin: 28px auto;
            padding: 0 18px 48px;
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 24px;
            align-items: start;
        }
        @media (max-width: 820px) { .cart-wrap { grid-template-columns: 1fr; } }

        /* ── Cart Items Card ── */
        .cart-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            overflow: hidden;
            border: 1px solid var(--border-light);
        }
        .cart-card-header {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 60%, var(--primary-light) 100%);
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 2px solid rgba(201,144,32,0.35);
        }
        .cart-card-header h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.2rem;
            color: #fff;
            font-weight: 800;
        }
        .cart-count-badge {
            background: rgba(201,144,32,0.25);
            color: var(--gold-light);
            border: 1px solid rgba(201,144,32,0.4);
            border-radius: var(--radius-pill);
            padding: 3px 14px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        /* ── Cart Item Row ── */
        .cart-item {
            display: grid;
            grid-template-columns: 90px 1fr auto;
            gap: 16px;
            align-items: center;
            padding: 16px 24px;
            border-bottom: 1px solid var(--border-light);
            transition: background var(--tr);
        }
        .cart-item:last-child { border-bottom: none; }
        .cart-item:hover { background: var(--primary-bg); }

        .cart-item-img {
            width: 90px; height: 90px;
            border-radius: var(--radius-md);
            object-fit: cover;
            border: 2px solid var(--border);
            box-shadow: var(--shadow-xs);
        }

        .cart-item-info .item-name {
            font-weight: 800;
            font-size: 0.97rem;
            color: var(--text-dark);
            margin-bottom: 3px;
        }
        .cart-item-info .item-category {
            display: inline-block;
            font-size: 0.72rem;
            color: var(--gold-dark);
            background: var(--gold-bg);
            border: 1px solid var(--gold-border);
            text-transform: uppercase;
            letter-spacing: 0.6px;
            font-weight: 700;
            padding: 2px 9px;
            border-radius: var(--radius-pill);
            margin-bottom: 8px;
        }
        .cart-item-info .item-price {
            color: var(--primary);
            font-weight: 700;
            font-size: 0.93rem;
        }

        /* ── Qty Controls ── */
        .cart-item-actions {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 10px;
            min-width: 120px;
        }
        .qty-form { display: flex; align-items: center; gap: 6px; }
        .qty-btn {
            width: 30px; height: 30px;
            border: 2px solid var(--border);
            background: #fff;
            border-radius: 50%;
            cursor: pointer;
            font-size: 1.1rem;
            font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            color: var(--primary);
            transition: all 0.18s;
            line-height: 1;
        }
        .qty-btn:hover {
            background: var(--primary);
            color: #fff;
            border-color: var(--primary);
            box-shadow: var(--shadow-primary);
        }
        .qty-input {
            width: 44px;
            text-align: center;
            border: 2px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 4px 2px;
            font-size: 0.95rem;
            font-weight: 800;
            color: var(--text-dark);
            background: var(--bg-input);
        }
        .qty-input:focus {
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px var(--primary-glow);
        }

        .item-subtotal {
            font-weight: 900;
            color: var(--primary);
            font-size: 1.05rem;
            text-align: right;
        }
        .remove-btn {
            background: none;
            border: none;
            color: var(--text-light);
            cursor: pointer;
            font-size: 0.8rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 3px 8px;
            border-radius: var(--radius-pill);
            transition: all 0.18s;
            border: 1px solid transparent;
        }
        .remove-btn:hover {
            color: var(--danger);
            background: var(--danger-bg);
            border-color: var(--danger-border);
        }

        /* ── Empty Cart ── */
        .empty-cart {
            text-align: center;
            padding: 70px 24px;
        }
        .empty-cart .empty-icon { font-size: 4rem; margin-bottom: 16px; display: block; }
        .empty-cart h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            color: var(--text-mid);
            margin-bottom: 8px;
        }
        .empty-cart p { color: var(--text-light); margin-bottom: 26px; font-size: 0.93rem; }

        /* ── Cart Footer ── */
        .cart-footer {
            padding: 14px 24px;
            border-top: 1px solid var(--border-light);
            background: var(--bg-page);
            display: flex;
            justify-content: flex-end;
        }

        /* ── Order Summary Card ── */
        .summary-card {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            overflow: hidden;
            position: sticky;
            top: 84px;
            border: 1px solid var(--border-light);
        }
        .summary-header {
            background: linear-gradient(135deg, var(--gold-dark) 0%, var(--gold) 60%, var(--gold-light) 100%);
            padding: 16px 22px;
            border-bottom: 2px solid rgba(139,21,32,0.2);
        }
        .summary-header h3 {
            font-family: 'Playfair Display', serif;
            color: #fff;
            font-size: 1.1rem;
            font-weight: 800;
            text-shadow: 0 1px 4px rgba(0,0,0,0.2);
        }
        .summary-body { padding: 18px 22px 4px; }
        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 9px 0;
            border-bottom: 1px solid var(--border-light);
            font-size: 0.9rem;
            color: var(--text-mid);
        }
        .summary-row:last-of-type { border-bottom: none; }
        .summary-row .label { font-weight: 600; }
        .summary-row .value { font-weight: 700; color: var(--text-dark); }
        .summary-row.total-row {
            margin-top: 6px;
            padding-top: 14px;
            border-top: 2px solid var(--gold-border);
            border-bottom: none;
        }
        .summary-row.total-row .label {
            font-weight: 800;
            font-size: 1rem;
            color: var(--text-dark);
        }
        .summary-row.total-row .value {
            font-size: 1.25rem;
            color: var(--primary);
            font-weight: 900;
        }
        .free-shipping-note {
            font-size: 0.78rem;
            color: var(--success);
            font-weight: 700;
            text-align: center;
            margin: 8px 0 2px;
            padding: 6px 10px;
            background: var(--success-bg);
            border-radius: var(--radius-sm);
            border: 1px solid var(--success-border);
        }

        .summary-actions { padding: 16px 22px 22px; display: flex; flex-direction: column; gap: 10px; }
        .btn-checkout {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 60%, var(--primary-light) 100%);
            color: #fff;
            padding: 14px 20px;
            border-radius: var(--radius-pill);
            font-size: 0.97rem;
            font-weight: 800;
            text-align: center;
            text-decoration: none;
            display: block;
            letter-spacing: 0.4px;
            box-shadow: var(--shadow-primary);
            transition: transform var(--tr), box-shadow var(--tr), filter var(--tr);
            border: none;
        }
        .btn-checkout:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(139,21,32,0.42);
            color: #fff;
            filter: brightness(1.06);
            text-decoration: none;
        }
        .btn-checkout.disabled { opacity: .5; pointer-events: none; }

        /* ── Flash bar ── */
        .flash-bar { max-width: 1140px; margin: 18px auto 0; padding: 0 18px; }

        /* ── Mobile tweaks ── */
        @media (max-width: 600px) {
            .cart-item { grid-template-columns: 72px 1fr; }
            .cart-item-actions { flex-direction: row; align-items: center; grid-column: 1 / -1; }
        }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<!-- Page Header -->
<div class="page-header">
    <h2>&#128722; My Shopping Cart</h2>
    <% if (!isEmpty) { %>
        <span style="color:rgba(255,255,255,0.85); font-size:0.9rem;"><%= itemCount %> item(s) in cart</span>
    <% } %>
</div>

<!-- Flash Messages -->
<div class="flash-bar">
    <% if ("added".equals(msg)) { %>
        <div class="alert alert-success">&#10003; Product added to cart successfully!</div>
    <% } else if ("removed".equals(msg)) { %>
        <div class="alert alert-info">&#128465; Item removed from cart.</div>
    <% } else if ("updated".equals(msg)) { %>
        <div class="alert alert-success">&#10003; Cart updated.</div>
    <% } else if ("cleared".equals(msg)) { %>
        <div class="alert alert-info">&#128465; Cart cleared.</div>
    <% } else if ("empty".equals(msg)) { %>
        <div class="alert alert-warning">&#9888; Your cart is empty. Add products before checkout.</div>
    <% } else if ("error".equals(msg)) { %>
        <div class="alert alert-error">&#10005; Something went wrong. Please try again.</div>
    <% } %>
</div>

<div class="cart-wrap">

    <!-- ── Left: Cart Items ── -->
    <div class="cart-card">
        <div class="cart-card-header">
            <h2>Cart Items</h2>
            <% if (!isEmpty) { %>
                <span class="cart-count-badge"><%= cartItems.size() %> product(s)</span>
            <% } %>
        </div>

        <% if (isEmpty) { %>
            <div class="empty-cart">
                <div class="empty-icon">&#128722;</div>
                <h3>Your cart is empty</h3>
                <p>Browse our handcrafted products and add them to your cart.</p>
                <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
                   class="btn btn-primary">&#128722; Shop Now</a>
            </div>
        <% } else { %>
            <% for (CartItem item : cartItems) { %>
            <div class="cart-item">

                <!-- Product Image -->
                <img src="<%= request.getContextPath() %>/<%= item.getP_image_path() %>"
                     alt="<%= item.getP_name() %>"
                     class="cart-item-img"
                     onerror="this.src='<%= request.getContextPath() %>/images/no-image.png'">

                <!-- Product Info -->
                <div class="cart-item-info">
                    <div class="item-name"><%= item.getP_name() %></div>
                    <div class="item-category"><%= item.getP_category() %></div>
                    <div class="item-price">&#8377;<%= String.format("%.2f", item.getP_price()) %> each</div>

                    <!-- Update Qty Form -->
                    <form action="<%= request.getContextPath() %>/CartServlet" method="post"
                          class="qty-form" style="margin-top:8px;">
                        <input type="hidden" name="action"  value="update">
                        <input type="hidden" name="cart_id" value="<%= item.getCart_id() %>">
                        <button type="button" class="qty-btn"
                                onclick="adjustQty(this,-1,<%= item.getP_stock() %>)">&#8722;</button>
                        <input type="number" name="qty"
                               class="qty-input"
                               value="<%= item.getQuantity() %>"
                               min="1" max="<%= item.getP_stock() %>"
                               id="qty_<%= item.getCart_id() %>">
                        <button type="button" class="qty-btn"
                                onclick="adjustQty(this,1,<%= item.getP_stock() %>)">&#43;</button>
                        <button type="submit" class="btn btn-secondary btn-sm">Update</button>
                    </form>
                </div>

                <!-- Subtotal + Remove -->
                <div class="cart-item-actions">
                    <div class="item-subtotal">&#8377;<%= String.format("%.2f", item.getSubtotal()) %></div>
                    <form action="<%= request.getContextPath() %>/CartServlet" method="post">
                        <input type="hidden" name="action"  value="remove">
                        <input type="hidden" name="cart_id" value="<%= item.getCart_id() %>">
                        <button type="submit" class="remove-btn"
                                onclick="return confirm('Remove this item?')">
                            &#10005; Remove
                        </button>
                    </form>
                </div>
            </div>
            <% } %>

            <!-- Clear All -->
            <div class="cart-footer">
                <form action="<%= request.getContextPath() %>/CartServlet" method="post">
                    <input type="hidden" name="action" value="clear">
                    <button type="submit" class="btn btn-secondary btn-sm"
                            onclick="return confirm('Clear entire cart?')">
                        &#128465; Clear Cart
                    </button>
                </form>
            </div>
        <% } %>
    </div>

    <!-- ── Right: Order Summary ── -->
    <div class="summary-card">
        <div class="summary-header">
            <h3>&#128203; Order Summary</h3>
        </div>
        <div class="summary-body">
            <div class="summary-row">
                <span class="label">Subtotal</span>
                <span class="value">&#8377;<%= String.format("%.2f", cartTotal) %></span>
            </div>
            <div class="summary-row">
                <span class="label">Shipping</span>
                <span class="value">
                    <% if (shipping == 0 && !isEmpty) { %>
                        <span style="color:var(--success)">FREE</span>
                    <% } else if (isEmpty) { %>
                        &#8211;
                    <% } else { %>
                        &#8377;<%= String.format("%.2f", shipping) %>
                    <% } %>
                </span>
            </div>
            <div class="summary-row total-row">
                <span class="label">Total</span>
                <span class="value">&#8377;<%= String.format("%.2f", grandTotal) %></span>
            </div>
            <% if (!isEmpty && cartTotal < 500) { %>
                <p class="free-shipping-note">
                    &#127381; Add &#8377;<%= String.format("%.2f", 500 - cartTotal) %> more for FREE shipping!
                </p>
            <% } else if (!isEmpty) { %>
                <p class="free-shipping-note">&#127881; You qualify for FREE shipping!</p>
            <% } %>
        </div>
        <div class="summary-actions">
            <a href="<%= request.getContextPath() %>/OrderServlet?action=checkout"
               class="btn-checkout <%= isEmpty ? "disabled" : "" %>">
                Proceed to Checkout &#10132;
            </a>
            <a href="<%= request.getContextPath() %>/ProductServlet?action=list"
               class="btn btn-secondary" style="text-align:center;">
                &#8592; Continue Shopping
            </a>
        </div>
    </div>

</div>

<%@ include file="../common/footer.jsp" %>

<script>
// Adjust qty +/- buttons and auto-submit form
function adjustQty(btn, delta, maxStock) {
    const form  = btn.closest('form');
    const input = form.querySelector('input[name="qty"]');
    let val = parseInt(input.value) + delta;
    if (val < 1) val = 1;
    if (val > maxStock) val = maxStock;
    input.value = val;
}

// Auto-dismiss alerts after 4 seconds
setTimeout(() => {
    document.querySelectorAll('.alert').forEach(el => {
        el.style.transition = 'opacity 0.5s';
        el.style.opacity = '0';
        setTimeout(() => el.remove(), 500);
    });
}, 4000);
</script>

</body>
</html>
