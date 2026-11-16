package model;

public class Admin {

    private int    a_id;
    private String a_fullname;
    private String a_login_id;
    private String a_password;
    private String a_email;
    private String a_address;
    private String a_gender;
    private long   a_contact;

    public int    getA_id()                  { return a_id; }
    public void   setA_id(int a_id)          { this.a_id = a_id; }

    public String getA_fullname()                      { return a_fullname; }
    public void   setA_fullname(String a_fullname)     { this.a_fullname = a_fullname; }

    public String getA_login_id()                      { return a_login_id; }
    public void   setA_login_id(String a_login_id)     { this.a_login_id = a_login_id; }

    public String getA_password()                      { return a_password; }
    public void   setA_password(String a_password)     { this.a_password = a_password; }

    public String getA_email()                         { return a_email; }
    public void   setA_email(String a_email)           { this.a_email = a_email; }

    public String getA_address()                       { return a_address; }
    public void   setA_address(String a_address)       { this.a_address = a_address; }

    public String getA_gender()                        { return a_gender; }
    public void   setA_gender(String a_gender)         { this.a_gender = a_gender; }

    public long   getA_contact()                       { return a_contact; }
    public void   setA_contact(long a_contact)         { this.a_contact = a_contact; }
}