<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    String userType = (String) session.getAttribute("userType");
    if(userEmail == null || !"user".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String userLocation = (String) session.getAttribute("userLocation");
    
    // Check Status Logic
    String icInput       = request.getParameter("ic");
    String fullName      = null;
    String phone         = null;
    String vstatus       = null;
    String centreName    = null;
    String centreAddress = null;
    String centreState   = null;
    String centreLocation= null;
    String centrePhone   = null;
    int    familyCount   = 0;
    Timestamp checkIn    = null;
    Timestamp checkOut   = null;
    boolean searched     = false;
    boolean found        = false;
    String searchError   = null;

    if(icInput != null && !icInput.trim().isEmpty()) {
        searched = true;
        icInput  = icInput.trim();

        Connection connCheck   = null;
        PreparedStatement pstmtCheck = null;
        ResultSet rsCheck      = null;

        try {
            connCheck  = DBConnection.getConnection();
            String sql = "SELECT v.full_name, v.phone, v.family_count, v.status, " +
                         "v.check_in_time, v.check_out_time, " +
                         "rc.centre_name, rc.address, rc.location, rc.state " +
                         "FROM victims v " +
                         "LEFT JOIN relief_centres rc ON v.centre_id = rc.centre_id " +
                         "WHERE v.ic_number = ? " +
                         "ORDER BY v.check_in_time DESC LIMIT 1";
            pstmtCheck = connCheck.prepareStatement(sql);
            pstmtCheck.setString(1, icInput);
            rsCheck    = pstmtCheck.executeQuery();

            if(rsCheck.next()) {
                found         = true;
                fullName      = rsCheck.getString("full_name");
                phone         = rsCheck.getString("phone");
                familyCount   = rsCheck.getInt("family_count");
                vstatus       = rsCheck.getString("status");
                checkIn       = rsCheck.getTimestamp("check_in_time");
                checkOut      = rsCheck.getTimestamp("check_out_time");
                centreName    = rsCheck.getString("centre_name");
                centreAddress = rsCheck.getString("address");
                centreLocation= rsCheck.getString("location");
                centreState   = rsCheck.getString("state");
            }

        } catch(Exception e) {
            searchError = e.getMessage();
            e.printStackTrace();
        } finally {
            if(rsCheck    != null) { try { rsCheck.close(); } catch(Exception ex) {} }
            if(pstmtCheck != null) { try { pstmtCheck.close(); } catch(Exception ex) {} }
            if(connCheck  != null) { try { connCheck.close(); } catch(Exception ex) {} }
        }
    }
%>
<%
    String localRiskLevel = "TIADA DATA";
    int localStationsCount = 0;
    int localDangerCount = 0;
    
    if (userLocation != null && !userLocation.trim().isEmpty()) {
        Connection localConn = null;
        PreparedStatement localPstmt = null;
        ResultSet localRs = null;
        try {
            localConn = DBConnection.getConnection();
            String query = "SELECT COUNT(*) as total, " +
                           "SUM(CASE WHEN r.risk_level = 'BAHAYA' THEN 1 ELSE 0 END) as danger_count, " +
                           "MAX(CASE WHEN r.risk_level = 'BAHAYA' THEN 5 " +
                           "         WHEN r.risk_level = 'AMARAN' THEN 4 " +
                           "         WHEN r.risk_level = 'WASPADA' THEN 3 " +
                           "         WHEN r.risk_level = 'NORMAL' THEN 2 " +
                           "         WHEN r.risk_level = 'SAFE' THEN 1 ELSE 0 END) as max_risk_val " +
                           "FROM readings r " +
                           "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
                           "ON r.reading_id = latest.max_id " +
                           "WHERE LOWER(r.state) LIKE ? OR LOWER(r.location) LIKE ?";
            localPstmt = localConn.prepareStatement(query);
            String searchPattern = "%" + userLocation.toLowerCase().trim() + "%";
            localPstmt.setString(1, searchPattern);
            localPstmt.setString(2, searchPattern);
            localRs = localPstmt.executeQuery();
            if (localRs.next()) {
                localStationsCount = localRs.getInt("total");
                localDangerCount = localRs.getInt("danger_count");
                int maxRiskVal = localRs.getInt("max_risk_val");
                if (maxRiskVal == 5) localRiskLevel = "BAHAYA";
                else if (maxRiskVal == 4) localRiskLevel = "AMARAN";
                else if (maxRiskVal == 3) localRiskLevel = "WASPADA";
                else if (maxRiskVal == 2) localRiskLevel = "NORMAL";
                else if (maxRiskVal == 1) localRiskLevel = "SAFE";
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(localRs != null) { try { localRs.close(); } catch(Exception ex){} }
            if(localPstmt != null) { try { localPstmt.close(); } catch(Exception ex){} }
            if(localConn != null) { try { localConn.close(); } catch(Exception ex){} }
        }
    }
%>
<%@ include file="header.jsp" %>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800;900&display=swap');

:root {
    --deep-blue: #121358;
    --navy-blue: #232F72;
    --steel-blue: #2F578A;
    --teal: #36ADA3;
    --white: #ffffff;
    --light-gray: #f8fafc;
    --border-color: rgba(35, 47, 114, 0.08);
    --text-dark: #0f172a;
    --text-light: #64748b;
    --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.container {
    max-width: 1200px;
    margin: 40px auto;
    background-color: transparent;
    box-shadow: none;
    padding: 0 20px;
}

.content {
    background-color: transparent;
    padding: 0;
}

.content h2.section-title {
    font-family: 'Outfit', sans-serif;
    background: linear-gradient(135deg, var(--navy-blue) 0%, var(--deep-blue) 100%);
    color: var(--white);
    padding: 24px;
    text-align: center;
    border-radius: 16px 16px 0 0;
    margin-bottom: 0;
    font-size: 24px;
    font-weight: 700;
    letter-spacing: -0.5px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

/* User Profile Card */
.user-profile-card {
    background: linear-gradient(135deg, var(--deep-blue) 0%, var(--navy-blue) 100%);
    border-radius: 16px;
    padding: 30px;
    color: var(--white);
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 30px;
    margin-bottom: 40px;
    box-shadow: 0 15px 35px rgba(18, 19, 88, 0.15);
    border: 1px solid rgba(255, 255, 255, 0.1);
}

.profile-main {
    display: flex;
    align-items: center;
    gap: 20px;
}

.profile-avatar {
    width: 70px;
    height: 70px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    border: 2px solid var(--teal);
    box-shadow: 0 0 15px rgba(54, 173, 163, 0.3);
}

.profile-info {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.profile-badge {
    background: var(--teal);
    color: var(--deep-blue);
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 0.5px;
    width: fit-content;
}

.profile-email {
    font-family: 'Outfit', sans-serif;
    font-size: 22px;
    margin: 0;
    font-weight: 700;
}

.profile-location {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.8);
    margin: 0;
    display: flex;
    align-items: center;
    gap: 6px;
}

.profile-stats {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.stat-item {
    background: rgba(255, 255, 255, 0.05);
    padding: 15px 20px;
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.05);
    display: flex;
    flex-direction: column;
    align-items: center;
    min-width: 120px;
    text-align: center;
}

.stat-label {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.6);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
}

.stat-value {
    font-size: 24px;
    font-weight: 800;
    font-family: 'Outfit', sans-serif;
    color: var(--white);
}

.stat-badge {
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 700;
}

.stat-badge.danger { background-color: #e11d48; color: white; }
.stat-badge.warning { background-color: #ea580c; color: white; }
.stat-badge.alert { background-color: #d97706; color: white; }
.stat-badge.success { background-color: #16a34a; color: white; }
.stat-badge.neutral { background-color: rgba(255,255,255,0.15); color: white; }

.danger-alert {
    border-color: rgba(225, 29, 72, 0.3);
    background: rgba(225, 29, 72, 0.1);
}

.text-danger {
    color: #e11d48;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.03); opacity: 0.95; }
}

.animate-pulse {
    animation: pulse 2s infinite ease-in-out;
}

/* Tab Styles */
.tabs {
    display: flex;
    background-color: var(--white);
    border-bottom: 2px solid var(--border-color);
    margin-bottom: 30px;
    padding: 10px 10px 0 10px;
    border-radius: 0 0 16px 16px;
    box-shadow: 0 10px 30px rgba(18, 19, 88, 0.02);
    gap: 10px;
}

.tab-button {
    background-color: transparent;
    border: none;
    outline: none;
    cursor: pointer;
    padding: 14px 28px;
    font-size: 16px;
    font-weight: 600;
    color: var(--text-light);
    transition: var(--transition);
    border-bottom: 3px solid transparent;
    font-family: 'Outfit', sans-serif;
    border-radius: 8px 8px 0 0;
}

.tab-button:hover {
    color: var(--navy-blue);
    background-color: var(--light-gray);
}

.tab-button.active {
    color: var(--teal);
    border-bottom: 3px solid var(--teal);
    background-color: transparent;
    font-weight: 700;
}

.tab-content {
    display: none;
    padding: 0;
    animation: fadeIn 0.5s;
}

.tab-content.active {
    display: block;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

/* Map Styles */
#map {
    height: 600px;
    width: 100%;
    border: 1px solid var(--border-color);
    border-radius: 16px;
    box-shadow: 0 10px 30px rgba(18, 19, 88, 0.04);
}

.popup-content {
    font-family: 'Inter', sans-serif;
    font-size: 14px;
    color: var(--text-dark);
}

.popup-content h4 {
    font-family: 'Outfit', sans-serif;
    margin: 0 0 10px 0;
    color: var(--navy-blue);
    font-size: 16px;
    font-weight: 700;
}

.popup-content p {
    margin: 6px 0;
}

.popup-badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    color: white;
    font-weight: bold;
    font-size: 12px;
}

.popup-badge.safe { background-color: #16a34a; }
.popup-badge.normal { background-color: #0284c7; }
.popup-badge.alert { background-color: #d97706; color: #fff; }
.popup-badge.warning { background-color: #ea580c; }
.popup-badge.danger { background-color: #e11d48; }

/* Graph Styles */
.chart-container {
    margin-bottom: 30px;
    background: var(--white);
    padding: 24px;
    border-radius: 16px;
    border: 1px solid var(--border-color);
    box-shadow: 0 10px 30px rgba(18, 19, 88, 0.03);
}

.chart-title {
    font-family: 'Outfit', sans-serif;
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 15px;
    color: var(--navy-blue);
}

.prediction-box {
    background: var(--white);
    border-left: 4px solid var(--teal);
    padding: 24px;
    margin: 20px 0;
    border-radius: 0 16px 16px 0;
    border: 1px solid var(--border-color);
    border-left-width: 4px;
    box-shadow: 0 10px 30px rgba(18, 19, 88, 0.03);
}

.prediction-box h3 {
    font-family: 'Outfit', sans-serif;
    margin-top: 0;
    color: var(--navy-blue);
}

.risk-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin-bottom: 30px;
}

.risk-card {
    padding: 20px;
    border-radius: 12px;
    color: white;
    text-align: center;
    box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    transition: var(--transition);
}

.risk-card:hover {
    transform: translateY(-3px);
}

.risk-card h3 {
    margin: 0;
    font-size: 32px;
    font-family: 'Outfit', sans-serif;
    font-weight: 800;
}

.risk-card p {
    margin: 5px 0 0 0;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* Category card styling */
.filter-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 20px rgba(18, 19, 88, 0.06) !important;
}

.filter-card.active {
    border-color: var(--teal) !important;
    box-shadow: 0 10px 20px rgba(54, 173, 163, 0.15) !important;
    transform: scale(1.02);
}

/* Station card style */
.station-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 15px 35px rgba(18, 19, 88, 0.07) !important;
    border-color: rgba(54, 173, 163, 0.3) !important;
}

.prediction-box input,
.prediction-box select {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
    color: var(--text-dark);
    background-color: var(--light-gray);
    transition: var(--transition);
    margin-bottom: 15px;
}

.prediction-box input:focus,
.prediction-box select:focus {
    outline: none;
    border-color: var(--teal);
    background-color: var(--white);
    box-shadow: 0 0 0 3px rgba(54, 173, 163, 0.15);
}

.btn-analyze {
    background: linear-gradient(135deg, var(--navy-blue) 0%, var(--deep-blue) 100%);
    color: white;
    padding: 14px 28px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 16px;
    font-weight: 700;
    width: 100%;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(35, 47, 114, 0.2);
}

.btn-analyze:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(35, 47, 114, 0.3);
}

/* ---- Semak Status Styles ---- */
.semak-wrapper {
    max-width: 750px;
    margin: 40px auto;
    padding: 0 20px 60px;
}

.semak-title {
    text-align: center;
    margin-bottom: 35px;
}

.semak-title h2 {
    font-family: 'Outfit', sans-serif;
    color: var(--navy-blue);
    font-size: 28px;
    font-weight: 800;
    margin-bottom: 6px;
    letter-spacing: -0.5px;
}

.semak-title p {
    color: var(--text-light);
    font-size: 14px;
}

.search-card {
    background: var(--white);
    border-radius: 18px;
    box-shadow: 0 8px 24px rgba(18, 19, 88, 0.03);
    border: 1px solid var(--border-color);
    padding: 35px;
    margin-bottom: 30px;
}

.search-card label {
    display: block;
    font-weight: 700;
    color: var(--navy-blue);
    margin-bottom: 10px;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.search-row {
    display: flex;
    gap: 12px;
}

.search-row input {
    flex: 1;
    padding: 12px 18px;
    border: 1.5px solid var(--border-color);
    background: var(--light-gray);
    border-radius: 10px;
    font-size: 15px;
    color: var(--text-dark);
    font-family: 'Inter', sans-serif;
    transition: var(--transition);
}

.search-row input:focus {
    outline: none;
    border-color: var(--teal);
    background: var(--white);
    box-shadow: 0 0 0 3px rgba(54, 173, 163, 0.15);
}

.btn-search {
    background: linear-gradient(135deg, var(--teal), #2b948a);
    color: white;
    border: none;
    padding: 12px 30px;
    border-radius: 50px;
    font-size: 15px;
    font-weight: 700;
    font-family: 'Outfit', sans-serif;
    cursor: pointer;
    box-shadow: 0 6px 18px rgba(54, 173, 163, 0.2);
    transition: var(--transition);
}

.btn-search:hover {
    transform: translateY(-1px);
    box-shadow: 0 10px 22px rgba(54, 173, 163, 0.3);
}

.result-card {
    background: var(--white);
    border-radius: 18px;
    border: 1px solid var(--border-color);
    box-shadow: 0 10px 30px rgba(18, 19, 88, 0.04);
    overflow: hidden;
    margin-bottom: 30px;
}

.result-header {
    padding: 24px 30px;
    color: white;
    display: flex;
    align-items: center;
    gap: 16px;
}

.result-header.checked_in  { background: linear-gradient(135deg, var(--deep-blue), var(--navy-blue)); }
.result-header.checked_out { background: linear-gradient(135deg, #475569, #64748b); }

.result-header h3 {
    margin: 0;
    font-family: 'Outfit', sans-serif;
    font-size: 20px;
    font-weight: 800;
}

.result-header p {
    margin: 4px 0 0;
    font-size: 13px;
    opacity: 0.85;
}

.result-icon {
    font-size: 36px;
    line-height: 1;
}

.result-body {
    padding: 30px;
}

.info-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 24px;
}

.info-item label {
    font-size: 11px;
    color: var(--text-light);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    display: block;
    margin-bottom: 6px;
    font-weight: 700;
}

.info-item span {
    font-size: 15px;
    color: var(--text-dark);
    font-weight: 600;
}

.divider {
    border: none;
    border-top: 1.5px solid var(--border-color);
    margin: 20px 0;
}

.centre-block {
    background: var(--light-gray);
    border-left: 4px solid var(--teal);
    border-radius: 0 12px 12px 0;
    padding: 20px 24px;
    border: 1px solid var(--border-color);
    border-left-width: 4px;
}

.centre-block h4 {
    margin: 0 0 10px;
    color: var(--navy-blue);
    font-family: 'Outfit', sans-serif;
    font-size: 16px;
    font-weight: 700;
}

.centre-block p {
    margin: 6px 0;
    color: var(--text-dark);
    font-size: 14px;
}

.status-pill {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 0.5px;
}
.status-pill.checked_in  { background: rgba(54, 173, 163, 0.1); color: var(--teal); }
.status-pill.checked_out { background: #e2e8f0; color: var(--text-light); }

.not-found-card {
    background: var(--white);
    border-radius: 18px;
    border: 1px solid var(--border-color);
    box-shadow: 0 10px 30px rgba(18, 19, 88, 0.04);
    padding: 45px 35px;
    text-align: center;
}

.not-found-card .nf-icon {
    font-size: 54px;
    margin-bottom: 20px;
}

.not-found-card h3 {
    font-family: 'Outfit', sans-serif;
    color: var(--navy-blue);
    font-size: 20px;
    font-weight: 700;
    margin-bottom: 10px;
}

.not-found-card p {
    font-size: 14px;
    color: var(--text-light);
    margin: 6px 0;
}

.info-notice {
    background: rgba(251, 191, 36, 0.08);
    border-left: 4px solid #d97706;
    border-radius: 0 10px 10px 0;
    padding: 16px 20px;
    font-size: 13px;
    color: #b45309;
    border: 1px solid rgba(251, 191, 36, 0.15);
    border-left-width: 4px;
    margin-top: 20px;
}
</style>

<!-- Leaflet CSS for Maps -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

<!-- Chart.js for Graphs -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<%
    int countAll = 0;
    int countBahaya = 0;
    int countAmaran = 0;
    int countWaspada = 0;
    int countNormalSafe = 0;
    
    Connection countConn = null;
    Statement countStmt = null;
    ResultSet countRs = null;
    try {
        countConn = DBConnection.getConnection();
        countStmt = countConn.createStatement();
        countRs = countStmt.executeQuery(
            "SELECT r.risk_level, COUNT(*) as qty " +
            "FROM readings r " +
            "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
            "ON r.reading_id = latest.max_id " +
            "GROUP BY r.risk_level"
        );
        while(countRs.next()) {
            String rl = countRs.getString("risk_level");
            int qty = countRs.getInt("qty");
            countAll += qty;
            if("BAHAYA".equals(rl)) countBahaya += qty;
            else if("AMARAN".equals(rl)) countAmaran += qty;
            else if("WASPADA".equals(rl)) countWaspada += qty;
            else countNormalSafe += qty;
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(countRs != null) { try { countRs.close(); } catch(Exception ex){} }
        if(countStmt != null) { try { countStmt.close(); } catch(Exception ex){} }
        if(countConn != null) { try { countConn.close(); } catch(Exception ex){} }
    }
%>

<div class="container">
    <!-- Sleek Glassmorphic Profile Banner -->
    <div class="user-profile-card">
        <div class="profile-main">
            <div class="profile-avatar">
                <span>👤</span>
            </div>
            <div class="profile-info">
                <span class="profile-badge">PROFIL PENGGUNA</span>
                <h3 class="profile-email"><%= userEmail %></h3>
                <p class="profile-location">
                    <span class="loc-icon">📍</span> Lokasi Pilihan: <strong><%= userLocation %></strong>
                </p>
            </div>
        </div>
        
        <div class="profile-stats">
            <div class="stat-item">
                <span class="stat-label">Stesen Tempatan</span>
                <span class="stat-value"><%= localStationsCount %></span>
            </div>
            <div class="stat-item">
                <span class="stat-label">Status Risiko Tempatan</span>
                <% if ("BAHAYA".equals(localRiskLevel)) { %>
                    <span class="stat-badge danger">🚨 <%= localRiskLevel %></span>
                <% } else if ("AMARAN".equals(localRiskLevel)) { %>
                    <span class="stat-badge warning">⚠️ <%= localRiskLevel %></span>
                <% } else if ("WASPADA".equals(localRiskLevel)) { %>
                    <span class="stat-badge alert">🟡 <%= localRiskLevel %></span>
                <% } else if ("NORMAL".equals(localRiskLevel) || "SAFE".equals(localRiskLevel)) { %>
                    <span class="stat-badge success">🟢 <%= localRiskLevel %></span>
                <% } else { %>
                    <span class="stat-badge neutral">⚪ <%= localRiskLevel %></span>
                <% } %>
            </div>
            <% if (localDangerCount > 0) { %>
                <div class="stat-item danger-alert animate-pulse">
                    <span class="stat-label">Stesen Bahaya Aktif</span>
                    <span class="stat-value text-danger"><%= localDangerCount %></span>
                </div>
            <% } %>
        </div>
    </div>
    
    <%
        boolean activeSemak = searched || "semak".equals(request.getParameter("tab"));
    %>
    <div class="content">
        <h2 class="section-title">Notifikasi Aras Air & Kadar Hujan Terkini</h2>
        
        <!-- Tabs -->
        <div class="tabs">
            <button class="tab-button <%= activeSemak ? "" : "active" %>" onclick="openTab(event, 'readings')">Bacaan</button>
            <button class="tab-button" onclick="openTab(event, 'maps')">Peta</button>
            <button class="tab-button" onclick="openTab(event, 'graphs')">Graf & Ramalan</button>
            <button class="tab-button <%= activeSemak ? "active" : "" %>" onclick="openTab(event, 'semak')">Semak Status</button>
        </div>
        
        <!-- Tab 1: Readings -->
        <div id="readings" class="tab-content <%= activeSemak ? "" : "active" %>">
            <!-- Search bar pill -->
            <div style="max-width: 600px; margin: 30px auto 40px auto; position: relative;">
                <div style="display: flex; background: var(--white); border-radius: 50px; padding: 6px 10px; box-shadow: 0 10px 30px rgba(18, 19, 88, 0.08); border: 1px solid rgba(18, 19, 88, 0.05); align-items: center;">
                    <span style="font-size: 20px; margin-left: 15px; color: var(--text-light);">🔍</span>
                    <input type="text" id="stationSearch" placeholder="Cari stesen, lokasi, atau negeri..." 
                           style="flex: 1; border: none; outline: none; padding: 12px 15px; font-size: 16px; background: transparent; color: var(--text-dark); font-family: 'Inter', sans-serif;">
                </div>
            </div>

            <!-- Category Filters -->
            <div class="category-filters-container" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px; margin-bottom: 40px;">
                <div class="filter-card active" onclick="filterByRisk('ALL', this)" style="background: var(--white); border-radius: 12px; padding: 16px 12px; text-align: center; cursor: pointer; border: 1px solid var(--border-color); box-shadow: 0 4px 12px rgba(0,0,0,0.02); transition: var(--transition);">
                    <div style="font-size: 20px; margin-bottom: 5px;">🌏</div>
                    <div style="font-weight: 700; font-size: 13px; color: var(--navy-blue); font-family: 'Outfit', sans-serif;">Semua</div>
                    <div style="font-size: 15px; font-weight: 800; color: var(--text-dark); margin-top: 4px;"><%= countAll %> Stesen</div>
                </div>
                <div class="filter-card" onclick="filterByRisk('BAHAYA', this)" style="background: var(--white); border-radius: 12px; padding: 16px 12px; text-align: center; cursor: pointer; border: 1px solid var(--border-color); box-shadow: 0 4px 12px rgba(0,0,0,0.02); transition: var(--transition);">
                    <div style="font-size: 20px; margin-bottom: 5px;">🚨</div>
                    <div style="font-weight: 700; font-size: 13px; color: #e11d48; font-family: 'Outfit', sans-serif;">Bahaya</div>
                    <div style="font-size: 15px; font-weight: 800; color: #e11d48; margin-top: 4px;"><%= countBahaya %> Stesen</div>
                </div>
                <div class="filter-card" onclick="filterByRisk('AMARAN', this)" style="background: var(--white); border-radius: 12px; padding: 16px 12px; text-align: center; cursor: pointer; border: 1px solid var(--border-color); box-shadow: 0 4px 12px rgba(0,0,0,0.02); transition: var(--transition);">
                    <div style="font-size: 20px; margin-bottom: 5px;">⚠️</div>
                    <div style="font-weight: 700; font-size: 13px; color: #ea580c; font-family: 'Outfit', sans-serif;">Amaran</div>
                    <div style="font-size: 15px; font-weight: 800; color: #ea580c; margin-top: 4px;"><%= countAmaran %> Stesen</div>
                </div>
                <div class="filter-card" onclick="filterByRisk('WASPADA', this)" style="background: var(--white); border-radius: 12px; padding: 16px 12px; text-align: center; cursor: pointer; border: 1px solid var(--border-color); box-shadow: 0 4px 12px rgba(0,0,0,0.02); transition: var(--transition);">
                    <div style="font-size: 20px; margin-bottom: 5px;">🟡</div>
                    <div style="font-weight: 700; font-size: 13px; color: #d97706; font-family: 'Outfit', sans-serif;">Waspada</div>
                    <div style="font-size: 15px; font-weight: 800; color: #d97706; margin-top: 4px;"><%= countWaspada %> Stesen</div>
                </div>
                <div class="filter-card" onclick="filterByRisk('NORMAL_SAFE', this)" style="background: var(--white); border-radius: 12px; padding: 16px 12px; text-align: center; cursor: pointer; border: 1px solid var(--border-color); box-shadow: 0 4px 12px rgba(0,0,0,0.02); transition: var(--transition);">
                    <div style="font-size: 20px; margin-bottom: 5px;">🟢</div>
                    <div style="font-weight: 700; font-size: 13px; color: #16a34a; font-family: 'Outfit', sans-serif;">Normal/Safe</div>
                    <div style="font-size: 15px; font-weight: 800; color: #16a34a; margin-top: 4px;"><%= countNormalSafe %> Stesen</div>
                </div>
            </div>

            <!-- Grouped Station Readings List by State -->
            <div id="stationCardsGrid" style="display: flex; flex-direction: column; gap: 24px;">
                <%
                // Grouping structure to hold readings by State name
                Map<String, List<Map<String, Object>>> stateReadingsUD = new LinkedHashMap<String, List<Map<String, Object>>>();
                
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DBConnection.getConnection();
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery(
                        "SELECT r.* FROM readings r " +
                        "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
                        "ON r.reading_id = latest.max_id " +
                        "ORDER BY " +
                        "CASE r.risk_level " +
                        "  WHEN 'BAHAYA' THEN 1 " +
                        "  WHEN 'AMARAN' THEN 2 " +
                        "  WHEN 'WASPADA' THEN 3 " +
                        "  WHEN 'NORMAL' THEN 4 " +
                        "  WHEN 'SAFE' THEN 5 " +
                        "  ELSE 6 " +
                        "END ASC, r.state ASC, r.station_name ASC"
                    );
                    
                    while(rs.next()) {
                        String state = rs.getString("state");
                        Map<String, Object> reading = new HashMap<String, Object>();
                        reading.put("station_name", rs.getString("station_name"));
                        reading.put("location", rs.getString("location"));
                        reading.put("risk_level", rs.getString("risk_level"));
                        
                        double wlVal = rs.getDouble("water_level_m");
                        reading.put("water_level_m", rs.wasNull() ? null : wlVal);
                        
                        double rfVal = rs.getDouble("rainfall_mm");
                        reading.put("rainfall_mm", rs.wasNull() ? null : rfVal);
                        
                        reading.put("trend", rs.getString("trend"));
                        reading.put("recorded_date", rs.getTimestamp("recorded_date"));
                        
                        if(!stateReadingsUD.containsKey(state)) {
                            stateReadingsUD.put(state, new ArrayList<Map<String, Object>>());
                        }
                        stateReadingsUD.get(state).add(reading);
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(rs != null) { try { rs.close(); } catch(Exception ex){} }
                    if(stmt != null) { try { stmt.close(); } catch(Exception ex){} }
                    if(conn != null) { try { conn.close(); } catch(Exception ex){} }
                }
                
                // Iterate through grouped states
                for(Map.Entry<String, List<Map<String, Object>>> entry : stateReadingsUD.entrySet()) {
                    String stateName = entry.getKey();
                    List<Map<String, Object>> readingsList = entry.getValue();
                %>
                <div class="state-box" style="background: var(--white); border-radius: 20px; border: 1px solid var(--border-color); box-shadow: 0 10px 30px rgba(18, 19, 88, 0.03); padding: 24px; display: block;">
                    
                    <!-- State Header Inside Box -->
                    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--border-color); padding-bottom: 14px; margin-bottom: 18px;">
                        <h3 style="font-size: 20px; color: var(--navy-blue); margin: 0; font-family: 'Outfit', sans-serif; display: flex; align-items: center; gap: 8px; text-transform: uppercase;">
                            <span>🗺️</span> <%= stateName %>
                        </h3>
                        <span style="font-size: 12px; color: var(--teal); font-weight: 800; background: rgba(54, 173, 163, 0.1); padding: 4px 12px; border-radius: 20px; font-family: 'Outfit', sans-serif;">
                            <%= readingsList.size() %> Stesen
                        </span>
                    </div>
                    
                    <!-- Nested Station Cards List -->
                    <div style="display: flex; flex-direction: column; gap: 14px;">
                        <%
                        for(Map<String, Object> r : readingsList) {
                            String sName = (String) r.get("station_name");
                            String loc = (String) r.get("location");
                            String rl = (String) r.get("risk_level");
                            Double wl = (Double) r.get("water_level_m");
                            Double rf = (Double) r.get("rainfall_mm");
                            String tr = (String) r.get("trend");
                            java.util.Date recordedDate = (java.util.Date) r.get("recorded_date");
                            String dateStr = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(recordedDate);
                            
                            // Parse River Name and Station Site
                            String riverName = sName;
                            String stationSite = sName;
                            if(sName.contains(" di ")) {
                                String[] parts = sName.split(" di ", 2);
                                riverName = parts[0];
                                stationSite = parts[1];
                            }
                            
                            // Setup status badge classes & translations
                            String statusText = "Normal";
                            String badgeBgColor = "#dcfce7";
                            String textThemeColor = "#166534";
                            String badgeBorder = "1px solid #bbf7d0";
                            
                            if("BAHAYA".equals(rl)) {
                                statusText = "Danger";
                                badgeBgColor = "#fee2e2";
                                textThemeColor = "#991b1b";
                                badgeBorder = "1px solid #fca5a5";
                            } else if("AMARAN".equals(rl)) {
                                statusText = "Warning";
                                badgeBgColor = "#ffedd5";
                                textThemeColor = "#c2410c";
                                badgeBorder = "1px solid #fed7aa";
                            } else if("WASPADA".equals(rl)) {
                                statusText = "Alert";
                                badgeBgColor = "#fef9c3";
                                textThemeColor = "#a16207";
                                badgeBorder = "1px solid #fef08a";
                            }
                            
                            // Setup trend indicators
                            String trendIcon = "➔";
                            String trendText = "No Change";
                            String trendColor = "#64748b";
                            if("Menaik".equals(tr)) {
                                trendIcon = "▲";
                                trendText = "Rising";
                                trendColor = "#dc2626";
                            } else if("Menurun".equals(tr)) {
                                trendIcon = "▼";
                                trendText = "Falling";
                                trendColor = "#16a34a";
                            }
                        %>
                        <div class="station-card" 
                             data-station="<%= sName.toLowerCase().replace("\"", "") %>" 
                             data-location="<%= loc.toLowerCase() %>" 
                             data-state="<%= stateName.toLowerCase() %>" 
                             data-risk="<%= rl %>"
                             style="background: var(--light-gray); border-radius: 12px; border: 1px solid rgba(35, 47, 114, 0.05); padding: 18px 20px; transition: var(--transition); display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap;">
                            
                            <!-- Left Section: River, Location -->
                            <div style="flex: 2; min-width: 220px; display: flex; flex-direction: column; gap: 4px;">
                                <h4 style="font-size: 18px; font-weight: 700; color: var(--navy-blue); margin: 0; font-family: 'Outfit', sans-serif;"><%= riverName %></h4>
                                <p style="font-size: 13px; color: var(--text-light); margin: 0; display: flex; align-items: center; gap: 6px;">
                                    <span style="font-size: 14px;">📍</span> <%= stationSite %>, <%= loc %>
                                </p>
                            </div>
                            
                            <!-- Middle Section: Telemetry Metrics -->
                            <div style="flex: 1.5; min-width: 180px; display: flex; align-items: center; gap: 20px;">
                                <div style="display: flex; flex-direction: column; gap: 2px;">
                                    <span style="font-size: 10px; font-weight: 600; text-transform: uppercase; color: var(--text-light); letter-spacing: 0.5px;">Aras Air</span>
                                    <span style="font-size: 15px; font-weight: 700; color: var(--text-dark); display: flex; align-items: center; gap: 4px;">
                                        <span style="color: var(--teal);">💧</span> <%= wl != null ? String.format("%.2f", wl) + " m" : "N/A" %>
                                    </span>
                                </div>
                                <div style="display: flex; flex-direction: column; gap: 2px;">
                                    <span style="font-size: 10px; font-weight: 600; text-transform: uppercase; color: var(--text-light); letter-spacing: 0.5px;">Kadar Hujan</span>
                                    <span style="font-size: 15px; font-weight: 700; color: var(--text-dark); display: flex; align-items: center; gap: 4px;">
                                        <span style="color: #2F578A;">☔</span> <%= rf != null ? String.format("%.1f", rf) + " mm" : "N/A" %>
                                    </span>
                                </div>
                            </div>
                            
                            <!-- Right Section: Status Badge, Trend, Updated Date -->
                            <div style="flex: 2; min-width: 220px; display: flex; flex-direction: column; align-items: flex-end; gap: 6px; justify-content: center;">
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <!-- Trend Indicator -->
                                    <span style="font-size: 12px; font-weight: 700; color: <%= trendColor %>; display: flex; align-items: center; gap: 4px; padding: 4px 10px; background: #e2e8f0; border-radius: 8px;">
                                        <%= trendIcon %> <%= trendText %>
                                    </span>
                                    <!-- Status Badge -->
                                    <span style="background-color: <%= badgeBgColor %>; color: <%= textThemeColor %>; border: <%= badgeBorder %>; padding: 6px 14px; border-radius: 20px; font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; font-family: 'Outfit', sans-serif; min-width: 80px; text-align: center;"><%= statusText %></span>
                                </div>
                                <div style="font-size: 11px; color: var(--text-light); display: flex; align-items: center; gap: 4px; margin-top: 2px;">
                                    <span>🕒</span> <%= dateStr %>
                                </div>
                            </div>
                        </div>
                        <%
                        }
                        %>
                    </div>
                </div>
                <%
                }
                %>
            </div>
        </div>
        
        <!-- Tab 2: Maps -->
        <div id="maps" class="tab-content">
            <div id="map"></div>
        </div>

        <!-- Prepare map data in JSP -->
        <%
        // Prepare markers data for JavaScript
        StringBuilder markersJson = new StringBuilder("[");
        Connection mapConn = null;
        Statement mapStmt = null;
        ResultSet mapRs = null;

        try {
            mapConn = DBConnection.getConnection();
            mapStmt = mapConn.createStatement();
            mapRs = mapStmt.executeQuery(
                "SELECT r.* FROM readings r " +
                "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
                "ON r.reading_id = latest.max_id " +
                "WHERE r.latitude IS NOT NULL AND r.longitude IS NOT NULL"
            );
            
            boolean firstMarker = true;
            while(mapRs.next()) {
                if(!firstMarker) markersJson.append(",");
                firstMarker = false;
                
                double lat = mapRs.getDouble("latitude");
                double lon = mapRs.getDouble("longitude");
                String stationName = mapRs.getString("station_name").replace("'", "\\'").replace("\"", "\\\"");
                String location = mapRs.getString("location").replace("'", "\\'").replace("\"", "\\\"");
                String state = mapRs.getString("state").replace("'", "\\'").replace("\"", "\\\"");
                String riskLevel = mapRs.getString("risk_level");
                String trend = mapRs.getString("trend");
                
                Double waterLevel = mapRs.getDouble("water_level_m");
                boolean hasWaterLevel = !mapRs.wasNull();
                Double rainfall = mapRs.getDouble("rainfall_mm");
                boolean hasRainfall = !mapRs.wasNull();
                
                String markerColor = "blue";
                if("BAHAYA".equals(riskLevel)) markerColor = "red";
                else if("AMARAN".equals(riskLevel)) markerColor = "orange";
                else if("WASPADA".equals(riskLevel)) markerColor = "yellow";
                else if("NORMAL".equals(riskLevel)) markerColor = "lightblue";
                else markerColor = "green";
                
                String riskClass = "";
                if("BAHAYA".equals(riskLevel)) riskClass = "danger";
                else if("AMARAN".equals(riskLevel)) riskClass = "warning";
                else if("WASPADA".equals(riskLevel)) riskClass = "alert";
                else if("NORMAL".equals(riskLevel)) riskClass = "normal";
                else riskClass = "safe";
                
                String waterLevelStr = hasWaterLevel ? String.format("%.2f", waterLevel) : "N/A";
                String rainfallStr = hasRainfall ? String.format("%.1f", rainfall) : "N/A";
                String dateStr = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(mapRs.getTimestamp("recorded_date"));
                
                markersJson.append("{");
                markersJson.append("\"lat\":").append(lat).append(",");
                markersJson.append("\"lon\":").append(lon).append(",");
                markersJson.append("\"stationName\":\"").append(stationName).append("\",");
                markersJson.append("\"location\":\"").append(location).append("\",");
                markersJson.append("\"state\":\"").append(state).append("\",");
                markersJson.append("\"riskLevel\":\"").append(riskLevel).append("\",");
                markersJson.append("\"riskClass\":\"").append(riskClass).append("\",");
                markersJson.append("\"trend\":\"").append(trend).append("\",");
                markersJson.append("\"markerColor\":\"").append(markerColor).append("\",");
                markersJson.append("\"waterLevel\":\"").append(waterLevelStr).append("\",");
                markersJson.append("\"rainfall\":\"").append(rainfallStr).append("\",");
                markersJson.append("\"hasWaterLevel\":").append(hasWaterLevel).append(",");
                markersJson.append("\"hasRainfall\":").append(hasRainfall).append(",");
                markersJson.append("\"date\":\"").append(dateStr).append("\"");
                markersJson.append("}");
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(mapRs != null) { try { mapRs.close(); } catch(Exception ex){} }
            if(mapStmt != null) { try { mapStmt.close(); } catch(Exception ex){} }
            if(mapConn != null) { try { mapConn.close(); } catch(Exception ex){} }
        }

        markersJson.append("]");
        %>
        
        <!-- Tab 3: Graphs & Predictions -->
        <div id="graphs" class="tab-content">
            <!-- Station Selector -->
            <div class="prediction-box">
                <h3>🔍 Pilih Stesen untuk Analisis & Ramalan</h3>
                <div style="margin-bottom: 15px;">
                    <label for="stationSelector" style="display: block; margin-bottom: 10px; font-weight: bold; color: var(--navy-blue);">Stesen:</label>
                    <select id="stationSelector">
                        <option value="">-- Pilih Stesen --</option>
                        <%
                        Connection selConn = null;
                        Statement selStmt = null;
                        ResultSet selRs = null;
                        
                        try {
                            selConn = DBConnection.getConnection();
                            selStmt = selConn.createStatement();
                            selRs = selStmt.executeQuery(
                                "SELECT r.reading_id, r.station_name, r.location, r.state, r.water_level_m, r.rainfall_mm, r.risk_level, r.trend " +
                                "FROM readings r " +
                                "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
                                "ON r.reading_id = latest.max_id " +
                                "WHERE r.water_level_m IS NOT NULL ORDER BY r.state, r.station_name"
                            );
                            
                            while(selRs.next()) {
                                int readingId = selRs.getInt("reading_id");
                                String stationName = selRs.getString("station_name");
                                String location = selRs.getString("location");
                                String state = selRs.getString("state");
                                Double waterLevel = selRs.getDouble("water_level_m");
                                Double rainfall = selRs.getDouble("rainfall_mm");
                                boolean hasRainfall = !selRs.wasNull();
                                String riskLevel = selRs.getString("risk_level");
                                String trend = selRs.getString("trend");
                                
                                String displayText = stationName + " - " + location + ", " + state + 
                                                   " (Aras: " + String.format("%.2f", waterLevel) + "m, " +
                                                   (hasRainfall ? "Hujan: " + String.format("%.1f", rainfall) + "mm, " : "") +
                                                   "Risiko: " + riskLevel + ", Trend: " + trend + ")";
                        %>
                        <option value="<%= readingId %>" 
                                data-station="<%= stationName.replace("\"", "&quot;") %>"
                                data-location="<%= location %>"
                                data-state="<%= state %>"
                                data-waterlevel="<%= waterLevel %>"
                                data-rainfall="<%= hasRainfall ? rainfall : 0 %>"
                                data-risk="<%= riskLevel %>"
                                data-trend="<%= trend %>">
                            <%= displayText %>
                        </option>
                        <%
                            }
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            if(selRs != null) { try { selRs.close(); } catch(Exception ex){} }
                            if(selStmt != null) { try { selStmt.close(); } catch(Exception ex){} }
                            if(selConn != null) { try { selConn.close(); } catch(Exception ex){} }
                        }
                        %>
                    </select>
                </div>
                <button onclick="analyzePrediction()" class="btn-analyze">
                    📊 Analisis & Ramal
                </button>
            </div>
            
            <!-- Analysis Result -->
            <div id="analysisResult" style="display: none;">
                <div class="prediction-box">
                    <h3>📊 Analisis & Ramalan Aras Air</h3>
                    <div id="stationInfo"></div>
                </div>
                
                <!-- Prediction Chart -->
                <div class="chart-container">
                    <div class="chart-title">Ramalan Aras Air untuk 7 Hari Akan Datang</div>
                    <canvas id="predictionChart"></canvas>
                </div>
                
                <!-- Detailed Analysis -->
                <div class="prediction-box">
                    <h3>🔮 Analisis Terperinci</h3>
                    <div id="detailedAnalysis"></div>
                </div>
            </div>
            
            <!-- Global Risk Summary & Analytical Graphs (Always Visible) -->
            <div class="prediction-box" style="margin-top: 30px;">
                <h3>📈 Ringkasan Status Keseluruhan</h3>
                <div class="risk-summary" style="margin-bottom: 30px;">
                    <%
                    Connection sumConn = null;
                    Statement sumStmt = null;
                    ResultSet sumRs = null;
                    
                    try {
                        sumConn = DBConnection.getConnection();
                        sumStmt = sumConn.createStatement();
                        
                        String[] riskLevels = {"BAHAYA", "AMARAN", "WASPADA", "NORMAL", "SAFE"};
                        String[] riskColors = {"#e11d48", "#ea580c", "#d97706", "#0284c7", "#16a34a"};
                        
                        for(int i = 0; i < riskLevels.length; i++) {
                            sumRs = sumStmt.executeQuery(
                                "SELECT COUNT(*) as count FROM readings r " +
                                "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
                                "ON r.reading_id = latest.max_id " +
                                "WHERE r.risk_level = '" + riskLevels[i] + "'"
                            );
                            if(sumRs.next()) {
                                int count = sumRs.getInt("count");
                                if(count > 0) {
                    %>
                    <div class="risk-card" style="background-color: <%= riskColors[i] %>;">
                        <h3><%= count %></h3>
                        <p><%= riskLevels[i] %></p>
                    </div>
                    <%
                                }
                            }
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        if(sumRs != null) { try { sumRs.close(); } catch(Exception ex){} }
                        if(sumStmt != null) { try { sumStmt.close(); } catch(Exception ex){} }
                        if(sumConn != null) { try { sumConn.close(); } catch(Exception ex){} }
                    }
                    %>
                </div>

                <div style="display: grid; grid-template-columns: 2fr 1.2fr; gap: 30px; margin-bottom: 30px; flex-wrap: wrap;">
                    <div class="chart-container" style="margin-bottom: 0;">
                        <div class="chart-title">Status Risiko Mengikut Negeri</div>
                        <canvas id="riskByStateChart"></canvas>
                    </div>
                    <div class="chart-container" style="margin-bottom: 0;">
                        <div class="chart-title">Arah Aliran Aras Air</div>
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>

                <div class="chart-container" style="margin-bottom: 0;">
                    <div class="chart-title">Perbandingan Kadar Hujan vs Aras Air Mengikut Stesen</div>
                    <canvas id="rainfallWaterChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Tab 4: Semak Status -->
        <div id="semak" class="tab-content <%= activeSemak ? "active" : "" %>">
            <div class="semak-wrapper">
                <div class="semak-title">
                    <h2>🔍 Semak Status Penempatan Banjir</h2>
                    <p>Masukkan No. Kad Pengenalan untuk menyemak status pendaftaran mangsa banjir</p>
                </div>

                <%-- Search Form --%>
                <div class="search-card">
                    <form method="get" action="user-dashboard.jsp">
                        <label for="ic">No. Kad Pengenalan (IC)</label>
                        <div class="search-row">
                            <input type="text"
                                   id="ic"
                                   name="ic"
                                   placeholder="cth: 900101-14-5678"
                                   maxlength="20"
                                   value="<%= icInput != null ? icInput : "" %>"
                                   autocomplete="off">
                            <button type="submit" class="btn-search">🔍 Semak</button>
                        </div>
                    </form>

                    <div class="info-notice">
                        ℹ️ Maklumat ini hanya untuk rujukan mangsa banjir yang telah didaftarkan oleh pegawai.
                        Untuk pertanyaan lanjut, sila hubungi pusat kawalan banjir terdekat.
                    </div>
                </div>

                <%-- Results --%>
                <% if(searchError != null) { %>
                    <div class="not-found-card">
                        <div class="nf-icon">⚠️</div>
                        <h3>Ralat Sistem</h3>
                        <p>Tidak dapat menyambung ke pangkalan data. Sila cuba sebentar lagi.</p>
                    </div>

                <% } else if(searched && found) {
                    boolean isCheckedIn = "checked_in".equals(vstatus);
                %>
                    <div class="result-card">
                        <div class="result-header <%= vstatus %>">
                            <div class="result-icon"><%= isCheckedIn ? "🏠" : "✅" %></div>
                            <div>
                                <h3><%= isCheckedIn ? "Sedang Berada di Pusat Pemindahan" : "Telah Keluar dari Pusat Pemindahan" %></h3>
                                <p>Status dikemaskini berdasarkan rekod terkini</p>
                            </div>
                        </div>

                        <div class="result-body">

                            <%-- Personal Info --%>
                            <div class="info-grid">
                                <div class="info-item">
                                    <label>Nama Penuh</label>
                                    <span><%= fullName %></span>
                                </div>
                                <div class="info-item">
                                    <label>No. IC</label>
                                    <span><%= icInput %></span>
                                </div>
                                <div class="info-item">
                                    <label>Bil. Ahli Keluarga</label>
                                    <span><%= familyCount %> orang</span>
                                </div>
                                <div class="info-item">
                                    <label>Status</label>
                                    <span class="status-pill <%= vstatus %>">
                                        <%= isCheckedIn ? "Sedang Menginap" : "Telah Keluar" %>
                                    </span>
                                </div>
                                <div class="info-item">
                                    <label>Masa Daftar Masuk</label>
                                    <span><%= checkIn != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(checkIn) : "-" %></span>
                                </div>
                                <div class="info-item">
                                    <label>Masa Daftar Keluar</label>
                                    <span><%= checkOut != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(checkOut) : "-" %></span>
                                </div>
                            </div>

                            <hr class="divider">

                            <%-- Centre Info --%>
                            <% if(centreName != null) { %>
                            <div class="centre-block">
                                <h4>🏫 Maklumat Pusat Pemindahan</h4>
                                <p><strong><%= centreName %></strong></p>
                                <p>📍 <%= centreAddress != null ? centreAddress : "" %></p>
                                <p>🗺️ <%= centreLocation != null ? centreLocation : "" %>, <%= centreState != null ? centreState : "" %></p>
                            </div>
                            <% } else { %>
                            <div class="centre-block">
                                <h4>🏫 Pusat Pemindahan</h4>
                                <p>Maklumat pusat tidak tersedia.</p>
                            </div>
                            <% } %>

                        </div>
                    </div>

                <% } else if(searched && !found) { %>
                    <div class="not-found-card">
                        <div class="nf-icon">❌</div>
                        <h3>Rekod Tidak Dijumpai</h3>
                        <p>Tiada rekod pendaftaran banjir untuk No. IC: <strong><%= icInput %></strong></p>
                        <p style="margin-top:12px; font-weight:700;">Kemungkinan sebab:</p>
                        <p>• No. IC tidak tepat atau belum didaftarkan</p>
                        <p>• Pendaftaran belum dilakukan oleh pegawai bertugas</p>
                        <p style="margin-top:20px; color:var(--teal); font-weight:700;">
                            Sila hubungi pegawai PPS terdekat untuk bantuan pendaftaran.
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<%
// Prepare all chart data in JSP before JavaScript starts
// Chart 1 data
Connection chart1Conn = null;
Statement chart1Stmt = null;
ResultSet chart1Rs = null;

Map<String, Map<String, Integer>> stateRiskData = new LinkedHashMap<String, Map<String, Integer>>();

try {
    chart1Conn = DBConnection.getConnection();
    chart1Stmt = chart1Conn.createStatement();
    chart1Rs = chart1Stmt.executeQuery(
        "SELECT r.state, r.risk_level, COUNT(*) as count FROM readings r " +
        "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
        "ON r.reading_id = latest.max_id " +
        "GROUP BY r.state, r.risk_level ORDER BY r.state"
    );
    
    while(chart1Rs.next()) {
        String state = chart1Rs.getString("state");
        String risk = chart1Rs.getString("risk_level");
        int count = chart1Rs.getInt("count");
        
        if(!stateRiskData.containsKey(state)) {
            stateRiskData.put(state, new LinkedHashMap<String, Integer>());
        }
        stateRiskData.get(state).put(risk, count);
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(chart1Rs != null) { try { chart1Rs.close(); } catch(Exception ex){} }
    if(chart1Stmt != null) { try { chart1Stmt.close(); } catch(Exception ex){} }
    if(chart1Conn != null) { try { chart1Conn.close(); } catch(Exception ex){} }
}

StringBuilder states = new StringBuilder("[");
StringBuilder bahayaData = new StringBuilder("[");
StringBuilder amaranData = new StringBuilder("[");
StringBuilder waspadaData = new StringBuilder("[");
StringBuilder normalData = new StringBuilder("[");
StringBuilder safeData = new StringBuilder("[");

boolean first = true;
for(Map.Entry<String, Map<String, Integer>> entry : stateRiskData.entrySet()) {
    if(!first) {
        states.append(",");
        bahayaData.append(",");
        amaranData.append(",");
        waspadaData.append(",");
        normalData.append(",");
        safeData.append(",");
    }
    first = false;
    
    states.append("'").append(entry.getKey()).append("'");
    bahayaData.append(entry.getValue().getOrDefault("BAHAYA", 0));
    amaranData.append(entry.getValue().getOrDefault("AMARAN", 0));
    waspadaData.append(entry.getValue().getOrDefault("WASPADA", 0));
    normalData.append(entry.getValue().getOrDefault("NORMAL", 0));
    safeData.append(entry.getValue().getOrDefault("SAFE", 0));
}

states.append("]");
bahayaData.append("]");
amaranData.append("]");
waspadaData.append("]");
normalData.append("]");
safeData.append("]");

// Chart 2 data
Connection chart2Conn = null;
Statement chart2Stmt = null;
ResultSet chart2Rs = null;

int menaik = 0, menurun = 0, tiada = 0;

try {
    chart2Conn = DBConnection.getConnection();
    chart2Stmt = chart2Conn.createStatement();
    
    chart2Rs = chart2Stmt.executeQuery(
        "SELECT COUNT(*) as count FROM readings r " +
        "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
        "ON r.reading_id = latest.max_id " +
        "WHERE r.trend = 'Menaik'"
    );
    if(chart2Rs.next()) menaik = chart2Rs.getInt("count");
    
    chart2Rs = chart2Stmt.executeQuery(
        "SELECT COUNT(*) as count FROM readings r " +
        "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
        "ON r.reading_id = latest.max_id " +
        "WHERE r.trend = 'Menurun'"
    );
    if(chart2Rs.next()) menurun = chart2Rs.getInt("count");
    
    chart2Rs = chart2Stmt.executeQuery(
        "SELECT COUNT(*) as count FROM readings r " +
        "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
        "ON r.reading_id = latest.max_id " +
        "WHERE r.trend = 'Tiada Perubahan'"
    );
    if(chart2Rs.next()) tiada = chart2Rs.getInt("count");
    
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(chart2Rs != null) { try { chart2Rs.close(); } catch(Exception ex){} }
    if(chart2Stmt != null) { try { chart2Stmt.close(); } catch(Exception ex){} }
    if(chart2Conn != null) { try { chart2Conn.close(); } catch(Exception ex){} }
}

// Chart 3 data
Connection chart3Conn = null;
Statement chart3Stmt = null;
ResultSet chart3Rs = null;

StringBuilder rainfallData = new StringBuilder("[");
StringBuilder waterLevelData = new StringBuilder("[");
StringBuilder labels = new StringBuilder("[");

try {
    chart3Conn = DBConnection.getConnection();
    chart3Stmt = chart3Conn.createStatement();
    chart3Rs = chart3Stmt.executeQuery(
        "SELECT r.station_name, r.rainfall_mm, r.water_level_m FROM readings r " +
        "INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest " +
        "ON r.reading_id = latest.max_id " +
        "WHERE r.rainfall_mm IS NOT NULL AND r.water_level_m IS NOT NULL LIMIT 15"
    );
    
    boolean firstItem = true;
    while(chart3Rs.next()) {
        if(!firstItem) {
            rainfallData.append(",");
            waterLevelData.append(",");
            labels.append(",");
        }
        firstItem = false;
        
        String shortName = chart3Rs.getString("station_name");
        if(shortName.length() > 20) shortName = shortName.substring(0, 17) + "...";
        
        labels.append("'").append(shortName.replace("'", "\\'")).append("'");
        rainfallData.append(chart3Rs.getDouble("rainfall_mm"));
        waterLevelData.append(chart3Rs.getDouble("water_level_m"));
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(chart3Rs != null) { try { chart3Rs.close(); } catch(Exception ex){} }
    if(chart3Stmt != null) { try { chart3Stmt.close(); } catch(Exception ex){} }
    if(chart3Conn != null) { try { chart3Conn.close(); } catch(Exception ex){} }
}

rainfallData.append("]");
waterLevelData.append("]");
labels.append("]");
%>

<script>
// Store markers data from JSP
var markersData = <%= markersJson.toString() %>;

var activeRiskFilter = 'ALL';

function filterByRisk(risk, el) {
    activeRiskFilter = risk;
    
    // Highlight active card
    var cards = document.querySelectorAll('.filter-card');
    cards.forEach(function(c) { c.classList.remove('active'); });
    el.classList.add('active');
    
    applyFilters();
}

function applyFilters() {
    var searchInput = document.getElementById('stationSearch');
    var searchVal = searchInput ? searchInput.value.toLowerCase().trim() : '';
    var sCards = document.querySelectorAll('.station-card');
    
    sCards.forEach(function(card) {
        var name = card.getAttribute('data-station') || '';
        var location = card.getAttribute('data-location') || '';
        var state = card.getAttribute('data-state') || '';
        var risk = card.getAttribute('data-risk') || '';
        
        // Search filter matches
        var matchesSearch = (name.indexOf(searchVal) > -1 || 
                             location.indexOf(searchVal) > -1 || 
                             state.indexOf(searchVal) > -1);
                             
        // Risk filter matches
        var matchesRisk = false;
        if (activeRiskFilter === 'ALL') {
            matchesRisk = true;
        } else if (activeRiskFilter === 'NORMAL_SAFE') {
            matchesRisk = (risk === 'NORMAL' || risk === 'SAFE');
        } else {
            matchesRisk = (risk === activeRiskFilter);
        }
        
        if (matchesSearch && matchesRisk) {
            card.style.display = 'flex';
        } else {
            card.style.display = 'none';
        }
    });
    
    // Update state boxes visibility based on nested station cards
    var stateBoxes = document.querySelectorAll('.state-box');
    stateBoxes.forEach(function(box) {
        var visibleCards = box.querySelectorAll('.station-card');
        var hasVisible = false;
        visibleCards.forEach(function(card) {
            if (card.style.display !== 'none') {
                hasVisible = true;
            }
        });
        if (hasVisible) {
            box.style.display = 'block';
        } else {
            box.style.display = 'none';
        }
    });
}

// Add real-time event listener to search input
document.addEventListener('DOMContentLoaded', function() {
    var searchInput = document.getElementById('stationSearch');
    if (searchInput) {
        searchInput.addEventListener('keyup', applyFilters);
        searchInput.addEventListener('input', applyFilters);
    }
});

// Tab switching function
function openTab(evt, tabName) {
    var i, tabcontent, tabbuttons;
    
    tabcontent = document.getElementsByClassName("tab-content");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].classList.remove("active");
    }
    
    tabbuttons = document.getElementsByClassName("tab-button");
    for (i = 0; i < tabbuttons.length; i++) {
        tabbuttons[i].classList.remove("active");
    }
    
    document.getElementById(tabName).classList.add("active");
    evt.currentTarget.classList.add("active");
    
    // Initialize map when maps tab is opened
    if(tabName === 'maps' && !window.mapInitialized) {
        initMap();
        window.mapInitialized = true;
    }
    
    // Initialize charts when graphs tab is opened
    if(tabName === 'graphs' && !window.chartsInitialized) {
        initCharts();
        window.chartsInitialized = true;
    }
}

// Initialize Leaflet Map
function initMap() {
    var map = L.map('map').setView([4.2105, 101.9758], 6);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);
    
    markersData.forEach(function(data) {
        var marker = L.circleMarker([data.lat, data.lon], {
            radius: 9,
            fillColor: data.markerColor === 'red' ? '#e11d48' :
                       data.markerColor === 'orange' ? '#ea580c' :
                       data.markerColor === 'yellow' ? '#d97706' :
                       data.markerColor === 'lightblue' ? '#0284c7' : '#16a34a',
            color: '#ffffff',
            weight: 2,
            opacity: 1,
            fillOpacity: 0.85
        }).addTo(map);
        
        var popupContent = '<div class="popup-content">';
        popupContent += '<h4>' + data.stationName + '</h4>';
        popupContent += '<p><strong>Lokasi:</strong> ' + data.location + ', ' + data.state + '</p>';
        popupContent += '<p><strong>Tahap Risiko:</strong> <span class="popup-badge ' + data.riskClass + '">' + data.riskLevel + '</span></p>';
        popupContent += '<p><strong>Trend:</strong> ' + data.trend + '</p>';
        
        if(data.hasWaterLevel) {
            popupContent += '<p><strong>Aras Air:</strong> ' + data.waterLevel + 'm</p>';
        }
        
        if(data.hasRainfall) {
            popupContent += '<p><strong>Kadar Hujan:</strong> ' + data.rainfall + 'mm</p>';
        }
        
        popupContent += '<p style="margin-top:8px;font-size:11px;color:#888;"><em>Kemaskini: ' + data.date + '</em></p>';
        popupContent += '</div>';
        
        marker.bindPopup(popupContent);
    });
}

// Initialize Analytical Charts
function initCharts() {
    // Chart 1: Risk by State
    var ctx1 = document.getElementById('riskByStateChart').getContext('2d');
    new Chart(ctx1, {
        type: 'bar',
        data: {
            labels: <%= states.toString() %>,
            datasets: [
                {
                    label: 'BAHAYA',
                    data: <%= bahayaData.toString() %>,
                    backgroundColor: '#e11d48'
                },
                {
                    label: 'AMARAN',
                    data: <%= amaranData.toString() %>,
                    backgroundColor: '#ea580c'
                },
                {
                    label: 'WASPADA',
                    data: <%= waspadaData.toString() %>,
                    backgroundColor: '#d97706'
                },
                {
                    label: 'NORMAL',
                    data: <%= normalData.toString() %>,
                    backgroundColor: '#0284c7'
                },
                {
                    label: 'SAFE',
                    data: <%= safeData.toString() %>,
                    backgroundColor: '#16a34a'
                }
            ]
        },
        options: {
            responsive: true,
            scales: {
                x: { stacked: true },
                y: { stacked: true, beginAtZero: true }
            }
        }
    });
    
    // Chart 2: Trend Chart
    var ctx2 = document.getElementById('trendChart').getContext('2d');
    new Chart(ctx2, {
        type: 'doughnut',
        data: {
            labels: ['Menaik', 'Menurun', 'Tiada Perubahan'],
            datasets: [{
                data: [<%= menaik %>, <%= menurun %>, <%= tiada %>],
                backgroundColor: ['#e11d48', '#16a34a', '#64748b']
            }]
        },
        options: {
            responsive: true
        }
    });
    
    // Chart 3: Rainfall vs Water Level (Bar Chart)
    var ctx3 = document.getElementById('rainfallWaterChart').getContext('2d');
    new Chart(ctx3, {
        type: 'bar',
        data: {
            labels: <%= labels.toString() %>,
            datasets: [
                {
                    label: 'Kadar Hujan (mm)',
                    data: <%= rainfallData.toString() %>,
                    backgroundColor: '#36ADA3', // Teal
                    yAxisID: 'y'
                },
                {
                    label: 'Aras Air (m)',
                    data: <%= waterLevelData.toString() %>,
                    backgroundColor: '#232F72', // Navy
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            interaction: {
                mode: 'index',
                intersect: false
            },
            scales: {
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    title: {
                        display: true,
                        text: 'Hujan (mm)'
                    }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    title: {
                        display: true,
                        text: 'Aras Air (m)'
                    },
                    grid: {
                        drawOnChartArea: false
                    }
                }
            }
        }
    });
}

var predictionChartInstance = null;

function analyzePrediction() {
    var selector = document.getElementById('stationSelector');
    var selectedOption = selector.options[selector.selectedIndex];
    
    if(!selectedOption.value) {
        alert('Sila pilih stesen terlebih dahulu!');
        return;
    }
    
    var stationName = selectedOption.getAttribute('data-station');
    var location = selectedOption.getAttribute('data-location');
    var state = selectedOption.getAttribute('data-state');
    var currentWaterLevel = parseFloat(selectedOption.getAttribute('data-waterlevel'));
    var rainfall = parseFloat(selectedOption.getAttribute('data-rainfall'));
    var riskLevel = selectedOption.getAttribute('data-risk');
    var trend = selectedOption.getAttribute('data-trend');
    
    document.getElementById('analysisResult').style.display = 'block';
    
    var stationInfo = '<p><strong>Stesen:</strong> ' + stationName + '</p>';
    stationInfo += '<p><strong>Lokasi:</strong> ' + location + ', ' + state + '</p>';
    stationInfo += '<p><strong>Aras Air Semasa:</strong> ' + currentWaterLevel.toFixed(2) + 'm</p>';
    stationInfo += '<p><strong>Kadar Hujan:</strong> ' + (rainfall > 0 ? rainfall.toFixed(1) + 'mm' : 'Tiada data') + '</p>';
    stationInfo += '<p><strong>Tahap Risiko Semasa:</strong> <span style="color: ' + getRiskColor(riskLevel) + '; font-weight: bold;">' + riskLevel + '</span></p>';
    stationInfo += '<p><strong>Trend:</strong> <span style="font-weight: bold;">' + trend + '</span></p>';
    
    document.getElementById('stationInfo').innerHTML = stationInfo;
    
    var prediction = calculatePrediction(currentWaterLevel, rainfall, trend, riskLevel);
    createPredictionChart(prediction);
    displayDetailedAnalysis(prediction, stationName, trend, rainfall, riskLevel);
    document.getElementById('analysisResult').scrollIntoView({ behavior: 'smooth' });
}

function calculatePrediction(currentLevel, rainfall, trend, riskLevel) {
    var today = new Date();
    var labels = [];
    var data = [];
    var riskLevels = [];
    
    labels.push('Hari Ini');
    data.push(currentLevel);
    riskLevels.push(riskLevel);
    
    var baseRate = 0;
    if(trend === 'Menaik') {
        baseRate = 0.15;
        if(rainfall > 40) baseRate = 0.35;
        else if(rainfall > 20) baseRate = 0.25;
        else if(rainfall > 10) baseRate = 0.20;
    } else if(trend === 'Menurun') {
        baseRate = -0.10;
        if(rainfall > 30) baseRate = 0.05;
        else if(rainfall > 15) baseRate = 0.00;
    } else {
        baseRate = 0.02;
        if(rainfall > 35) baseRate = 0.15;
        else if(rainfall > 20) baseRate = 0.08;
        else if(rainfall < 5) baseRate = -0.05;
    }
    
    var predictedLevel = currentLevel;
    for(var i = 1; i <= 7; i++) {
        var variance = (Math.random() - 0.5) * 0.4 * Math.abs(baseRate);
        var dailyChange = baseRate + variance;
        var decayFactor = 1 - (i * 0.08);
        if(decayFactor < 0.4) decayFactor = 0.4;
        
        predictedLevel += dailyChange * decayFactor;
        if(predictedLevel < 0) predictedLevel = 0;
        
        labels.push('Hari +' + i);
        data.push(predictedLevel);
        riskLevels.push(determineRiskLevel(predictedLevel));
    }
    
    return {
        labels: labels,
        data: data,
        riskLevels: riskLevels,
        maxLevel: Math.max(...data),
        minLevel: Math.min(...data),
        finalLevel: data[data.length - 1],
        trend: data[data.length - 1] > currentLevel ? 'MENAIK' : 'MENURUN'
    };
}

function determineRiskLevel(waterLevel) {
    if(waterLevel >= 4.5) return 'BAHAYA';
    if(waterLevel >= 3.5) return 'AMARAN';
    if(waterLevel >= 2.5) return 'WASPADA';
    if(waterLevel >= 1.0) return 'NORMAL';
    return 'SAFE';
}

function getRiskColor(risk) {
    var colors = {
        'BAHAYA': '#e11d48',
        'AMARAN': '#ea580c',
        'WASPADA': '#d97706',
        'NORMAL': '#0284c7',
        'SAFE': '#16a34a'
    };
    return colors[risk] || '#64748b';
}

function createPredictionChart(prediction) {
    var ctx = document.getElementById('predictionChart').getContext('2d');
    
    if(predictionChartInstance) {
        predictionChartInstance.destroy();
    }
    
    var pointColors = prediction.riskLevels.map(function(risk) {
        return getRiskColor(risk);
    });
    
    predictionChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: prediction.labels,
            datasets: [{
                label: 'Aras Air (m)',
                data: prediction.data,
                backgroundColor: pointColors,
                borderColor: 'rgba(18, 19, 88, 0.1)',
                borderWidth: 1,
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        afterLabel: function(context) {
                            return 'Tahap Risiko: ' + prediction.riskLevels[context.dataIndex];
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Aras Air (meter)'
                    },
                    ticks: {
                        callback: function(value) {
                            return value.toFixed(2) + 'm';
                        }
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Hari'
                    }
                }
            }
        }
    });
}

function displayDetailedAnalysis(prediction, stationName, trend, rainfall, currentRisk) {
    var analysis = '<p><strong>📍 Stesen:</strong> ' + stationName + '</p>';
    analysis += '<p><strong>📊 Analisis Trend:</strong></p><ul>';
    
    if(prediction.trend === 'MENAIK') {
        analysis += '<li style="color: #e11d48;">⚠️ Aras air dijangka <strong>MENINGKAT</strong> dari ' + 
                   prediction.data[0].toFixed(2) + 'm kepada ' + prediction.finalLevel.toFixed(2) + 'm dalam 7 hari.</li>';
        if(rainfall > 30) {
            analysis += '<li>☔ Hujan lebat (' + rainfall.toFixed(1) + 'mm) akan mempercepatkan peningkatan aras air.</li>';
        }
        var dangerDay = -1;
        for(var i = 0; i < prediction.riskLevels.length; i++) {
            if(prediction.riskLevels[i] === 'BAHAYA' || prediction.riskLevels[i] === 'AMARAN') {
                dangerDay = i;
                break;
            }
        }
        if(dangerDay > 0) {
            analysis += '<li style="color: #e11d48; font-weight: bold;">⚠️ Tahap BAHAYA/AMARAN dijangka pada Hari +' + dangerDay + '</li>';
        }
    } else if(prediction.trend === 'MENURUN') {
        analysis += '<li style="color: #16a34a;">✅ Aras air dijangka <strong>MENURUN</strong> dari ' + 
                   prediction.data[0].toFixed(2) + 'm kepada ' + prediction.finalLevel.toFixed(2) + 'm dalam 7 hari.</li>';
        analysis += '<li>Keadaan dijangka bertambah baik.</li>';
    }
    
    analysis += '</ul>';
    analysis += '<p><strong>🔮 Ramalan 7 Hari:</strong></p><ul>';
    analysis += '<li>Aras air maksimum: <strong>' + prediction.maxLevel.toFixed(2) + 'm</strong></li>';
    analysis += '<li>Aras air minimum: <strong>' + prediction.minLevel.toFixed(2) + 'm</strong></li>';
    analysis += '<li>Tahap risiko akhir: <span style="color: ' + getRiskColor(prediction.riskLevels[7]) + '; font-weight: bold;">' + prediction.riskLevels[7] + '</span></li>';
    analysis += '</ul>';
    
    analysis += '<p><strong>📌 Cadangan Tindakan:</strong></p><ul>';
    var finalRisk = prediction.riskLevels[prediction.riskLevels.length - 1];
    if(finalRisk === 'BAHAYA' || finalRisk === 'AMARAN') {
        analysis += '<li style="color: #e11d48; font-weight: bold;">🚨 Bersedia untuk kemungkinan banjir!</li>';
        analysis += '<li>Pindahkan barangan berharga ke tempat tinggi</li>';
        analysis += '<li>Sediakan bekalan makanan dan air</li>';
        analysis += '<li>Pantau kemas kini setiap 6-12 jam</li>';
        analysis += '<li>Ikuti arahan pihak berkuasa</li>';
    } else if(finalRisk === 'WASPADA') {
        analysis += '<li style="color: #ea580c; font-weight: bold;">⚠️ Kekal berwaspada</li>';
        analysis += '<li>Pantau tahap air setiap 12-24 jam</li>';
        analysis += '<li>Sediakan pelan kecemasan</li>';
    } else {
        analysis += '<li style="color: #16a34a;">✅ Keadaan selamat</li>';
        analysis += '<li>Teruskan pemantauan rutin</li>';
    }
    analysis += '</ul>';
    
    analysis += '<p><strong>ℹ️ Faktor-faktor yang Mempengaruhi:</strong></p><ul>';
    analysis += '<li>Trend semasa: <strong>' + trend + '</strong></li>';
    analysis += '<li>Kadar hujan: <strong>' + (rainfall > 0 ? rainfall.toFixed(1) + 'mm' : 'Tiada data') + '</strong></li>';
    analysis += '<li>Tahap risiko semasa: <strong>' + currentRisk + '</strong></li>';
    analysis += '<li><em>* Ramalan ini berdasarkan data semasa dan mungkin berubah bergantung kepada cuaca sebenar</em></li>';
    analysis += '</ul>';
    
    document.getElementById('detailedAnalysis').innerHTML = analysis;
}
</script>
<script type="text/javascript">
    // Prevent browser back button navigation
    (function() {
        window.history.pushState(null, null, window.location.href);
        window.onpopstate = function() {
            window.history.pushState(null, null, window.location.href);
        };
    })();
</script>
</body>
</html>