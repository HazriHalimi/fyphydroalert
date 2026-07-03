package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class DeleteUserServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if admin is logged in
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        
        if(!"admin".equals(userType)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String userIdStr = request.getParameter("id");
        
        if(userIdStr == null) {
            response.sendRedirect("admin-users.jsp");
            return;
        }
        
        int userId = Integer.parseInt(userIdStr);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            String sql = "DELETE FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            pstmt.executeUpdate();
            
            response.sendRedirect("admin-users.jsp?deleted=true");
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-users.jsp?error=true");
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