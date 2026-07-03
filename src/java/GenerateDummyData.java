import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DBConnection;

public class GenerateDummyData {

    // Inner class representing a station template
    static class StationTemplate {
        String state;
        String stationName;
        String location;
        double latitude;
        double longitude;
        
        // Final reading targets
        String latestRisk;
        String latestTrend;
        double finalWaterLevel;
        double finalRainfall;
        
        // Initial readings at hour -4
        double initialWaterLevel;
        double initialRainfall;

        public StationTemplate(String state, String stationName, String location, double latitude, double longitude,
                               String latestRisk, String latestTrend, double initialWaterLevel, double finalWaterLevel,
                               double initialRainfall, double finalRainfall) {
            this.state = state;
            this.stationName = stationName;
            this.location = location;
            this.latitude = latitude;
            this.longitude = longitude;
            this.latestRisk = latestRisk;
            this.latestTrend = latestTrend;
            this.initialWaterLevel = initialWaterLevel;
            this.finalWaterLevel = finalWaterLevel;
            this.initialRainfall = initialRainfall;
            this.finalRainfall = finalRainfall;
        }
    }

    public static void main(String[] args) {
        List<StationTemplate> templates = new ArrayList<>();

        // 1. Melaka (3 stations)
        templates.add(new StationTemplate("Melaka", "Sg. Melaka di Batu Hampar", "Batu Hampar, Melaka Tengah", 2.245, 102.228,
                "BAHAYA", "Menaik", 2.10, 6.20, 10.0, 95.0));
        templates.add(new StationTemplate("Melaka", "Sg. Duyong di Duyong Bridge", "Kampung Duyong, Melaka Tengah", 2.198, 102.298,
                "AMARAN", "Menurun", 4.80, 4.20, 65.0, 0.0));
        templates.add(new StationTemplate("Melaka", "Sg. Kesang di Chin Chin", "Chin Chin, Jasin", 2.381, 102.562,
                "NORMAL", "Tiada Perubahan", 1.10, 1.10, 2.0, 0.0));

        // 2. Negeri Sembilan (3 stations)
        templates.add(new StationTemplate("Negeri Sembilan", "Sg. Linggi di Taman Margins", "Taman Margins, Seremban", 2.705, 101.954,
                "BAHAYA", "Menaik", 3.20, 7.80, 15.0, 120.0));
        templates.add(new StationTemplate("Negeri Sembilan", "Sg. Muar di Kuala Pilah", "Pekan Kuala Pilah, Kuala Pilah", 2.741, 102.249,
                "WASPADA", "Menaik", 1.80, 2.95, 5.0, 32.0));
        templates.add(new StationTemplate("Negeri Sembilan", "Sg. Gemas di Gemas", "Gemas Town, Tampin", 2.583, 102.617,
                "NORMAL", "Tiada Perubahan", 0.90, 0.90, 1.5, 0.0));

        // 3. Perlis (3 stations)
        templates.add(new StationTemplate("Perlis", "Sg. Perlis di Kangar", "Kangar Town, Kangar", 6.438, 100.198,
                "AMARAN", "Menaik", 1.50, 4.85, 8.0, 64.0));
        templates.add(new StationTemplate("Perlis", "Sg. Korok di Arau", "Arau Town, Arau", 6.427, 100.274,
                "NORMAL", "Menurun", 2.40, 1.20, 45.0, 2.0));
        templates.add(new StationTemplate("Perlis", "Sg. Pelarit di Wang Kelian", "Wang Kelian, Padang Besar", 6.679, 100.188,
                "NORMAL", "Tiada Perubahan", 0.75, 0.75, 0.0, 0.0));

        // 4. Pulau Pinang (3 stations)
        templates.add(new StationTemplate("Pulau Pinang", "Sg. Pinang di Jalan P. Ramlee", "Jalan P. Ramlee, Georgetown", 5.409, 100.315,
                "BAHAYA", "Menaik", 2.50, 6.70, 20.0, 105.0));
        templates.add(new StationTemplate("Pulau Pinang", "Sg. Perai di Ampang Jajar", "Ampang Jajar, Butterworth", 5.412, 100.395,
                "WASPADA", "Menurun", 3.10, 2.10, 50.0, 5.0));
        templates.add(new StationTemplate("Pulau Pinang", "Sg. Juru di Simpang Ampat", "Simpang Ampat, Seberang Perai Selatan", 5.281, 100.479,
                "NORMAL", "Tiada Perubahan", 0.85, 0.85, 3.0, 0.5));

        // 5. Kuala Lumpur (3 stations)
        templates.add(new StationTemplate("Kuala Lumpur", "Sg. Bunus di Jalan Tun Razak", "Jalan Tun Razak, Kuala Lumpur", 3.172, 101.713,
                "BAHAYA", "Menaik", 3.00, 7.10, 25.0, 115.0));
        templates.add(new StationTemplate("Kuala Lumpur", "Sg. Gombak di Jalan Parlimen", "Jalan Parlimen, Kuala Lumpur", 3.151, 101.694,
                "AMARAN", "Menaik", 2.00, 4.55, 12.0, 58.0));
        templates.add(new StationTemplate("Kuala Lumpur", "Sg. Klang di Masjid Jamek", "Masjid Jamek, Kuala Lumpur", 3.149, 101.696,
                "BAHAYA", "Menurun", 8.20, 6.90, 80.0, 10.0));

        // 6. Putrajaya (2 stations)
        templates.add(new StationTemplate("Putrajaya", "Tasik Putrajaya di Presint 8", "Presint 8, Putrajaya", 2.935, 101.681,
                "NORMAL", "Tiada Perubahan", 1.80, 1.80, 0.0, 0.0));
        templates.add(new StationTemplate("Putrajaya", "Sg. Bisa di Presint 14", "Presint 14, Putrajaya", 2.955, 101.708,
                "WASPADA", "Menaik", 1.10, 2.45, 2.0, 38.0));

        // 7. Labuan (2 stations)
        templates.add(new StationTemplate("Labuan", "Sg. Kina di Kampung Gersik", "Kampung Gersik, Labuan", 5.285, 115.247,
                "AMARAN", "Menaik", 1.20, 4.10, 10.0, 70.0));
        templates.add(new StationTemplate("Labuan", "Sg. Ganggarak di Kampung Ganggarak", "Kampung Ganggarak, Labuan", 5.334, 115.228,
                "NORMAL", "Tiada Perubahan", 0.60, 0.60, 0.0, 0.0));

        int officerId = 3; // Officer: HAZIQ NAJMI BIN HASMADI

        System.out.println("Starting dummy data generation into readings table...");
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            String sql = "INSERT INTO readings (station_name, location, state, rainfall_mm, water_level_m, " +
                         "risk_level, trend, officer_id, recorded_date, notes, latitude, longitude) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                long nowMs = System.currentTimeMillis();
                int insertedCount = 0;
                
                for (StationTemplate st : templates) {
                    // Generate 5 readings for this station, spaced 1 hour apart
                    for (int step = 0; step < 5; step++) {
                        double fraction = step / 4.0; // 0.0 -> 0.25 -> 0.50 -> 0.75 -> 1.0
                        
                        double waterLevel = st.initialWaterLevel + (st.finalWaterLevel - st.initialWaterLevel) * fraction;
                        double rainfall = st.initialRainfall + (st.finalRainfall - st.initialRainfall) * fraction;
                        
                        // Round to 2 decimals
                        waterLevel = Math.round(waterLevel * 100.0) / 100.0;
                        rainfall = Math.round(rainfall * 10.0) / 10.0;
                        
                        // Determine step risk level
                        String stepRisk = "NORMAL";
                        if (step == 4) {
                            stepRisk = st.latestRisk;
                        } else {
                            // intermediate states
                            double maxWl = Math.max(st.initialWaterLevel, st.finalWaterLevel);
                            double ratio = (waterLevel / maxWl);
                            if (ratio > 0.85) stepRisk = st.latestRisk;
                            else if (ratio > 0.65) stepRisk = "WASPADA";
                            else if (ratio > 0.45) stepRisk = "NORMAL";
                            else stepRisk = "SAFE";
                        }
                        
                        // Determine step trend
                        String stepTrend = st.latestTrend;
                        if (!"Tiada Perubahan".equals(st.latestTrend)) {
                            stepTrend = st.latestTrend;
                        } else {
                            stepTrend = "Tiada Perubahan";
                        }
                        
                        // recorded_date spacing: -4 hours, -3 hours, -2 hours, -1 hour, current
                        Timestamp recordedDate = new Timestamp(nowMs - (4 - step) * 60L * 60L * 1000L);
                        
                        pstmt.setString(1, st.stationName);
                        pstmt.setString(2, st.location);
                        pstmt.setString(3, st.state);
                        pstmt.setDouble(4, rainfall);
                        pstmt.setDouble(5, waterLevel);
                        pstmt.setString(6, stepRisk);
                        pstmt.setString(7, stepTrend);
                        pstmt.setInt(8, officerId);
                        pstmt.setTimestamp(9, recordedDate);
                        pstmt.setString(10, "FYP Presentation Mock Data for state: " + st.state);
                        pstmt.setDouble(11, st.latitude);
                        pstmt.setDouble(12, st.longitude);
                        
                        pstmt.addBatch();
                        insertedCount++;
                    }
                }
                
                pstmt.executeBatch();
                conn.commit();
                System.out.println("Successfully inserted " + insertedCount + " mock readings for " + templates.size() + " stations!");
                
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
            
        } catch (Exception e) {
            System.err.println("Error occurred during batch insert:");
            e.printStackTrace();
        }
    }
}
