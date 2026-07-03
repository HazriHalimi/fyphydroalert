package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class UpdateCentreServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");

        if(!"officer".equals(userType)) {
            response.sendRedirect("login.jsp");
            return;
        }

        int centreId       = Integer.parseInt(request.getParameter("centreId"));
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

            String sql = "UPDATE relief_centres SET centre_name=?, address=?, location=?, state=?, " +
                         "capacity=?, status=?, latitude=?, longitude=?, notes=? WHERE centre_id=?";
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

            pstmt.setString(9, notes);
            pstmt.setInt(10, centreId);

            pstmt.executeUpdate();

            response.sendRedirect("officer-center.jsp?updated=true");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("officer-edit-centre.jsp?id=" + centreId + "&error=true");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
