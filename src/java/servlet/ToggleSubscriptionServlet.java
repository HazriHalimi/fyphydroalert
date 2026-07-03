package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class ToggleSubscriptionServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get user ID from session
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if(userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            String sql = "UPDATE users SET subscribed = ? WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            
            if("subscribe".equals(action)) {
                pstmt.setInt(1, 1);
            } else {
                pstmt.setInt(1, 0);
            }
            
            pstmt.setInt(2, userId);
            
            pstmt.executeUpdate();
            
            if("subscribe".equals(action)) {
                response.sendRedirect("user-places.jsp?subscribed=true");
            } else {
                response.sendRedirect("user-places.jsp?unsubscribed=true");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("user-dashboard.jsp?error=true");
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