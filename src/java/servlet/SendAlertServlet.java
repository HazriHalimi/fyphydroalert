package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import util.DBConnection;
import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;

public class SendAlertServlet extends HttpServlet {
    
    // Email configuration
    private static final String FROM_EMAIL = "sysmail999@gmail.com";
    private static final String EMAIL_PASSWORD = "bfsr udtr glee ufyz";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if admin is logged in
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        
        if(!"admin".equals(userType)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String state = request.getParameter("state");
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        int emailCount = 0;
        
        try {
            conn = DBConnection.getConnection();
            
            // Get subscribers based on state
            String sql;
            if("ALL".equals(state)) {
                sql = "SELECT email FROM users WHERE subscribed = 1";
                pstmt = conn.prepareStatement(sql);
            } else {
                sql = "SELECT email FROM users WHERE subscribed = 1 AND location = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, state);
            }
            
            rs = pstmt.executeQuery();
            
            // Collect all subscriber emails
            List<String> subscriberEmails = new ArrayList<>();
            while(rs.next()) {
                subscriberEmails.add(rs.getString("email"));
            }
            
            // Send emails
            final List<String> fSubscriberEmails = subscriberEmails;
            final String fSubject = subject;
            final String fMessage = message;
            
            if(!subscriberEmails.isEmpty()) {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        sendEmails(fSubscriberEmails, fSubject, fMessage);
                    }
                }).start();
                emailCount = subscriberEmails.size();
            }
            
            response.sendRedirect("admin-alerts.jsp?success=true&count=" + emailCount);
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-alerts.jsp?error=true");
        } finally {
            try {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private int sendEmails(List<String> emails, String subject, String messageText) {
        int successCount = 0;
        
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        
        // Create session
        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, EMAIL_PASSWORD);
            }
        });
        
        // Send to each subscriber
        for(String toEmail : emails) {
            try {
                Message message = new MimeMessage(mailSession);
                message.setFrom(new InternetAddress(FROM_EMAIL));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
                message.setSubject(subject);
                message.setText(messageText);
                
                Transport.send(message);
                successCount++;
                
            } catch(Exception e) {
                System.out.println("Failed to send to: " + toEmail);
                e.printStackTrace();
            }
        }
        
        return successCount;
    }
}