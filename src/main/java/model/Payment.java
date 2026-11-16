package model;

/**
 * Payment.java
 * Represents one row in the payment table (sakhi.sql exact match).
 *
 * payment_id     | payment_amount | payment_method | payment_status
 * payment_date   | transaction_id | o_id
 *
 * + joined display fields for JSP rendering (not DB columns):
 *   o_status, delivery_date, c_fullname, c_email, c_contact
 */
public class Payment {

    // ── Core DB columns ───────────────────────────────────────────────────────
    private int    payment_id;
    private double payment_amount;
    private String payment_method;    // 'UPI' | 'Online' | 'Cash on Delivery'
    private String payment_status;    // 'Completed' | 'Pending' | 'Failed'
    private String payment_date;
    private String transaction_id;    // nullable
    private int    o_id;              // FK → order(o_id)

    // ── Joined display fields (populated by DAO for JSP) ─────────────────────
    private String o_status;          // order delivery status
    private String delivery_date;
    private String c_fullname;
    private String c_email;
    private String c_contact;

    // ── Constructors ──────────────────────────────────────────────────────────
    public Payment() {}

    public Payment(int o_id, double payment_amount, String payment_method, String payment_status) {
        this.o_id            = o_id;
        this.payment_amount  = payment_amount;
        this.payment_method  = payment_method;
        this.payment_status  = payment_status;
    }

    // ── Computed helper ───────────────────────────────────────────────────────
    /** Returns true if payment is complete and successful. */
    public boolean isCompleted() {
        return "Completed".equalsIgnoreCase(payment_status);
    }

    /** Returns true if payment is still pending. */
    public boolean isPending() {
        return "Pending".equalsIgnoreCase(payment_status);
    }

    /** Returns CSS badge class name based on payment_status. */
    public String getStatusBadgeClass() {
        if (payment_status == null) return "badge-warning";
        switch (payment_status) {
            case "Completed": return "badge-success";
            case "Failed":    return "badge-danger";
            default:          return "badge-warning";
        }
    }

    /** Returns CSS badge class name based on o_status (delivery). */
    public String getDeliveryBadgeClass() {
        if (o_status == null) return "badge-info";
        switch (o_status) {
            case "Delivered":  return "badge-success";
            case "Shipped":    return "badge-warning";
            case "Cancelled":  return "badge-danger";
            case "Confirmed":  return "badge-info";
            default:           return "badge-secondary";
        }
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────
    public int    getPayment_id()                      { return payment_id; }
    public void   setPayment_id(int payment_id)        { this.payment_id = payment_id; }

    public double getPayment_amount()                  { return payment_amount; }
    public void   setPayment_amount(double v)          { this.payment_amount = v; }

    public String getPayment_method()                  { return payment_method; }
    public void   setPayment_method(String v)          { this.payment_method = v; }

    public String getPayment_status()                  { return payment_status; }
    public void   setPayment_status(String v)          { this.payment_status = v; }

    public String getPayment_date()                    { return payment_date; }
    public void   setPayment_date(String v)            { this.payment_date = v; }

    public String getTransaction_id()                  { return transaction_id; }
    public void   setTransaction_id(String v)          { this.transaction_id = v; }

    public int    getO_id()                            { return o_id; }
    public void   setO_id(int o_id)                   { this.o_id = o_id; }

    public String getO_status()                        { return o_status; }
    public void   setO_status(String v)                { this.o_status = v; }

    public String getDelivery_date()                   { return delivery_date; }
    public void   setDelivery_date(String v)           { this.delivery_date = v; }

    public String getC_fullname()                      { return c_fullname; }
    public void   setC_fullname(String v)              { this.c_fullname = v; }

    public String getC_email()                         { return c_email; }
    public void   setC_email(String v)                 { this.c_email = v; }

    public String getC_contact()                       { return c_contact; }
    public void   setC_contact(String v)               { this.c_contact = v; }
}