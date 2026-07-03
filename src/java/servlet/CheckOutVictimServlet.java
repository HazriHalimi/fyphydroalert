package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class CheckOutVictimServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");

        if(!"officer".equals(userType)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        if(idStr == null) {
            response.sendRedirect("officer-victims.jsp");
            return;
        }

        int victimId = Integer.parseInt(idStr);

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Get victim's current centre and family count
            int centreId = 0;
            int familyCount = 0;
            boolean valid = false;
            
            pstmt = conn.prepareStatement(
                "SELECT centre_id, family_count, status FROM victims WHERE victim_id = ?");
            pstmt.setInt(1, victimId);
            ResultSet rs = pstmt.executeQuery();
            try {
                if(rs.next() && "checked_in".equals(rs.getString("status"))) {
                    centreId    = rs.getInt("centre_id");
                    familyCount = rs.getInt("family_count");
                    valid = true;
                }
            } finally {
                rs.close();
                pstmt.close();
            }

            if(!valid) {
                conn.rollback();
                response.sendRedirect("officer-victims.jsp?error=true");
                return;
            }

            // Mark victim as checked out
            pstmt = conn.prepareStatement(
                "UPDATE victims SET status = 'checked_out', check_out_time = NOW() WHERE victim_id = ?");
            pstmt.setInt(1, victimId);
            pstmt.executeUpdate();
            pstmt.close();

            // Decrement centre count (floor at 0)
            pstmt = conn.prepareStatement(
                "UPDATE relief_centres SET current_count = GREATEST(current_count - ?, 0) WHERE centre_id = ?");
            pstmt.setInt(1, familyCount);
            pstmt.setInt(2, centreId);
            pstmt.executeUpdate();
            pstmt.close();

            // If centre was full and now has space, set back to active
            pstmt = conn.prepareStatement(
                "UPDATE relief_centres SET status = 'active' " +
                "WHERE centre_id = ? AND status = 'full' AND current_count < capacity");
            pstmt.setInt(1, centreId);
            pstmt.executeUpdate();

            conn.commit();
            response.sendRedirect("officer-victims.jsp?checkout=true");

        } catch(Exception e) {
            e.printStackTrace();
            try { if(conn != null) conn.rollback(); } catch(Exception ex) { ex.printStackTrace(); }
            response.sendRedirect("officer-victims.jsp?error=true");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) { conn.setAutoCommit(true); conn.close(); }
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
