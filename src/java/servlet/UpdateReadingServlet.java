package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;
import util.DBConnection;

public class UpdateReadingServlet extends HttpServlet {
    
    private static final String FROM_EMAIL = "sysmail999@gmail.com";
    private static final String EMAIL_PASSWORD = "bfsr udtr glee ufyz";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get officer ID from session
        HttpSession session = request.getSession();
        Integer officerId = (Integer) session.getAttribute("officerId");
        
        if(officerId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get form parameters
        int readingId = Integer.parseInt(request.getParameter("readingId"));
        String stationName = request.getParameter("stationName");
        String location = request.getParameter("location");
        String state = request.getParameter("state");
        String rainfallStr = request.getParameter("rainfall");
        String waterLevelStr = request.getParameter("waterLevel");
        String riskLevel = request.getParameter("riskLevel");
        String trend = request.getParameter("trend");
        String notes = request.getParameter("notes");
        String latitudeStr = request.getParameter("latitude");
        String longitudeStr = request.getParameter("longitude");
        
        // Convert to numbers
        Double rainfall = null;
        if(rainfallStr != null && !rainfallStr.trim().isEmpty()) {
            rainfall = Double.parseDouble(rainfallStr);
        }
        
        Double waterLevel = null;
        if(waterLevelStr != null && !waterLevelStr.trim().isEmpty()) {
            waterLevel = Double.parseDouble(waterLevelStr);
        }
        
        Double latitude = null;
        if(latitudeStr != null && !latitudeStr.trim().isEmpty()) {
            latitude = Double.parseDouble(latitudeStr);
        }
        
        Double longitude = null;
        if(longitudeStr != null && !longitudeStr.trim().isEmpty()) {
            longitude = Double.parseDouble(longitudeStr);
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // Update reading only if it belongs to logged-in officer
            String sql = "UPDATE readings SET station_name=?, location=?, state=?, rainfall_mm=?, " +
                        "water_level_m=?, risk_level=?, trend=?, notes=?, latitude=?, longitude=? " +
                        "WHERE reading_id=? AND officer_id=?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, stationName);
            pstmt.setString(2, location);
            pstmt.setString(3, state);
            
            if(rainfall != null) {
                pstmt.setDouble(4, rainfall);
            } else {
                pstmt.setNull(4, Types.DECIMAL);
            }
            
            if(waterLevel != null) {
                pstmt.setDouble(5, waterLevel);
            } else {
                pstmt.setNull(5, Types.DECIMAL);
            }
            
            pstmt.setString(6, riskLevel);
            pstmt.setString(7, trend);
            pstmt.setString(8, notes);
            
            if(latitude != null) {
                pstmt.setDouble(9, latitude);
            } else {
                pstmt.setNull(9, Types.DECIMAL);
            }
            
            if(longitude != null) {
                pstmt.setDouble(10, longitude);
            } else {
                pstmt.setNull(10, Types.DECIMAL);
            }
            
            pstmt.setInt(11, readingId);
            pstmt.setInt(12, officerId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                // Send email notifications after successful update asynchronously
                final String fState = state;
                final String fLocation = location;
                final String fStationName = stationName;
                final String fRiskLevel = riskLevel;
                final Double fWaterLevel = waterLevel;
                final Double fRainfall = rainfall;
                final String fTrend = trend;
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        Connection bgConn = null;
                        try {
                            bgConn = DBConnection.getConnection();
                            sendEmailNotifications(bgConn, fState, fLocation, fStationName, fRiskLevel, fWaterLevel, fRainfall, fTrend);
                        } catch(Exception ex) {
                            ex.printStackTrace();
                        } finally {
                            try { if(bgConn != null) bgConn.close(); } catch(Exception ex) { ex.printStackTrace(); }
                        }
                    }
                }).start();
                
