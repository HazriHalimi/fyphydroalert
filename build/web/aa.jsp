<%@ page import="java.sql.*, util.DBConnection" %>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    String userType = (String) session.getAttribute("userType");
    if(userEmail == null || !"user".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String userLocation = (String) session.getAttribute("userLocation");
    Integer userId = (Integer) session.getAttribute("userId");
    
    // Get current subscription status
    boolean isSubscribed = false;
    Connection connSub = null;
    PreparedStatement pstmtSub = null;
    
    try {
        connSub = DBConnection.getConnection();
        String sql = "SELECT subscribed FROM users WHERE user_id = ?";
        pstmtSub = connSub.prepareStatement(sql);
        pstmtSub.setInt(1, userId);
        ResultSet rsSub = pstmtSub.executeQuery();
        if(rsSub.next()) {
            isSubscribed = rsSub.getBoolean("subscribed");
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(pstmtSub != null) pstmtSub.close();
        if(connSub != null) connSub.close();
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="dashboard-header">
        <h2>Welcome, <%= userEmail %></h2>
        <p>Location: <%= userLocation %></p>
    </div>
    
    <!-- Subscription Card -->
    <div class="subscription-card">
        <div class="subscription-info">
            <h3>Email Notification Settings</h3>
            <p>Get instant email alerts when flood risk levels change in your area (<%= userLocation %>)</p>
            <p><strong>Current Status: 
                <% if(isSubscribed) { %>
                    <span style="color: #28a745;">Subscribed</span>
                <% } else { %>
                    <span style="color: #dc3545;">Unsubscribed</span>
                <% } %>
            </strong></p>
        </div>
        <div class="subscription-action">
            <% if(isSubscribed) { %>
                <form action="ToggleSubscriptionServlet" method="post" style="display: inline;">
                    <input type="hidden" name="action" value="unsubscribe">
                    <button type="submit" class="btn-unsubscribe" onclick="return confirm('Are you sure you want to unsubscribe from email alerts?')">Unsubscribe</button>
                </form>
            <% } else { %>
                <form action="ToggleSubscriptionServlet" method="post" style="display: inline;">
                    <input type="hidden" name="action" value="subscribe">
                    <button type="submit" class="btn-subscribe">Subscribe to Alerts</button>
                </form>
            <% } %>
        </div>
    </div>
    
    <% if(request.getParameter("subscribed") != null) { %>
        <div class="success-message">Successfully subscribed to email alerts!</div>
    <% } %>
    
    <% if(request.getParameter("unsubscribed") != null) { %>
        <div class="success-message">Successfully unsubscribed from email alerts.</div>
    <% } %>
    
    <div class="content">
        <h3>Flood Alerts for Your Area (<%= userLocation %>)</h3>
        
        <table class="flood-table">
            <thead>
                <tr>
                    <th>Station</th>
                    <th>Water Level (m)</th>
                    <th>Risk Level</th>
                    <th>Trend</th>
                </tr>
            </thead>
            <tbody>
                <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DBConnection.getConnection();
                    String sql = "SELECT * FROM readings WHERE state = ? ORDER BY risk_level DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, userLocation);
                    rs = pstmt.executeQuery();
                    
                    while(rs.next()) {
                        String riskLevel = rs.getString("risk_level");
                        String riskClass = "";
                        
                        if("BAHAYA".equals(riskLevel)) riskClass = "danger";
                        else if("AMARAN".equals(riskLevel)) riskClass = "warning";
                        else if("WASPADA".equals(riskLevel)) riskClass = "alert";
                        else riskClass = "safe";
                %>
                <tr>
                    <td><%= rs.getString("station_name") %></td>
                    <td><%= String.format("%.2f", rs.getDouble("water_level_m")) %></td>
                    <td class="<%= riskClass %>"><%= riskLevel %></td>
                    <td><%= rs.getString("trend") %></td>
                </tr>
                <%
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(rs != null) rs.close();
                    if(pstmt != null) pstmt.close();
                    if(conn != null) conn.close();
                }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>