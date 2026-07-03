<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Clear cache headers for protected pages
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Remove all session attributes explicitly
    if (session != null) {
        java.util.Enumeration<String> attributeNames = session.getAttributeNames();
        while (attributeNames.hasMoreElements()) {
            session.removeAttribute(attributeNames.nextElement());
        }
        // Invalidate session completely
        session.invalidate();
    }
    
    // Redirect to login page
    response.sendRedirect("login.jsp");
%>