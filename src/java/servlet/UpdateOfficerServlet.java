package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class UpdateOfficerServlet extends HttpServlet {
    
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
        int officerId = Integer.parseInt(request.getParameter("officerId"));
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String status = request.getParameter("status");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            String sql = "UPDATE officers SET password=?, full_name=?, email=?, phone=?, status=? WHERE officer_id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, password);
            pstmt.setString(2, fullName);
            pstmt.setString(3, email);
            pstmt.setString(4, phone);
            pstmt.setString(5, status);
            pstmt.setInt(6, officerId);
            
            pstmt.executeUpdate();
            
            response.sendRedirect("admin-officers.jsp?updated=true");
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-edit-officer.jsp?id=" + officerId + "&error=true");
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