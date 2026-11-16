package model;

/**
 * OrderItem.java
 * Represents one product line inside an order.
 * order_item_id | order_id | p_id | quantity | unit_price
 */
public class OrderItem {

    private int    order_item_id;
    private int    order_id;
    private int    p_id;
    private int    quantity;
    private double unit_price;

    // ── Joined for display ────────────────────────────────────────────────────
    private String p_name;
    private String p_image_path;
    private String p_category;

    // ── Constructors ─────────────────────────────────────────────────────────
    public OrderItem() {}

    public OrderItem(int order_id, int p_id, int quantity, double unit_price) {
        this.order_id   = order_id;
        this.p_id       = p_id;
        this.quantity   = quantity;
        this.unit_price = unit_price;
    }

    // ── Getters / Setters ─────────────────────────────────────────────────────
    public int    getOrder_item_id()             { return order_item_id; }
    public void   setOrder_item_id(int v)        { this.order_item_id = v; }

    public int    getOrder_id()                  { return order_id; }
    public void   setOrder_id(int v)             { this.order_id = v; }

    public int    getP_id()                      { return p_id; }
    public void   setP_id(int v)                { this.p_id = v; }

    public int    getQuantity()                  { return quantity; }
    public void   setQuantity(int v)             { this.quantity = v; }

    public double getUnit_price()                { return unit_price; }
    public void   setUnit_price(double v)        { this.unit_price = v; }

    public String getP_name()                    { return p_name; }
    public void   setP_name(String v)            { this.p_name = v; }

    public String getP_image_path()              { return p_image_path; }
    public void   setP_image_path(String v)      { this.p_image_path = v; }

    public String getP_category()                { return p_category; }
    public void   setP_category(String v)        { this.p_category = v; }

    // ── Computed ──────────────────────────────────────────────────────────────
    public double getSubtotal() {
        return unit_price * quantity;
    }
}