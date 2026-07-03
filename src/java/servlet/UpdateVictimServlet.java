package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class UpdateVictimServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");

        if(!"officer".equals(userType)) {
            response.sendRedirect("login.jsp");
            return;
        }

        int victimId          = Integer.parseInt(request.getParameter("victimId"));
        String fullName       = request.getParameter("fullName");
        String icNumber       = request.getParameter("icNumber");
        String phone          = request.getParameter("phone");
        int newFamilyCount    = Integer.parseInt(request.getParameter("familyCount"));
        int newCentreId       = Integer.parseInt(request.getParameter("centreId"));
        String newStatus      = request.getParameter("status");
        String notes          = request.getParameter("notes");

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Get old values before update
            pstmt = conn.prepareStatement(
                "SELECT centre_id, family_count, status FROM victims WHERE victim_id = ?");
            pstmt.setInt(1, victimId);
            ResultSet rs = pstmt.executeQuery();

            int oldCentreId = 0, oldFamilyCount = 0;
            String oldStatus = "";
            if(rs.next()) {
                oldCentreId    = rs.getInt("centre_id");
                oldFamilyCount = rs.getInt("family_count");
                oldStatus      = rs.getString("status");
            }
            rs.close();
            pstmt.close();

            // Validate capacity constraints before making changes
            boolean wasCheckedIn = "checked_in".equals(oldStatus);
            boolean isCheckedIn  = "checked_in".equals(newStatus);

            boolean needsCapacityCheck = false;
            int diffToCheck = 0;
            if(oldCentreId == newCentreId) {
                if(wasCheckedIn && isCheckedIn) {
                    diffToCheck = newFamilyCount - oldFamilyCount;
                    if(diffToCheck > 0) {
                        needsCapacityCheck = true;
                    }
                } else if(!wasCheckedIn && isCheckedIn) {
                    diffToCheck = newFamilyCount;
                    needsCapacityCheck = true;
                }
            } else {
                if(isCheckedIn) {
                    diffToCheck = newFamilyCount;
                    needsCapacityCheck = true;
                }
            }

            if(needsCapacityCheck) {
                pstmt = conn.prepareStatement("SELECT capacity, current_count FROM relief_centres WHERE centre_id = ?");
                pstmt.setInt(1, newCentreId);
                ResultSet rsCap = pstmt.executeQuery();
                int capacity = 0;
                int currentCount = 0;
                boolean found = false;
                try {
                    if(rsCap.next()) {
                        capacity = rsCap.getInt("capacity");
                        currentCount = rsCap.getInt("current_count");
                        found = true;
                    }
                } finally {
                    rsCap.close();
                    pstmt.close();
                }

                if(found && (currentCount + diffToCheck > capacity)) {
                    conn.rollback();
                    response.sendRedirect("officer-edit-victim.jsp?id=" + victimId + "&error=overcapacity&remaining=" + (capacity - currentCount));
                    return;
                }
            }

            // Update victim record
            String updateSql = "UPDATE victims SET full_name=?, ic_number=?, phone=?, " +
                               "family_count=?, centre_id=?, status=?, notes=? WHERE victim_id=?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, fullName);
            pstmt.setString(2, icNumber);
            pstmt.setString(3, (phone != null && !phone.trim().isEmpty()) ? phone : null);
            pstmt.setInt(4, newFamilyCount);
            pstmt.setInt(5, newCentreId);
            pstmt.setString(6, newStatus);
            pstmt.setString(7, (notes != null && !notes.trim().isEmpty()) ? notes : null);
            pstmt.setInt(8, victimId);
            pstmt.executeUpdate();
            pstmt.close();

            // If checking out, set check_out_time
            if("checked_out".equals(newStatus) && !"checked_out".equals(oldStatus)) {
                pstmt = conn.prepareStatement(
                    "UPDATE victims SET check_out_time = NOW() WHERE victim_id = ?");
                pstmt.setInt(1, victimId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            if(oldCentreId == newCentreId) {
                // Same centre — just adjust for family count change
                if(wasCheckedIn && isCheckedIn) {
                    int diff = newFamilyCount - oldFamilyCount;
                    if(diff != 0) {
                        pstmt = conn.prepareStatement(
                            "UPDATE relief_centres SET current_count = current_count + ? WHERE centre_id = ?");
                        pstmt.setInt(1, diff);
                        pstmt.setInt(2, newCentreId);
                        pstmt.executeUpdate();
                        pstmt.close();
                    }
                } else if(wasCheckedIn && !isCheckedIn) {
                    // Checked out — decrement
                    pstmt = conn.prepareStatement(
                        "UPDATE relief_centres SET current_count = GREATEST(current_count - ?, 0) WHERE centre_id = ?");
                    pstmt.setInt(1, oldFamilyCount);
                    pstmt.setInt(2, oldCentreId);
                    pstmt.executeUpdate();
                    pstmt.close();
                } else if(!wasCheckedIn && isCheckedIn) {
                    // Re-checked in — increment
                    pstmt = conn.prepareStatement(
                        "UPDATE relief_centres SET current_count = current_count + ? WHERE centre_id = ?");
                    pstmt.setInt(1, newFamilyCount);
                    pstmt.setInt(2, newCentreId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            } else {
                // Centre changed — remove from old, add to new
                if(wasCheckedIn) {
                    pstmt = conn.prepareStatement(
                        "UPDATE relief_centres SET current_count = GREATEST(current_count - ?, 0) WHERE centre_id = ?");
                    pstmt.setInt(1, oldFamilyCount);
                    pstmt.setInt(2, oldCentreId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
                if(isCheckedIn) {
                    pstmt = conn.prepareStatement(
                        "UPDATE relief_centres SET current_count = current_count + ? WHERE centre_id = ?");
                    pstmt.setInt(1, newFamilyCount);
                    pstmt.setInt(2, newCentreId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            // Refresh full/active status on affected centres
            String refreshSql = "UPDATE relief_centres SET status = " +
                "CASE WHEN current_count >= capacity THEN 'full' " +
                "     WHEN status = 'full' AND current_count < capacity THEN 'active' " +
                "     ELSE status END " +
                "WHERE centre_id = ?";
            for(int cid : new int[]{oldCentreId, newCentreId}) {
                if(cid > 0) {
                    pstmt = conn.prepareStatement(refreshSql);
                    pstmt.setInt(1, cid);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            conn.commit();
            response.sendRedirect("officer-victims.jsp?updated=true");

        } catch(Exception e) {
            e.printStackTrace();
            try { if(conn != null) conn.rollback(); } catch(Exception ex) { ex.printStackTrace(); }
            response.sendRedirect("officer-edit-victim.jsp?id=" + victimId + "&error=true");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) { conn.setAutoCommit(true); conn.close(); }
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
