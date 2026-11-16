package model;


public class Product {

    private int    p_id;
    private String p_name;
    private String p_description;
    private String p_category;
    private double p_price;
    private int    p_quantity;
    private String p_image_path;
    private String p_status;      
    private int    m_id;           // FK → Member(m_id)

    // ── Constructors ────────────────────────────────────────────────────────

    public Product() {}

    public Product(int p_id, String p_name, String p_description, String p_category,
                   double p_price, int p_quantity, String p_image_path,
                   String p_status, int m_id) {
        this.p_id          = p_id;
        this.p_name        = p_name;
        this.p_description = p_description;
        this.p_category    = p_category;
        this.p_price       = p_price;
        this.p_quantity    = p_quantity;
        this.p_image_path  = p_image_path;
        this.p_status      = p_status;
        this.m_id          = m_id;
    }

    // ── Getters & Setters ────────────────────────────────────────────────────

    public int    getP_id()               { return p_id; }
    public void   setP_id(int p_id)       { this.p_id = p_id; }

    public String getP_name()             { return p_name; }
    public void   setP_name(String v)     { this.p_name = v; }

    public String getP_description()      { return p_description; }
    public void   setP_description(String v) { this.p_description = v; }

    public String getP_category()         { return p_category; }
    public void   setP_category(String v) { this.p_category = v; }

    public double getP_price()            { return p_price; }
    public void   setP_price(double v)    { this.p_price = v; }

    public int    getP_quantity()         { return p_quantity; }
    public void   setP_quantity(int v)    { this.p_quantity = v; }

    public String getP_image_path()       { return p_image_path; }
    public void   setP_image_path(String v){ this.p_image_path = v; }

    public String getP_status()           { return p_status; }
    public void   setP_status(String v)   { this.p_status = v; }

    public int    getM_id()               { return m_id; }
    public void   setM_id(int v)          { this.m_id = v; }
}