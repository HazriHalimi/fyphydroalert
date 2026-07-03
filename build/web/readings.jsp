<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%@ include file="header.jsp" %>

<style>
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
}

.content {
    background-color: transparent;
    padding: 0;
}

.content h2 {
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

/* Semak Status Banner */
.semak-banner {
    background: linear-gradient(135deg, var(--teal), #2b948a);
    color: white;
    padding: 18px 24px;
    margin-bottom: 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 15px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.semak-banner strong {
    font-size: 16px;
}

.semak-banner a.btn-semak {
    background: white;
    color: var(--deep-blue);
    padding: 10px 24px;
    border-radius: 30px;
    text-decoration: none;
    font-weight: 700;
    font-size: 14px;
    transition: var(--transition);
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

.semak-banner a.btn-semak:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 15px rgba(0,0,0,0.15);
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

/* Category card active styling */
.filter-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 20px rgba(18, 19, 88, 0.06) !important;
}

.filter-card.active {
    border-color: var(--teal) !important;
    box-shadow: 0 10px 20px rgba(54, 173, 163, 0.15) !important;
    transform: scale(1.02);
}

/* Station card hover style */
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
        countRs = countStmt.executeQuery("SELECT risk_level, COUNT(*) as qty FROM readings GROUP BY risk_level");
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
        if(countRs != null) countRs.close();
        if(countStmt != null) countStmt.close();
        if(countConn != null) countConn.close();
    }
%>

<div class="container">
    <div class="content">
        <h2>Notifikasi Aras Air & Kadar Hujan Terkini</h2>
        
        <!-- Semak Status Banner -->
        <div class="semak-banner">
            <div>
                <strong>🔍 Adakah anda mangsa banjir?</strong>
                <span style="font-size:13px; margin-left:8px; opacity:0.95;">Semak status pendaftaran dan lokasi pusat pemindahan anda di sini.</span>
            </div>
            <a href="semak-status.jsp" class="btn-semak">
                Semak Status Saya →
            </a>
        </div>

        <!-- Tabs -->
        <div class="tabs">
            <button class="tab-button active" onclick="openTab(event, 'readings')">Bacaan</button>
            <button class="tab-button" onclick="openTab(event, 'maps')">Peta</button>
            <button class="tab-button" onclick="openTab(event, 'graphs')">Graf & Ramalan</button>
        </div>
        
        <!-- Tab 1: Readings -->
        <div id="readings" class="tab-content active">
            <!-- Search bar pill -->
            <div style="max-width: 600px; margin: 30px auto 40px auto; position: relative;">
                <div style="display: flex; background: var(--white); border-radius: 50px; padding: 6px 10px; box-shadow: 0 10px 30px rgba(18, 19, 88, 0.08); border: 1px solid rgba(18, 19, 88, 0.05); align-items: center;">
                    <span style="font-size: 20px; margin-left: 15px; color: var(--text-light);">🔍</span>
                    <input type="text" id="stationSearch" placeholder="Cari stesen, lokasi, atau negeri..." 
                           style="flex: 1; border: none; outline: none; padding: 12px 15px; font-size: 16px; background: transparent; color: var(--text-dark); font-family: 'Inter', sans-serif;">
                </div>
            </div>

            <!-- Category Filters -->
            <div class="category-filters-container" style="display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin-bottom: 40px;">
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
                Map<String, List<Map<String, Object>>> stateReadings = new LinkedHashMap<String, List<Map<String, Object>>>();
                
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DBConnection.getConnection();
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery(
                        "SELECT * FROM readings " +
                        "ORDER BY state ASC, recorded_date DESC"
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
                        
                        if(!stateReadings.containsKey(state)) {
                            stateReadings.put(state, new ArrayList<Map<String, Object>>());
                        }
                        stateReadings.get(state).add(reading);
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(rs != null) rs.close();
                    if(stmt != null) stmt.close();
                    if(conn != null) conn.close();
                }
                
                // Iterate through grouped states
                for(Map.Entry<String, List<Map<String, Object>>> entry : stateReadings.entrySet()) {
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
                            String dateStr = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(recordedDate);
                            
                            // Setup status badge classes & translations
                            String statusText = rl;
                            String badgeBgColor = "#e2e8f0";
                            String textThemeColor = "#475569";
                            String badgeBorder = "1px solid #cbd5e1";
                            
                            if("BAHAYA".equals(rl)) {
                                badgeBgColor = "#fee2e2";
                                textThemeColor = "#991b1b";
                                badgeBorder = "1px solid #fca5a5";
                            } else if("AMARAN".equals(rl)) {
                                badgeBgColor = "#ffedd5";
                                textThemeColor = "#c2410c";
                                badgeBorder = "1px solid #fed7aa";
                            } else if("WASPADA".equals(rl)) {
                                badgeBgColor = "#fef9c3";
                                textThemeColor = "#a16207";
                                badgeBorder = "1px solid #fef08a";
                            } else if("NORMAL".equals(rl)) {
                                badgeBgColor = "#e0f2fe";
                                textThemeColor = "#0369a1";
                                badgeBorder = "1px solid #bae6fd";
                            } else if("SAFE".equals(rl)) {
                                badgeBgColor = "#dcfce7";
                                textThemeColor = "#166534";
                                badgeBorder = "1px solid #bbf7d0";
                            }
                            
                            // Setup trend indicators
                            String trendIcon = "➔";
                            String trendText = tr;
                            String trendColor = "#64748b";
                            if("Menaik".equals(tr)) {
                                trendIcon = "▲";
                                trendColor = "#dc2626";
                            } else if("Menurun".equals(tr)) {
                                trendIcon = "▼";
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
                                <h4 style="font-size: 18px; font-weight: 700; color: var(--navy-blue); margin: 0; font-family: 'Outfit', sans-serif;"><%= sName %></h4>
                                <p style="font-size: 13px; color: var(--text-light); margin: 0; display: flex; align-items: center; gap: 6px;">
                                    <span style="font-size: 14px;">📍</span> <%= loc %>, <%= stateName %>
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
        conn = null;
        stmt = null;
        rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM readings WHERE latitude IS NOT NULL AND longitude IS NOT NULL");
            
            boolean firstMarker = true;
            while(rs.next()) {
                if(!firstMarker) markersJson.append(",");
                firstMarker = false;
                
                double lat = rs.getDouble("latitude");
                double lon = rs.getDouble("longitude");
                String stationName = rs.getString("station_name").replace("'", "\\'").replace("\"", "\\\"");
                String location = rs.getString("location").replace("'", "\\'").replace("\"", "\\\"");
                String state = rs.getString("state").replace("'", "\\'").replace("\"", "\\\"");
                String riskLevel = rs.getString("risk_level");
                String trend = rs.getString("trend");
                
                Double waterLevel = rs.getDouble("water_level_m");
                boolean hasWaterLevel = !rs.wasNull();
                Double rainfall = rs.getDouble("rainfall_mm");
                boolean hasRainfall = !rs.wasNull();
                
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
                String dateStr = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("recorded_date"));
                
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
            if(rs != null) rs.close();
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
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
                        conn = null;
                        stmt = null;
                        rs = null;
                        
                        try {
                            conn = DBConnection.getConnection();
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT reading_id, station_name, location, state, water_level_m, rainfall_mm, risk_level, trend FROM readings WHERE water_level_m IS NOT NULL ORDER BY state, station_name");
                            
                            while(rs.next()) {
                                int readingId = rs.getInt("reading_id");
                                String stationName = rs.getString("station_name");
                                String location = rs.getString("location");
                                String state = rs.getString("state");
                                Double waterLevel = rs.getDouble("water_level_m");
                                Double rainfall = rs.getDouble("rainfall_mm");
                                boolean hasRainfall = !rs.wasNull();
                                String riskLevel = rs.getString("risk_level");
                                String trend = rs.getString("trend");
                                
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
                            if(rs != null) rs.close();
                            if(stmt != null) stmt.close();
                            if(conn != null) conn.close();
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
                    conn = null;
                    stmt = null;
                    rs = null;
                    
                    try {
                        conn = DBConnection.getConnection();
                        stmt = conn.createStatement();
                        
                        String[] riskLevels = {"BAHAYA", "AMARAN", "WASPADA", "NORMAL", "SAFE"};
                        String[] riskColors = {"#e11d48", "#ea580c", "#d97706", "#0284c7", "#16a34a"};
                        
                        for(int i = 0; i < riskLevels.length; i++) {
                            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM readings WHERE risk_level = '" + riskLevels[i] + "'");
                            if(rs.next()) {
                                int count = rs.getInt("count");
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
                        if(rs != null) rs.close();
                        if(stmt != null) stmt.close();
                        if(conn != null) conn.close();
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
    </div>
</div>

<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<%
// Prepare all chart data in JSP before JavaScript starts
// Chart 1 data
conn = null;
stmt = null;
rs = null;

Map<String, Map<String, Integer>> stateRiskData = new LinkedHashMap<String, Map<String, Integer>>();

try {
    conn = DBConnection.getConnection();
    stmt = conn.createStatement();
    rs = stmt.executeQuery("SELECT state, risk_level, COUNT(*) as count FROM readings GROUP BY state, risk_level ORDER BY state");
    
    while(rs.next()) {
        String state = rs.getString("state");
        String risk = rs.getString("risk_level");
        int count = rs.getInt("count");
        
        if(!stateRiskData.containsKey(state)) {
            stateRiskData.put(state, new LinkedHashMap<String, Integer>());
        }
        stateRiskData.get(state).put(risk, count);
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) rs.close();
    if(stmt != null) stmt.close();
    if(conn != null) conn.close();
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
conn = null;
stmt = null;
rs = null;

int menaik = 0, menurun = 0, tiada = 0;

try {
    conn = DBConnection.getConnection();
    stmt = conn.createStatement();
    
    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM readings WHERE trend = 'Menaik'");
    if(rs.next()) menaik = rs.getInt("count");
    
    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM readings WHERE trend = 'Menurun'");
    if(rs.next()) menurun = rs.getInt("count");
    
    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM readings WHERE trend = 'Tiada Perubahan'");
    if(rs.next()) tiada = rs.getInt("count");
    
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) rs.close();
    if(stmt != null) stmt.close();
    if(conn != null) conn.close();
}

// Chart 3 data
conn = null;
stmt = null;
rs = null;

StringBuilder rainfallData = new StringBuilder("[");
StringBuilder waterLevelData = new StringBuilder("[");
StringBuilder labels = new StringBuilder("[");

try {
    conn = DBConnection.getConnection();
    stmt = conn.createStatement();
    rs = stmt.executeQuery("SELECT station_name, rainfall_mm, water_level_m FROM readings WHERE rainfall_mm IS NOT NULL AND water_level_m IS NOT NULL LIMIT 15");
    
    boolean firstItem = true;
    while(rs.next()) {
        if(!firstItem) {
            rainfallData.append(",");
            waterLevelData.append(",");
            labels.append(",");
        }
        firstItem = false;
        
        String shortName = rs.getString("station_name");
        if(shortName.length() > 20) shortName = shortName.substring(0, 17) + "...";
        
        labels.append("'").append(shortName.replace("'", "\\'")).append("'");
        rainfallData.append(rs.getDouble("rainfall_mm"));
        waterLevelData.append(rs.getDouble("water_level_m"));
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) rs.close();
    if(stmt != null) stmt.close();
    if(conn != null) conn.close();
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

</body>
</html>