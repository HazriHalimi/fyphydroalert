<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%
    // Check if admin is logged in
    String adminUsername = (String) session.getAttribute("adminUsername");
    String userType = (String) session.getAttribute("userType");
    
    if(adminUsername == null || !"admin".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String adminName = (String) session.getAttribute("adminName");
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Hantar Amaran - HydroAlert</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Outfit:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/portal.css">
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* ===== FORM CARD ===== */
        .form-card {
            background: var(--white);
            border-radius: 18px;
            border: 1px solid var(--border);
            box-shadow: 0 6px 22px rgba(18,19,88,.04);
            padding: 30px;
            max-width: 900px;
            margin: 0 auto;
        }
        .form-group {
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .form-label {
            font-size: 11px;
            font-weight: 700;
            color: var(--navy);
            text-transform: uppercase;
            letter-spacing: .5px;
        }
        .form-input {
            padding: 10px 14px;
            border: 1px solid var(--border);
            border-radius: 9px;
            font-size: 13px;
            color: #0f172a;
            background: var(--light);
            font-family: 'Inter', sans-serif;
            transition: var(--tr);
            width: 100%;
        }
        .form-input:focus {
            outline: none;
            border-color: var(--teal);
            background: #fff;
            box-shadow: 0 0 0 3px rgba(54,173,163,.12);
        }
        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 24px;
        }
        .btn-submit {
            background: linear-gradient(135deg, var(--teal), #2b948a);
            color: #fff;
            padding: 10px 24px;
            border: none;
            border-radius: 50px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: var(--tr);
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(54,173,163,.25);
        }

        /* ===== ADMIN SIDEBAR ===== */
        .sidebar.admin-sb {
            background: linear-gradient(180deg, #0a0726 0%, #14134a 50%, #1a1960 100%);
        }

        /* ===== TABS ===== */
        .alert-tabs {
            display: flex;
            gap: 6px;
            margin-bottom: 24px;
            background: var(--white);
            padding: 8px 10px;
            border-radius: 14px;
            border: 1px solid var(--border);
            box-shadow: 0 4px 12px rgba(18,19,88,.04);
        }
        .alert-tab-btn {
            padding: 9px 20px;
            border: none;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            background: transparent;
            color: var(--muted);
            font-family: 'Inter', sans-serif;
            transition: var(--tr);
            display: flex;
            align-items: center;
            gap: 7px;
        }
        .alert-tab-btn:hover {
            background: var(--light);
            color: var(--navy);
        }
        .alert-tab-btn.active {
            background: var(--navy);
            color: #fff;
        }
        .alert-tab-content { display: none; }
        .alert-tab-content.active { display: block; animation: fadeIn .35s; }
        @keyframes fadeIn { from { opacity:0; transform:translateY(6px); } to { opacity:1; transform:translateY(0); } }

        /* ===== MAP ===== */
        #alertMap {
            height: 520px;
            width: 100%;
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: 0 8px 24px rgba(18,19,88,.06);
        }
        .map-legend {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            margin-top: 14px;
            padding: 14px 18px;
            background: var(--white);
            border-radius: 12px;
            border: 1px solid var(--border);
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 600;
            color: var(--navy);
        }
        .legend-dot {
            width: 12px; height: 12px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        /* ===== CHART ===== */
        .chart-wrap {
            background: var(--white);
            border-radius: 18px;
            border: 1px solid var(--border);
            box-shadow: 0 6px 22px rgba(18,19,88,.04);
            padding: 26px 30px;
        }
        .chart-wrap + .chart-wrap { margin-top: 20px; }
        .chart-title {
            font-family: 'Outfit', sans-serif;
            font-size: 16px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .chart-title i { color: var(--teal); }
        .risk-summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 14px;
            margin-bottom: 24px;
        }
        .risk-card {
            border-radius: 14px;
            padding: 20px 16px;
            text-align: center;
            color: #fff;
            box-shadow: 0 4px 14px rgba(0,0,0,.08);
        }
        .risk-card .risk-num {
            font-family: 'Outfit', sans-serif;
            font-size: 36px;
            font-weight: 800;
            line-height: 1;
        }
        .risk-card .risk-lbl {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .6px;
            margin-top: 6px;
            opacity: .9;
        }
        .two-charts {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 20px;
        }
        @media(max-width:768px){.two-charts{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<div class="app">

<!-- ===== SIDEBAR ===== -->
<aside class="sidebar admin-sb">
    <div class="sb-brand"><img src="images/logo.png" alt="HydroAlert" onerror="this.style.display='none'"><div><div class="sb-brand-name">HydroAlert</div><div class="sb-brand-role">Admin Portal</div></div></div>
    <nav class="sb-nav">
        <div class="sb-section">Overview</div>
        <a href="admin-dashboard.jsp" class="sb-link"><i class="fa-solid fa-house"></i> Dashboard</a>
        <div class="sb-section">Management</div>
        <a href="admin-officers.jsp" class="sb-link"><i class="fa-solid fa-user-shield"></i> Manage Officers</a>
        <a href="admin-readings.jsp" class="sb-link"><i class="fa-solid fa-chart-column"></i> View Readings</a>
        <a href="admin-users.jsp" class="sb-link"><i class="fa-solid fa-users"></i> Manage Users</a>
        <div class="sb-section">Alerts</div>
        <a href="admin-alerts.jsp" class="sb-link active"><i class="fa-solid fa-bell"></i> Send Alerts</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>

<!-- ===== MAIN ===== -->
<div class="main">
<div class="topbar">
    <div class="topbar-title">Alert Management</div>
    <div class="topbar-user"><div class="tb-avatar admin"><i class="fa-solid fa-crown"></i></div><%= adminName %></div>
</div>
<div class="body-content">

    <!-- Page Header -->
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-bell"></i> Pengurusan Amaran Banjir</div>
        <a href="admin-dashboard.jsp" class="btn-reset" style="padding: 8px 16px;"><i class="fa-solid fa-arrow-left"></i> Kembali</a>
    </div>

    <!-- Alerts -->
    <% if(request.getParameter("success") != null) { %>
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check"></i>
            Amaran e-mel berjaya dihantar kepada <%= request.getParameter("count") %> pengguna!
        </div>
    <% } %>
    <% if(request.getParameter("error") != null) { %>
        <div class="alert alert-error">
            <i class="fa-solid fa-circle-xmark"></i>
            Gagal menghantar amaran e-mel. Sila cuba lagi.
        </div>
    <% } %>

    <!-- ===== TABS ===== -->
    <div class="alert-tabs">
        <button class="alert-tab-btn active" onclick="switchTab('tab-table', this)"><i class="fa-solid fa-table"></i> Bacaan Kritikal</button>
        <button class="alert-tab-btn" onclick="switchTab('tab-map', this)"><i class="fa-solid fa-map-location-dot"></i> Peta</button>
        <button class="alert-tab-btn" onclick="switchTab('tab-graph', this)"><i class="fa-solid fa-chart-bar"></i> Graf</button>
        <button class="alert-tab-btn" onclick="switchTab('tab-send', this)"><i class="fa-solid fa-paper-plane"></i> Hantar Amaran</button>
    </div>

    <%
    // ---- Shared DB query for critical readings ----
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    // Collect all readings for map & chart
    List<Map<String,Object>> allReadings = new ArrayList<Map<String,Object>>();
    int cntBahaya = 0, cntAmaran = 0, cntWaspada = 0, cntNormal = 0, cntSafe = 0;

    // Map: state -> count of readings
    Map<String,int[]> stateRiskMap = new LinkedHashMap<String,int[]>(); // [BAHAYA,AMARAN,WASPADA,NORMAL,SAFE]

    try {
        conn = DBConnection.getConnection();
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT r.* FROM readings r INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest ON r.reading_id = latest.max_id ORDER BY CASE r.risk_level WHEN 'BAHAYA' THEN 1 WHEN 'AMARAN' THEN 2 WHEN 'WASPADA' THEN 3 WHEN 'NORMAL' THEN 4 ELSE 5 END, r.state");
        while(rs.next()) {
            Map<String,Object> row = new HashMap<String,Object>();
            row.put("station_name", rs.getString("station_name"));
            row.put("location", rs.getString("location"));
            row.put("state", rs.getString("state"));
            row.put("risk_level", rs.getString("risk_level"));
            row.put("trend", rs.getString("trend"));
            double wlV = rs.getDouble("water_level_m"); row.put("water_level_m", rs.wasNull()?null:wlV);
            double rfV = rs.getDouble("rainfall_mm");   row.put("rainfall_mm",   rs.wasNull()?null:rfV);
            row.put("recorded_date", rs.getTimestamp("recorded_date"));
            double latV = rs.getDouble("latitude");  row.put("latitude",  rs.wasNull()?null:latV);
            double lonV = rs.getDouble("longitude"); row.put("longitude", rs.wasNull()?null:lonV);
            allReadings.add(row);

            String rl = rs.getString("risk_level");
            if("BAHAYA".equals(rl)) cntBahaya++;
            else if("AMARAN".equals(rl)) cntAmaran++;
            else if("WASPADA".equals(rl)) cntWaspada++;
            else if("NORMAL".equals(rl)) cntNormal++;
            else cntSafe++;

            String st = rs.getString("state");
            if(!stateRiskMap.containsKey(st)) stateRiskMap.put(st, new int[]{0,0,0,0,0});
            int[] arr = stateRiskMap.get(st);
            if("BAHAYA".equals(rl)) arr[0]++;
            else if("AMARAN".equals(rl)) arr[1]++;
            else if("WASPADA".equals(rl)) arr[2]++;
            else if("NORMAL".equals(rl)) arr[3]++;
            else arr[4]++;
        }
    } catch(Exception e) { e.printStackTrace(); }
    finally { if(rs!=null) rs.close(); if(stmt!=null) stmt.close(); if(conn!=null) conn.close(); }

    // Build markers JSON for Leaflet
    StringBuilder markersJson = new StringBuilder("[");
    boolean firstM = true;
    for(Map<String,Object> row : allReadings) {
        Double lat = (Double) row.get("latitude");
        Double lon = (Double) row.get("longitude");
        if(lat == null || lon == null) continue;
        if(!firstM) markersJson.append(",");
        firstM = false;
        String rl = (String) row.get("risk_level");
        String mc = "green";
        if("BAHAYA".equals(rl)) mc = "red";
        else if("AMARAN".equals(rl)) mc = "orange";
        else if("WASPADA".equals(rl)) mc = "yellow";
        else if("NORMAL".equals(rl)) mc = "blue";
        String sName = ((String)row.get("station_name")).replace("'","\'").replace("\"","\\\"");
        String loc   = ((String)row.get("location")).replace("'","\'").replace("\"","\\\"");
        String st    = ((String)row.get("state")).replace("'","\'").replace("\"","\\\"");
        String wlStr = row.get("water_level_m")!=null ? String.format("%.2f", (Double)row.get("water_level_m")) : "N/A";
        String rfStr = row.get("rainfall_mm")!=null   ? String.format("%.1f",  (Double)row.get("rainfall_mm"))  : "N/A";
        markersJson.append("{\"lat\":").append(lat)
            .append(",\"lon\":").append(lon)
            .append(",\"station\":\"").append(sName).append("\"")
            .append(",\"location\":\"").append(loc).append("\"")
            .append(",\"state\":\"").append(st).append("\"")
            .append(",\"risk\":\"").append(rl).append("\"")
            .append(",\"mc\":\"").append(mc).append("\"")
            .append(",\"wl\":\"").append(wlStr).append("\"")
            .append(",\"rf\":\"").append(rfStr).append("\"")
            .append("}");
    }
    markersJson.append("]");

    // Critical-only list for table tab
    List<Map<String,Object>> criticalList = new ArrayList<Map<String,Object>>();
    for(Map<String,Object> row : allReadings) {
        String rl = (String) row.get("risk_level");
        if("BAHAYA".equals(rl) || "AMARAN".equals(rl)) criticalList.add(row);
    }
    %>

    <!-- ===== TAB 1: CRITICAL READINGS TABLE ===== -->
    <div id="tab-table" class="alert-tab-content active">
        <div class="data-card">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Stesen</th>
                        <th>Lokasi / Kawasan</th>
                        <th>Negeri</th>
                        <th>Aras Air</th>
                        <th>Hujan</th>
                        <th>Trend</th>
                        <th>Tahap Risiko</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(criticalList.isEmpty()) { %>
                    <tr>
                        <td colspan="7" style="text-align:center;padding:40px;color:var(--muted);">
                            <i class="fa-solid fa-circle-check" style="color:#16a34a;font-size:22px;margin-right:8px;"></i>
                            Tiada stesen dalam amaran kritikal pada masa ini.
                        </td>
                    </tr>
                    <% } else {
                        for(Map<String,Object> r : criticalList) {
                            String rl = (String)r.get("risk_level");
                            String badgeClass = "BAHAYA".equals(rl) ? "badge-bahaya" : "badge-amaran";
                            String tr = (String)r.get("trend");
                            String tiCls = "fa-minus", tiCol = "#64748b";
                            if("Menaik".equals(tr)) { tiCls = "fa-arrow-trend-up"; tiCol = "#dc2626"; }
                            else if("Menurun".equals(tr)) { tiCls = "fa-arrow-trend-down"; tiCol = "#16a34a"; }
                    %>
                    <tr>
                        <td><strong><%= r.get("station_name") %></strong></td>
                        <td><%= r.get("location") %></td>
                        <td><%= r.get("state") %></td>
                        <td style="font-weight:700;color:var(--teal);"><i class="fa-solid fa-droplet"></i>
                            <%= r.get("water_level_m")!=null ? String.format("%.2f",(Double)r.get("water_level_m"))+" m" : "N/A" %></td>
                        <td style="font-weight:700;color:#2F578A;"><i class="fa-solid fa-cloud-rain"></i>
                            <%= r.get("rainfall_mm")!=null ? String.format("%.1f",(Double)r.get("rainfall_mm"))+" mm" : "N/A" %></td>
                        <td style="font-size:12px;color:<%= tiCol %>;font-weight:700;"><i class="fa-solid <%= tiCls %>"></i> <%= tr!=null?tr:"-" %></td>
                        <td><span class="badge <%= badgeClass %>"><%= rl %></span></td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ===== TAB 2: MAP ===== -->
    <div id="tab-map" class="alert-tab-content">
        <div id="alertMap"></div>
        <div class="map-legend">
            <div class="legend-item"><div class="legend-dot" style="background:#e11d48;"></div> BAHAYA</div>
            <div class="legend-item"><div class="legend-dot" style="background:#ea580c;"></div> AMARAN</div>
            <div class="legend-item"><div class="legend-dot" style="background:#d97706;"></div> WASPADA</div>
            <div class="legend-item"><div class="legend-dot" style="background:#0284c7;"></div> NORMAL</div>
            <div class="legend-item"><div class="legend-dot" style="background:#16a34a;"></div> SAFE</div>
            <div style="margin-left:auto;font-size:12px;color:var(--muted);">
                <i class="fa-solid fa-circle-info"></i> Klik pada marker untuk maklumat stesen
            </div>
        </div>
    </div>

    <!-- ===== TAB 3: GRAPH ===== -->
    <div id="tab-graph" class="alert-tab-content">
        <!-- Risk Summary Cards -->
        <div class="risk-summary-grid">
            <% if(cntBahaya > 0) { %>
            <div class="risk-card" style="background:#e11d48;">
                <div class="risk-num"><%= cntBahaya %></div>
                <div class="risk-lbl">BAHAYA</div>
            </div>
            <% } if(cntAmaran > 0) { %>
            <div class="risk-card" style="background:#ea580c;">
                <div class="risk-num"><%= cntAmaran %></div>
                <div class="risk-lbl">AMARAN</div>
            </div>
            <% } if(cntWaspada > 0) { %>
            <div class="risk-card" style="background:#d97706;">
                <div class="risk-num"><%= cntWaspada %></div>
                <div class="risk-lbl">WASPADA</div>
            </div>
            <% } if(cntNormal > 0) { %>
            <div class="risk-card" style="background:#0284c7;">
                <div class="risk-num"><%= cntNormal %></div>
                <div class="risk-lbl">NORMAL</div>
            </div>
            <% } if(cntSafe > 0) { %>
            <div class="risk-card" style="background:#16a34a;">
                <div class="risk-num"><%= cntSafe %></div>
                <div class="risk-lbl">SAFE</div>
            </div>
            <% } %>
        </div>

        <div class="two-charts">
            <!-- Stacked Bar: Risk by State -->
            <div class="chart-wrap">
                <div class="chart-title"><i class="fa-solid fa-chart-bar"></i> Status Risiko Mengikut Negeri</div>
                <canvas id="stateRiskChart"></canvas>
            </div>
            <!-- Doughnut: Overall Distribution -->
            <div class="chart-wrap">
                <div class="chart-title"><i class="fa-solid fa-chart-pie"></i> Taburan Tahap Risiko</div>
                <canvas id="riskDoughnut"></canvas>
            </div>
        </div>
    </div>

    <!-- ===== TAB 4: SEND ALERT FORM ===== -->
    <div id="tab-send" class="alert-tab-content">
        <div class="form-card">
            <form action="SendAlertServlet" method="post">
                <div class="sec-title" style="margin-bottom:18px;font-size:15px;border-bottom:1px solid var(--border);padding-bottom:10px;">
                    <i class="fa-solid fa-paper-plane"></i> Tetapan Amaran E-mel
                </div>
                
                <div class="form-group">
                    <label class="form-label">Pilih Negeri Pengguna</label>
                    <select name="state" class="form-input" required>
                        <option value="">-- Pilih Negeri --</option>
                        <option value="ALL">Semua Negeri (Hantar kepada Semua Pengguna)</option>
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
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Subjek Amaran E-mel *</label>
                    <input type="text" name="subject" class="form-input" value="HydroAlert: Flood Warning Notification" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Mesej Amaran *</label>
                    <textarea name="message" class="form-input" rows="8" required placeholder="Taip mesej amaran anda di sini...">Dear User,

This is an urgent flood alert notification from HydroAlert System.

Critical flood warnings have been issued for your area. Please check the latest updates on our website and take necessary precautions.

Stay safe!

HydroAlert Team</textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn-submit" onclick="return confirm('Adakah anda pasti mahu menghantar amaran e-mel ini kepada semua pelanggan?')">
                        <i class="fa-solid fa-paper-plane"></i> Hantar Amaran E-mel
                    </button>
                </div>
            </form>
        </div>
    </div>

</div><!-- /body-content -->
</div><!-- /main -->
</div><!-- /app -->

<!-- ===== Leaflet JS ===== -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
// ---- Tab switching ----
function switchTab(id, btn) {
    document.querySelectorAll('.alert-tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.alert-tab-btn').forEach(el => el.classList.remove('active'));
    document.getElementById(id).classList.add('active');
    btn.classList.add('active');

    if(id === 'tab-map' && !window._mapInit) initMap();
    if(id === 'tab-graph' && !window._chartInit) initCharts();
}

// ---- Map ----
var markersData = <%= markersJson.toString() %>;

function getRiskColor(risk) {
    if(risk==='BAHAYA')  return '#e11d48';
    if(risk==='AMARAN')  return '#ea580c';
    if(risk==='WASPADA') return '#d97706';
    if(risk==='NORMAL')  return '#0284c7';
    return '#16a34a';
}

function initMap() {
    window._mapInit = true;
    var map = L.map('alertMap').setView([4.2105, 108.9758], 6);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    markersData.forEach(function(m) {
        var color = getRiskColor(m.risk);
        var icon = L.divIcon({
            className: '',
            html: '<div style="width:14px;height:14px;background:' + color + ';border:2px solid #fff;border-radius:50%;box-shadow:0 2px 6px rgba(0,0,0,.4);"></div>',
            iconSize: [14, 14],
            iconAnchor: [7, 7]
        });
        var popup = '<div style="font-family:Inter,sans-serif;font-size:13px;min-width:200px;">'
            + '<div style="font-family:Outfit,sans-serif;font-weight:800;font-size:15px;color:#232F72;margin-bottom:6px;">' + m.station + '</div>'
            + '<p style="margin:3px 0;color:#64748b;"><i class="fa-solid fa-location-dot" style="color:#e11d48;margin-right:4px;"></i>' + m.location + ', ' + m.state + '</p>'
            + '<p style="margin:3px 0;"><i class="fa-solid fa-droplet" style="color:#36ADA3;margin-right:4px;"></i><strong>Aras Air:</strong> ' + m.wl + ' m</p>'
            + '<p style="margin:3px 0;"><i class="fa-solid fa-cloud-rain" style="color:#2F578A;margin-right:4px;"></i><strong>Hujan:</strong> ' + m.rf + ' mm</p>'
            + '<span style="background:' + color + ';color:#fff;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:800;">' + m.risk + '</span>'
            + '</div>';
        L.marker([m.lat, m.lon], { icon: icon }).addTo(map).bindPopup(popup);
    });

    // Fit bounds if markers exist
    if(markersData.length > 0) {
        var latlngs = markersData.map(m => [m.lat, m.lon]);
        map.fitBounds(latlngs, { padding: [40, 40] });
    }
}

// ---- Charts ----
<%
// Build JS arrays for chart data
StringBuilder stateLabels = new StringBuilder("[");
StringBuilder bahayaData  = new StringBuilder("[");
StringBuilder amaranData  = new StringBuilder("[");
StringBuilder waspadaData = new StringBuilder("[");
StringBuilder normalData  = new StringBuilder("[");
StringBuilder safeData    = new StringBuilder("[");
boolean fst = true;
for(Map.Entry<String,int[]> e : stateRiskMap.entrySet()) {
    String comma = fst ? "" : ",";
    stateLabels.append(comma).append("\"").append(e.getKey()).append("\"");
    bahayaData.append(comma).append(e.getValue()[0]);
    amaranData.append(comma).append(e.getValue()[1]);
    waspadaData.append(comma).append(e.getValue()[2]);
    normalData.append(comma).append(e.getValue()[3]);
    safeData.append(comma).append(e.getValue()[4]);
    fst = false;
}
stateLabels.append("]"); bahayaData.append("]"); amaranData.append("]"); waspadaData.append("]"); normalData.append("]"); safeData.append("]");
%>

function initCharts() {
    window._chartInit = true;

    var stateLabels = <%= stateLabels %>;
    var bahayaData  = <%= bahayaData %>;
    var amaranData  = <%= amaranData %>;
    var waspadaData = <%= waspadaData %>;
    var normalData  = <%= normalData %>;
    var safeData    = <%= safeData %>;

    // Stacked bar chart
    new Chart(document.getElementById('stateRiskChart'), {
        type: 'bar',
        data: {
            labels: stateLabels,
            datasets: [
                { label:'BAHAYA',  data:bahayaData,  backgroundColor:'#e11d48' },
                { label:'AMARAN',  data:amaranData,  backgroundColor:'#ea580c' },
                { label:'WASPADA', data:waspadaData, backgroundColor:'#d97706' },
                { label:'NORMAL',  data:normalData,  backgroundColor:'#0284c7' },
                { label:'SAFE',    data:safeData,    backgroundColor:'#16a34a' }
            ]
        },
        options: {
            responsive: true,
            plugins: { legend: { position:'bottom' } },
            scales: {
                x: { stacked:true, ticks: { font:{size:11} } },
                y: { stacked:true, beginAtZero:true, ticks:{ stepSize:1 } }
            }
        }
    });

    // Doughnut chart
    new Chart(document.getElementById('riskDoughnut'), {
        type: 'doughnut',
        data: {
            labels: ['BAHAYA', 'AMARAN', 'WASPADA', 'NORMAL', 'SAFE'],
            datasets: [{
                data: [<%= cntBahaya %>, <%= cntAmaran %>, <%= cntWaspada %>, <%= cntNormal %>, <%= cntSafe %>],
                backgroundColor: ['#e11d48','#ea580c','#d97706','#0284c7','#16a34a'],
                borderWidth: 3,
                borderColor: '#fff'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { position:'bottom', labels:{ font:{size:12}, padding:12 } }
            },
            cutout: '60%'
        }
    });
}
</script>
<!-- Bootstrap 5 JS Bundle & Sidebar Toggle Script -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        var topbar = document.querySelector('.topbar');
        var sidebar = document.querySelector('.sidebar');
        if (topbar && sidebar) {
            var toggleBtn = document.createElement('button');
            toggleBtn.className = 'btn btn-link text-dark p-0 me-3 d-lg-none';
            toggleBtn.style.fontSize = '24px';
            toggleBtn.style.lineHeight = '1';
            toggleBtn.style.textDecoration = 'none';
            toggleBtn.innerHTML = '<i class="fa-solid fa-bars"></i>';
            topbar.insertBefore(toggleBtn, topbar.firstChild);
            
            toggleBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                sidebar.classList.toggle('show-sidebar');
            });
            
            document.addEventListener('click', function(event) {
                if (!sidebar.contains(event.target) && !toggleBtn.contains(event.target)) {
                    sidebar.classList.remove('show-sidebar');
                }
            });
        }
    });
</script>
</body>
</html>