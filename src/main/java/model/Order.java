package model;

/**
 * Order.java
 * Represents one row in the orders table.
 * order_id | c_id | order_date | total_amount | payment_method | payment_status | delivery_status | delivery_address
 */
public class Order {

    private int    order_id;
    private int    c_id;
    private String order_date;
    private double total_amount;
    private String payment_method;   // "COD" | "UPI" | "Card"
    private String payment_status;   // "pending" | "confirmed" | "failed"
    private String delivery_status;  // "processing" | "shipped" | "delivered" | "cancelled"
    private String delivery_address;

    // ── Joined for display ────────────────────────────────────────────────────
    private String c_fullname;
    private String c_email;
    private String c_contact;

    // ── Constructors ─────────────────────────────────────────────────────────
    public Order() {}

    // ── Getters / Setters ─────────────────────────────────────────────────────
    public int    getOrder_id()                  { return order_id; }
    public void   setOrder_id(int v)             { this.order_id = v; }

    public int    getC_id()                      { return c_id; }
    public void   setC_id(int v)                { this.c_id = v; }

    public String getOrder_date()                { return order_date; }
    public void   setOrder_date(String v)        { this.order_date = v; }

    public double getTotal_amount()              { return total_amount; }
    public void   setTotal_amount(double v)      { this.total_amount = v; }

    public String getPayment_method()            { return payment_method; }
    public void   setPayment_method(String v)    { this.payment_method = v; }

    public String getPayment_status()            { return payment_status; }
    public void   setPayment_status(String v)    { this.payment_status = v; }

    public String getDelivery_status()           { return delivery_status; }
    public void   setDelivery_status(String v)   { this.delivery_status = v; }

    public String getDelivery_address()          { return delivery_address; }
    public void   setDelivery_address(String v)  { this.delivery_address = v; }

    public String getC_fullname()                { return c_fullname; }
    public void   setC_fullname(String v)        { this.c_fullname = v; }

    public String getC_email()                   { return c_email; }
    public void   setC_email(String v)           { this.c_email = v; }

    public String getC_contact()                 { return c_contact; }
    public void   setC_contact(String v)         { this.c_contact = v; }
}