package model;

public class Customer {
    private int c_id;
    private String c_fullname, c_login_id, c_password;
    private String c_email, c_address, c_gender;
    private long c_contact;

    // BUG FIX #4: c_id had no getter/setter — ProfileDAO and CustomerDAO
    // can now properly read/expose the primary key when needed
    public int getC_id() { return c_id; }
    public void setC_id(int c_id) { this.c_id = c_id; }

    public String getC_fullname() { return c_fullname; }
    public void setC_fullname(String c_fullname) { this.c_fullname = c_fullname; }

    public String getC_login_id() { return c_login_id; }
    public void setC_login_id(String c_login_id) { this.c_login_id = c_login_id; }

    public String getC_password() { return c_password; }
    public void setC_password(String c_password) { this.c_password = c_password; }

    public String getC_email() { return c_email; }
    public void setC_email(String c_email) { this.c_email = c_email; }

    public String getC_address() { return c_address; }
    public void setC_address(String c_address) { this.c_address = c_address; }

    public String getC_gender() { return c_gender; }
    public void setC_gender(String c_gender) { this.c_gender = c_gender; }

    public long getC_contact() { return c_contact; }
    public void setC_contact(long c_contact) { this.c_contact = c_contact; }
}
