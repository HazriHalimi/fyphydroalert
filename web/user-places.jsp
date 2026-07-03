<%@ page import="java.sql.*, util.DBConnection, java.text.SimpleDateFormat, java.util.*" %>
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
    
    // Pre-fetch station data for cards, map, and charts
    int totalStations = 0;
    String highestRisk = "SAFE";
    int highestRiskPriority = 99;
    
    List<Map<String,String>> stationList = new ArrayList<>();
    
    Connection connData = null;
    PreparedStatement pstmtData = null;
    ResultSet rsData = null;
    
    try {
        connData = DBConnection.getConnection();
        String sqlData = "SELECT r.* FROM readings r INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest ON r.reading_id = latest.max_id WHERE r.state = ? ORDER BY CASE r.risk_level WHEN 'BAHAYA' THEN 1 WHEN 'AMARAN' THEN 2 WHEN 'WASPADA' THEN 3 WHEN 'NORMAL' THEN 4 WHEN 'SAFE' THEN 5 ELSE 6 END, r.station_name";
        pstmtData = connData.prepareStatement(sqlData);
        pstmtData.setString(1, userLocation);
        rsData = pstmtData.executeQuery();
        
        while(rsData.next()) {
            totalStations++;
            Map<String,String> s = new HashMap<>();
            s.put("readingId", String.valueOf(rsData.getInt("reading_id")));
            s.put("stationName", rsData.getString("station_name"));
            s.put("location", rsData.getString("location"));
            s.put("state", rsData.getString("state"));
            String rl = rsData.getString("risk_level");
            s.put("riskLevel", rl != null ? rl : "SAFE");
            s.put("trend", rsData.getString("trend"));
            double wl = rsData.getDouble("water_level_m");
            s.put("waterLevel", rsData.wasNull() ? "" : String.format("%.2f", wl));
            double rf = rsData.getDouble("rainfall_mm");
            s.put("rainfall", rsData.wasNull() ? "" : String.format("%.1f", rf));
            double lat = rsData.getDouble("latitude");
            s.put("latitude", rsData.wasNull() ? "" : String.valueOf(lat));
            double lng = rsData.getDouble("longitude");
            s.put("longitude", rsData.wasNull() ? "" : String.valueOf(lng));
            Timestamp ts = rsData.getTimestamp("recorded_date");
            s.put("recordedDate", ts != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(ts) : "");
            s.put("notes", rsData.getString("notes") != null ? rsData.getString("notes") : "");
            stationList.add(s);
            
            int rp = 99;
            if("BAHAYA".equals(rl)) rp = 1;
            else if("AMARAN".equals(rl)) rp = 2;
            else if("WASPADA".equals(rl)) rp = 3;
            else if("NORMAL".equals(rl)) rp = 4;
            else if("SAFE".equals(rl)) rp = 5;
            if(rp < highestRiskPriority) { highestRiskPriority = rp; highestRisk = rl; }
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rsData != null) rsData.close();
        if(pstmtData != null) pstmtData.close();
        if(connData != null) connData.close();
    }
    
    // Pre-fetch historical data for charts (last 7 readings per station)
    Map<String, List<Map<String,String>>> historyMap = new HashMap<>();
    Connection connHist = null;
    PreparedStatement pstmtHist = null;
    ResultSet rsHist = null;
    try {
        connHist = DBConnection.getConnection();
        for(Map<String,String> st : stationList) {
            String stName = st.get("stationName");
            String sqlHist = "SELECT water_level_m, rainfall_mm, recorded_date FROM readings WHERE station_name = ? AND state = ? ORDER BY recorded_date DESC LIMIT 7";
            pstmtHist = connHist.prepareStatement(sqlHist);
            pstmtHist.setString(1, stName);
            pstmtHist.setString(2, userLocation);
            rsHist = pstmtHist.executeQuery();
            List<Map<String,String>> points = new ArrayList<>();
            while(rsHist.next()) {
                Map<String,String> p = new HashMap<>();
                double wlH = rsHist.getDouble("water_level_m");
                p.put("wl", rsHist.wasNull() ? "null" : String.format("%.2f", wlH));
                double rfH = rsHist.getDouble("rainfall_mm");
                p.put("rf", rsHist.wasNull() ? "null" : String.format("%.1f", rfH));
                Timestamp tsH = rsHist.getTimestamp("recorded_date");
                p.put("date", tsH != null ? new SimpleDateFormat("dd/MM HH:mm").format(tsH) : "");
                points.add(p);
            }
            Collections.reverse(points);
            historyMap.put(stName, points);
            rsHist.close();
            pstmtHist.close();
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(connHist != null) connHist.close();
    }
    
    // Greeting based on time of day
    int hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);
    String greeting = hour < 12 ? "Selamat Pagi" : hour < 18 ? "Selamat Petang" : "Selamat Malam";
    String greetIcon = hour < 12 ? "<i class='fa-solid fa-sun' style='color:#fbbf24;'></i>" : hour < 18 ? "<i class='fa-solid fa-cloud-sun' style='color:#f59e0b;'></i>" : "<i class='fa-solid fa-moon' style='color:#a78bfa;'></i>";
    String nowFormatted = new SimpleDateFormat("dd MMMM yyyy • hh:mm a").format(new java.util.Date());
    
    // Risk display helpers
    String hrText = "Normal";
    String hrColor = "#16a34a";
    String hrBg = "#dcfce7";
    String hrBorder = "#bbf7d0";
    String hrIcon = "<i class='fa-solid fa-circle' style='color:#16a34a;font-size:12px;'></i>";
    if("BAHAYA".equals(highestRisk)) { hrText = "Bahaya"; hrColor = "#991b1b"; hrBg = "#fee2e2"; hrBorder = "#fca5a5"; hrIcon = "<i class='fa-solid fa-circle' style='color:#ef4444;font-size:12px;'></i>"; }
    else if("AMARAN".equals(highestRisk)) { hrText = "Amaran"; hrColor = "#c2410c"; hrBg = "#ffedd5"; hrBorder = "#fed7aa"; hrIcon = "<i class='fa-solid fa-circle' style='color:#f97316;font-size:12px;'></i>"; }
    else if("WASPADA".equals(highestRisk)) { hrText = "Waspada"; hrColor = "#a16207"; hrBg = "#fef9c3"; hrBorder = "#fef08a"; hrIcon = "<i class='fa-solid fa-circle' style='color:#eab308;font-size:12px;'></i>"; }
    else if("NORMAL".equals(highestRisk)) { hrText = "Normal"; hrColor = "#1e40af"; hrBg = "#dbeafe"; hrBorder = "#bfdbfe"; hrIcon = "<i class='fa-solid fa-circle' style='color:#3b82f6;font-size:12px;'></i>"; }
%>
<%@ include file="header.jsp" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<link rel="stylesheet" href="https://unpkg.com/aos@2.3.4/dist/aos.css"/>
<style>
/* ============================================
   HYDROALERT USER PLACES – PREMIUM DASHBOARD
   ============================================ */

.up-wrapper { max-width:1280px; margin:0 auto; padding:24px 20px 80px; }

