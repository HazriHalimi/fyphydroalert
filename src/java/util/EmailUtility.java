package util;

import java.io.InputStream;
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtility {
    private static final Properties emailProps = new Properties();

    static {
        try (InputStream input = EmailUtility.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (input == null) {
                System.err.println("Error: email.properties not found in classpath.");
            } else {
                emailProps.load(input);
            }
        } catch (Exception e) {
            System.err.println("Error loading email.properties configuration file:");
            e.printStackTrace();
        }
    }

    public static void sendRegistrationEmail(final String toEmail, final String password) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    String host = emailProps.getProperty("mail.smtp.host", "smtp.gmail.com");
                    String port = emailProps.getProperty("mail.smtp.port", "587");
                    String auth = emailProps.getProperty("mail.smtp.auth", "true");
                    String starttls = emailProps.getProperty("mail.smtp.starttls.enable", "true");
                    final String fromEmail = emailProps.getProperty("mail.smtp.username");
                    final String fromPassword = emailProps.getProperty("mail.smtp.password");

                    if (fromEmail == null || fromPassword == null) {
                        System.err.println("SMTP Configuration error: username or password is missing in email.properties.");
                        return;
                    }

                    Properties props = new Properties();
                    props.put("mail.smtp.host", host);
                    props.put("mail.smtp.port", port);
                    props.put("mail.smtp.auth", auth);
                    props.put("mail.smtp.starttls.enable", starttls);
                    props.put("mail.smtp.ssl.protocols", "TLSv1.2"); // Ensure compatibility

                    // Connection timeouts
                    props.put("mail.smtp.connectiontimeout", "10000");
                    props.put("mail.smtp.timeout", "10000");

                    Session session = Session.getInstance(props, new Authenticator() {
                        @Override
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(fromEmail, fromPassword);
                        }
                    });

                    // Parse name from email address prefix (before @)
                    String userName = toEmail;
                    if (toEmail != null && toEmail.contains("@")) {
                        String prefix = toEmail.split("@")[0];
                        if (prefix.length() > 0) {
                            userName = prefix.substring(0, 1).toUpperCase() + prefix.substring(1);
                        }
                    }

                    Message message = new MimeMessage(session);
                    message.setFrom(new InternetAddress(fromEmail));
                    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
                    message.setSubject("HydroAlert Account Registration");

                    String emailBody = "Dear " + userName + ",\n\n"
                            + "Your HydroAlert account has been successfully created.\n\n"
                            + "Here are your login credentials:\n\n"
                            + "Email Address: " + toEmail + "\n"
                            + "Password: " + password + "\n\n"
                            + "You can now log in to the HydroAlert system using the credentials above.\n\n"
                            + "For security purposes, please change your password after your first login.\n\n"
                            + "Thank you.\n\n"
                            + "Best Regards,\n"
                            + "HydroAlert Team";

                    message.setText(emailBody);

                    Transport.send(message);
                    System.out.println("HydroAlert account registration email successfully sent to: " + toEmail);
                } catch (Exception e) {
                    System.err.println("Failed to send registration email to " + toEmail + ". Error details:");
                    e.printStackTrace();
                }
            }
        }).start();
    }
}
