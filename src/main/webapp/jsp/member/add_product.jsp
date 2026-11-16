<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("m_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Product &#8211; SakhiMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .invalid-feedback { display:none; color:#dc3545; font-size:0.82rem; margin-top:4px; }
        .is-invalid { border-color:#dc3545 !important; }
        .req { color:#dc3545; }
    </style>
</head>
<body>

<%@ include file="../common/navbar.jsp" %>

<div class="container">
    <div class="form-card">
        <h2 class="form-title">&#43; Add New Product</h2>

        <% if (message != null) { %>
            <div class="alert <%= message.contains("success") ? "alert-success" : "alert-error" %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Client-side summary error -->
        <div class="alert alert-error" id="formError" style="display:none;">
            &#9888; Please fix the errors below before submitting.
        </div>

        <%-- FIX: onsubmit on form, not onclick on button --%>
        <form action="<%= request.getContextPath() %>/ProductServlet"
              method="post"
              enctype="multipart/form-data"
              id="addProductForm"
              novalidate
              onsubmit="return validateProductForm()">

            <input type="hidden" name="action" value="add">

            <div class="form-group">
                <label for="p_name">Product Name <span class="req">*</span></label>
                <input type="text" id="p_name" name="p_name"
                       class="form-control"
                       placeholder="e.g. Homemade Mango Pickle"
                       maxlength="50" required>
                <div class="invalid-feedback" id="p_nameError">Product name is required.</div>
            </div>

            <div class="form-group">
                <label for="p_category">Category <span class="req">*</span></label>
                <select id="p_category" name="p_category" class="form-control" required>
                    <option value="">-- Select Category --</option>
                    <option value="Food">Food &amp; Snacks</option>
                    <option value="Pickle">Pickles &amp; Preserves</option>
                    <option value="Handicraft">Handicrafts</option>
                    <option value="Cloth">Cloth &amp; Textiles</option>
                    <option value="Beauty">Beauty &amp; Wellness</option>
                    <option value="Other">Other</option>
                </select>
                <div class="invalid-feedback" id="p_categoryError">Please select a category.</div>
            </div>

            <div class="form-group">
                <label for="p_description">Description</label>
                <textarea id="p_description" name="p_description"
                          rows="4" maxlength="255"
                          placeholder="Describe your product (ingredients, size, usage...)"></textarea>
            </div>

            <div class="form-row">
                <div class="form-group half">
                    <label for="p_price">Price (&#8377;) <span class="req">*</span></label>
                    <input type="number" id="p_price" name="p_price"
                           class="form-control"
                           placeholder="0.00" step="0.01" min="1" required>
                    <div class="invalid-feedback" id="p_priceError">Enter a valid price (min ₹1).</div>
                </div>
                <div class="form-group half">
                    <label for="p_quantity">Quantity <span class="req">*</span></label>
                    <input type="number" id="p_quantity" name="p_quantity"
                           class="form-control"
                           placeholder="0" min="1" required>
                    <div class="invalid-feedback" id="p_quantityError">Enter quantity (min 1).</div>
                </div>
            </div>

            <div class="form-group">
                <label for="p_image">Product Image <span class="req">*</span></label>
                <input type="file" id="p_image" name="p_image"
                       accept="image/jpeg,image/jpg,image/png"
                       required onchange="previewImage(this)">
                <small class="hint">JPG / PNG only, max 5 MB</small>
                <div class="invalid-feedback" id="p_imageError">Please select a product image.</div>
                <div id="imagePreview"></div>
            </div>

            <p class="info-note">
                &#9432; Your product will be reviewed by the admin before it appears to customers.
            </p>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Submit for Approval</button>
                <a href="<%= request.getContextPath() %>/ProductServlet?action=memberProducts"
                   class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>

<%-- FIX: Removed broken <script src="/js/validation.js"> — file doesn't exist.
     Inline JS below handles all validation instead. --%>
<script>
    function validateProductForm() {
        var valid = true;

        function setError(id, errorId, condition) {
            var field = document.getElementById(id);
            var err   = document.getElementById(errorId);
            if (condition) {
                if (field) field.classList.add('is-invalid');
                if (err)   err.style.display = 'block';
                valid = false;
            } else {
                if (field) field.classList.remove('is-invalid');
                if (err)   err.style.display = 'none';
            }
        }

        setError('p_name',     'p_nameError',
                 document.getElementById('p_name').value.trim() === '');
        setError('p_category', 'p_categoryError',
                 document.getElementById('p_category').value === '');
        setError('p_price',    'p_priceError',
                 document.getElementById('p_price').value <= 0 ||
                 document.getElementById('p_price').value === '');
        setError('p_quantity', 'p_quantityError',
                 document.getElementById('p_quantity').value < 1 ||
                 document.getElementById('p_quantity').value === '');
        setError('p_image',    'p_imageError',
                 document.getElementById('p_image').files.length === 0);

        document.getElementById('formError').style.display = valid ? 'none' : 'block';
        return valid;
    }

    function previewImage(input) {
        var preview = document.getElementById('imagePreview');
        preview.innerHTML = '';
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                preview.innerHTML =
                    '<img src="' + e.target.result +
                    '" style="max-width:200px; margin-top:8px; border-radius:6px;">';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    /* Clear errors as user corrects each field */
    ['p_name','p_category','p_price','p_quantity'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) {
            el.addEventListener('input', function() {
                if (this.value.trim() !== '') {
                    this.classList.remove('is-invalid');
                    var e = document.getElementById(id + 'Error');
                    if (e) e.style.display = 'none';
                    document.getElementById('formError').style.display = 'none';
                }
            });
        }
    });
</script>
</body>
</html>