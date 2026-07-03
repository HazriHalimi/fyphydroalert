package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class DeleteReadingServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get officer ID from session
        HttpSession session = request.getSession();
        Integer officerId = (Integer) session.getAttribute("officerId");
        
        if(officerId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String readingIdStr = request.getParameter("id");
        
        if(readingIdStr == null) {
            response.sendRedirect("officer-my-readings.jsp");
            return;
        }
        
        int readingId = Integer.parseInt(readingIdStr);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // Delete only if it belongs to this officer
            String sql = "DELETE FROM readings WHERE reading_id = ? AND officer_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, readingId);
            pstmt.setInt(2, officerId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                response.sendRedirect("officer-my-readings.jsp?deleted=true");
            } else {
                response.sendRedirect("officer-my-readings.jsp?error=true");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("officer-my-readings.jsp?error=true");
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