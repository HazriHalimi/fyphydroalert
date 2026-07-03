<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HydroAlert - Portal Amaran & Maklumat Banjir Negara</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/landing.css">
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" defer></script>
</head>
<body class="landing-page">
    <%
        String currentURI = request.getRequestURI();
        boolean isIndex = currentURI.endsWith("index.jsp") || currentURI.endsWith("/") || currentURI.endsWith("/hydroalert");
        boolean isReadings = currentURI.endsWith("readings.jsp");
        boolean isSemak = currentURI.endsWith("semak-status.jsp");
        boolean isEmergency = currentURI.endsWith("emergency.jsp");
        boolean isUserPlaces = currentURI.endsWith("user-places.jsp");
        
        String officerUsernameHeader = (String) session.getAttribute("officerUsername");
        String adminUsernameHeader = (String) session.getAttribute("adminUsername");
        String userEmailHeader = (String) session.getAttribute("userEmail");
    %>
    <!-- Sticky Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark landing-nav py-2">
        <div class="container nav-container">
            <a href="index.jsp" class="navbar-brand nav-logo d-flex align-items-center">
                <img src="<%= request.getContextPath() %>/images/logo.png" alt="HydroAlert Logo">
                <span class="ms-2">HydroAlert</span>
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#landingNavbar" aria-controls="landingNavbar" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="landingNavbar">
                <div class="navbar-nav ms-auto nav-menu align-items-lg-center">
                    <% if (userEmailHeader != null) { %>
                        <a href="<%= request.getContextPath() %>/user-places.jsp" class="nav-link nav-item px-3 <%= isUserPlaces ? "active" : "" %>">Utama</a>
                    <% } else { %>
                        <a href="<%= request.getContextPath() %>/index.jsp" class="nav-link nav-item px-3 <%= isIndex ? "active" : "" %>">Utama</a>
                    <% } %>
                    <a href="<%= request.getContextPath() %>/readings.jsp" class="nav-link nav-item px-3 <%= isReadings ? "active" : "" %>">Stesen & Bacaan</a>
                    <% if (userEmailHeader != null) { %>
                        <a href="<%= request.getContextPath() %>/user-dashboard.jsp?tab=semak" class="nav-link nav-item px-3 <%= (isSemak || "semak".equals(request.getParameter("tab"))) ? "active" : "" %>">Semak Status</a>
                    <% } else { %>
                        <a href="<%= request.getContextPath() %>/semak-status.jsp" class="nav-link nav-item px-3 <%= isSemak ? "active" : "" %>">Semak Status</a>
                    <% } %>
                    <a href="<%= request.getContextPath() %>/emergency.jsp" class="nav-link nav-item px-3 <%= isEmergency ? "active" : "" %>">Talian Kecemasan</a>
                    
                    <!-- Account Dropdown -->
                    <div class="account-dropdown-wrap nav-item px-3 mt-2 mt-lg-0">
                        <% if (userEmailHeader != null) { %>
                            <select onchange="location = this.value;" class="form-select form-select-sm" style="display: inline-block; width: auto; font-family: inherit;">
                                <option value=""><%= userEmailHeader %></option>
                                <option value="<%= request.getContextPath() %>/user-places.jsp">Laman Utama</option>
                                <option value="<%= request.getContextPath() %>/user-dashboard.jsp">Dashboard Saya</option>
                                <option value="<%= request.getContextPath() %>/logout.jsp">Log Keluar</option>
                            </select>
                        <% } else if (officerUsernameHeader != null) { %>
                            <select onchange="location = this.value;" class="form-select form-select-sm" style="display: inline-block; width: auto; font-family: inherit;">
                                <option value="">Pegawai: <%= officerUsernameHeader %></option>
                                <option value="<%= request.getContextPath() %>/officer-dashboard.jsp">Dashboard Pegawai</option>
                                <option value="<%= request.getContextPath() %>/logout.jsp">Log Keluar</option>
                            </select>
                        <% } else if (adminUsernameHeader != null) { %>
                            <select onchange="location = this.value;" class="form-select form-select-sm" style="display: inline-block; width: auto; font-family: inherit;">
                                <option value="">Admin: <%= adminUsernameHeader %></option>
                                <option value="<%= request.getContextPath() %>/admin-dashboard.jsp">Dashboard Admin</option>
                                <option value="<%= request.getContextPath() %>/logout.jsp">Log Keluar</option>
                            </select>
                        <% } else { %>
                            <select onchange="location = this.value;" class="form-select form-select-sm" style="display: inline-block; width: auto; font-family: inherit;">
                                <option value="">Akaun / Log Masuk</option>
                                <option value="<%= request.getContextPath() %>/login.jsp">Log Masuk</option>
                                <option value="<%= request.getContextPath() %>/user-register.jsp">Daftar Pengguna</option>
                            </select>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </nav>