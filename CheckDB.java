import java.sql.*;
import util.DBConnection;

public class CheckDB {
    public static void main(String[] args) {
        try {
            Connection conn = DBConnection.getConnection();
            
            System.out.println("=== ADMINS ===");
            PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM admins");
            ResultSet rs = pstmt.executeQuery();
            while(rs.next()) {
                System.out.println("Admin: ID=" + rs.getInt("admin_id") + 
                                   ", Username=" + rs.getString("username") + 
                                   ", Name=" + rs.getString("full_name") + 
                                   ", Email=" + rs.getString("email") + 
                                   ", Status=" + rs.getString("status") +
                                   ", Password=" + rs.getString("password"));
            }
            rs.close();
            pstmt.close();
            
            System.out.println("\n=== OFFICERS ===");
            pstmt = conn.prepareStatement("SELECT * FROM officers");
            rs = pstmt.executeQuery();
            while(rs.next()) {
                System.out.println("Officer: ID=" + rs.getInt("officer_id") + 
                                   ", Username=" + rs.getString("username") + 
                                   ", Name=" + rs.getString("full_name") + 
                                   ", Email=" + rs.getString("email") + 
                                   ", Status=" + rs.getString("status") +
                                   ", Password=" + rs.getString("password"));
            }
            rs.close();
            pstmt.close();
            
            System.out.println("\n=== USERS ===");
            pstmt = conn.prepareStatement("SELECT * FROM users");
            rs = pstmt.executeQuery();
            while(rs.next()) {
                System.out.println("User: ID=" + rs.getInt("user_id") + 
                                   ", Email=" + rs.getString("email") + 
                                   ", Location=" + rs.getString("location") + 
                                   ", Subscribed=" + rs.getInt("subscribed") +
                                   ", Password=" + rs.getString("password"));
            }
            rs.close();
            pstmt.close();
            
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
