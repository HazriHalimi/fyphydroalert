<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%
    String adminUsername=(String)session.getAttribute("adminUsername");
    String userType=(String)session.getAttribute("userType");
    if(adminUsername==null||!"admin".equals(userType)){response.sendRedirect("login.jsp");return;}
    String adminName=(String)session.getAttribute("adminName");
    String adminEmail=(String)session.getAttribute("adminEmail");
%>
<!DOCTYPE html><html lang="ms"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Admin Dashboard - HydroAlert</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Outfit:wght@400;600;700;800;900&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/portal.css">
<style>
.pb-avatar.admin-av{border-color:#e11d48;box-shadow:0 0 18px rgba(225,29,72,.3);}
.sidebar.admin-sb{background:linear-gradient(180deg,#0a0726 0%,#14134a 50%,#1a1960 100%);}
</style>
</head><body><div class="app">
<aside class="sidebar admin-sb">
    <div class="sb-brand"><img src="images/logo.png" alt="HydroAlert" onerror="this.style.display='none'"><div><div class="sb-brand-name">HydroAlert</div><div class="sb-brand-role">Admin Portal</div></div></div>
    <nav class="sb-nav">
        <div class="sb-section">Overview</div>
        <a href="admin-dashboard.jsp" class="sb-link active"><i class="fa-solid fa-house"></i> Dashboard</a>
        <div class="sb-section">Management</div>
        <a href="admin-officers.jsp" class="sb-link"><i class="fa-solid fa-user-shield"></i> Manage Officers</a>
        <a href="admin-readings.jsp" class="sb-link"><i class="fa-solid fa-chart-column"></i> View Readings</a>
        <a href="admin-users.jsp" class="sb-link"><i class="fa-solid fa-users"></i> Manage Users</a>
        <div class="sb-section">Alerts</div>
        <a href="admin-alerts.jsp" class="sb-link"><i class="fa-solid fa-bell"></i> Send Alerts</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">System Dashboard</div>
    <div class="topbar-user"><div class="tb-avatar admin"><i class="fa-solid fa-crown"></i></div><%= adminName %></div>
</div>
<div class="body-content">
<%
int totalOfficers=0,totalUsers=0,totalReadings=0,criticalAlerts=0;
Connection conn=null; Statement stmt=null;
try {
    conn=DBConnection.getConnection(); stmt=conn.createStatement();
    ResultSet r1=stmt.executeQuery("SELECT COUNT(*) FROM officers WHERE status='active'"); r1.next(); totalOfficers=r1.getInt(1);
    ResultSet r2=stmt.executeQuery("SELECT COUNT(*) FROM users"); r2.next(); totalUsers=r2.getInt(1);
    ResultSet r3=stmt.executeQuery("SELECT COUNT(DISTINCT station_name) FROM readings"); r3.next(); totalReadings=r3.getInt(1);
    ResultSet r4=stmt.executeQuery("SELECT COUNT(*) FROM readings r INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest ON r.reading_id = latest.max_id WHERE r.risk_level IN('BAHAYA','AMARAN')"); r4.next(); criticalAlerts=r4.getInt(1);
}catch(Exception e){e.printStackTrace();}finally{if(stmt!=null)stmt.close();if(conn!=null)conn.close();}
%>
<!-- Profile Banner -->
<div class="profile-banner" style="background:linear-gradient(135deg,#0a0726 0%,#14134a 55%,#1a1960 100%);">
    <div class="pb-left">
        <div class="pb-avatar admin-av"><i class="fa-solid fa-crown" style="font-size:26px;"></i></div>
        <div>
            <div class="pb-badge" style="background:#e11d48;color:#fff;">ADMIN</div>
            <div class="pb-name"><%= adminName %></div>
            <div class="pb-email"><i class="fa-solid fa-envelope" style="font-size:11px;margin-right:4px;"></i><%= adminEmail!=null?adminEmail:adminUsername %></div>
        </div>
    </div>
    <div class="pb-stats">
        <div class="pb-stat"><div class="pb-stat-label">Pegawai Aktif</div><div class="pb-stat-val accent"><%= totalOfficers %></div></div>
        <div class="pb-stat"><div class="pb-stat-label">Pengguna</div><div class="pb-stat-val"><%= totalUsers %></div></div>
        <div class="pb-stat"><div class="pb-stat-label">Jumlah Bacaan</div><div class="pb-stat-val warning"><%= totalReadings %></div></div>
        <div class="pb-stat"><div class="pb-stat-label">Kritikal</div><div class="pb-stat-val danger"><%= criticalAlerts %></div></div>
    </div>
</div>

<!-- Stats Grid -->
<div class="stats-grid">
    <div class="stat-card"><div class="stat-icon" style="background:rgba(54,173,163,.1);color:var(--teal);"><i class="fa-solid fa-user-shield"></i></div><div><div class="stat-info-label">Pegawai Aktif</div><div class="stat-info-val" style="color:var(--teal)"><%= totalOfficers %></div></div></div>
    <div class="stat-card"><div class="stat-icon" style="background:rgba(35,47,114,.08);color:var(--navy);"><i class="fa-solid fa-users"></i></div><div><div class="stat-info-label">Pengguna Berdaftar</div><div class="stat-info-val"><%= totalUsers %></div></div></div>
    <div class="stat-card"><div class="stat-icon" style="background:rgba(251,191,36,.1);color:#d97706;"><i class="fa-solid fa-clipboard-list"></i></div><div><div class="stat-info-label">Jumlah Bacaan</div><div class="stat-info-val" style="color:#d97706"><%= totalReadings %></div></div></div>
    <div class="stat-card"><div class="stat-icon" style="background:rgba(225,29,72,.08);color:#e11d48;"><i class="fa-solid fa-triangle-exclamation"></i></div><div><div class="stat-info-label">Amaran Kritikal</div><div class="stat-info-val" style="color:#e11d48"><%= criticalAlerts %></div></div></div>
</div>

<!-- Critical Readings -->
<div class="sec-header">
    <div class="sec-title"><i class="fa-solid fa-triangle-exclamation" style="color:#e11d48;"></i> Bacaan Kritikal Terkini</div>
    <a href="admin-readings.jsp" class="btn-add"><i class="fa-solid fa-chart-column"></i> Semua Bacaan</a>
</div>
<div class="data-card">
<table class="data-table">
    <thead><tr><th>Stesen</th><th>Lokasi / Negeri</th><th>Aras Air</th><th>Hujan</th><th>Risiko</th><th>Trend</th><th>Pegawai</th><th>Tarikh</th></tr></thead>
    <tbody>
    <%
    Connection conn2=null; Statement st2=null; ResultSet rs2=null;
    try {
        conn2=DBConnection.getConnection(); st2=conn2.createStatement();
        rs2=st2.executeQuery("SELECT r.*,o.full_name as officer_name FROM readings r INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest ON r.reading_id = latest.max_id LEFT JOIN officers o ON r.officer_id=o.officer_id WHERE r.risk_level IN('BAHAYA','AMARAN') ORDER BY CASE r.risk_level WHEN 'BAHAYA' THEN 1 ELSE 2 END,r.recorded_date DESC LIMIT 20");
        boolean hasData=false;
        while(rs2.next()){
            hasData=true;
            String rl=rs2.getString("risk_level");
            double wlV=rs2.getDouble("water_level_m"); boolean hasWl=!rs2.wasNull();
            double rfV=rs2.getDouble("rainfall_mm"); boolean hasRf=!rs2.wasNull();
            String bbg="BAHAYA".equals(rl)?"#fee2e2":"#ffedd5",bt="BAHAYA".equals(rl)?"#991b1b":"#c2410c",bb="BAHAYA".equals(rl)?"1px solid #fca5a5":"1px solid #fed7aa",stxt="BAHAYA".equals(rl)?"Bahaya":"Amaran";
            String tr=rs2.getString("trend");
            String tiCls="fa-minus",tiCol="#64748b";
            if("Menaik".equals(tr)){tiCls="fa-arrow-trend-up";tiCol="#dc2626";}
            else if("Menurun".equals(tr)){tiCls="fa-arrow-trend-down";tiCol="#16a34a";}
    %>
    <tr>
        <td><strong><%= rs2.getString("station_name") %></strong></td>
        <td><%= rs2.getString("location") %><div class="td-sub"><%= rs2.getString("state") %></div></td>
        <td style="font-weight:700;color:#36ADA3;"><i class="fa-solid fa-droplet"></i> <%= hasWl?String.format("%.2f",wlV)+" m":"N/A" %></td>
        <td style="font-weight:700;color:#2F578A;"><i class="fa-solid fa-cloud-rain"></i> <%= hasRf?String.format("%.1f",rfV)+" mm":"N/A" %></td>
        <td><span class="badge" style="background:<%= bbg %>;color:<%= bt %>;border:<%= bb %>"><%= stxt %></span></td>
        <td style="font-size:12px;color:<%= tiCol %>;font-weight:700;"><i class="fa-solid <%= tiCls %>"></i> <%= tr!=null?tr:"-" %></td>
        <td style="font-size:12px;"><%= rs2.getString("officer_name")!=null?rs2.getString("officer_name"):"N/A" %></td>
        <td style="font-size:12px;color:#64748b;"><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs2.getTimestamp("recorded_date")) %></td>
    </tr>
    <% } if(!hasData){ %>
    <tr><td colspan="8" style="text-align:center;padding:40px;"><i class="fa-solid fa-circle-check" style="color:#22c55e;font-size:24px;margin-right:8px;"></i> Tiada amaran kritikal. Sistem selamat.</td></tr>
    <% }
    }catch(Exception e){e.printStackTrace();}finally{if(rs2!=null)rs2.close();if(st2!=null)st2.close();if(conn2!=null)conn2.close();}
    %>
    </tbody>
</table>
</div>
</div></div></div>
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
