package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class LoginServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // 1. Check admin first
            String adminSql = "SELECT * FROM admins WHERE email = ? AND password = ? AND status = 'active'";
            pstmt = conn.prepareStatement(adminSql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                // Admin login successful
                HttpSession session = request.getSession();
                session.invalidate(); // Clear any existing session to prevent role leakage
                session = request.getSession(true);
                
                session.setAttribute("adminId", rs.getInt("admin_id"));
                session.setAttribute("adminUsername", rs.getString("username"));
                session.setAttribute("adminName", rs.getString("full_name"));
                session.setAttribute("adminEmail", email);
                session.setAttribute("userType", "admin");
                
                response.sendRedirect("admin-dashboard.jsp");
                return;
            }
            rs.close();
            pstmt.close();
            
            // 2. Check officer second
            String officerSql = "SELECT * FROM officers WHERE email = ? AND password = ? AND status = 'active'";
            pstmt = conn.prepareStatement(officerSql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                // Officer login successful
                HttpSession session = request.getSession();
                session.invalidate(); // Clear any existing session
                session = request.getSession(true);
                
                session.setAttribute("officerId", rs.getInt("officer_id"));
                session.setAttribute("officerUsername", rs.getString("username"));
                session.setAttribute("officerName", rs.getString("full_name"));
                session.setAttribute("officerEmail", email);
                session.setAttribute("userType", "officer");
                
                response.sendRedirect("officer-dashboard.jsp");
                return;
            }
            rs.close();
            pstmt.close();
            
            // 3. Check user (resident) third
            String userSql = "SELECT * FROM users WHERE email = ? AND password = ?";
            pstmt = conn.prepareStatement(userSql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                // Resident login successful
                HttpSession session = request.getSession();
                session.invalidate(); // Clear any existing session
                session = request.getSession(true);
                
                session.setAttribute("userId", rs.getInt("user_id"));
                session.setAttribute("userEmail", email);
                session.setAttribute("userLocation", rs.getString("location"));
                session.setAttribute("userType", "user");
                
                response.sendRedirect("user-places.jsp");
                return;
            }
            
            // Login failed
            response.sendRedirect("login.jsp?error=invalid");
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=failed");
        } finally {
            try {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }
}