package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class UpdateOfficerProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType  = (String) session.getAttribute("userType");
        Integer officerId = (Integer) session.getAttribute("officerId");

        if(!"officer".equals(userType) || officerId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String newEmail       = request.getParameter("email").trim();
        String newPhone       = request.getParameter("phone");
        String newPassword    = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Server-side password match check
        if(newPassword != null && !newPassword.trim().isEmpty()) {
            if(!newPassword.equals(confirmPassword)) {
                response.sendRedirect("officer-profile.jsp?msg=pwmismatch");
                return;
            }
        }

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            // Check if email is taken by another officer
            boolean emailTaken = false;
            pstmt = conn.prepareStatement(
                "SELECT officer_id FROM officers WHERE email = ? AND officer_id != ?");
            pstmt.setString(1, newEmail);
            pstmt.setInt(2, officerId);
            ResultSet rs = pstmt.executeQuery();
            try {
                if(rs.next()) {
                    emailTaken = true;
                }
            } finally {
                rs.close();
                pstmt.close();
            }

            if(emailTaken) {
                response.sendRedirect("officer-profile.jsp?msg=emailtaken");
                return;
            }

            // Update with or without password
            if(newPassword != null && !newPassword.trim().isEmpty()) {
                pstmt = conn.prepareStatement(
                    "UPDATE officers SET email=?, phone=?, password=? WHERE officer_id=?");
                pstmt.setString(1, newEmail);
                pstmt.setString(2, (newPhone != null && !newPhone.trim().isEmpty()) ? newPhone.trim() : null);
                pstmt.setString(3, newPassword.trim());
                pstmt.setInt(4, officerId);
            } else {
                pstmt = conn.prepareStatement(
                    "UPDATE officers SET email=?, phone=? WHERE officer_id=?");
                pstmt.setString(1, newEmail);
                pstmt.setString(2, (newPhone != null && !newPhone.trim().isEmpty()) ? newPhone.trim() : null);
                pstmt.setInt(3, officerId);
            }

            pstmt.executeUpdate();

            response.sendRedirect("officer-profile.jsp?msg=updated");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("officer-profile.jsp?msg=error");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
