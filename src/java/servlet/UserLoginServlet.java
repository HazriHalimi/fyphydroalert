package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class UserLoginServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            
            ResultSet rs = pstmt.executeQuery();
            
            if(rs.next()) {
                // Login successful - create session
                HttpSession session = request.getSession();
                session.setAttribute("userEmail", email);
                session.setAttribute("userId", rs.getInt("user_id"));
                session.setAttribute("userLocation", rs.getString("location"));
                session.setAttribute("userType", "user");
                
                response.sendRedirect("user-places.jsp");
            } else {
                // Login failed
                response.sendRedirect("user-login.jsp?error=invalid");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("user-login.jsp?error=failed");
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