/* ── HERO HEADER ── */
.up-hero {
    background: linear-gradient(135deg, #0d0e45 0%, #121358 40%, #232F72 70%, #2F578A 100%);
    border-radius: 22px;
    padding: 36px 40px;
    color: #fff;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 24px;
    margin-bottom: 28px;
    box-shadow: 0 16px 48px rgba(18,19,88,.18);
    border: 1px solid rgba(255,255,255,.06);
    position: relative;
    overflow: hidden;
}
.up-hero::before {
    content: '';
    position: absolute;
    width: 400px; height: 400px;
    background: radial-gradient(circle, rgba(54,173,163,.12) 0%, transparent 70%);
    top: -160px; right: -80px;
    pointer-events: none;
}
.up-hero-left { flex:1; min-width:300px; }
.up-hero-greeting { font-size:13px; color:rgba(255,255,255,.55); font-weight:600; letter-spacing:.5px; text-transform:uppercase; margin-bottom:6px; }
.up-hero-name { font-family:'Outfit',sans-serif; font-size:28px; font-weight:800; letter-spacing:-.5px; margin-bottom:4px; }
.up-hero-email { font-size:13px; color:rgba(255,255,255,.5); margin-bottom:0; }
.up-hero-right { display:flex; gap:20px; flex-wrap:wrap; }
.up-hero-stat {
    background: rgba(255,255,255,.07);
    border: 1px solid rgba(255,255,255,.1);
    border-radius: 14px;
    padding: 14px 20px;
    min-width: 155px;
    backdrop-filter: blur(6px);
}
.up-hero-stat-label { font-size:10px; color:rgba(255,255,255,.45); font-weight:700; text-transform:uppercase; letter-spacing:.6px; margin-bottom:4px; }
.up-hero-stat-value { font-family:'Outfit',sans-serif; font-size:16px; font-weight:700; }

/* ── SUMMARY CARDS ── */
.up-summary { display:grid; grid-template-columns:repeat(4,1fr); gap:18px; margin-bottom:28px; }
.up-scard {
    background: #fff;
    border-radius: 18px;
    border: 1px solid #e2e8f0;
    padding: 22px 24px;
    box-shadow: 0 4px 16px rgba(18,19,88,.03);
    transition: all .3s cubic-bezier(.4,0,.2,1);
    position: relative;
    overflow: hidden;
}
.up-scard:hover { transform:translateY(-3px); box-shadow:0 12px 32px rgba(18,19,88,.07); }
.up-scard-icon { width:42px; height:42px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:18px; margin-bottom:14px; }
.up-scard-label { font-size:11px; color:#64748b; font-weight:700; text-transform:uppercase; letter-spacing:.5px; margin-bottom:4px; }
.up-scard-value { font-family:'Outfit',sans-serif; font-size:22px; font-weight:800; color:#0f172a; }
.up-scard-sub { font-size:11px; color:#94a3b8; margin-top:4px; }

/* ── EMAIL SUBSCRIPTION ── */
.up-sub-card {
    background: #fff;
    border-radius: 18px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 6px 22px rgba(18,19,88,.03);
    padding: 28px 30px;
    margin-bottom: 28px;
    display: flex;
    align-items: flex-start;
    gap: 24px;
    flex-wrap: wrap;
    transition: all .3s cubic-bezier(.4,0,.2,1);
}
.up-sub-card:hover { box-shadow:0 12px 36px rgba(18,19,88,.06); }
.up-sub-left { flex:1; min-width:300px; }
.up-sub-title { font-family:'Outfit',sans-serif; font-size:18px; font-weight:700; color:#0f172a; margin-bottom:14px; display:flex; align-items:center; gap:8px; }
.up-sub-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(180px,1fr)); gap:12px; margin-bottom:18px; }
.up-sub-item-label { font-size:10px; color:#94a3b8; font-weight:700; text-transform:uppercase; letter-spacing:.5px; }
.up-sub-item-value { font-size:14px; font-weight:700; color:#0f172a; margin-top:2px; }
.up-sub-right { display:flex; flex-direction:column; gap:8px; align-items:flex-end; }
.up-badge-active { display:inline-flex; align-items:center; gap:5px; padding:5px 14px; border-radius:20px; font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.4px; }
.up-badge-active.on  { background:rgba(22,163,74,.1); color:#16a34a; }
.up-badge-active.off { background:rgba(225,29,72,.08); color:#e11d48; }

.btn-sub-action {
    padding: 10px 24px;
    border: none;
    border-radius: 50px;
    font-size: 13px;
    font-weight: 700;
    font-family: 'Outfit', sans-serif;
    cursor: pointer;
    transition: all .3s cubic-bezier(.4,0,.2,1);
}
.btn-sub-action.btn-sub {
    background: linear-gradient(135deg, #36ADA3, #2b948a);
    color: white;
    box-shadow: 0 6px 18px rgba(54,173,163,.25);
}
.btn-sub-action.btn-sub:hover { transform:translateY(-1px); box-shadow:0 10px 22px rgba(54,173,163,.35); }
.btn-sub-action.btn-unsub { background:rgba(225,29,72,.08); color:#e11d48; }
.btn-sub-action.btn-unsub:hover { background:#e11d48; color:#fff; box-shadow:0 6px 18px rgba(225,29,72,.2); }

/* ── ALERTS ── */
.up-alert-toast {
    border-radius:14px;
    padding:14px 20px;
    margin-bottom:20px;
    font-size:13px;
    font-weight:600;
    display:flex;
    align-items:center;
    gap:8px;
    animation: fadeInDown .4s ease;
}
.up-alert-toast.success { background:rgba(22,163,74,.08); color:#16a34a; border:1px solid rgba(22,163,74,.15); }
.up-alert-toast.info    { background:rgba(59,130,246,.08); color:#2563eb; border:1px solid rgba(59,130,246,.15); }

/* ── MAP ── */
.up-map-card {
    background: #fff;
    border-radius: 18px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 6px 22px rgba(18,19,88,.03);
    padding: 0;
    margin-bottom: 28px;
    overflow: hidden;
}
.up-map-header {
    padding: 20px 26px;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    gap: 8px;
    font-family: 'Outfit',sans-serif;
    font-size: 17px;
    font-weight: 700;
    color: #0f172a;
}
#stationMap { width:100%; height:380px; }

/* ── SEARCH & FILTER ── */
.up-filter-bar {
    background: #fff;
    border-radius: 18px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 16px rgba(18,19,88,.03);
    padding: 18px 24px;
    margin-bottom: 22px;
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    align-items: center;
}
.up-filter-bar input,
.up-filter-bar select {
    padding: 9px 14px;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    font-size: 13px;
    font-family: 'Inter',sans-serif;
    color: #0f172a;
    background: #f8fafc;
    transition: all .25s;
    min-width: 160px;
}
.up-filter-bar input:focus,
.up-filter-bar select:focus { outline:none; border-color:#36ADA3; box-shadow:0 0 0 3px rgba(54,173,163,.1); background:#fff; }
.up-filter-bar .btn-reset {
    padding:9px 18px;
    background:rgba(100,116,139,.08);
    border:none;
    border-radius:10px;
    font-size:12px;
    font-weight:700;
    color:#64748b;
    cursor:pointer;
    transition:all .25s;
}
.up-filter-bar .btn-reset:hover { background:rgba(100,116,139,.15); color:#0f172a; }

/* ── STATION CARDS ── */
.up-stations-grid { display:flex; flex-direction:column; gap:16px; margin-bottom:28px; }
.up-station-card {
    background: #fff;
    border-radius: 18px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 16px rgba(18,19,88,.03);
    padding: 0;
    overflow: hidden;
    transition: all .3s cubic-bezier(.4,0,.2,1);
}
.up-station-card:hover { box-shadow:0 12px 36px rgba(18,19,88,.07); transform:translateY(-2px); }
.up-station-body {
    display: flex;
    align-items: stretch;
    gap: 0;
    flex-wrap: wrap;
}
.up-station-left {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 22px 24px;
    flex: 1;
    min-width: 260px;
}
.up-station-thumb {
    width: 64px; height: 64px;
    border-radius: 14px;
    background: linear-gradient(135deg, #e0f2fe, #bae6fd);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 26px;
    flex-shrink: 0;
}
.up-station-info h4 { font-family:'Outfit',sans-serif; font-size:15px; font-weight:700; color:#0f172a; margin:0 0 3px; }
.up-station-info .up-station-addr { font-size:12px; color:#64748b; margin:0 0 2px; }
.up-station-info .up-station-id   { font-size:10px; color:#94a3b8; font-weight:600; }

.up-station-center {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 22px 20px;
    flex-shrink: 0;
}
.up-metric-box { text-align:center; min-width:80px; }
.up-metric-label { font-size:10px; color:#94a3b8; font-weight:700; text-transform:uppercase; letter-spacing:.4px; }
.up-metric-val   { font-family:'Outfit',sans-serif; font-size:18px; font-weight:800; margin-top:2px; }
.up-metric-val.wl { color:#36ADA3; }
.up-metric-val.rf { color:#2F578A; }
.up-progress-bar { width:80px; height:5px; background:#e2e8f0; border-radius:3px; margin:6px auto 0; overflow:hidden; }
.up-progress-fill { height:100%; border-radius:3px; transition:width .6s ease; }

.up-station-right {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    justify-content: center;
    gap: 10px;
    padding: 22px 24px;
    flex-shrink: 0;
    min-width: 180px;
}
.up-risk-badge {
    display:inline-block;
    padding:5px 14px;
    border-radius:20px;
    font-size:11px;
    font-weight:800;
    text-transform:uppercase;
    letter-spacing:.4px;
}
.up-risk-badge.bahaya  { background:#fee2e2; color:#991b1b; border:1px solid #fca5a5; }
.up-risk-badge.amaran  { background:#ffedd5; color:#c2410c; border:1px solid #fed7aa; }
.up-risk-badge.waspada { background:#fef9c3; color:#a16207; border:1px solid #fef08a; }
.up-risk-badge.normal  { background:#dbeafe; color:#1e40af; border:1px solid #bfdbfe; }
.up-risk-badge.safe    { background:#dcfce7; color:#166534; border:1px solid #bbf7d0; }

.up-trend-pill {
    font-size:11px; font-weight:700;
    padding:3px 10px; border-radius:6px;
    display:inline-flex; align-items:center; gap:4px;
}
.up-trend-pill.up   { color:#dc2626; background:#fee2e2; }
.up-trend-pill.down { color:#16a34a; background:#dcfce7; }
.up-trend-pill.flat { color:#64748b; background:#f1f5f9; }

.up-station-ts { font-size:10px; color:#94a3b8; }
.up-station-actions { display:flex; gap:6px; }
.up-btn-action {
    padding:6px 12px;
    border:none;
    border-radius:8px;
    font-size:11px;
    font-weight:700;
    cursor:pointer;
    transition:all .25s;
    display:inline-flex;
    align-items:center;
    gap:4px;
}
.up-btn-action.details { background:rgba(54,173,163,.08); color:#36ADA3; }
.up-btn-action.details:hover { background:#36ADA3; color:#fff; }
.up-btn-action.graph   { background:rgba(47,87,138,.08); color:#2F578A; }
.up-btn-action.graph:hover   { background:#2F578A; color:#fff; }
.up-btn-action.map-btn { background:rgba(18,19,88,.06); color:#232F72; }
.up-btn-action.map-btn:hover { background:#232F72; color:#fff; }

/* ── RECOMMENDATION ── */
.up-recommend {
    border-radius: 12px;
    padding: 12px 20px;
    font-size: 12px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 8px;
    border-top: 1px solid #e2e8f0;
}
.up-recommend.safe    { background:#f0fdf4; color:#166534; }
.up-recommend.normal  { background:#eff6ff; color:#1e40af; }
.up-recommend.waspada { background:#fefce8; color:#a16207; }
.up-recommend.amaran  { background:#fff7ed; color:#c2410c; }
.up-recommend.bahaya  { background:#fef2f2; color:#991b1b; }

/* ── MODAL ── */
.up-modal-overlay {
    display:none;
    position:fixed;
    inset:0;
    background:rgba(0,0,0,.45);
    z-index:2000;
    align-items:center;
    justify-content:center;
    backdrop-filter:blur(4px);
}
.up-modal-overlay.active { display:flex; }
.up-modal {
    background:#fff;
    border-radius:22px;
    width:90%;
    max-width:600px;
    max-height:85vh;
    overflow-y:auto;
    box-shadow:0 30px 80px rgba(0,0,0,.2);
    padding:32px;
    animation:modalIn .3s ease;
}
@keyframes modalIn { from { opacity:0; transform:scale(.95) translateY(10px); } to { opacity:1; transform:scale(1) translateY(0); } }
.up-modal-title { font-family:'Outfit',sans-serif; font-size:20px; font-weight:800; color:#0f172a; margin-bottom:20px; display:flex; align-items:center; gap:8px; }
.up-modal-close {
    position:absolute; top:16px; right:20px;
    background:rgba(100,116,139,.08); border:none; border-radius:50%;
    width:34px; height:34px; cursor:pointer; font-size:16px; color:#64748b;
    transition:all .25s;
}
.up-modal-close:hover { background:rgba(100,116,139,.15); color:#0f172a; }
.up-modal-row { display:flex; gap:12px; margin-bottom:12px; flex-wrap:wrap; }
.up-modal-field { flex:1; min-width:140px; }
.up-modal-field-label { font-size:10px; color:#94a3b8; font-weight:700; text-transform:uppercase; letter-spacing:.5px; }
.up-modal-field-value { font-size:14px; font-weight:700; color:#0f172a; margin-top:2px; }

/* ── GRAPH MODAL ── */
.up-graph-modal { max-width:700px; }
.up-graph-canvas { width:100%!important; height:280px!important; margin-top:16px; }

/* ── SECTIONS ── */
.up-section-title {
    font-family:'Outfit',sans-serif;
    font-size:18px;
    font-weight:700;
    color:#0f172a;
    margin-bottom:18px;
    display:flex;
    align-items:center;
    gap:8px;
}

/* ── TIMELINE ── */
.up-timeline { margin-bottom:28px; }
.up-tl-item {
    display:flex;
    gap:14px;
    padding:12px 0;
    border-bottom:1px solid #f1f5f9;
}
.up-tl-dot {
    width:10px; height:10px;
    border-radius:50%;
    background:#36ADA3;
    margin-top:5px;
    flex-shrink:0;
    box-shadow:0 0 0 4px rgba(54,173,163,.15);
}
.up-tl-time { font-size:10px; color:#94a3b8; font-weight:600; text-transform:uppercase; }
.up-tl-text { font-size:13px; color:#334155; font-weight:500; margin-top:2px; }

/* ── EMERGENCY CONTACTS ── */
.up-emergency-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:14px; margin-bottom:28px; }
.up-emergency-card {
    background:#fff;
    border-radius:14px;
    border:1px solid #e2e8f0;
    padding:18px;
    text-align:center;
    transition:all .3s;
    box-shadow:0 2px 8px rgba(18,19,88,.02);
}
.up-emergency-card:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(18,19,88,.06); }
.up-emergency-icon { font-size:28px; margin-bottom:8px; }
.up-emergency-name { font-family:'Outfit',sans-serif; font-size:14px; font-weight:700; color:#0f172a; margin-bottom:4px; }
.up-emergency-num  { font-size:13px; color:#36ADA3; font-weight:800; }
.up-emergency-btn {
    margin-top:10px;
    padding:7px 16px;
    background:linear-gradient(135deg,#36ADA3,#2b948a);
    color:#fff;
    border:none;
    border-radius:50px;
    font-size:11px;
    font-weight:700;
    cursor:pointer;
    text-decoration:none;
    display:inline-block;
    transition:all .25s;
}
.up-emergency-btn:hover { transform:translateY(-1px); box-shadow:0 6px 16px rgba(54,173,163,.3); color:#fff; }

/* ── SAFETY TIPS ── */
.up-tips-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:18px; margin-bottom:28px; }
.up-tip-card {
    background:#fff;
    border-radius:18px;
    border:1px solid #e2e8f0;
    padding:24px;
    box-shadow:0 4px 16px rgba(18,19,88,.03);
    transition:all .3s;
}
.up-tip-card:hover { transform:translateY(-2px); box-shadow:0 10px 28px rgba(18,19,88,.06); }
.up-tip-icon { font-size:32px; margin-bottom:12px; }
.up-tip-title { font-family:'Outfit',sans-serif; font-size:15px; font-weight:700; color:#0f172a; margin-bottom:10px; }
.up-tip-list { list-style:none; padding:0; margin:0; }
.up-tip-list li { font-size:12px; color:#475569; padding:4px 0; display:flex; align-items:flex-start; gap:6px; }
.up-tip-list li::before { content:'✓'; color:#36ADA3; font-weight:800; flex-shrink:0; }

/* ── EMPTY STATE ── */
.up-empty { text-align:center; padding:60px 20px; color:#94a3b8; }
.up-empty i { font-size:48px; margin-bottom:14px; display:block; color:#cbd5e1; }
.up-empty p { font-size:14px; }

/* ── RESPONSIVE ── */
@media(max-width:1024px) {
    .up-summary { grid-template-columns:repeat(2,1fr); }
    .up-tips-grid { grid-template-columns:repeat(2,1fr); }
}
@media(max-width:768px) {
    .up-hero { padding:24px; }
    .up-hero-name { font-size:22px; }
    .up-summary { grid-template-columns:1fr; }
    .up-station-body { flex-direction:column; }
    .up-station-right { align-items:flex-start; flex-direction:row; flex-wrap:wrap; }
    .up-tips-grid { grid-template-columns:1fr; }
    .up-filter-bar { flex-direction:column; }
    .up-filter-bar input, .up-filter-bar select { width:100%; }
}

@keyframes fadeInDown { from { opacity:0; transform:translateY(-10px); } to { opacity:1; transform:translateY(0); } }
@keyframes fadeInUp   { from { opacity:0; transform:translateY(10px); }  to { opacity:1; transform:translateY(0); } }
@keyframes countUp    { from { opacity:0; } to { opacity:1; } }
</style>

<div class="up-wrapper">

    <!-- ═══════════ HERO HEADER ═══════════ -->
    <div class="up-hero" data-aos="fade-down">
        <div class="up-hero-left">
            <div class="up-hero-greeting"><%= greetIcon %> <%= greeting %></div>
            <h1 class="up-hero-name"><%= userEmail %></h1>
            <p class="up-hero-email"><i class="fa-solid fa-envelope"></i> <%= userEmail %></p>
        </div>
        <div class="up-hero-right">
            <div class="up-hero-stat">
                <div class="up-hero-stat-label">Kawasan Pemantauan</div>
                <div class="up-hero-stat-value"><i class="fa-solid fa-map-location-dot"></i> <%= userLocation %></div>
            </div>
            <div class="up-hero-stat">
                <div class="up-hero-stat-label">Risiko Semasa</div>
                <div class="up-hero-stat-value"><%= hrIcon %> <%= hrText %></div>
            </div>
            <div class="up-hero-stat">
                <div class="up-hero-stat-label">Tarikh & Masa</div>
                <div class="up-hero-stat-value" style="font-size:13px;"><%= nowFormatted %></div>
            </div>
        </div>
    </div>

    <!-- ═══════════ ALERTS ═══════════ -->
    <% if(request.getParameter("subscribed") != null) { %>
        <div class="up-alert-toast success"><i class="fa-solid fa-circle-check"></i> Berjaya melanggan notifikasi amaran e-mel!</div>
    <% } %>
    <% if(request.getParameter("unsubscribed") != null) { %>
        <div class="up-alert-toast info"><i class="fa-solid fa-circle-info"></i> Berjaya membatalkan langganan notifikasi amaran e-mel.</div>
    <% } %>

    <!-- ═══════════ SUMMARY CARDS ═══════════ -->
    <div class="up-summary" data-aos="fade-up" data-aos-delay="100">
        <div class="up-scard">
            <div class="up-scard-icon" style="background:rgba(54,173,163,.1);color:#36ADA3;"><i class="fa-solid fa-map-location-dot"></i></div>
            <div class="up-scard-label">Negeri Pemantauan</div>
            <div class="up-scard-value"><%= userLocation %></div>
        </div>
        <div class="up-scard">
            <div class="up-scard-icon" style="background:rgba(47,87,138,.1);color:#2F578A;"><i class="fa-solid fa-tower-broadcast"></i></div>
            <div class="up-scard-label">Jumlah Stesen</div>
            <div class="up-scard-value" id="counterStations"><%= totalStations %></div>
            <div class="up-scard-sub">Stesen aktif</div>
        </div>
        <div class="up-scard">
            <div class="up-scard-icon" style="background:<%= hrBg %>;color:<%= hrColor %>;"><i class="fa-solid fa-triangle-exclamation"></i></div>
            <div class="up-scard-label">Risiko Tertinggi</div>
            <div class="up-scard-value" style="color:<%= hrColor %>"><%= hrText %></div>
        </div>
        <div class="up-scard">
            <div class="up-scard-icon" style="background:rgba(99,102,241,.1);color:#6366f1;"><i class="fa-solid fa-envelope-circle-check"></i></div>
            <div class="up-scard-label">Notifikasi E-mel</div>
            <div class="up-scard-value" style="color:<%= isSubscribed ? "#16a34a" : "#e11d48" %>"><%= isSubscribed ? "Aktif" : "Tidak Aktif" %></div>
        </div>
    </div>

    <!-- ═══════════ EMAIL SUBSCRIPTION ═══════════ -->
    <div class="up-sub-card" data-aos="fade-up" data-aos-delay="150">
        <div class="up-sub-left">
            <div class="up-sub-title"><i class="fa-solid fa-bell"></i> Tetapan Notifikasi E-mel</div>
            <div class="up-sub-grid">
                <div>
                    <div class="up-sub-item-label">Status</div>
                    <div class="up-sub-item-value">
                        <% if(isSubscribed) { %>
                            <span class="up-badge-active on"><i class="fa-solid fa-circle" style="font-size:7px;"></i> Aktif</span>
                        <% } else { %>
                            <span class="up-badge-active off"><i class="fa-solid fa-circle" style="font-size:7px;"></i> Tidak Aktif</span>
                        <% } %>
                    </div>
                </div>
                <div>
                    <div class="up-sub-item-label">Kawasan Pemantauan</div>
                    <div class="up-sub-item-value"><%= userLocation %></div>
                </div>
                <div>
                    <div class="up-sub-item-label">Jenis Notifikasi</div>
                    <div class="up-sub-item-value">Masa Nyata</div>
                </div>
            </div>
            <p style="font-size:12px;color:#94a3b8;margin:0;">Terima e-mel makluman segera apabila aras risiko stesen di kawasan pilihan anda bertukar.</p>
        </div>
        <div class="up-sub-right">
            <% if(isSubscribed) { %>
                <form action="ToggleSubscriptionServlet" method="post" style="display: inline;">
                    <input type="hidden" name="action" value="unsubscribe">
                    <button type="submit" class="btn-sub-action btn-unsub" onclick="return confirm('Adakah anda pasti mahu membatalkan langganan?')"><i class="fa-solid fa-bell-slash"></i> Batal Langganan</button>
                </form>
            <% } else { %>
                <form action="ToggleSubscriptionServlet" method="post" style="display: inline;">
                    <input type="hidden" name="action" value="subscribe">
                    <button type="submit" class="btn-sub-action btn-sub"><i class="fa-solid fa-bell"></i> Langgan Notifikasi</button>
                </form>
            <% } %>
        </div>
    </div>

    <!-- ═══════════ INTERACTIVE MAP ═══════════ -->
    <div class="up-map-card" data-aos="fade-up" data-aos-delay="200">
        <div class="up-map-header"><i class="fa-solid fa-map-location-dot"></i> Peta Stesen Pemantauan</div>
        <div id="stationMap"></div>
    </div>

    <!-- ═══════════ SEARCH & FILTER ═══════════ -->
    <div class="up-filter-bar" data-aos="fade-up" data-aos-delay="100">
        <input type="text" id="searchStation" placeholder="Cari stesen..." oninput="filterStations()">
        <select id="filterStatus" onchange="filterStations()">
            <option value="">Semua Status</option>
            <option value="bahaya">Bahaya</option>
            <option value="amaran">Amaran</option>
            <option value="waspada">Waspada</option>
            <option value="normal">Normal</option>
            <option value="safe">Safe</option>
        </select>
        <select id="filterRiver" onchange="filterStations()">
            <option value="">Semua Sungai</option>
        </select>
        <select id="sortBy" onchange="filterStations()">
            <option value="">Isih Mengikut</option>
            <option value="risk">Risiko Tertinggi</option>
            <option value="wl">Aras Air Tertinggi</option>
            <option value="name">Nama A-Z</option>
        </select>
        <button class="btn-reset" onclick="resetFilters()"><i class="fa-solid fa-rotate-left"></i> Set Semula</button>
    </div>

    <!-- ═══════════ STATION CARDS ═══════════ -->
    <div class="up-stations-grid" id="stationsContainer">
        <%
            if(stationList.isEmpty()) {
        %>
            <div class="up-empty">
                <i class="fa-solid fa-satellite-dish"></i>
                <p>Tiada stesen pemantauan didaftarkan di negeri <strong><%= userLocation %></strong>.</p>
            </div>
        <%
            } else {
                int cardIdx = 0;
                for(Map<String,String> s : stationList) {
                    String rl = s.get("riskLevel");
                    String riskClass = "safe";
                    String riskText = "Safe";
                    String recText = "Tiada tindakan segera diperlukan. Keadaan selamat.";
                    String recClass = "safe";
                    if("BAHAYA".equals(rl)) { riskClass="bahaya"; riskText="Bahaya"; recText="Sila ke pusat pemindahan terdekat dengan segera!"; recClass="bahaya"; }
                    else if("AMARAN".equals(rl)) { riskClass="amaran"; riskText="Amaran"; recText="Sediakan bekalan kecemasan dan sentiasa berwaspada."; recClass="amaran"; }
                    else if("WASPADA".equals(rl)) { riskClass="waspada"; riskText="Waspada"; recText="Pantau kemas kini banjir secara berkala."; recClass="waspada"; }
                    else if("NORMAL".equals(rl)) { riskClass="normal"; riskText="Normal"; recText="Keadaan normal. Teruskan pemantauan rutin."; recClass="normal"; }
                    
                    String trend = s.get("trend");
                    String trendClass = "flat";
                    String trendIcon = "<i class='fa-solid fa-minus'></i>";
                    String trendText = trend != null ? trend : "Tiada Perubahan";
                    if("Menaik".equals(trend)) { trendClass = "up"; trendIcon = "<i class='fa-solid fa-arrow-trend-up'></i>"; }
                    else if("Menurun".equals(trend)) { trendClass = "down"; trendIcon = "<i class='fa-solid fa-arrow-trend-down'></i>"; }
                    
                    String wlStr = s.get("waterLevel");
                    double wlVal = 0;
                    try { wlVal = Double.parseDouble(wlStr); } catch(Exception ex) {}
                    int wlPct = (int)Math.min(100, (wlVal / 10.0) * 100);
                    String wlBarColor = wlVal < 3 ? "#36ADA3" : wlVal < 5 ? "#eab308" : wlVal < 7 ? "#f97316" : "#ef4444";
        %>
        <div class="up-station-card station-item"
             data-name="<%= s.get("stationName").toLowerCase() %>"
             data-status="<%= riskClass %>"
             data-river="<%= s.get("stationName").toLowerCase() %>"
             data-wl="<%= wlStr %>"
             data-aos="fade-up" data-aos-delay="<%= 50 + cardIdx * 30 %>">
            <div class="up-station-body">
                <div class="up-station-left">
                    <div class="up-station-thumb"><i class="fa-solid fa-water" style="color:#0ea5e9;"></i></div>
                    <div class="up-station-info">
                        <h4><%= s.get("stationName") %></h4>
                        <p class="up-station-addr"><i class="fa-solid fa-location-dot"></i> <%= s.get("location") %>, <%= s.get("state") %></p>
                        <p class="up-station-id">ID: #<%= s.get("readingId") %></p>
                    </div>
                </div>
                <div class="up-station-center">
                    <div class="up-metric-box">
                        <div class="up-metric-label">Aras Air</div>
                        <div class="up-metric-val wl"><i class="fa-solid fa-droplet"></i> <%= wlStr.isEmpty() ? "N/A" : wlStr + " m" %></div>
                        <div class="up-progress-bar"><div class="up-progress-fill" style="width:<%= wlPct %>%;background:<%= wlBarColor %>;"></div></div>
                    </div>
                    <div class="up-metric-box">
                        <div class="up-metric-label">Hujan</div>
                        <div class="up-metric-val rf"><i class="fa-solid fa-cloud-rain"></i> <%= s.get("rainfall").isEmpty() ? "N/A" : s.get("rainfall") + " mm" %></div>
                    </div>
                    <div class="up-metric-box">
                        <div class="up-metric-label">Trend</div>
                        <div><span class="up-trend-pill <%= trendClass %>"><%= trendIcon %> <%= trendText %></span></div>
                    </div>
                </div>
                <div class="up-station-right">
                    <span class="up-risk-badge <%= riskClass %>"><%= riskText %></span>
                    <span class="up-station-ts"><i class="fa-regular fa-clock"></i> <%= s.get("recordedDate") %></span>
                    <div class="up-station-actions">
                        <button class="up-btn-action details" onclick="showDetail(<%= cardIdx %>)"><i class="fa-solid fa-eye"></i> Detail</button>
                        <button class="up-btn-action graph" onclick="showGraph(<%= cardIdx %>)"><i class="fa-solid fa-chart-line"></i> Graf</button>
                        <button class="up-btn-action map-btn" onclick="panToStation(<%= cardIdx %>)"><i class="fa-solid fa-map-pin"></i> Peta</button>
                    </div>
                </div>
            </div>
            <div class="up-recommend <%= recClass %>"><i class="fa-solid fa-lightbulb"></i> <%= recText %></div>
        </div>
        <%
                    cardIdx++;
                }
            }
        %>
    </div>

    <!-- ═══════════ RECENT NOTIFICATIONS TIMELINE ═══════════ -->
    <div class="up-section-title" data-aos="fade-up"><i class="fa-solid fa-clock-rotate-left"></i> Notifikasi Terkini</div>
    <div class="up-timeline" data-aos="fade-up">
        <div class="up-tl-item">
            <div class="up-tl-dot"></div>
            <div>
                <div class="up-tl-time">Hari Ini</div>
                <div class="up-tl-text">Aras air dikemas kini untuk semua stesen di <%= userLocation %>.</div>
            </div>
        </div>
        <div class="up-tl-item">
            <div class="up-tl-dot" style="background:#2F578A;box-shadow:0 0 0 4px rgba(47,87,138,.15);"></div>
            <div>
                <div class="up-tl-time">Semalam</div>
                <div class="up-tl-text">Kadar hujan melepasi ambang di beberapa stesen.</div>
            </div>
        </div>
        <div class="up-tl-item">
            <div class="up-tl-dot" style="background:#6366f1;box-shadow:0 0 0 4px rgba(99,102,241,.15);"></div>
            <div>
                <div class="up-tl-time">2 Hari Lepas</div>
                <div class="up-tl-text">E-mel notifikasi amaran telah dihantar kepada pelanggan.</div>
            </div>
        </div>
    </div>

    <!-- ═══════════ EMERGENCY CONTACTS ═══════════ -->
    <div class="up-section-title" data-aos="fade-up"><i class="fa-solid fa-phone-volume"></i> Talian Kecemasan</div>
    <div class="up-emergency-grid" data-aos="fade-up">
        <div class="up-emergency-card">
            <div class="up-emergency-icon"><i class="fa-solid fa-circle-exclamation" style="color:#ef4444;"></i></div>
            <div class="up-emergency-name">Kecemasan</div>
            <div class="up-emergency-num">999</div>
            <a href="tel:999" class="up-emergency-btn"><i class="fa-solid fa-phone"></i> Hubungi</a>
        </div>
        <div class="up-emergency-card">
            <div class="up-emergency-icon"><i class="fa-solid fa-fire-extinguisher" style="color:#f97316;"></i></div>
            <div class="up-emergency-name">Bomba & Penyelamat</div>
            <div class="up-emergency-num">994</div>
            <a href="tel:994" class="up-emergency-btn"><i class="fa-solid fa-phone"></i> Hubungi</a>
        </div>
        <div class="up-emergency-card">
            <div class="up-emergency-icon"><i class="fa-solid fa-shield-halved" style="color:#3b82f6;"></i></div>
            <div class="up-emergency-name">Polis</div>
            <div class="up-emergency-num">999</div>
            <a href="tel:999" class="up-emergency-btn"><i class="fa-solid fa-phone"></i> Hubungi</a>
        </div>
        <div class="up-emergency-card">
            <div class="up-emergency-icon"><i class="fa-solid fa-hospital" style="color:#ef4444;"></i></div>
            <div class="up-emergency-name">Hospital</div>
            <div class="up-emergency-num">999</div>
            <a href="tel:999" class="up-emergency-btn"><i class="fa-solid fa-phone"></i> Hubungi</a>
        </div>
        <div class="up-emergency-card">
            <div class="up-emergency-icon"><i class="fa-solid fa-user-shield" style="color:#8b5cf6;"></i></div>
            <div class="up-emergency-name">NADMA</div>
            <div class="up-emergency-num">03-8064 2400</div>
            <a href="tel:0380642400" class="up-emergency-btn"><i class="fa-solid fa-phone"></i> Hubungi</a>
        </div>
        <div class="up-emergency-card">
            <div class="up-emergency-icon"><i class="fa-solid fa-clipboard-list" style="color:#36ADA3;"></i></div>
            <div class="up-emergency-name">JPBM</div>
            <div class="up-emergency-num">03-8000 8000</div>
            <a href="tel:0380008000" class="up-emergency-btn"><i class="fa-solid fa-phone"></i> Hubungi</a>
        </div>
    </div>

    <!-- ═══════════ FLOOD SAFETY TIPS ═══════════ -->
    <div class="up-section-title" data-aos="fade-up"><i class="fa-solid fa-shield-halved"></i> Tips Keselamatan Banjir</div>
    <div class="up-tips-grid" data-aos="fade-up">
        <div class="up-tip-card">
            <div class="up-tip-icon"><i class="fa-solid fa-shield-halved" style="color:#36ADA3;"></i></div>
            <div class="up-tip-title">Sebelum Banjir</div>
            <ul class="up-tip-list">
                <li>Sediakan beg kecemasan</li>
                <li>Simpan dokumen penting dalam plastik kalis air</li>
                <li>Simpan nombor kecemasan</li>
                <li>Kenalpasti laluan pemindahan terdekat</li>
            </ul>
        </div>
        <div class="up-tip-card">
            <div class="up-tip-icon"><i class="fa-solid fa-triangle-exclamation" style="color:#f59e0b;"></i></div>
            <div class="up-tip-title">Semasa Banjir</div>
            <ul class="up-tip-list">
                <li>Elakkan jalan yang dinaiki air</li>
                <li>Ikut arahan pihak berkuasa</li>
                <li>Bergerak ke tempat yang lebih tinggi</li>
                <li>Jangan cuba meredah air banjir</li>
            </ul>
        </div>
        <div class="up-tip-card">
            <div class="up-tip-icon"><i class="fa-solid fa-circle-check" style="color:#22c55e;"></i></div>
            <div class="up-tip-title">Selepas Banjir</div>
            <ul class="up-tip-list">
                <li>Pulang hanya setelah diisytiharkan selamat</li>
                <li>Periksa peralatan elektrik sebelum digunakan</li>
                <li>Bersihkan rumah daripada lumpur dan sisa banjir</li>
                <li>Dapatkan rawatan perubatan jika perlu</li>
            </ul>
        </div>
    </div>
</div>

<!-- ═══════════ DETAIL MODAL ═══════════ -->
<div class="up-modal-overlay" id="detailModal" onclick="if(event.target===this)closeDetail()">
    <div class="up-modal" style="position:relative;">
        <button class="up-modal-close" onclick="closeDetail()">&times;</button>
        <div class="up-modal-title"><i class="fa-solid fa-circle-info"></i> <span id="dm-title"></span></div>
        <div class="up-modal-row">
            <div class="up-modal-field"><div class="up-modal-field-label">Nama Stesen</div><div class="up-modal-field-value" id="dm-station"></div></div>
            <div class="up-modal-field"><div class="up-modal-field-label">Sungai</div><div class="up-modal-field-value" id="dm-river"></div></div>
        </div>
        <div class="up-modal-row">
            <div class="up-modal-field"><div class="up-modal-field-label">Negeri</div><div class="up-modal-field-value" id="dm-state"></div></div>
            <div class="up-modal-field"><div class="up-modal-field-label">Aras Air (m)</div><div class="up-modal-field-value" id="dm-wl" style="color:#36ADA3;"></div></div>
        </div>
        <div class="up-modal-row">
            <div class="up-modal-field"><div class="up-modal-field-label">Hujan (mm)</div><div class="up-modal-field-value" id="dm-rf" style="color:#2F578A;"></div></div>
            <div class="up-modal-field"><div class="up-modal-field-label">Trend</div><div class="up-modal-field-value" id="dm-trend"></div></div>
        </div>
        <div class="up-modal-row">
            <div class="up-modal-field"><div class="up-modal-field-label">Tahap Risiko</div><div class="up-modal-field-value" id="dm-risk"></div></div>
            <div class="up-modal-field"><div class="up-modal-field-label">Dikemas Kini</div><div class="up-modal-field-value" id="dm-date"></div></div>
        </div>
        <div style="margin-top:14px;padding:14px;border-radius:12px;background:#f8fafc;border:1px solid #e2e8f0;">
            <div style="font-size:11px;color:#94a3b8;font-weight:700;text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px;">Keterangan Risiko</div>
            <div id="dm-desc" style="font-size:13px;color:#475569;font-weight:500;"></div>
        </div>
    </div>
</div>

<!-- ═══════════ GRAPH MODAL ═══════════ -->
<div class="up-modal-overlay" id="graphModal" onclick="if(event.target===this)closeGraph()">
    <div class="up-modal up-graph-modal" style="position:relative;">
        <button class="up-modal-close" onclick="closeGraph()">&times;</button>
        <div class="up-modal-title"><i class="fa-solid fa-chart-line"></i> <span id="gm-title"></span></div>
        <canvas id="graphCanvas" class="up-graph-canvas"></canvas>
    </div>
</div>

<!-- Scripts -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://unpkg.com/aos@2.3.4/dist/aos.js"></script>
<script>
AOS.init({ duration: 500, once: true, offset: 40 });

// ── Station Data ──
var stations = [
<% for(int i = 0; i < stationList.size(); i++) {
    Map<String,String> s = stationList.get(i);
    String rl = s.get("riskLevel");
    String rClass = "safe";
    if("BAHAYA".equals(rl)) rClass="bahaya";
    else if("AMARAN".equals(rl)) rClass="amaran";
    else if("WASPADA".equals(rl)) rClass="waspada";
    else if("NORMAL".equals(rl)) rClass="normal";
%>
{
    name: "<%= s.get("stationName").replace("\"","\\\"") %>",
    location: "<%= s.get("location").replace("\"","\\\"") %>",
    state: "<%= s.get("state").replace("\"","\\\"") %>",
    wl: "<%= s.get("waterLevel") %>",
    rf: "<%= s.get("rainfall") %>",
    risk: "<%= rl %>",
    riskClass: "<%= rClass %>",
    trend: "<%= s.get("trend") != null ? s.get("trend") : "" %>",
    date: "<%= s.get("recordedDate") %>",
    lat: <%= s.get("latitude").isEmpty() ? "null" : s.get("latitude") %>,
    lng: <%= s.get("longitude").isEmpty() ? "null" : s.get("longitude") %>
}<%= i < stationList.size()-1 ? "," : "" %>
<% } %>
];

// ── History Data ──
var historyData = {};
<% for(Map.Entry<String, List<Map<String,String>>> entry : historyMap.entrySet()) { %>
historyData["<%= entry.getKey().replace("\"","\\\"") %>"] = {
    labels: [<% List<Map<String,String>> pts = entry.getValue(); for(int i=0;i<pts.size();i++){ %>"<%= pts.get(i).get("date") %>"<%= i<pts.size()-1?",":"" %><% } %>],
    wl: [<% for(int i=0;i<pts.size();i++){ %><%= pts.get(i).get("wl") %><%= i<pts.size()-1?",":"" %><% } %>],
    rf: [<% for(int i=0;i<pts.size();i++){ %><%= pts.get(i).get("rf") %><%= i<pts.size()-1?",":"" %><% } %>]
};
<% } %>

// ── Leaflet Map ──
var map = L.map('stationMap').setView([4.2, 101.97], 6);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap'
}).addTo(map);

var markers = [];
stations.forEach(function(s, idx) {
    if (s.lat !== null && s.lng !== null) {
        var riskColors = {bahaya:'#ef4444', amaran:'#f97316', waspada:'#eab308', normal:'#3b82f6', safe:'#22c55e'};
        var c = riskColors[s.riskClass] || '#36ADA3';
        var icon = L.divIcon({
            className: '',
            html: '<div style="width:14px;height:14px;border-radius:50%;background:'+c+';border:3px solid #fff;box-shadow:0 2px 8px rgba(0,0,0,.3);"></div>',
            iconSize: [14, 14],
            iconAnchor: [7, 7]
        });
        var m = L.marker([s.lat, s.lng], {icon: icon}).addTo(map);
        m.bindPopup(
            '<div style="font-family:Inter,sans-serif;min-width:180px;">'+
            '<strong style="font-size:14px;">'+s.name+'</strong><br>'+
            '<span style="font-size:12px;color:#64748b;">'+s.location+', '+s.state+'</span><hr style="margin:6px 0;border-color:#e2e8f0;">'+
            '<span style="font-size:12px;"><strong>Aras Air:</strong> '+(s.wl||'N/A')+' m</span><br>'+
            '<span style="font-size:12px;"><strong>Hujan:</strong> '+(s.rf||'N/A')+' mm</span><br>'+
            '<span style="font-size:12px;"><strong>Trend:</strong> '+s.trend+'</span><br>'+
            '<span style="font-size:12px;"><strong>Status:</strong> <span style="color:'+c+';font-weight:800;">'+s.risk+'</span></span>'+
            '</div>'
        );
        markers.push(m);
    }
});
if(markers.length > 0) {
    var group = L.featureGroup(markers);
    map.fitBounds(group.getBounds().pad(0.2));
}

// ── Populate River Filter ──
(function() {
    var rivers = {};
    stations.forEach(function(s) { rivers[s.name] = true; });
    var sel = document.getElementById('filterRiver');
    Object.keys(rivers).sort().forEach(function(r) {
        var o = document.createElement('option');
        o.value = r.toLowerCase();
        o.textContent = r;
        sel.appendChild(o);
    });
})();

// ── Filter & Sort ──
function filterStations() {
    var search = document.getElementById('searchStation').value.toLowerCase();
    var status = document.getElementById('filterStatus').value;
    var river  = document.getElementById('filterRiver').value;
    var sort   = document.getElementById('sortBy').value;
    var items  = Array.from(document.querySelectorAll('.station-item'));
    
    items.forEach(function(el) {
        var name = el.dataset.name;
        var st   = el.dataset.status;
        var rv   = el.dataset.river;
        var show = true;
        if(search && name.indexOf(search) === -1) show = false;
        if(status && st !== status) show = false;
        if(river && rv !== river) show = false;
        el.style.display = show ? '' : 'none';
    });
    
    if(sort) {
        var container = document.getElementById('stationsContainer');
        var sorted = items.slice().sort(function(a,b) {
            if(sort === 'risk') {
                var order = {bahaya:1, amaran:2, waspada:3, normal:4, safe:5};
                return (order[a.dataset.status]||6) - (order[b.dataset.status]||6);
            } else if(sort === 'wl') {
                return (parseFloat(b.dataset.wl)||0) - (parseFloat(a.dataset.wl)||0);
            } else if(sort === 'name') {
                return a.dataset.name.localeCompare(b.dataset.name);
            }
            return 0;
        });
        sorted.forEach(function(el) { container.appendChild(el); });
    }
}
function resetFilters() {
    document.getElementById('searchStation').value = '';
    document.getElementById('filterStatus').value = '';
    document.getElementById('filterRiver').value = '';
    document.getElementById('sortBy').value = '';
    document.querySelectorAll('.station-item').forEach(function(el) { el.style.display = ''; });
}

// ── Detail Modal ──
function showDetail(idx) {
    var s = stations[idx];
    document.getElementById('dm-title').textContent = 'Maklumat Stesen';
    document.getElementById('dm-station').textContent = s.name;
    document.getElementById('dm-river').textContent = s.name;
    document.getElementById('dm-state').textContent = s.state;
    document.getElementById('dm-wl').textContent = (s.wl || 'N/A') + ' m';
    document.getElementById('dm-rf').textContent = (s.rf || 'N/A') + ' mm';
    document.getElementById('dm-trend').textContent = s.trend || '-';
    document.getElementById('dm-risk').innerHTML = '<span class="up-risk-badge '+s.riskClass+'">'+s.risk+'</span>';
    document.getElementById('dm-date').textContent = s.date;
    
    var desc = 'Keadaan selamat. Tiada tindakan diperlukan.';
    if(s.risk==='BAHAYA') desc = 'Tahap bahaya! Aras air melepasi had kritikal. Penduduk dinasihatkan berpindah ke pusat pemindahan segera.';
    else if(s.risk==='AMARAN') desc = 'Amaran! Aras air semakin meningkat. Sediakan bekalan kecemasan dan pantau perkembangan.';
    else if(s.risk==='WASPADA') desc = 'Waspada. Aras air meningkat secara perlahan. Pantau kemas kini secara berkala.';
    else if(s.risk==='NORMAL') desc = 'Keadaan normal. Aras air berada dalam tahap yang selamat.';
    document.getElementById('dm-desc').textContent = desc;
    document.getElementById('detailModal').classList.add('active');
}
function closeDetail() { document.getElementById('detailModal').classList.remove('active'); }

// ── Graph Modal ──
var graphChart = null;
function showGraph(idx) {
    var s = stations[idx];
    var data = historyData[s.name];
    document.getElementById('gm-title').textContent = 'Trend - ' + s.name;
    document.getElementById('graphModal').classList.add('active');
    
    if(graphChart) graphChart.destroy();
    var ctx = document.getElementById('graphCanvas').getContext('2d');
    
    var labels = data ? data.labels : [];
    var wlData = data ? data.wl : [];
    var rfData = data ? data.rf : [];
    
    graphChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Aras Air (m)',
                    data: wlData,
                    borderColor: '#36ADA3',
                    backgroundColor: 'rgba(54,173,163,.1)',
                    borderWidth: 2.5,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 4,
                    pointBackgroundColor: '#36ADA3',
                    yAxisID: 'y'
                },
                {
                    label: 'Hujan (mm)',
                    data: rfData,
                    type: 'bar',
                    backgroundColor: 'rgba(47,87,138,.2)',
                    borderColor: '#2F578A',
                    borderWidth: 1,
                    borderRadius: 4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode:'index', intersect: false },
            plugins: { legend: { position:'top', labels: { usePointStyle:true, font:{size:11,family:'Inter'} } } },
            scales: {
                y:  { position:'left',  title: { display:true, text:'Aras Air (m)', font:{size:11} }, beginAtZero:true },
                y1: { position:'right', title: { display:true, text:'Hujan (mm)', font:{size:11} }, beginAtZero:true, grid:{drawOnChartArea:false} }
            }
        }
    });
}
function closeGraph() { document.getElementById('graphModal').classList.remove('active'); if(graphChart){graphChart.destroy(); graphChart=null;} }

// ── Pan to station on map ──
function panToStation(idx) {
    var s = stations[idx];
    if(s.lat !== null && s.lng !== null) {
        map.setView([s.lat, s.lng], 13);
        if(markers[idx]) markers[idx].openPopup();
        document.getElementById('stationMap').scrollIntoView({behavior:'smooth', block:'center'});
    }
}
</script>
</body>
</html>