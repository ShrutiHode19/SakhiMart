<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Product" %>
<%
    if (session.getAttribute("m_id") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    Product p = (Product) request.getAttribute("product");
    if (p == null) {
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=memberProducts");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Product &#8211; SakhiMart</title>
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
        <h2 class="form-title">&#9998; Update Product</h2>

        <!-- Client-side summary error -->
        <div class="alert alert-error" id="formError" style="display:none;">
            &#9888; Please fix the errors below before submitting.
        </div>

        <%-- FIX: onsubmit on form, not onclick on button --%>
        <form action="<%= request.getContextPath() %>/ProductServlet"
              method="post"
              enctype="multipart/form-data"
              id="updateProductForm"
              novalidate
              onsubmit="return validateProductForm()">

            <input type="hidden" name="action"         value="update">
            <input type="hidden" name="p_id"           value="<%= p.getP_id() %>">
            <input type="hidden" name="existing_image" value="<%= p.getP_image_path() %>">

            <div class="form-group">
                <label for="p_name">Product Name <span class="req">*</span></label>
                <input type="text" id="p_name" name="p_name"
                       class="form-control"
                       value="<%= p.getP_name() %>" maxlength="50" required>
                <div class="invalid-feedback" id="p_nameError">Product name is required.</div>
            </div>

            <div class="form-group">
                <label for="p_category">Category <span class="req">*</span></label>
                <select id="p_category" name="p_category" class="form-control" required>
                    <option value="">-- Select Category --</option>
                    <%
                        String[] cats   = {"Food","Pickle","Handicraft","Cloth","Beauty","Other"};
                        String[] labels = {"Food & Snacks","Pickles & Preserves","Handicrafts",
                                           "Cloth & Textiles","Beauty & Wellness","Other"};
                        for (int i = 0; i < cats.length; i++) {
                    %>
                        <option value="<%= cats[i] %>"
                            <%= cats[i].equals(p.getP_category()) ? "selected" : "" %>>
                            <%= labels[i] %>
                        </option>
                    <% } %>
                </select>
                <div class="invalid-feedback" id="p_categoryError">Please select a category.</div>
            </div>

            <div class="form-group">
                <label for="p_description">Description</label>
                <textarea id="p_description" name="p_description"
                          rows="4" maxlength="255">
                    <%= p.getP_description() != null ? p.getP_description() : "" %>
                </textarea>
            </div>

            <div class="form-row">
                <div class="form-group half">
                    <label for="p_price">Price (&#8377;) <span class="req">*</span></label>
                    <input type="number" id="p_price" name="p_price"
                           class="form-control"
                           value="<%= p.getP_price() %>" step="0.01" min="1" required>
                    <div class="invalid-feedback" id="p_priceError">Enter a valid price (min ₹1).</div>
                </div>
                <div class="form-group half">
                    <label for="p_quantity">Quantity <span class="req">*</span></label>
                    <input type="number" id="p_quantity" name="p_quantity"
                           class="form-control"
                           value="<%= p.getP_quantity() %>" min="0" required>
                    <div class="invalid-feedback" id="p_quantityError">Enter a valid quantity.</div>
                </div>
            </div>

            <div class="form-group">
                <label>Current Image</label><br>
                <img src="<%= request.getContextPath() %>/<%= p.getP_image_path() %>"
                     alt="Current Image" class="preview-img">
            </div>

            <div class="form-group">
                <label for="p_image">Replace Image <small>(optional)</small></label>
                <input type="file" id="p_image" name="p_image"
                       accept="image/jpeg,image/jpg,image/png"
                       onchange="previewImage(this)">
                <small class="hint">Leave blank to keep existing image. JPG / PNG, max 5 MB</small>
                <div id="imagePreview"></div>
            </div>

            <p class="info-note">
                &#9432; After update, product status resets to <strong>Pending</strong>
                for admin re-approval.
            </p>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Update Product</button>
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
                 document.getElementById('p_quantity').value === '');

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