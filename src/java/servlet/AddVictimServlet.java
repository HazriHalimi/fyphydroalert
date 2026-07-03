package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class AddVictimServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        Integer officerId = (Integer) session.getAttribute("officerId");

        if(!"officer".equals(userType) || officerId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String fullName        = request.getParameter("fullName");
        String icNumber        = request.getParameter("icNumber");
        String phone           = request.getParameter("phone");
        String familyCountStr  = request.getParameter("familyCount");
        String centreIdStr     = request.getParameter("centreId");
        String notes           = request.getParameter("notes");

        int familyCount = Integer.parseInt(familyCountStr);
        int centreId    = Integer.parseInt(centreIdStr);

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // use transaction

            // Check if IC already checked-in (active registration)
            String checkSql = "SELECT victim_id FROM victims WHERE ic_number = ? AND status = 'checked_in'";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, icNumber);
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()) {
                rs.close();
                conn.rollback();
                response.sendRedirect("officer-add-victim.jsp?error=exists");
                return;
            }
            rs.close();
            pstmt.close();

            // Check center capacity
            String capSql = "SELECT capacity, current_count FROM relief_centres WHERE centre_id = ?";
            pstmt = conn.prepareStatement(capSql);
            pstmt.setInt(1, centreId);
            ResultSet rsCap = pstmt.executeQuery();
            if(rsCap.next()) {
                int capacity = rsCap.getInt("capacity");
                int currentCount = rsCap.getInt("current_count");
                if(currentCount + familyCount > capacity) {
                    rsCap.close();
                    conn.rollback();
                    response.sendRedirect("officer-add-victim.jsp?error=overcapacity&remaining=" + (capacity - currentCount));
                    return;
                }
            }
            rsCap.close();
            pstmt.close();


            // Insert victim
            String insertSql = "INSERT INTO victims (full_name, ic_number, phone, family_count, " +
                               "centre_id, officer_id, status, notes) VALUES (?, ?, ?, ?, ?, ?, 'checked_in', ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, fullName);
            pstmt.setString(2, icNumber);
            pstmt.setString(3, (phone != null && !phone.trim().isEmpty()) ? phone : null);
            pstmt.setInt(4, familyCount);
            pstmt.setInt(5, centreId);
            pstmt.setInt(6, officerId);
            pstmt.setString(7, (notes != null && !notes.trim().isEmpty()) ? notes : null);
            pstmt.executeUpdate();
            pstmt.close();

            // Increment current_count by familyCount
            String updateSql = "UPDATE relief_centres SET current_count = current_count + ? WHERE centre_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, familyCount);
            pstmt.setInt(2, centreId);
            pstmt.executeUpdate();
            pstmt.close();

            // Auto-set status to 'full' if at/over capacity
            String fullCheckSql = "UPDATE relief_centres SET status = 'full' " +
                                  "WHERE centre_id = ? AND current_count >= capacity AND status = 'active'";
            pstmt = conn.prepareStatement(fullCheckSql);
            pstmt.setInt(1, centreId);
            pstmt.executeUpdate();

            conn.commit();
            response.sendRedirect("officer-victims.jsp?added=true");

        } catch(Exception e) {
            e.printStackTrace();
            try { if(conn != null) conn.rollback(); } catch(Exception ex) { ex.printStackTrace(); }
            response.sendRedirect("officer-add-victim.jsp?error=true");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) { conn.setAutoCommit(true); conn.close(); }
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
