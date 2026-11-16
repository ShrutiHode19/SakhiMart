package controller;

import dao.ProductDAO;
import model.Product;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.Paths;
import java.util.List;

@WebServlet("/ProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB - start buffering to disk
    maxFileSize       = 1024 * 1024 * 5,   // 5 MB per file max
    maxRequestSize    = 1024 * 1024 * 10   // 10 MB total request max
)
public class ProductServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
    }

    // ── GET Requests ─────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) action = "list";

        switch (action) {

            // ── MEMBER ──
            case "memberProducts":
                showMemberProducts(request, response);
                break;
            case "editForm":
                showEditForm(request, response);
                break;

            // ── ADMIN ──
            case "adminProducts":
                showAdminProducts(request, response);
                break;
            case "approve":
                approveProduct(request, response);
                break;
            case "reject":
                rejectProduct(request, response);
                break;
            case "adminDelete":
                adminDeleteProduct(request, response);
                break;

            // ── CUSTOMER ──
            case "list":
                showProductList(request, response);
                break;
            case "search":
                searchProducts(request, response);
                break;
            case "details":
                showProductDetails(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/ProductServlet?action=list");
        }
    }

    // ── POST Requests ────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "add":
                addProduct(request, response);
                break;
            case "update":
                updateProduct(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/ProductServlet?action=list");
        }
    }

    // ══════════════════════════════════════════════════════════
    //  MEMBER HANDLERS
    // ══════════════════════════════════════════════════════════

    /** Member: View own product list */
    private void showMemberProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isMemberLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        int m_id = (int) request.getSession().getAttribute("m_id");
        List<Product> products = productDAO.getProductsByMember(m_id);
        request.setAttribute("products", products);
        request.getRequestDispatcher("/jsp/member/view_products.jsp").forward(request, response);
    }

    /** Member: Process add product form */
    private void addProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isMemberLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        int    m_id          = (int) request.getSession().getAttribute("m_id");
        String p_name        = request.getParameter("p_name");
        String p_description = request.getParameter("p_description");
        String p_category    = request.getParameter("p_category");
        double p_price       = Double.parseDouble(request.getParameter("p_price"));
        int    p_quantity    = Integer.parseInt(request.getParameter("p_quantity"));
        String p_image_path  = saveImage(request, "p_image");

        Product p = new Product();
        p.setM_id(m_id);
        p.setP_name(p_name);
        p.setP_description(p_description);
        p.setP_category(p_category);
        p.setP_price(p_price);
        p.setP_quantity(p_quantity);
        p.setP_image_path(p_image_path != null ? p_image_path : "images/products/default.png");

        boolean success = productDAO.addProduct(p);
        HttpSession session = request.getSession();
        session.setAttribute("message",
            success ? "Product added successfully! Waiting for admin approval."
                    : "Failed to add product. Please try again.");
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=memberProducts");
    }

    /** Member: Load edit form pre-filled with product data */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isMemberLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        int p_id = Integer.parseInt(request.getParameter("p_id"));
        Product product = productDAO.getProductById(p_id);
        request.setAttribute("product", product);
        request.getRequestDispatcher("/jsp/member/update_product.jsp").forward(request, response);
    }

    /** Member: Process update product form */
    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isMemberLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }

        int    m_id          = (int) request.getSession().getAttribute("m_id");
        int    p_id          = Integer.parseInt(request.getParameter("p_id"));
        String p_name        = request.getParameter("p_name");
        String p_description = request.getParameter("p_description");
        String p_category    = request.getParameter("p_category");
        double p_price       = Double.parseDouble(request.getParameter("p_price"));
        int    p_quantity    = Integer.parseInt(request.getParameter("p_quantity"));

        // Keep existing image if no new image is uploaded
        String p_image_path  = request.getParameter("existing_image");
        String newImage      = saveImage(request, "p_image");
        if (newImage != null) p_image_path = newImage;

        Product p = new Product();
        p.setP_id(p_id);
        p.setM_id(m_id);
        p.setP_name(p_name);
        p.setP_description(p_description);
        p.setP_category(p_category);
        p.setP_price(p_price);
        p.setP_quantity(p_quantity);
        p.setP_image_path(p_image_path);

        boolean success = productDAO.updateProduct(p);
        request.getSession().setAttribute("message",
            success ? "Product updated! Sent for admin re-approval."
                    : "Update failed. Please try again.");
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=memberProducts");
    }

    /** Member: Delete own product */
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isMemberLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        int m_id = (int) request.getSession().getAttribute("m_id");
        int p_id = Integer.parseInt(request.getParameter("p_id"));

        boolean success = productDAO.deleteProduct(p_id, m_id);
        request.getSession().setAttribute("message",
            success ? "Product deleted successfully." : "Delete failed. Please try again.");
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=memberProducts");
    }

    // ══════════════════════════════════════════════════════════
    //  ADMIN HANDLERS
    // ══════════════════════════════════════════════════════════

    /** Admin: View all products */
    private void showAdminProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        List<Product> products = productDAO.getAllProducts();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/jsp/admin/manage_products.jsp").forward(request, response);
    }

    /** Admin: Approve a product */
    private void approveProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        int p_id = Integer.parseInt(request.getParameter("p_id"));
        productDAO.updateProductStatus(p_id, "approved");
        request.getSession().setAttribute("message", "Product approved successfully.");
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=adminProducts");
    }

    /** Admin: Reject a product */
    private void rejectProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        int p_id = Integer.parseInt(request.getParameter("p_id"));
        productDAO.updateProductStatus(p_id, "rejected");
        request.getSession().setAttribute("message", "Product rejected.");
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=adminProducts");
    }

    /** Admin: Permanently delete any product */
    private void adminDeleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
            return;
        }
        int p_id = Integer.parseInt(request.getParameter("p_id"));
        productDAO.adminDeleteProduct(p_id);
        request.getSession().setAttribute("message", "Product removed.");
        response.sendRedirect(request.getContextPath() + "/ProductServlet?action=adminProducts");
    }

    // ══════════════════════════════════════════════════════════
    //  CUSTOMER HANDLERS
    // ══════════════════════════════════════════════════════════

    /** Customer: Browse all approved products */
    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Product> products = productDAO.getApprovedProducts();
        request.setAttribute("products", products);
        request.setAttribute("keyword", "");
        request.getRequestDispatcher("/jsp/customer/product_list.jsp").forward(request, response);
    }

    /** Customer: Search products */
    private void searchProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<Product> products = (keyword != null && !keyword.trim().isEmpty())
                ? productDAO.searchProducts(keyword)
                : productDAO.getApprovedProducts();
        request.setAttribute("products", products);
        request.setAttribute("keyword", keyword != null ? keyword : "");
        request.getRequestDispatcher("/jsp/customer/product_list.jsp").forward(request, response);
    }

    /** Customer: View individual product details */
    private void showProductDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int p_id = Integer.parseInt(request.getParameter("p_id"));
        Product product = productDAO.getProductById(p_id);
        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/ProductServlet?action=list");
            return;
        }
        request.setAttribute("product", product);
        request.getRequestDispatcher("/jsp/customer/product_details.jsp").forward(request, response);
    }

    // ══════════════════════════════════════════════════════════
    //  UTILITY METHODS
    // ══════════════════════════════════════════════════════════

    /**
     * Saves uploaded image to WebContent/images/products/ directory.
     * Returns the relative path for storing in DB, or null if no file uploaded.
     */
    private String saveImage(HttpServletRequest request, String fieldName)
            throws IOException, ServletException {

        Part filePart = request.getPart(fieldName);
        if (filePart == null || filePart.getSize() == 0) return null;

        String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        if (originalName == null || originalName.isEmpty()) return null;

        String uploadDir = getServletContext().getRealPath("/images/products/");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        // Unique filename: timestamp + original name
        String uniqueName = System.currentTimeMillis() + "_" + originalName.replaceAll("\\s+", "_");
        filePart.write(uploadDir + File.separator + uniqueName);
        return "images/products/" + uniqueName;
    }

    /** Check if a member is logged in via session attribute m_id */
    private boolean isMemberLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("m_id") != null;
    }

    /** Check if admin is logged in via session attribute a_id */
    private boolean isAdminLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("a_id") != null;
    }
}