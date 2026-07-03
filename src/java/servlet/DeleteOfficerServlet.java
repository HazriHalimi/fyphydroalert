package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class DeleteOfficerServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if admin is logged in
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        
        if(!"admin".equals(userType)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String officerIdStr = request.getParameter("id");
        
        if(officerIdStr == null) {
            response.sendRedirect("admin-officers.jsp");
            return;
        }
        
        int officerId = Integer.parseInt(officerIdStr);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            String sql = "DELETE FROM officers WHERE officer_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, officerId);
            
            pstmt.executeUpdate();
            
            response.sendRedirect("admin-officers.jsp?deleted=true");
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-officers.jsp?error=true");
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