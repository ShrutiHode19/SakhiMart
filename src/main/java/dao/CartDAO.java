package dao;

import model.CartItem;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
 /* All database operations for the Cart module.
 *
 * Table: cart
 *   cart_id INT PK AUTO_INCREMENT
 *   c_id    INT FK → customer(c_id)
 *   p_id    INT FK → product(p_id)
 *   quantity INT
 *   added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
 */
public class CartDAO {

    // ── Auto-create cart table if it doesn't exist ────────────────────────────
    static {
        String sql = "CREATE TABLE IF NOT EXISTS cart (" +
            "cart_id INT NOT NULL AUTO_INCREMENT, " +
            "c_id INT NOT NULL, " +
            "p_id INT NOT NULL, " +
            "quantity INT NOT NULL DEFAULT 1, " +
            "added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
            "PRIMARY KEY (cart_id), " +
            "UNIQUE KEY uq_cart_item (c_id, p_id), " +
            "CONSTRAINT fk_cart_customer FOREIGN KEY (c_id) REFERENCES customer(c_id) ON DELETE CASCADE, " +
            "CONSTRAINT fk_cart_product  FOREIGN KEY (p_id) REFERENCES product(p_id)  ON DELETE CASCADE" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {
            st.executeUpdate(sql);
        } catch (Exception e) {
            System.err.println("[CartDAO] Table init warning: " + e.getMessage());
        }
    }

    // ── Add item to cart (or increment quantity if already exists) ────────────
    public boolean addToCart(int c_id, int p_id, int quantity) {
        // Check if already in cart
        String checkSql = "SELECT cart_id, quantity FROM cart WHERE c_id=? AND p_id=?";
        String updateSql = "UPDATE cart SET quantity = quantity + ? WHERE c_id=? AND p_id=?";
        String insertSql = "INSERT INTO cart (c_id, p_id, quantity) VALUES (?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {

            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setInt(1, c_id);
            checkPs.setInt(2, p_id);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                // Item exists — update quantity
                PreparedStatement updPs = con.prepareStatement(updateSql);
                updPs.setInt(1, quantity);
                updPs.setInt(2, c_id);
                updPs.setInt(3, p_id);
                return updPs.executeUpdate() > 0;
            } else {
                // New item — insert
                PreparedStatement insPs = con.prepareStatement(insertSql);
                insPs.setInt(1, c_id);
                insPs.setInt(2, p_id);
                insPs.setInt(3, quantity);
                return insPs.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Update quantity of a specific cart item ───────────────────────────────
    public boolean updateQuantity(int cart_id, int c_id, int quantity) {
        String sql = "UPDATE cart SET quantity=? WHERE cart_id=? AND c_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, cart_id);
            ps.setInt(3, c_id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Remove a specific item from cart ─────────────────────────────────────
    public boolean removeFromCart(int cart_id, int c_id) {
        String sql = "DELETE FROM cart WHERE cart_id=? AND c_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cart_id);
            ps.setInt(2, c_id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Clear entire cart for a customer (called after order placed) ──────────
    public boolean clearCart(int c_id) {
        String sql = "DELETE FROM cart WHERE c_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c_id);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Get all cart items for a customer (with product details joined) ────────
    public List<CartItem> getCartItems(int c_id) {
        List<CartItem> list = new ArrayList<>();
        String sql = "SELECT c.cart_id, c.c_id, c.p_id, c.quantity, c.added_at, " +
                     "p.p_name, p.p_price, p.p_image_path, p.p_quantity AS p_stock, p.p_category " +
                     "FROM cart c " +
                     "JOIN product p ON c.p_id = p.p_id " +
                     "WHERE c.c_id = ? " +
                     "ORDER BY c.added_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, c_id);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CartItem item = new CartItem();
                item.setCart_id(rs.getInt("cart_id"));
                item.setC_id(rs.getInt("c_id"));
                item.setP_id(rs.getInt("p_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setAdded_at(rs.getString("added_at"));
                item.setP_name(rs.getString("p_name"));
                item.setP_price(rs.getDouble("p_price"));
                item.setP_image_path(rs.getString("p_image_path"));
                item.setP_stock(rs.getInt("p_stock"));
                item.setP_category(rs.getString("p_category"));
                list.add(item);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Count number of distinct items in customer's cart ─────────────────────
    public int getCartCount(int c_id) {
        String sql = "SELECT COUNT(*) FROM cart WHERE c_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c_id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── Compute cart total for a customer ─────────────────────────────────────
    public double getCartTotal(int c_id) {
        String sql = "SELECT SUM(c.quantity * p.p_price) AS total " +
                     "FROM cart c JOIN product p ON c.p_id = p.p_id " +
                     "WHERE c.c_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c_id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble("total");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}