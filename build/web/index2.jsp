<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%@ include file="header.jsp" %>

<style>
/* Tab Styles */
.tabs {
    display: flex;
    background-color: #f1f1f1;
    border-bottom: 2px solid #004080;
    margin-bottom: 20px;
}

.tab-button {
    background-color: #f1f1f1;
    border: none;
    outline: none;
    cursor: pointer;
    padding: 14px 20px;
    font-size: 16px;
    transition: 0.3s;
    border-right: 1px solid #ddd;
}

.tab-button:hover {
    background-color: #ddd;
}

.tab-button.active {
    background-color: #004080;
    color: white;
}

.tab-content {
    display: none;
    padding: 20px;
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
    border: 2px solid #004080;
    border-radius: 5px;
}

.popup-content {
    font-size: 14px;
}

.popup-content h4 {
    margin: 0 0 10px 0;
    color: #004080;
}

.popup-content p {
    margin: 5px 0;
}

.popup-badge {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 3px;
    color: white;
    font-weight: bold;
}

.popup-badge.safe { background-color: #28a745; }
.popup-badge.normal { background-color: #17a2b8; }
.popup-badge.alert { background-color: #ffc107; color: #000; }
.popup-badge.warning { background-color: #fd7e14; }
.popup-badge.danger { background-color: #dc3545; }

/* Graph Styles */
.chart-container {
    margin-bottom: 30px;
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.chart-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 15px;
    color: #004080;
}

.prediction-box {
    background: #f8f9fa;
    border-left: 4px solid #004080;
    padding: 15px;
    margin: 20px 0;
    border-radius: 4px;
}

.prediction-box h3 {
    margin-top: 0;
    color: #004080;
}

.risk-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin-bottom: 30px;
}

.risk-card {
    padding: 20px;
    border-radius: 8px;
    color: white;
    text-align: center;
}

.risk-card h3 {
    margin: 0;
    font-size: 32px;
}

.risk-card p {
    margin: 5px 0 0 0;
}
</style>

<!-- Leaflet CSS for Maps -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

<!-- Chart.js for Graphs -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<div class="container">
    <div class="content">
        <h2>Notifikasi Aras Air dan Hujan Terkini</h2>
        
        <!-- Tabs -->
        <div class="tabs">
            <button class="tab-button active" onclick="openTab(event, 'readings')">Bacaan</button>
            <button class="tab-button" onclick="openTab(event, 'maps')">Peta</button>
            <button class="tab-button" onclick="openTab(event, 'graphs')">Graf & Ramalan</button>
        </div>
        
        <!-- Tab 1: Readings -->
        <div id="readings" class="tab-content active">
            <table class="flood-table">
                <thead>
                    <tr>
                        <th>Stesen</th>
                        <th>Aras Air (m)</th>
                        <th>Hujan (mm)</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    String currentState = "";
                    
                    try {
                        conn = DBConnection.getConnection();
                        stmt = conn.createStatement();
                        rs = stmt.executeQuery("SELECT * FROM readings ORDER BY state, station_name");
                        
                        while(rs.next()) {
                            String state = rs.getString("state");
                            
                            if(!state.equals(currentState)) {
                                currentState = state;
                    %>
                    <tr class="state-header">
                        <td colspan="3">NEGERI: <%= state.toUpperCase() %></td>
                    </tr>
                    <%
                            }
                            
                            String riskLevel = rs.getString("risk_level");
                            String riskClass = "";
                            
                            if("BAHAYA".equals(riskLevel)) riskClass = "danger";
                            else if("AMARAN".equals(riskLevel)) riskClass = "warning";
                            else if("WASPADA".equals(riskLevel)) riskClass = "alert";
                            else if("NORMAL".equals(riskLevel)) riskClass = "normal";
                            else riskClass = "safe";
                            
                            Double waterLevel = rs.getDouble("water_level_m");
                            boolean hasWaterLevel = !rs.wasNull();
                            Double rainfall = rs.getDouble("rainfall_mm");
                            boolean hasRainfall = !rs.wasNull();
                            String trend = rs.getString("trend");
                    %>
                    <tr>
                        <td class="station-name">
                            <a href="#"><%= rs.getString("station_name") %></a>
                        </td>
                        <td class="<%= riskClass %>">
                            <% if(hasWaterLevel) { %>
                                Aras air <strong><%= String.format("%.2f", waterLevel) %>m</strong> 
                                <% if(!"NORMAL".equals(riskLevel) && !"SAFE".equals(riskLevel)) { %>
                                    telah melebihi tahap <strong><%= riskLevel %></strong>
                                <% } else { %>
                                    - <%= riskLevel %>
                                <% } %>
                                <br><strong>Trend: <%= trend %></strong> (Tarikh: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("recorded_date")) %>)
                            <% } else { %>
                                Tiada stesen aras air.
                            <% } %>
                        </td>
                        <td class="rainfall-col">
                            <% if(hasRainfall) { %>
                                Hujan: <strong><%= String.format("%.1f", rainfall) %>mm</strong> berada pada tahap Lebat<br>
                                (Tarikh: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("recorded_date")) %>)
                            <% } else { %>
                                Tiada stesen hujan.
                            <% } %>
                        </td>
                    </tr>
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
                </tbody>
            </table>
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
    <div class="prediction-box" style="margin-bottom: 30px;">
        <h3>🔍 Pilih Stesen untuk Analisis & Ramalan</h3>
        <div style="margin-bottom: 15px;">
            <label for="stationSelector" style="display: block; margin-bottom: 10px; font-weight: bold;">Cari Stesen:</label>
            <input type="text" id="stationSearch" placeholder="Cari nama stesen, lokasi, atau negeri..." 
                   style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; margin-bottom: 10px;">
            
            <select id="stationSelector" style="width: 100%; padding: 10px; font-size: 14px; border: 1px solid #004080; border-radius: 4px;">
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
        <button onclick="analyzePrediction()" style="background: #004080; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%;">
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
    
    <!-- Global Risk Summary (Always Visible) -->
    <div class="prediction-box" style="margin-top: 30px;">
        <h3>📈 Ringkasan Status Keseluruhan</h3>
        <div class="risk-summary">
            <%
            conn = null;
            stmt = null;
            rs = null;
            
            try {
                conn = DBConnection.getConnection();
                stmt = conn.createStatement();
                
                String[] riskLevels = {"BAHAYA", "AMARAN", "WASPADA", "NORMAL", "SAFE"};
                String[] riskColors = {"#dc3545", "#fd7e14", "#ffc107", "#17a2b8", "#28a745"};
                
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

// Initialize Map
// Initialize Map
function initMap() {
    // Center map on Malaysia
    var map = L.map('map').setView([4.2105, 101.9758], 6);
    
    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);
    
    // Debug: Check if we have markers data
    console.log('Markers data:', markersData);
    console.log('Total markers:', markersData.length);
    
    // Add markers from data
    markersData.forEach(function(data) {
        console.log('Adding marker:', data); // Debug each marker
        
        var marker = L.circleMarker([data.lat, data.lon], {
            radius: 8,
            fillColor: data.markerColor,
            color: '#000',
            weight: 1,
            opacity: 1,
            fillOpacity: 0.8
        }).addTo(map);
        
        // Build popup content without template literals (more compatible)
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
        
        popupContent += '<p><em>Kemaskini: ' + data.date + '</em></p>';
        popupContent += '</div>';
        
        marker.bindPopup(popupContent);
    });
    
    // If no markers, show alert
    if(markersData.length === 0) {
        alert('Tiada data koordinat. Sila tambah latitude dan longitude ke dalam bacaan.');
    }
}

// Initialize Charts
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
                    backgroundColor: '#dc3545'
                },
                {
                    label: 'AMARAN',
                    data: <%= amaranData.toString() %>,
                    backgroundColor: '#fd7e14'
                },
                {
                    label: 'WASPADA',
                    data: <%= waspadaData.toString() %>,
                    backgroundColor: '#ffc107'
                },
                {
                    label: 'NORMAL',
                    data: <%= normalData.toString() %>,
                    backgroundColor: '#17a2b8'
                },
                {
                    label: 'SAFE',
                    data: <%= safeData.toString() %>,
                    backgroundColor: '#28a745'
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
                backgroundColor: ['#dc3545', '#28a745', '#6c757d']
            }]
        },
        options: {
            responsive: true
        }
    });
    
    // Chart 3: Rainfall vs Water Level
    var ctx3 = document.getElementById('rainfallWaterChart').getContext('2d');
    new Chart(ctx3, {
        type: 'line',
        data: {
            labels: <%= labels.toString() %>,
            datasets: [
                {
                    label: 'Kadar Hujan (mm)',
                    data: <%= rainfallData.toString() %>,
                    borderColor: '#17a2b8',
                    backgroundColor: 'rgba(23, 162, 184, 0.1)',
                    yAxisID: 'y'
                },
                {
                    label: 'Aras Air (m)',
                    data: <%= waterLevelData.toString() %>,
                    borderColor: '#dc3545',
                    backgroundColor: 'rgba(220, 53, 69, 0.1)',
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

// Search functionality for station selector
document.addEventListener('DOMContentLoaded', function() {
    var searchInput = document.getElementById('stationSearch');
    var stationSelector = document.getElementById('stationSelector');
    
    if(searchInput && stationSelector) {
        searchInput.addEventListener('keyup', function() {
            var filter = this.value.toUpperCase();
            var options = stationSelector.getElementsByTagName('option');
            
            for (var i = 1; i < options.length; i++) {
                var txtValue = options[i].textContent || options[i].innerText;
                if (txtValue.toUpperCase().indexOf(filter) > -1) {
                    options[i].style.display = "";
                } else {
                    options[i].style.display = "none";
                }
            }
        });
    }
});

var predictionChartInstance = null;

function analyzePrediction() {
    var selector = document.getElementById('stationSelector');
    var selectedOption = selector.options[selector.selectedIndex];
    
    if(!selectedOption.value) {
        alert('Sila pilih stesen terlebih dahulu!');
        return;
    }
    
    // Get station data
    var stationName = selectedOption.getAttribute('data-station');
    var location = selectedOption.getAttribute('data-location');
    var state = selectedOption.getAttribute('data-state');
    var currentWaterLevel = parseFloat(selectedOption.getAttribute('data-waterlevel'));
    var rainfall = parseFloat(selectedOption.getAttribute('data-rainfall'));
    var riskLevel = selectedOption.getAttribute('data-risk');
    var trend = selectedOption.getAttribute('data-trend');
    
    // Show analysis section
    document.getElementById('analysisResult').style.display = 'block';
    
    // Display station info
    var stationInfo = '<p><strong>Stesen:</strong> ' + stationName + '</p>';
    stationInfo += '<p><strong>Lokasi:</strong> ' + location + ', ' + state + '</p>';
    stationInfo += '<p><strong>Aras Air Semasa:</strong> ' + currentWaterLevel.toFixed(2) + 'm</p>';
    stationInfo += '<p><strong>Kadar Hujan:</strong> ' + (rainfall > 0 ? rainfall.toFixed(1) + 'mm' : 'Tiada data') + '</p>';
    stationInfo += '<p><strong>Tahap Risiko Semasa:</strong> <span style="color: ' + getRiskColor(riskLevel) + '; font-weight: bold;">' + riskLevel + '</span></p>';
    stationInfo += '<p><strong>Trend:</strong> <span style="font-weight: bold;">' + trend + '</span></p>';
    
    document.getElementById('stationInfo').innerHTML = stationInfo;
    
    // Calculate prediction
    var prediction = calculatePrediction(currentWaterLevel, rainfall, trend, riskLevel);
    
    // Create chart
    createPredictionChart(prediction);
    
    // Display detailed analysis
    displayDetailedAnalysis(prediction, stationName, trend, rainfall, riskLevel);
    
    // Scroll to result
    document.getElementById('analysisResult').scrollIntoView({ behavior: 'smooth' });
}

function calculatePrediction(currentLevel, rainfall, trend, riskLevel) {
    var today = new Date();
    var labels = [];
    var data = [];
    var riskLevels = [];
    
    // Add today's data
    labels.push('Hari Ini');
    data.push(currentLevel);
    riskLevels.push(riskLevel);
    
    // Calculate rate of change based on trend and rainfall
    var baseRate = 0;
    
    if(trend === 'Menaik') {
        baseRate = 0.15; // Increasing 0.15m per day base
        if(rainfall > 40) baseRate = 0.35; // Heavy rain
        else if(rainfall > 20) baseRate = 0.25; // Moderate rain
        else if(rainfall > 10) baseRate = 0.20; // Light rain
    } else if(trend === 'Menurun') {
        baseRate = -0.10; // Decreasing 0.10m per day
        if(rainfall > 30) baseRate = 0.05; // But if heavy rain, might still increase
        else if(rainfall > 15) baseRate = 0.00; // Moderate rain, stable
    } else {
        // Tiada Perubahan
        baseRate = 0.02; // Slight increase
        if(rainfall > 35) baseRate = 0.15; // Heavy rain causes increase
        else if(rainfall > 20) baseRate = 0.08;
        else if(rainfall < 5) baseRate = -0.05; // No rain, level drops
    }
    
    // Predict for next 7 days
    var predictedLevel = currentLevel;
    for(var i = 1; i <= 7; i++) {
        var futureDate = new Date(today);
        futureDate.setDate(today.getDate() + i);
        
        // Add some randomness to make it realistic (±20%)
        var variance = (Math.random() - 0.5) * 0.4 * Math.abs(baseRate);
        var dailyChange = baseRate + variance;
        
        // Decay factor - change rate decreases over time
        var decayFactor = 1 - (i * 0.08);
        if(decayFactor < 0.4) decayFactor = 0.4;
        
        predictedLevel += dailyChange * decayFactor;
        
        // Ensure water level doesn't go negative
        if(predictedLevel < 0) predictedLevel = 0;
        
        labels.push('Hari +' + i);
        data.push(predictedLevel);
        
        // Determine predicted risk level
        var predictedRisk = determineRiskLevel(predictedLevel);
        riskLevels.push(predictedRisk);
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
    if(waterLevel >= 45) return 'BAHAYA';
    if(waterLevel >= 35) return 'AMARAN';
    if(waterLevel >= 25) return 'WASPADA';
    if(waterLevel >= 10) return 'NORMAL';
    return 'SAFE';
}

function getRiskColor(risk) {
    var colors = {
        'BAHAYA': '#dc3545',
        'AMARAN': '#fd7e14',
        'WASPADA': '#ffc107',
        'NORMAL': '#17a2b8',
        'SAFE': '#28a745'
    };
    return colors[risk] || '#6c757d';
}

function createPredictionChart(prediction) {
    var ctx = document.getElementById('predictionChart').getContext('2d');
    
    // Destroy existing chart if exists
    if(predictionChartInstance) {
        predictionChartInstance.destroy();
    }
    
    // Create gradient
    var gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, 'rgba(220, 53, 69, 0.5)');
    gradient.addColorStop(0.5, 'rgba(255, 193, 7, 0.3)');
    gradient.addColorStop(1, 'rgba(40, 167, 69, 0.2)');
    
    // Color points based on risk level
    var pointColors = prediction.riskLevels.map(function(risk) {
        return getRiskColor(risk);
    });
    
    predictionChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: prediction.labels,
            datasets: [{
                label: 'Aras Air (m)',
                data: prediction.data,
                borderColor: '#004080',
                backgroundColor: gradient,
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointRadius: 6,
                pointBackgroundColor: pointColors,
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointHoverRadius: 8
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                },
                tooltip: {
                    callbacks: {
                        afterLabel: function(context) {
                            var risk = prediction.riskLevels[context.dataIndex];
                            return 'Tahap Risiko: ' + risk;
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
                            return value.toFixed(1) + 'm';
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
        analysis += '<li style="color: #dc3545;">⚠️ Aras air dijangka <strong>MENINGKAT</strong> dari ' + 
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
            analysis += '<li style="color: #dc3545; font-weight: bold;">⚠️ Tahap BAHAYA/AMARAN dijangka pada Hari +' + dangerDay + '</li>';
        }
        
    } else if(prediction.trend === 'MENURUN') {
        analysis += '<li style="color: #28a745;">✅ Aras air dijangka <strong>MENURUN</strong> dari ' + 
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
        analysis += '<li style="color: #dc3545; font-weight: bold;">🚨 Bersedia untuk kemungkinan banjir!</li>';
        analysis += '<li>Pindahkan barangan berharga ke tempat tinggi</li>';
        analysis += '<li>Sediakan bekalan makanan dan air</li>';
        analysis += '<li>Pantau kemas kini setiap 6-12 jam</li>';
        analysis += '<li>Ikuti arahan pihak berkuasa</li>';
    } else if(finalRisk === 'WASPADA') {
        analysis += '<li style="color: #fd7e14; font-weight: bold;">⚠️ Kekal berwaspada</li>';
        analysis += '<li>Pantau tahap air setiap 12-24 jam</li>';
        analysis += '<li>Sediakan pelan kecemasan</li>';
    } else {
        analysis += '<li style="color: #28a745;">✅ Keadaan selamat</li>';
        analysis += '<li>Teruskan pemantauan rutin</li>';
    }
    
    analysis += '</ul>';
    
    // Additional factors
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