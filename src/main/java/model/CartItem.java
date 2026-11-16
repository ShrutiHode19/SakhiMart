package model;

/**
 * CartItem.java
 * Represents one row in the cart table.
 * cart_id | c_id | p_id | quantity | added_at
 */
public class CartItem {

    private int    cart_id;
    private int    c_id;
    private int    p_id;
    private int    quantity;
    private String added_at;

    // ── Joined fields (populated by CartDAO for display) ─────────────────────
    private String p_name;
    private double p_price;
    private String p_image_path;
    private int    p_stock;       // max available quantity
    private String p_category;

    // ── Constructors ─────────────────────────────────────────────────────────
    public CartItem() {}

    public CartItem(int c_id, int p_id, int quantity) {
        this.c_id     = c_id;
        this.p_id     = p_id;
        this.quantity = quantity;
    }

    // ── Core Getters / Setters ────────────────────────────────────────────────
    public int    getCart_id()             { return cart_id; }
    public void   setCart_id(int v)        { this.cart_id = v; }

    public int    getC_id()                { return c_id; }
    public void   setC_id(int v)          { this.c_id = v; }

    public int    getP_id()                { return p_id; }
    public void   setP_id(int v)          { this.p_id = v; }

    public int    getQuantity()            { return quantity; }
    public void   setQuantity(int v)       { this.quantity = v; }

    public String getAdded_at()            { return added_at; }
    public void   setAdded_at(String v)    { this.added_at = v; }

    // ── Joined Getters / Setters ──────────────────────────────────────────────
    public String getP_name()              { return p_name; }
    public void   setP_name(String v)      { this.p_name = v; }

    public double getP_price()             { return p_price; }
    public void   setP_price(double v)     { this.p_price = v; }

    public String getP_image_path()        { return p_image_path; }
    public void   setP_image_path(String v){ this.p_image_path = v; }

    public int    getP_stock()             { return p_stock; }
    public void   setP_stock(int v)        { this.p_stock = v; }

    public String getP_category()          { return p_category; }
    public void   setP_category(String v)  { this.p_category = v; }

    // ── Computed ──────────────────────────────────────────────────────────────
    public double getSubtotal() {
        return p_price * quantity;
    }
}