package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class UpdateProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        Integer userId  = (Integer) session.getAttribute("userId");

        if(!"user".equals(userType) || userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String newEmail       = request.getParameter("email").trim();
        String newPassword    = request.getParameter("password");
        String confirmPassword= request.getParameter("confirmPassword");
        String newLocation    = request.getParameter("location");

        // Server-side password match check
        if(newPassword != null && !newPassword.trim().isEmpty()) {
            if(!newPassword.equals(confirmPassword)) {
                response.sendRedirect("user-profile.jsp?msg=pwmismatch");
                return;
            }
        }

        Connection conn   = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            // Check if new email is taken by another user
            boolean emailTaken = false;
            pstmt = conn.prepareStatement(
                "SELECT user_id FROM users WHERE email = ? AND user_id != ?");
            pstmt.setString(1, newEmail);
            pstmt.setInt(2, userId);
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
                response.sendRedirect("user-profile.jsp?msg=emailtaken");
                return;
            }

            // Build update query — only update password if not empty
            if(newPassword != null && !newPassword.trim().isEmpty()) {
                pstmt = conn.prepareStatement(
                    "UPDATE users SET email=?, password=?, location=? WHERE user_id=?");
                pstmt.setString(1, newEmail);
                pstmt.setString(2, newPassword.trim());
                pstmt.setString(3, newLocation);
                pstmt.setInt(4, userId);
            } else {
                pstmt = conn.prepareStatement(
                    "UPDATE users SET email=?, location=? WHERE user_id=?");
                pstmt.setString(1, newEmail);
                pstmt.setString(2, newLocation);
                pstmt.setInt(3, userId);
            }

            pstmt.executeUpdate();

            // Update session with new email and location
            session.setAttribute("userEmail", newEmail);
            session.setAttribute("userLocation", newLocation);

            response.sendRedirect("user-profile.jsp?msg=updated");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("user-profile.jsp?msg=error");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
