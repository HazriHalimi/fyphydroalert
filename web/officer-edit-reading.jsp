<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    // Check if officer is logged in
    String officerUsername = (String) session.getAttribute("officerUsername");
    String userType = (String) session.getAttribute("userType");
    Integer officerId = (Integer) session.getAttribute("officerId");
    
    if(officerUsername == null || !"officer".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String officerName = (String) session.getAttribute("officerName");
    String readingIdStr = request.getParameter("id");
    
    if(readingIdStr == null) {
        response.sendRedirect("officer-my-readings.jsp");
        return;
    }
    
    int readingId = Integer.parseInt(readingIdStr);
    
    // Fetch reading data
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String stationName = "";
    String location = "";
    String state = "";
    Double rainfall = null;
    Double waterLevel = null;
    String riskLevel = "";
    String trend = "";
    String notes = "";
    Double latitude = null;
    Double longitude = null;
    
    try {
        conn = DBConnection.getConnection();
        // Get reading only if it belongs to logged-in officer
        String sql = "SELECT * FROM readings WHERE reading_id = ? AND officer_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, readingId);
        pstmt.setInt(2, officerId);
        rs = pstmt.executeQuery();
        
        if(rs.next()) {
            stationName = rs.getString("station_name");
            location = rs.getString("location");
            state = rs.getString("state");
            rainfall = rs.getDouble("rainfall_mm");
            if(rs.wasNull()) rainfall = null;
            waterLevel = rs.getDouble("water_level_m");
            if(rs.wasNull()) waterLevel = null;
            riskLevel = rs.getString("risk_level");
            trend = rs.getString("trend");
            notes = rs.getString("notes");
            if(notes == null) notes = "";
            latitude = rs.getDouble("latitude");
            if(rs.wasNull()) latitude = null;
            longitude = rs.getDouble("longitude");
            if(rs.wasNull()) longitude = null;
        } else {
            response.sendRedirect("officer-my-readings.jsp?error=true");
            return;
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) rs.close();
        if(pstmt != null) pstmt.close();
        if(conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Edit Bacaan - HydroAlert</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Outfit:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/portal.css">
    <style>
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
        .form-row {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }
        .form-row .form-group {
            flex: 1;
            min-width: 200px;
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
        .btn-cancel {
            background: rgba(100,116,139,.08);
            color: var(--muted);
            padding: 10px 24px;
            border-radius: 50px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            transition: var(--tr);
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .btn-cancel:hover {
            background: rgba(100,116,139,.15);
            color: #0f172a;
        }
        .risk-preview {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 800;
            font-size: 10px;
            margin-left: 10px;
            vertical-align: middle;
            text-transform: uppercase;
            letter-spacing: .4px;
        }
        .risk-safe     { background:#dcfce7; color:#166534; border: 1px solid #bbf7d0; }
        .risk-normal   { background:#dbeafe; color:#1e40af; border: 1px solid #bfdbfe; }
        .risk-waspada  { background:#fef9c3; color:#a16207; border: 1px solid #fef08a; }
        .risk-amaran   { background:#ffedd5; color:#c2410c; border: 1px solid #fed7aa; }
        .risk-bahaya   { background:#fee2e2; color:#991b1b; border: 1px solid #fca5a5; }
        .threshold-info {
            background: var(--light);
            border-left: 4px solid var(--teal);
            padding: 12px;
            border-radius: 0 10px 10px 0;
            font-size: 12px;
            color: var(--muted);
            margin-top: 8px;
            border: 1px solid var(--border);
            border-left-width: 4px;
        }
        .threshold-info table { width:100%; border-collapse:collapse; margin-top:6px; }
        .threshold-info td    { padding:3px 0; font-size:11.5px; color:#475569; }
        .threshold-info td:first-child { font-weight: 700; }
        #map {
            width: 100%;
            height: 350px;
            margin-top: 10px;
            border: 1px solid var(--border);
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(18,19,88,.02);
        }
    </style>
</head>
<body>
<div class="app">
<aside class="sidebar">
    <div class="sb-brand"><img src="images/logo.png" alt="HydroAlert" onerror="this.style.display='none'"><div><div class="sb-brand-name">HydroAlert</div><div class="sb-brand-role">Officer Portal</div></div></div>
    <nav class="sb-nav">
        <div class="sb-section">Overview</div>
        <a href="officer-dashboard.jsp" class="sb-link"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>
        <div class="sb-section">Readings</div>
        <a href="officer-add-reading.jsp" class="sb-link"><i class="fa-solid fa-plus-circle"></i> Add Reading</a>
        <a href="officer-my-readings.jsp" class="sb-link active"><i class="fa-solid fa-clipboard-list"></i> My Readings</a>
        <div class="sb-section">Relief Centres</div>
        <a href="officer-center.jsp" class="sb-link"><i class="fa-solid fa-house-chimney"></i> Centre List</a>
        <a href="officer-add-center.jsp" class="sb-link"><i class="fa-solid fa-plus-circle"></i> Add Centre</a>
        <div class="sb-section">Victims</div>
        <a href="officer-victims.jsp" class="sb-link"><i class="fa-solid fa-users"></i> Victims List</a>
        <a href="officer-add-victim.jsp" class="sb-link"><i class="fa-solid fa-user-plus"></i> Register Victim</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">Kemaskini Bacaan</div>
    <div class="topbar-user"><div class="tb-avatar officer"><i class="fa-solid fa-user-shield"></i></div><%= officerName %></div>
</div>
<div class="body-content">
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-pen"></i> Kemaskini Rekod Bacaan Banjir</div>
        <a href="officer-my-readings.jsp" class="btn-cancel" style="padding: 8px 16px;"><i class="fa-solid fa-arrow-left"></i> Kembali</a>
    </div>

    <div class="form-card">
        <form action="UpdateReadingServlet" method="post">
            <input type="hidden" name="readingId" value="<%= readingId %>">
            
            <!-- NAMA STESEN -->
            <div class="form-group">
                <label class="form-label">Nama Stesen *</label>
                <input type="text" name="stationName" class="form-input" value="<%= stationName %>" required placeholder="Taip nama stesen di sini">
            </div>
            
            <!-- LOKASI & NEGERI -->
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Lokasi *</label>
                    <input type="text" id="locationField" name="location" class="form-input" value="<%= location %>" required placeholder="Sila masukkan daerah atau mukim">
                </div>
                <div class="form-group">
                    <label class="form-label">Negeri *</label>
                    <select id="stateField" name="state" class="form-input" required onchange="onStateChange(this.value)">
                        <option value="">-- Pilih Negeri --</option>
                        <option value="Johor" <%= "Johor".equals(state) ? "selected" : "" %>>Johor</option>
                        <option value="Kedah" <%= "Kedah".equals(state) ? "selected" : "" %>>Kedah</option>
                        <option value="Kelantan" <%= "Kelantan".equals(state) ? "selected" : "" %>>Kelantan</option>
                        <option value="Melaka" <%= "Melaka".equals(state) ? "selected" : "" %>>Melaka</option>
                        <option value="Negeri Sembilan" <%= "Negeri Sembilan".equals(state) ? "selected" : "" %>>Negeri Sembilan</option>
                        <option value="Pahang" <%= "Pahang".equals(state) ? "selected" : "" %>>Pahang</option>
                        <option value="Perak" <%= "Perak".equals(state) ? "selected" : "" %>>Perak</option>
                        <option value="Perlis" <%= "Perlis".equals(state) ? "selected" : "" %>>Perlis</option>
                        <option value="Pulau Pinang" <%= "Pulau Pinang".equals(state) ? "selected" : "" %>>Pulau Pinang</option>
                        <option value="Sabah" <%= "Sabah".equals(state) ? "selected" : "" %>>Sabah</option>
                        <option value="Sarawak" <%= "Sarawak".equals(state) ? "selected" : "" %>>Sarawak</option>
                        <option value="Selangor" <%= "Selangor".equals(state) ? "selected" : "" %>>Selangor</option>
                        <option value="Terengganu" <%= "Terengganu".equals(state) ? "selected" : "" %>>Terengganu</option>
                        <option value="Wilayah Persekutuan" <%= "Wilayah Persekutuan".equals(state) ? "selected" : "" %>>Wilayah Persekutuan</option>
                    </select>
                </div>
            </div>
            
            <!-- ARAS AIR & TAHAP RISIKO -->
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Aras Air (m)</label>
                    <input type="number" id="waterLevelInput" name="waterLevel" class="form-input" step="0.01" value="<%= waterLevel != null ? waterLevel : "" %>" placeholder="cth: 2.50" oninput="autoRiskFromWaterLevel(this.value)">
                    <span style="font-size:11px;color:var(--muted);margin-top:2px;">Biarkan kosong jika tiada bacaan aras air</span>
                    <div class="threshold-info">
                        <strong>Had Piawai JPS:</strong>
                        <table>
                            <tr><td>SAFE (Selamat)</td><td>&lt; 1.0 m</td></tr>
                            <tr><td>NORMAL</td><td>1.0 - 2.99 m</td></tr>
                            <tr><td>WASPADA (Alert)</td><td>3.0 - 4.99 m</td></tr>
                            <tr><td>AMARAN (Warning)</td><td>5.0 - 6.99 m</td></tr>
                            <tr><td>BAHAYA (Danger)</td><td>&ge; 7.0 m</td></tr>
                        </table>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">
                        Tahap Risiko *
                        <span id="riskPreviewBadge" class="risk-preview" style="display:none;"></span>
                    </label>
                    <select id="riskLevelSelect" name="riskLevel" class="form-input" required>
                        <option value="">-- Pilih Tahap Risiko --</option>
                        <option value="SAFE" <%= "SAFE".equals(riskLevel) ? "selected" : "" %>>SAFE</option>
                        <option value="NORMAL" <%= "NORMAL".equals(riskLevel) ? "selected" : "" %>>NORMAL</option>
                        <option value="WASPADA" <%= "WASPADA".equals(riskLevel) ? "selected" : "" %>>WASPADA</option>
                        <option value="AMARAN" <%= "AMARAN".equals(riskLevel) ? "selected" : "" %>>AMARAN</option>
                        <option value="BAHAYA" <%= "BAHAYA".equals(riskLevel) ? "selected" : "" %>>BAHAYA</option>
                    </select>
                    <small id="riskAutoNote" style="color:var(--teal);font-size:11px;display:none;margin-top:4px;font-weight:600;">
                        * Diisi automatik mengikut aras air. Anda boleh mengubahnya semula.
                    </small>
                </div>
            </div>
            
            <!-- KADAR HUJAN & TREND ARAS AIR -->
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Kadar Hujan (mm)</label>
                    <input type="number" id="rainfallInput" name="rainfall" class="form-input" step="0.01" value="<%= rainfall != null ? rainfall : "" %>" placeholder="cth: 12.0" oninput="autoTrendFromRainfall(this.value)">
                    <span style="font-size:11px;color:var(--muted);margin-top:2px;">Biarkan kosong jika tiada bacaan kadar hujan</span>
                    <div class="threshold-info">
                        <strong>Klasifikasi Kadar Hujan:</strong>
                        <table>
                            <tr><td>Tiada Perubahan</td><td>0 mm</td></tr>
                            <tr><td>Menurun</td><td>1 - 10 mm</td></tr>
                            <tr><td>Menaik</td><td>&ge; 11 mm</td></tr>
                        </table>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Trend Aras Air *</label>
                    <select id="trendSelect" name="trend" class="form-input" required>
                        <option value="">-- Pilih Trend --</option>
                        <option value="Menaik" <%= "Menaik".equals(trend) ? "selected" : "" %>>Menaik</option>
                        <option value="Menurun" <%= "Menurun".equals(trend) ? "selected" : "" %>>Menurun</option>
                        <option value="Tiada Perubahan" <%= "Tiada Perubahan".equals(trend) ? "selected" : "" %>>Tiada Perubahan</option>
                    </select>
                    <small id="trendAutoNote" style="color:var(--teal);font-size:11px;display:none;margin-top:4px;font-weight:600;">
                        * Diisi automatik mengikut kadar hujan. Anda boleh mengubahnya semula.
                    </small>
                </div>
            </div>
            
            <!-- LATITUD & LONGITUD -->
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Latitud</label>
                    <input type="number" id="latField" name="latitude" class="form-input" step="0.000001" value="<%= latitude != null ? latitude : "" %>" placeholder="cth: 3.139003" oninput="onCoordsInput()">
                    <span style="font-size:11px;color:var(--muted);margin-top:2px;">Diisi automatik jika stesen mempunyai koordinat</span>
                </div>
                <div class="form-group">
                    <label class="form-label">Longitud</label>
                    <input type="number" id="lngField" name="longitude" class="form-input" step="0.000001" value="<%= longitude != null ? longitude : "" %>" placeholder="cth: 101.686855" oninput="onCoordsInput()">
                    <span style="font-size:11px;color:var(--muted);margin-top:2px;">Diisi automatik jika stesen mempunyai koordinat</span>
                </div>
            </div>
            
            <!-- GOOGLE MAPS -->
            <div class="form-group">
                <label class="form-label">Pilih Lokasi Di Atas Peta</label>
                <div id="map"></div>
                <span style="font-size:11px;color:var(--muted);margin-top:4px;">Klik pada mana-mana kawasan peta untuk menetapkan/mengemaskini Latitud dan Longitud stesen</span>
            </div>
            
            <!-- NOTES -->
            <div class="form-group">
                <label class="form-label">Nota / Catatan</label>
                <textarea name="notes" class="form-input" rows="3" placeholder="Maklumat tambahan atau ulasan tentang bacaan stesen..."><%= notes %></textarea>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn-submit"><i class="fa-solid fa-circle-check"></i> Kemaskini Bacaan</button>
                <a href="officer-my-readings.jsp" class="btn-cancel">Batal</a>
            </div>
        </form>
    </div>
</div>
</div>
</div>

<script>
var map;
var marker;

var stateCenters = {
    'Johor': {lat: 1.4854, lng: 103.7618, zoom: 9},
    'Kedah': {lat: 6.1184, lng: 100.3685, zoom: 9},
    'Kelantan': {lat: 6.1254, lng: 102.2382, zoom: 9},
    'Melaka': {lat: 2.1896, lng: 102.2501, zoom: 11},
    'Negeri Sembilan': {lat: 2.7258, lng: 101.9424, zoom: 10},
    'Pahang': {lat: 3.8126, lng: 103.3256, zoom: 8},
    'Perak': {lat: 4.5921, lng: 101.0901, zoom: 9},
    'Perlis': {lat: 6.4449, lng: 100.2048, zoom: 11},
    'Pulau Pinang': {lat: 5.4141, lng: 100.3288, zoom: 11},
    'Sabah': {lat: 5.9788, lng: 116.0753, zoom: 8},
    'Sarawak': {lat: 1.5533, lng: 110.3592, zoom: 8},
    'Selangor': {lat: 3.0738, lng: 101.5183, zoom: 10},
    'Terengganu': {lat: 5.3117, lng: 103.1324, zoom: 9},
    'Wilayah Persekutuan': {lat: 3.1390, lng: 101.6869, zoom: 11}
};

function initMap() {
    var defaultPos = {lat: 4.2105, lng: 101.9758}; // Malaysia center
    map = new google.maps.Map(document.getElementById('map'), {
        zoom: 6,
        center: defaultPos
    });
    
    marker = new google.maps.Marker({
        map: map,
        draggable: true
    });
    
    // Check if initial coordinates already exist in form
    var initialLat = document.getElementById('latField').value;
    var initialLng = document.getElementById('lngField').value;
    if (initialLat && initialLng) {
        var pos = {lat: parseFloat(initialLat), lng: parseFloat(initialLng)};
        marker.setPosition(pos);
        marker.setVisible(true);
        map.setCenter(pos);
        map.setZoom(11);
    } else {
        marker.setVisible(false);
        // Pan to currently selected state if map has no coordinates
        var currentState = document.getElementById('stateField').value;
        if(currentState && stateCenters[currentState]) {
            var sc = stateCenters[currentState];
            map.setCenter({lat: sc.lat, lng: sc.lng});
            map.setZoom(sc.zoom);
        }
    }
    
    // Click on map listener
    map.addListener('click', function(e) {
        var clickedPos = e.latLng;
        marker.setPosition(clickedPos);
        marker.setVisible(true);
        document.getElementById('latField').value = clickedPos.lat().toFixed(6);
        document.getElementById('lngField').value = clickedPos.lng().toFixed(6);
    });
    
    // Drag marker listener
    marker.addListener('dragend', function(e) {
        var pos = marker.getPosition();
        document.getElementById('latField').value = pos.lat().toFixed(6);
        document.getElementById('lngField').value = pos.lng().toFixed(6);
    });
}

function onStateChange(stateName) {
    if (!map || !stateCenters[stateName]) return;
    var center = stateCenters[stateName];
    map.setCenter({lat: center.lat, lng: center.lng});
    map.setZoom(center.zoom);
}

function onCoordsInput() {
    var latVal = document.getElementById('latField').value;
    var lngVal = document.getElementById('lngField').value;
    if (latVal && lngVal && map && marker) {
        var lat = parseFloat(latVal);
        var lng = parseFloat(lngVal);
        if (!isNaN(lat) && !isNaN(lng)) {
            var pos = {lat: lat, lng: lng};
            marker.setPosition(pos);
            marker.setVisible(true);
            map.setCenter(pos);
            map.setZoom(12);
        }
    }
}

function autoRiskFromWaterLevel(val) {
    var riskSel  = document.getElementById('riskLevelSelect');
    var badge    = document.getElementById('riskPreviewBadge');
    var autoNote = document.getElementById('riskAutoNote');
    if(val === '' || isNaN(parseFloat(val))) {
        badge.style.display   = 'none';
        autoNote.style.display = 'none';
        return;
    }
    var wl = parseFloat(val);
    var risk = wl < 1.0 ? 'SAFE' : wl < 3.0 ? 'NORMAL' : wl < 5.0 ? 'WASPADA' : wl < 7.0 ? 'AMARAN' : 'BAHAYA';
    for(var i = 0; i < riskSel.options.length; i++) {
        if(riskSel.options[i].value === risk) { riskSel.selectedIndex = i; break; }
    }
    badge.textContent   = risk;
    badge.className     = 'risk-preview risk-' + risk.toLowerCase();
    badge.style.display = 'inline-block';
    autoNote.style.display = 'block';
}

function autoTrendFromRainfall(val) {
    var trendSel = document.getElementById('trendSelect');
    var autoNote = document.getElementById('trendAutoNote');
    if(val === '' || isNaN(parseFloat(val))) {
        autoNote.style.display = 'none';
        return;
    }
    var rf = parseFloat(val);
    var trend = 'Tiada Perubahan';
    
    if (rf >= 11) {
        trend = 'Menaik';
    } else if (rf >= 1 && rf <= 10) {
        trend = 'Menurun';
    } else {
        trend = 'Tiada Perubahan';
    }
    
    for(var i = 0; i < trendSel.options.length; i++) {
        if(trendSel.options[i].value === trend) { trendSel.selectedIndex = i; break; }
    }
    autoNote.style.display = 'block';
}

document.addEventListener('DOMContentLoaded', function() {
    var initialWl = "<%= waterLevel != null ? waterLevel : "" %>";
    if (initialWl) {
        autoRiskFromWaterLevel(initialWl);
    }
    
    document.getElementById('riskLevelSelect').addEventListener('change', function() {
        var badge = document.getElementById('riskPreviewBadge');
        if(this.value) {
            badge.textContent   = this.value;
            badge.className     = 'risk-preview risk-' + this.value.toLowerCase();
            badge.style.display = 'inline-block';
        } else {
            badge.style.display = 'none';
        }
    });
});
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
<script src="https://maps.googleapis.com/maps/api/js?callback=initMap" async defer></script>
</body>
</html>