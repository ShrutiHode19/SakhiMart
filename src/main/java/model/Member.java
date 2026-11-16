package model;

public class Member {

    private int    m_id;
    private String m_fullname;
    private String m_login_id;
    private String m_password;
    private String m_email;
    private String m_address;
    private String m_gender;
    private long   m_contact;
    private String m_status;   // values: pending | approved | rejected

    public int    getM_id()                          { return m_id; }
    public void   setM_id(int m_id)                  { this.m_id = m_id; }

    public String getM_fullname()                    { return m_fullname; }
    public void   setM_fullname(String m_fullname)   { this.m_fullname = m_fullname; }

    public String getM_login_id()                    { return m_login_id; }
    public void   setM_login_id(String m_login_id)   { this.m_login_id = m_login_id; }

    public String getM_password()                    { return m_password; }
    public void   setM_password(String m_password)   { this.m_password = m_password; }

    public String getM_email()                       { return m_email; }
    public void   setM_email(String m_email)         { this.m_email = m_email; }

    public String getM_address()                     { return m_address; }
    public void   setM_address(String m_address)     { this.m_address = m_address; }

    public String getM_gender()                      { return m_gender; }
    public void   setM_gender(String m_gender)       { this.m_gender = m_gender; }

    public long   getM_contact()                     { return m_contact; }
    public void   setM_contact(long m_contact)       { this.m_contact = m_contact; }

    public String getM_status()                      { return m_status; }
    public void   setM_status(String m_status)       { this.m_status = m_status; }
}