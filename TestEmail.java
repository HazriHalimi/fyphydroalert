import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class TestEmail {
    public static void main(String[] args) {
        String FROM_EMAIL = "sysmail999@gmail.com";
        String EMAIL_PASSWORD = "bfsr udtr glee ufyz";
        String toEmail = "test@example.com";
        
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        
        System.out.println("Trying to connect to " + FROM_EMAIL);
        
        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, EMAIL_PASSWORD);
            }
        });
        
        try {
            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Test Email");
            message.setText("This is a test email.");
            
            Transport.send(message);
            System.out.println("Success!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