                response.sendRedirect("officer-my-readings.jsp?updated=true");
            } else {
                response.sendRedirect("officer-my-readings.jsp?error=true");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("officer-edit-reading.jsp?id=" + readingId + "&error=true");
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private void sendEmailNotifications(Connection conn, String state, String location, 
                                       String stationName, String riskLevel, 
                                       Double waterLevel, Double rainfall, String trend) {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Get all subscribed users
            String sql = "SELECT email, location FROM users WHERE subscribed = 1";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                String userEmail = rs.getString("email");
                String userLocation = rs.getString("location");
                
                // Determine if location matches
                boolean isMatchingLocation = state.equalsIgnoreCase(userLocation);
                
                // Send appropriate email
                if(isMatchingLocation) {
                    sendLocationUpdateEmail(userEmail, state, location, stationName, riskLevel, waterLevel, rainfall, trend);
                } else {
                    sendGeneralUpdateEmail(userEmail, state, location, stationName, riskLevel, waterLevel, rainfall, trend);
                }
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private void sendLocationUpdateEmail(String toEmail, String state, String location, 
                                        String stationName, String riskLevel, 
                                        Double waterLevel, Double rainfall, String trend) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            
            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, EMAIL_PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("🔄 KEMASKINI: Data Dikemaskini di Kawasan Anda - HydroAlert");
            
            String emailContent = "<!DOCTYPE html>" +
                "<html><head><style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background-color: #ff9800; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }" +
                ".content { background-color: #f8f9fa; padding: 20px; border: 1px solid #dee2e6; }" +
                ".alert-box { background-color: #fff3cd; border-left: 4px solid #ff9800; padding: 15px; margin: 15px 0; }" +
                ".details { background-color: white; padding: 15px; margin: 15px 0; border-radius: 5px; }" +
                ".detail-row { padding: 8px 0; border-bottom: 1px solid #eee; }" +
                ".label { font-weight: bold; color: #555; }" +
                ".risk-" + riskLevel.toLowerCase() + " { color: " + getRiskColor(riskLevel) + "; font-weight: bold; font-size: 18px; }" +
                ".footer { background-color: #343a40; color: white; padding: 15px; text-align: center; font-size: 12px; border-radius: 0 0 5px 5px; }" +
                "</style></head><body>" +
                "<div class='container'>" +
                "<div class='header'>" +
                "<h2>🔄 KEMASKINI DATA KAWASAN ANDA</h2>" +
                "<p>Data Telah Dikemaskini</p>" +
                "</div>" +
                "<div class='content'>" +
                "<div class='alert-box'>" +
                "<strong>🔔 Makluman:</strong> Kemaskini data telah dibuat untuk kawasan anda (" + state + ")" +
                "</div>" +
                "<div class='details'>" +
                "<h3 style='color: #ff9800; margin-top: 0;'>Maklumat Terkini</h3>" +
                "<div class='detail-row'><span class='label'>Stesen:</span> " + stationName + "</div>" +
                "<div class='detail-row'><span class='label'>Lokasi:</span> " + location + ", " + state + "</div>" +
                "<div class='detail-row'><span class='label'>Tahap Risiko:</span> <span class='risk-" + riskLevel.toLowerCase() + "'>" + riskLevel + "</span></div>" +
                "<div class='detail-row'><span class='label'>Arah Aliran:</span> " + trend + "</div>";
            
            if(waterLevel != null) {
                emailContent += "<div class='detail-row'><span class='label'>Aras Air:</span> " + String.format("%.2f", waterLevel) + " meter</div>";
            }
            
            if(rainfall != null) {
                emailContent += "<div class='detail-row'><span class='label'>Jumlah Hujan:</span> " + String.format("%.2f", rainfall) + " mm</div>";
            }
            
            emailContent += "</div>" +
                "<div style='margin-top: 20px; padding: 15px; background-color: #d1ecf1; border-left: 4px solid #0c5460; border-radius: 5px;'>" +
                "<strong>💡 Tindakan Dicadangkan:</strong><br>" +
                "<ul style='margin: 10px 0;'>" +
                "<li>Sentiasa pantau kemaskini terkini</li>" +
                "<li>Ambil perhatian terhadap perubahan tahap risiko</li>" +
                "<li>Bersedia dengan pelan kecemasan jika perlu</li>" +
                "<li>Ikuti arahan pihak berkuasa tempatan</li>" +
                "</ul>" +
                "</div>" +
                "</div>" +
                "<div class='footer'>" +
                "<p><strong>HydroAlert System</strong></p>" +
                "<p>Sistem Pemantauan Banjir Universiti Malaysia Terengganu</p>" +
                "<p style='font-size: 10px; margin-top: 10px;'>Emel ini dijana secara automatik. Sila jangan balas.</p>" +
                "</div>" +
                "</div>" +
                "</body></html>";
            
            message.setContent(emailContent, "text/html; charset=utf-8");
            
            Transport.send(message);
            System.out.println("Location update email sent to: " + toEmail);
            
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    private void sendGeneralUpdateEmail(String toEmail, String state, String location, 
                                       String stationName, String riskLevel, 
                                       Double waterLevel, Double rainfall, String trend) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            
            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, EMAIL_PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("📝 Kemaskini: Data Dikemaskini di Kawasan Lain - HydroAlert");
            
            String emailContent = "<!DOCTYPE html>" +
                "<html><head><style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background-color: #6c757d; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }" +
                ".content { background-color: #f8f9fa; padding: 20px; border: 1px solid #dee2e6; }" +
                ".info-box { background-color: #e7f3ff; border-left: 4px solid #6c757d; padding: 15px; margin: 15px 0; }" +
                ".details { background-color: white; padding: 15px; margin: 15px 0; border-radius: 5px; }" +
                ".detail-row { padding: 8px 0; border-bottom: 1px solid #eee; }" +
                ".label { font-weight: bold; color: #555; }" +
                ".risk-" + riskLevel.toLowerCase() + " { color: " + getRiskColor(riskLevel) + "; font-weight: bold; }" +
                ".footer { background-color: #343a40; color: white; padding: 15px; text-align: center; font-size: 12px; border-radius: 0 0 5px 5px; }" +
                "</style></head><body>" +
                "<div class='container'>" +
                "<div class='header'>" +
                "<h2>📝 Kemaskini Data</h2>" +
                "<p>Data Telah Dikemaskini</p>" +
                "</div>" +
                "<div class='content'>" +
                "<div class='info-box'>" +
                "<strong>ℹ️ Maklumat:</strong> Kemaskini data untuk kawasan berikut telah dibuat dalam sistem." +
                "</div>" +
                "<div class='details'>" +
                "<h3 style='color: #6c757d; margin-top: 0;'>Maklumat Terkini</h3>" +
                "<div class='detail-row'><span class='label'>Stesen:</span> " + stationName + "</div>" +
                "<div class='detail-row'><span class='label'>Lokasi:</span> " + location + ", " + state + "</div>" +
                "<div class='detail-row'><span class='label'>Tahap Risiko:</span> <span class='risk-" + riskLevel.toLowerCase() + "'>" + riskLevel + "</span></div>" +
                "<div class='detail-row'><span class='label'>Arah Aliran:</span> " + trend + "</div>";
            
            if(waterLevel != null) {
                emailContent += "<div class='detail-row'><span class='label'>Aras Air:</span> " + String.format("%.2f", waterLevel) + " meter</div>";
            }
            
            if(rainfall != null) {
                emailContent += "<div class='detail-row'><span class='label'>Jumlah Hujan:</span> " + String.format("%.2f", rainfall) + " mm</div>";
            }
            
            emailContent += "</div>" +
                "<div style='margin-top: 20px; padding: 15px; background-color: #f8f9fa; border-left: 4px solid #6c757d; border-radius: 5px;'>" +
                "<strong>📌 Nota:</strong> Ini adalah kemaskini maklumat untuk kawasan lain. " +
                "Anda menerima emel ini sebagai makluman umum sistem pemantauan banjir." +
                "</div>" +
                "</div>" +
                "<div class='footer'>" +
                "<p><strong>HydroAlert System</strong></p>" +
                "<p>Sistem Pemantauan Banjir Universiti Malaysia Terengganu</p>" +
                "<p style='font-size: 10px; margin-top: 10px;'>Emel ini dijana secara automatik. Sila jangan balas.</p>" +
                "</div>" +
                "</div>" +
                "</body></html>";
            
            message.setContent(emailContent, "text/html; charset=utf-8");
            
            Transport.send(message);
            System.out.println("General update email sent to: " + toEmail);
            
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    private String getRiskColor(String riskLevel) {
        switch(riskLevel.toUpperCase()) {
            case "SAFE": return "#28a745";
            case "NORMAL": return "#17a2b8";
            case "WASPADA": return "#ffc107";
            case "AMARAN": return "#fd7e14";
            case "BAHAYA": return "#dc3545";
            default: return "#6c757d";
        }
    }
}