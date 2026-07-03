package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class AddOfficerServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if admin is logged in
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        
        if(!"admin".equals(userType)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get form parameters
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String status = request.getParameter("status");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // Check if username already exists
            String checkSql = "SELECT * FROM officers WHERE username = ?";
            ResultSet rs = null;
            boolean exists = false;
            try {
                pstmt = conn.prepareStatement(checkSql);
                pstmt.setString(1, username);
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    exists = true;
                }
            } finally {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
            }
            
            if(exists) {
                response.sendRedirect("admin-add-officer.jsp?error=exists");
                return;
            }
            
            // Insert new officer
            String insertSql = "INSERT INTO officers (username, password, full_name, email, phone, status) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            pstmt.setString(3, fullName);
            pstmt.setString(4, email);
            pstmt.setString(5, phone);
            pstmt.setString(6, status);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                response.sendRedirect("admin-officers.jsp?added=true");
            } else {
                response.sendRedirect("admin-add-officer.jsp?error=failed");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-add-officer.jsp?error=failed");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }
}