package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;
import util.EmailUtility;

public class UserRegisterServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String location = request.getParameter("location");
        
        // Check if passwords match
        if(!password.equals(confirmPassword)) {
            response.sendRedirect("user-register.jsp?error=mismatch");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // Check if email already exists
            String checkSql = "SELECT * FROM users WHERE email = ?";
            ResultSet rs = null;
            boolean exists = false;
            try {
                pstmt = conn.prepareStatement(checkSql);
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    exists = true;
                }
            } finally {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
            }
            
            if(exists) {
                response.sendRedirect("user-register.jsp?error=exists");
                return;
            }
            
            // Insert new user (we need to add password column to users table)
            String insertSql = "INSERT INTO users (email, password, location, subscribed) VALUES (?, ?, ?, 1)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            pstmt.setString(3, location);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                EmailUtility.sendRegistrationEmail(email, password);
                response.sendRedirect("login.jsp?success=registered");
            } else {
                response.sendRedirect("user-register.jsp?error=failed");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("user-register.jsp?error=failed");
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