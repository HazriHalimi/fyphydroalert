<%-- 
    Document   : header1
    Created on : Apr 26, 2026, 6:03:58 PM
    Author     : hazzr
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>HydroAlert - Sistem Maklumat Banjir</title>
        <link rel="stylesheet" href="css/style.css">
    </head>

    <body>
        <header>
            <div class="header-container">
                <div class="logo-section">
                    <img src="images/logo.png" alt="HydroAlert Logo" class="logo">
                    <div class="header-text">
                        <h1>HydroAlert Flood Detection System</h1>
                    </div>
                </div>

                <div class="account-dropdown">
                    <% String userEmailHeader=(String) session.getAttribute("userEmail"); if (userEmailHeader !=null) {
                        %>
                        <select onchange="location = this.value;">
                            <option>
                                <%= userEmailHeader %>
                            </option>
                            <option value="user-dashboard.jsp">My Dashboard</option>
                            <option value="user-places.jsp">Your State</option>
                            <option value="logout.jsp">Logout</option>
                        </select>
                        <% } else { %>
                            <select onchange="location = this.value;">
                                <option value="">Account</option>
                                <option value="user-register.jsp">Register</option>
                                <option value="login.jsp">Login</option>
                            </select>
                            <% } %>
                </div>
            </div>
        </header>