package dao;

import model.Product;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ProductDAO.java
 *
 * Database operations for Product Module.
 * All column names exactly match the Product Table specification from
 * SakhiMart_diagrams_2nd.pptx (Slide 25):
 *   p_id | p_name | p_description | p_category | p_price | p_quantity | p_image_path | p_status | m_id
 *
 * Covers all roles:
 *   - Member  : addProduct, updateProduct, deleteProduct, getProductsByMember
 *   - Admin   : getAllProducts, updateProductStatus, adminDeleteProduct
 *   - Customer: getApprovedProducts, searchProducts, getProductById
 */
public class ProductDAO {

    // ══════════════════════════════════════════════════════════
    //  MEMBER OPERATIONS
    // ══════════════════════════════════════════════════════════

    /**
     * Member: Add a new homemade product.
     * New products always start with p_status = 'pending' (admin must approve).
     */
    public boolean addProduct(Product p) {
        String sql = "INSERT INTO product (p_name, p_description, p_category, p_price, "
                   + "p_quantity, p_image_path, p_status, m_id) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 'pending', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getP_name());
            ps.setString(2, p.getP_description());
            ps.setString(3, p.getP_category());
            ps.setDouble(4, p.getP_price());
            ps.setInt(5, p.getP_quantity());
            ps.setString(6, p.getP_image_path());
            ps.setInt(7, p.getM_id());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Member: Update own product details.
     * Status resets to 'pending' so admin re-approves after any edit.
     * Security: member_id check ensures member can only edit their own products.
     */
    public boolean updateProduct(Product p) {
        String sql = "UPDATE product SET p_name=?, p_description=?, p_category=?, "
                   + "p_price=?, p_quantity=?, p_image_path=?, p_status='pending' "
                   + "WHERE p_id=? AND m_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getP_name());
            ps.setString(2, p.getP_description());
            ps.setString(3, p.getP_category());
            ps.setDouble(4, p.getP_price());
            ps.setInt(5, p.getP_quantity());
            ps.setString(6, p.getP_image_path());
            ps.setInt(7, p.getP_id());
            ps.setInt(8, p.getM_id());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Member: Delete own product.
     * Security: m_id check ensures member cannot delete other members' products.
     */
    public boolean deleteProduct(int p_id, int m_id) {
        String sql = "DELETE FROM product WHERE p_id=? AND m_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, p_id);
            ps.setInt(2, m_id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Member: View list of own products (all statuses).
     */
    public List<Product> getProductsByMember(int m_id) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM product WHERE m_id=? ORDER BY p_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, m_id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ══════════════════════════════════════════════════════════
    //  ADMIN OPERATIONS
    // ══════════════════════════════════════════════════════════

    /**
     * Admin: View all products with member name (JOIN with member table).
     */
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, m.m_fullname FROM product p "
                   + "JOIN member m ON p.m_id = m.m_id "
                   + "ORDER BY p.p_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Product p = mapRow(rs);
                // Store member name in p_description temporarily for display (or use a DTO)
                // Best practice: use a wrapper, but for simplicity tag it
                list.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Admin: Approve or reject a product (update p_status).
     * Allowed values: 'approved', 'rejected'
     */
    public boolean updateProductStatus(int p_id, String status) {
        String sql = "UPDATE product SET p_status=? WHERE p_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, p_id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Admin: Remove/delete any product regardless of member.
     */
    public boolean adminDeleteProduct(int p_id) {
        String sql = "DELETE FROM product WHERE p_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, p_id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ══════════════════════════════════════════════════════════
    //  CUSTOMER OPERATIONS
    // ══════════════════════════════════════════════════════════

    /**
     * Customer: View all approved products.
     */
    public List<Product> getApprovedProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM product WHERE p_status='approved' ORDER BY p_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Customer: Search products by p_name or p_category.
     * Only searches approved products.
     */
    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM product WHERE p_status='approved' "
                   + "AND (p_name LIKE ? OR p_category LIKE ?) ORDER BY p_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String kw = "%" + keyword.trim() + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Customer / Member / Admin: Fetch a single product by p_id.
     */
    public Product getProductById(int p_id) {
        String sql = "SELECT * FROM product WHERE p_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, p_id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ══════════════════════════════════════════════════════════
    //  HELPER - Map ResultSet row → Product object
    // ══════════════════════════════════════════════════════════

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setP_id(rs.getInt("p_id"));
        p.setP_name(rs.getString("p_name"));
        p.setP_description(rs.getString("p_description"));
        p.setP_category(rs.getString("p_category"));
        p.setP_price(rs.getDouble("p_price"));
        p.setP_quantity(rs.getInt("p_quantity"));
        p.setP_image_path(rs.getString("p_image_path"));
        p.setP_status(rs.getString("p_status"));
        p.setM_id(rs.getInt("m_id"));
        return p;
    }
}