package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class DeleteCentreServlet extends HttpServlet {

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
            response.sendRedirect("officer-center.jsp");
            return;
        }

        int centreId = Integer.parseInt(idStr);

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            // Nullify victims' centre_id before deleting (FK is ON DELETE SET NULL)
            String sql = "DELETE FROM relief_centres WHERE centre_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, centreId);
            pstmt.executeUpdate();

            response.sendRedirect("officer-center.jsp?deleted=true");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("officer-center.jsp?error=true");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
