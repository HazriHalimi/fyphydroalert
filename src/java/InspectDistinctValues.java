import java.sql.*;
import util.DBConnection;

public class InspectDistinctValues {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            System.out.println("=== Unique risk_level values ===");
            try (ResultSet rs = stmt.executeQuery("SELECT DISTINCT risk_level FROM readings")) {
                while (rs.next()) {
                    System.out.println(rs.getString("risk_level"));
                }
            }
            
            System.out.println("\n=== Unique trend values ===");
            try (ResultSet rs = stmt.executeQuery("SELECT DISTINCT trend FROM readings")) {
                while (rs.next()) {
                    System.out.println(rs.getString("trend"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
