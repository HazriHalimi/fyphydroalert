package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class AddCentreServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        Integer officerId = (Integer) session.getAttribute("officerId");

        if(!"officer".equals(userType) || officerId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String centreName  = request.getParameter("centreName");
        String address     = request.getParameter("address");
        String location    = request.getParameter("location");
        String state       = request.getParameter("state");
        String capacityStr = request.getParameter("capacity");
        String status      = request.getParameter("status");
        String latStr      = request.getParameter("latitude");
        String lngStr      = request.getParameter("longitude");
        String notes       = request.getParameter("notes");

        int capacity = Integer.parseInt(capacityStr);

        Double latitude = null;
        if(latStr != null && !latStr.trim().isEmpty()) latitude = Double.parseDouble(latStr);

        Double longitude = null;
        if(lngStr != null && !lngStr.trim().isEmpty()) longitude = Double.parseDouble(lngStr);

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "INSERT INTO relief_centres (centre_name, address, location, state, capacity, " +
                         "current_count, status, latitude, longitude, created_by, notes) " +
                         "VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, centreName);
            pstmt.setString(2, address);
            pstmt.setString(3, location);
            pstmt.setString(4, state);
            pstmt.setInt(5, capacity);
            pstmt.setString(6, status);

            if(latitude != null) pstmt.setDouble(7, latitude);
            else pstmt.setNull(7, Types.DECIMAL);

            if(longitude != null) pstmt.setDouble(8, longitude);
            else pstmt.setNull(8, Types.DECIMAL);

            pstmt.setInt(9, officerId);
            pstmt.setString(10, notes);

            int result = pstmt.executeUpdate();

            if(result > 0) {
                response.sendRedirect("officer-center.jsp?added=true");
            } else {
                response.sendRedirect("officer-add-center.jsp?error=true");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("officer-add-center.jsp?error=true");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
