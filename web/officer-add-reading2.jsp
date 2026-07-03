<%-- 
    Document   : officer-add-reading2
    Created on : Apr 26, 2026, 6:10:10 PM
    Author     : hazzr
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if officer is logged in
    String officerUsername = (String) session.getAttribute("officerUsername");
    String userType = (String) session.getAttribute("userType");
    
    if(officerUsername == null || !"officer".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String officerName = (String) session.getAttribute("officerName");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Add Reading - HydroAlert</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <div class="admin-header">
        <div class="admin-header-container">
            <div>
                <h2>HydroAlert - Officer Dashboard</h2>
                <p>Welcome, <%= officerName %></p>
            </div>
            <div>
                <a href="logout.jsp" class="btn-logout">Logout</a>
            </div>
        </div>
    </div>
    
    <div class="admin-container">
        <div class="admin-sidebar">
            <ul>
                <li><a href="officer-dashboard.jsp">Dashboard</a></li>

                
                <li><a href="officer-add-reading.jsp" class="active">Add New Redings</a></li>
                <li><a href="officer-my-readings.jsp">My Readings</a></li>

                
                <li><a href="officer-center.jsp">Center List</a></li>
                <li><a href="officer-add-center.jsp">Add Center</a></li>

                
                <li><a href="officer-victims.jsp">Victims List</a></li>
                <li><a href="officer-add-victim.jsp">Register Victims</a></li>
            </ul>
        </div>
        
        <div class="admin-content">
            <h3>Add New Flood Reading</h3>
            
            <% if(request.getParameter("success") != null) { %>
                <div class="success-message">Reading added successfully!</div>
            <% } %>
            
            <% if(request.getParameter("error") != null) { %>
                <div class="error-message">Failed to add reading. Please try again.</div>
            <% } %>
            
            <form action="AddReadingServlet" method="post" class="form-container">
                <div class="form-row">
                    <div class="form-group">
                        <label>Station Name: *</label>
                        <input type="text" name="stationName" required placeholder="e.g., Sg. Nerus di Kg. Bukit">
                    </div>
                    
                    <div class="form-group">
                        <label>Location: *</label>
                        <input type="text" name="location" required placeholder="e.g., Kg. Bukit">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>State: *</label>
                        <select name="state" required>
                            <option value="">Select State</option>
                            <option value="Johor">Johor</option>
                            <option value="Kedah">Kedah</option>
                            <option value="Kelantan">Kelantan</option>
                            <option value="Melaka">Melaka</option>
                            <option value="Negeri Sembilan">Negeri Sembilan</option>
                            <option value="Pahang">Pahang</option>
                            <option value="Perak">Perak</option>
                            <option value="Perlis">Perlis</option>
                            <option value="Pulau Pinang">Pulau Pinang</option>
                            <option value="Sabah">Sabah</option>
                            <option value="Sarawak">Sarawak</option>
                            <option value="Selangor">Selangor</option>
                            <option value="Terengganu">Terengganu</option>
                            <option value="Wilayah Persekutuan">Wilayah Persekutuan</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Rainfall (mm):</label>
                        <input type="number" name="rainfall" step="0.01" placeholder="Leave empty if no rainfall station">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Water Level (m):</label>
                        <input type="number" name="waterLevel" step="0.01" placeholder="Leave empty if no water level station">
                    </div>
                    
                    <div class="form-group">
                        <label>Risk Level: *</label>
                        <select name="riskLevel" required>
                            <option value="">Select Risk Level</option>
                            <option value="SAFE">SAFE</option>
                            <option value="NORMAL">NORMAL</option>
                            <option value="WASPADA">WASPADA</option>
                            <option value="AMARAN">AMARAN</option>
                            <option value="BAHAYA">BAHAYA</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Trend: *</label>
                        <select name="trend" required>
                            <option value="">Select Trend</option>
                            <option value="Menaik">Menaik</option>
                            <option value="Menurun">Menurun</option>
                            <option value="Tiada Perubahan">Tiada Perubahan</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Latitude:</label>
                        <input type="number" name="latitude" step="0.000001" placeholder="e.g., 3.139003">
                        <small style="color: #666; font-size: 12px;">Decimal degrees format (e.g., 3.139003)</small>
                    </div>
                    
                    <div class="form-group">
                        <label>Longitude:</label>
                        <input type="number" name="longitude" step="0.000001" placeholder="e.g., 101.686855">
                        <small style="color: #666; font-size: 12px;">Decimal degrees format (e.g., 101.686855)</small>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Notes:</label>
                    <textarea name="notes" rows="4" placeholder="Additional observations or comments"></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn-primary">Add Reading</button>
                    <a href="officer-dashboard.jsp" class="btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>