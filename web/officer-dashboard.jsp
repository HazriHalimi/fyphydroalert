<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%
    String officerUsername = (String) session.getAttribute("officerUsername");
    String userType = (String) session.getAttribute("userType");
    if(officerUsername == null || !"officer".equals(userType)) { response.sendRedirect("login.jsp"); return; }
    String officerName = (String) session.getAttribute("officerName");
    Integer officerId  = (Integer) session.getAttribute("officerId");
    String officerEmail = (String) session.getAttribute("officerEmail");
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Officer Dashboard - HydroAlert</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/portal.css">
    <style>
        .btn-profile{background:var(--teal);color:#fff;padding:7px 16px;border-radius:50px;font-size:13px;font-weight:700;text-decoration:none;transition:var(--tr);}
        .btn-profile:hover{background:#2b948a;transform:translateY(-1px);}
        .body{padding:28px 30px;}
        /* PROFILE BANNER */
        .profile-banner{background:linear-gradient(135deg,#0d0e45 0%,var(--deep-blue) 55%,var(--navy) 100%);border-radius:18px;padding:28px 32px;color:#fff;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:20px;margin-bottom:28px;box-shadow:0 12px 35px rgba(18,19,88,.18);border:1px solid rgba(255,255,255,.07);position:relative;overflow:hidden;}
        .profile-banner::before{content:'';position:absolute;width:280px;height:280px;background:radial-gradient(circle,rgba(54,173,163,.18) 0%,transparent 70%);top:-100px;right:-40px;pointer-events:none;}
        .pb-left{display:flex;align-items:center;gap:18px;position:relative;}
        .pb-avatar{width:66px;height:66px;border-radius:50%;background:rgba(255,255,255,.1);display:flex;align-items:center;justify-content:center;font-size:26px;border:2px solid var(--teal);box-shadow:0 0 18px rgba(54,173,163,.3);color:#fff;}
        .pb-badge{background:var(--teal);color:#0d1030;padding:3px 10px;border-radius:20px;font-size:10px;font-weight:800;letter-spacing:.5px;display:inline-block;margin-bottom:5px;}
        .pb-name{font-family:'Outfit',sans-serif;font-size:21px;font-weight:800;margin-bottom:3px;}
        .pb-email{font-size:13px;color:rgba(255,255,255,.65);}
        .pb-stats{display:flex;gap:14px;flex-wrap:wrap;}
        .pb-stat{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.1);border-radius:13px;padding:14px 20px;text-align:center;min-width:105px;}
        .pb-stat-label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:rgba(255,255,255,.5);margin-bottom:5px;}
        .pb-stat-val{font-family:'Outfit',sans-serif;font-size:26px;font-weight:800;color:#fff;}
        .pb-stat-val.danger{color:#fca5a5;}
        .pb-stat-val.warning{color:#fbbf24;}
        /* SECTION */
        .sec-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:18px;}
        .sec-title{font-family:'Outfit',sans-serif;font-size:18px;font-weight:700;color:var(--navy);display:flex;align-items:center;gap:8px;}
        .sec-title i{color:var(--teal);}
        .btn-add{background:linear-gradient(135deg,var(--teal),#2b948a);color:#fff;padding:9px 18px;border-radius:50px;font-size:13px;font-weight:700;text-decoration:none;transition:var(--tr);display:inline-flex;align-items:center;gap:6px;}
        .btn-add:hover{transform:translateY(-2px);box-shadow:0 8px 18px rgba(54,173,163,.28);}
        /* READING CARDS */
        .readings-list{display:flex;flex-direction:column;gap:18px;}
        .state-box{background:var(--white);border-radius:18px;border:1px solid var(--border);box-shadow:0 6px 22px rgba(18,19,88,.04);padding:22px;}
        .state-header{display:flex;justify-content:space-between;align-items:center;border-bottom:2px solid var(--border);padding-bottom:12px;margin-bottom:14px;}
        .state-name{font-family:'Outfit',sans-serif;font-size:17px;font-weight:700;color:var(--navy);text-transform:uppercase;display:flex;align-items:center;gap:8px;}
        .state-name i{color:var(--teal);font-size:15px;}
        .state-cnt{font-size:11px;color:var(--teal);font-weight:800;background:rgba(54,173,163,.1);padding:3px 12px;border-radius:20px;}
        .station-rows{display:flex;flex-direction:column;gap:10px;}
        .srow{background:var(--light);border-radius:11px;border:1px solid rgba(35,47,114,.05);padding:14px 18px;display:flex;align-items:center;justify-content:space-between;gap:14px;flex-wrap:wrap;transition:var(--tr);}
        .srow:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(18,19,88,.06);border-color:rgba(54,173,163,.2);}
        .srow-left{flex:2;min-width:190px;}
        .srow-river{font-family:'Outfit',sans-serif;font-size:15px;font-weight:700;color:var(--navy);margin-bottom:3px;}
        .srow-loc{font-size:12px;color:var(--muted);display:flex;align-items:center;gap:4px;}
        .srow-loc i{font-size:11px;color:#e11d48;}
        .srow-metrics{flex:1.4;min-width:150px;display:flex;gap:18px;}
        .metric{display:flex;flex-direction:column;gap:2px;}
        .metric-lbl{font-size:9.5px;font-weight:700;text-transform:uppercase;color:var(--muted);letter-spacing:.5px;}
        .metric-val{font-size:14px;font-weight:700;color:#0f172a;display:flex;align-items:center;gap:4px;}
        .metric-val i{font-size:12px;}
        .srow-right{display:flex;flex-direction:column;align-items:flex-end;gap:5px;}
        .risk-badge{padding:5px 13px;border-radius:20px;font-size:10.5px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;}
        .trend-pill{font-size:11px;font-weight:700;padding:3px 9px;border-radius:7px;background:#e2e8f0;display:flex;align-items:center;gap:4px;}
        .ts{font-size:11px;color:var(--muted);display:flex;align-items:center;gap:4px;}
        .ts i{font-size:10px;}
        .row-actions{display:flex;gap:6px;margin-top:2px;}
        .btn-edit-sm{background:rgba(35,47,114,.08);color:var(--navy);padding:5px 11px;border-radius:7px;font-size:11px;font-weight:700;text-decoration:none;transition:var(--tr);display:flex;align-items:center;gap:4px;}
        .btn-edit-sm:hover{background:var(--navy);color:#fff;}
        .btn-del-sm{background:rgba(225,29,72,.08);color:#e11d48;padding:5px 11px;border-radius:7px;font-size:11px;font-weight:700;text-decoration:none;transition:var(--tr);display:flex;align-items:center;gap:4px;}
        .btn-del-sm:hover{background:#e11d48;color:#fff;}
        .empty-state{text-align:center;padding:55px 20px;background:var(--white);border-radius:18px;border:2px dashed var(--border);}
        .empty-state i{font-size:44px;color:#cbd5e1;margin-bottom:14px;display:block;}
        .empty-state p{font-size:15px;font-weight:600;color:var(--muted);}
    </style>
</head>
<body>
<div class="app">
<aside class="sidebar">
    <div class="sb-brand">
        <img src="images/logo.png" alt="HydroAlert" onerror="this.style.display='none'">
        <div><div class="sb-brand-name">HydroAlert</div><div class="sb-brand-role">Officer Portal</div></div>
    </div>
    <nav class="sb-nav">
        <div class="sb-section">Overview</div>
        <a href="officer-dashboard.jsp" class="sb-link active"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>
        <div class="sb-section">Readings</div>
        <a href="officer-add-reading.jsp" class="sb-link"><i class="fa-solid fa-plus-circle"></i> Add Reading</a>
        <a href="officer-my-readings.jsp" class="sb-link"><i class="fa-solid fa-clipboard-list"></i> My Readings</a>
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
    <div class="topbar-title">Dashboard</div>
    <div style="display:flex;align-items:center;gap:12px;">
        <div class="topbar-user"><div class="tb-avatar"><i class="fa-solid fa-user-shield"></i></div><%= officerName %></div>
        <a href="officer-profile.jsp" class="btn-profile"><i class="fa-solid fa-gear"></i> Profil</a>
    </div>
</div>
<div class="body">
<%
int totalReadings=0, todayReadings=0, criticalReadings=0;
Connection conn=null; PreparedStatement pstmt=null;
try {
    conn=DBConnection.getConnection();
    pstmt=conn.prepareStatement("SELECT COUNT(DISTINCT station_name) FROM readings WHERE officer_id=?"); pstmt.setInt(1,officerId); ResultSet r1=pstmt.executeQuery(); r1.next(); totalReadings=r1.getInt(1);
    pstmt=conn.prepareStatement("SELECT COUNT(DISTINCT station_name) FROM readings WHERE officer_id=? AND DATE(recorded_date)=CURDATE()"); pstmt.setInt(1,officerId); ResultSet r2=pstmt.executeQuery(); r2.next(); todayReadings=r2.getInt(1);
    pstmt=conn.prepareStatement("SELECT COUNT(*) FROM readings r INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest ON r.reading_id = latest.max_id WHERE r.officer_id=? AND r.risk_level IN('BAHAYA','AMARAN')"); pstmt.setInt(1,officerId); ResultSet r3=pstmt.executeQuery(); r3.next(); criticalReadings=r3.getInt(1);
} catch(Exception e){e.printStackTrace();} finally{if(pstmt!=null)pstmt.close();if(conn!=null)conn.close();}
%>
<div class="profile-banner">
    <div class="pb-left">
        <div class="pb-avatar"><i class="fa-solid fa-user-shield" style="font-size:28px;"></i></div>
        <div>
            <div class="pb-badge">PEGAWAI</div>
            <div class="pb-name"><%= officerName %></div>
            <div class="pb-email"><i class="fa-solid fa-envelope" style="font-size:11px;margin-right:4px;"></i><%= officerEmail!=null?officerEmail:officerUsername %></div>
        </div>
    </div>
    <div class="pb-stats">
        <div class="pb-stat"><div class="pb-stat-label">Jumlah Bacaan</div><div class="pb-stat-val"><%= totalReadings %></div></div>
        <div class="pb-stat"><div class="pb-stat-label">Hari Ini</div><div class="pb-stat-val warning"><%= todayReadings %></div></div>
        <div class="pb-stat"><div class="pb-stat-label">Kritikal</div><div class="pb-stat-val danger"><%= criticalReadings %></div></div>
    </div>
</div>

<div class="sec-header">
    <div class="sec-title"><i class="fa-solid fa-clipboard-list"></i> Bacaan Terkini Saya</div>
    <a href="officer-add-reading.jsp" class="btn-add"><i class="fa-solid fa-plus"></i> Tambah Bacaan</a>
</div>

<%
Map<String,List<Map<String,Object>>> stateMap=new LinkedHashMap<String,List<Map<String,Object>>>();
Connection conn2=null; PreparedStatement ps2=null; ResultSet rs=null;
try {
    conn2=DBConnection.getConnection();
    ps2=conn2.prepareStatement("SELECT r.* FROM readings r INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest ON r.reading_id = latest.max_id WHERE r.officer_id=? ORDER BY CASE r.risk_level WHEN 'BAHAYA' THEN 1 WHEN 'AMARAN' THEN 2 WHEN 'WASPADA' THEN 3 WHEN 'NORMAL' THEN 4 WHEN 'SAFE' THEN 5 ELSE 6 END, r.state, r.station_name");
    ps2.setInt(1,officerId); rs=ps2.executeQuery();
    while(rs.next()){
        String st=rs.getString("state");
        Map<String,Object> row=new HashMap<String,Object>();
        row.put("id",rs.getInt("reading_id")); row.put("station_name",rs.getString("station_name")); row.put("location",rs.getString("location")); row.put("risk_level",rs.getString("risk_level"));
        double wlV=rs.getDouble("water_level_m"); row.put("water_level_m",rs.wasNull()?null:wlV);
        double rfV=rs.getDouble("rainfall_mm");   row.put("rainfall_mm",  rs.wasNull()?null:rfV);
        row.put("trend",rs.getString("trend")); row.put("recorded_date",rs.getTimestamp("recorded_date"));
        if(!stateMap.containsKey(st)) stateMap.put(st,new ArrayList<Map<String,Object>>());
        stateMap.get(st).add(row);
    }
} catch(Exception e){e.printStackTrace();} finally{if(rs!=null)rs.close();if(ps2!=null)ps2.close();if(conn2!=null)conn2.close();}
%>
<% if(stateMap.isEmpty()){ %>
<div class="empty-state"><i class="fa-solid fa-inbox"></i><p>Tiada bacaan ditemui. Mulakan dengan menambah bacaan baru.</p></div>
<% }else{ %>
<div class="readings-list">
<% for(Map.Entry<String,List<Map<String,Object>>> entry:stateMap.entrySet()){
    String sn=entry.getKey(); List<Map<String,Object>> rows=entry.getValue(); %>
<div class="state-box">
    <div class="state-header">
        <div class="state-name"><i class="fa-solid fa-map"></i> <%= sn %></div>
        <span class="state-cnt"><%= rows.size() %> Stesen</span>
    </div>
    <div class="station-rows">
    <% for(Map<String,Object> r:rows){
        String sName=(String)r.get("station_name"),loc=(String)r.get("location"),rl=(String)r.get("risk_level");
        Double wl=(Double)r.get("water_level_m"),rf=(Double)r.get("rainfall_mm"),tr1=null;
        String tr=(String)r.get("trend"); int rid=(Integer)r.get("id");
        java.util.Date rd=(java.util.Date)r.get("recorded_date");
        String ds=new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rd);
        String river=sName,site=sName; if(sName.contains(" di ")){String[]p=sName.split(" di ",2);river=p[0];site=p[1];}
        String bbg="#dcfce7",bt="#166534",bb="1px solid #bbf7d0",stxt="Normal";
        if("BAHAYA".equals(rl)){bbg="#fee2e2";bt="#991b1b";bb="1px solid #fca5a5";stxt="Bahaya";}
        else if("AMARAN".equals(rl)){bbg="#ffedd5";bt="#c2410c";bb="1px solid #fed7aa";stxt="Amaran";}
        else if("WASPADA".equals(rl)){bbg="#fef9c3";bt="#a16207";bb="1px solid #fef08a";stxt="Waspada";}
        else if("NORMAL".equals(rl)){bbg="#dbeafe";bt="#1e40af";bb="1px solid #bfdbfe";stxt="Normal";}
        String ti="fa-minus",tc="#64748b",tt="Tiada Perubahan";
        if("Menaik".equals(tr)){ti="fa-arrow-trend-up";tc="#dc2626";tt="Menaik";}
        else if("Menurun".equals(tr)){ti="fa-arrow-trend-down";tc="#16a34a";tt="Menurun";}
    %>
    <div class="srow">
        <div class="srow-left">
            <div class="srow-river"><%= river %></div>
            <div class="srow-loc"><i class="fa-solid fa-location-dot"></i> <%= site %>, <%= loc %></div>
        </div>
        <div class="srow-metrics">
            <div class="metric"><span class="metric-lbl">Aras Air</span><span class="metric-val" style="color:var(--teal)"><i class="fa-solid fa-droplet"></i><%= wl!=null?String.format("%.2f",wl)+" m":"N/A" %></span></div>
            <div class="metric"><span class="metric-lbl">Hujan</span><span class="metric-val" style="color:#2F578A"><i class="fa-solid fa-cloud-rain"></i><%= rf!=null?String.format("%.1f",rf)+" mm":"N/A" %></span></div>
        </div>
        <div class="srow-right">
            <div style="display:flex;gap:7px;align-items:center;">
                <span class="trend-pill" style="color:<%= tc %>"><i class="fa-solid <%= ti %>"></i> <%= tt %></span>
                <span class="risk-badge" style="background:<%= bbg %>;color:<%= bt %>;border:<%= bb %>"><%= stxt %></span>
            </div>
            <div class="ts"><i class="fa-regular fa-clock"></i> <%= ds %></div>
            <div class="row-actions">
                <a href="officer-edit-reading.jsp?id=<%= rid %>" class="btn-edit-sm"><i class="fa-solid fa-pen"></i> Edit</a>
                <a href="DeleteReadingServlet?id=<%= rid %>" class="btn-del-sm" onclick="return confirm('Padam bacaan ini?')"><i class="fa-solid fa-trash"></i> Padam</a>
            </div>
        </div>
    </div>
    <% } %>
    </div>
</div>
<% } %>
</div>
<% } %>
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
<script type="text/javascript">
    // Prevent browser back button navigation
    (function() {
        window.history.pushState(null, null, window.location.href);
        window.onpopstate = function() {
            window.history.pushState(null, null, window.location.href);
        };
    })();
</script>
</body></html>
