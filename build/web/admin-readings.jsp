<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%
    String adminUsername=(String)session.getAttribute("adminUsername");
    String userType=(String)session.getAttribute("userType");
    if(adminUsername==null||!"admin".equals(userType)){response.sendRedirect("login.jsp");return;}
    String adminName=(String)session.getAttribute("adminName");
    String filterState=request.getParameter("state");
    String filterRisk=request.getParameter("risk");
    String searchTerm=request.getParameter("search");
%>
<!DOCTYPE html><html lang="ms"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>View Readings - HydroAlert Admin</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Outfit:wght@400;600;700;800;900&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/portal.css">
<style>.sidebar{background:linear-gradient(180deg,#0a0726 0%,#14134a 50%,#1a1960 100%);}</style>
</head><body><div class="app">
<aside class="sidebar">
    <div class="sb-brand"><img src="images/logo.png" alt="HydroAlert" onerror="this.style.display='none'"><div><div class="sb-brand-name">HydroAlert</div><div class="sb-brand-role">Admin Portal</div></div></div>
    <nav class="sb-nav">
        <div class="sb-section">Overview</div>
        <a href="admin-dashboard.jsp" class="sb-link"><i class="fa-solid fa-house"></i> Dashboard</a>
        <div class="sb-section">Management</div>
        <a href="admin-officers.jsp" class="sb-link"><i class="fa-solid fa-user-shield"></i> Manage Officers</a>
        <a href="admin-readings.jsp" class="sb-link active"><i class="fa-solid fa-chart-column"></i> View Readings</a>
        <a href="admin-users.jsp" class="sb-link"><i class="fa-solid fa-users"></i> Manage Users</a>
        <div class="sb-section">Alerts</div>
        <a href="admin-alerts.jsp" class="sb-link"><i class="fa-solid fa-bell"></i> Send Alerts</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">All Flood Readings</div>
    <div class="topbar-user"><div class="tb-avatar admin"><i class="fa-solid fa-crown"></i></div><%= adminName %></div>
</div>
<div class="body-content">
    <!-- Filter Bar -->
    <div class="filter-bar">
        <form method="get" action="admin-readings.jsp">
            <div class="filter-group">
                <label class="filter-lbl"><i class="fa-solid fa-magnifying-glass"></i> Cari Stesen</label>
                <input type="text" name="search" class="filter-input" placeholder="Nama stesen atau lokasi..." value="<%= searchTerm!=null?searchTerm:"" %>">
            </div>
            <div class="filter-group">
                <label class="filter-lbl">Negeri</label>
                <select name="state" class="filter-select">
                    <option value="">Semua Negeri</option>
                    <% String[] states={"Johor","Kedah","Kelantan","Melaka","Negeri Sembilan","Pahang","Perak","Perlis","Pulau Pinang","Sabah","Sarawak","Selangor","Terengganu","Wilayah Persekutuan"};
                       for(String s:states){%><option value="<%= s %>"<%= s.equals(filterState)?" selected":""%>><%= s %></option><%}%>
                </select>
            </div>
            <div class="filter-group">
                <label class="filter-lbl">Tahap Risiko</label>
                <select name="risk" class="filter-select">
                    <option value="">Semua Tahap</option>
                    <% String[] risks={"BAHAYA","AMARAN","WASPADA","NORMAL","SAFE"};
                       for(String rk:risks){%><option value="<%= rk %>"<%= rk.equals(filterRisk)?" selected":""%>><%= rk %></option><%}%>
                </select>
            </div>
            <button type="submit" class="btn-filter"><i class="fa-solid fa-filter"></i> Filter</button>
            <a href="admin-readings.jsp" class="btn-reset"><i class="fa-solid fa-rotate-left"></i> Reset</a>
        </form>
    </div>

    <%
    Map<String,List<Map<String,Object>>> stateMap=new LinkedHashMap<String,List<Map<String,Object>>>();
    int totalCount=0;
    Connection conn=null; PreparedStatement ps=null; ResultSet rs=null;
    try {
        conn=DBConnection.getConnection();
        StringBuilder sql=new StringBuilder("SELECT r.*,o.full_name as officer_name FROM readings r INNER JOIN (SELECT station_name, MAX(reading_id) as max_id FROM readings GROUP BY station_name) latest ON r.reading_id = latest.max_id LEFT JOIN officers o ON r.officer_id=o.officer_id WHERE 1=1 ");
        List<Object> params=new ArrayList<Object>();
        if(filterState!=null&&!filterState.isEmpty()){sql.append("AND r.state=? ");params.add(filterState);}
        if(filterRisk!=null&&!filterRisk.isEmpty()){sql.append("AND r.risk_level=? ");params.add(filterRisk);}
        if(searchTerm!=null&&!searchTerm.trim().isEmpty()){sql.append("AND (r.station_name LIKE ? OR r.location LIKE ?) ");params.add("%"+searchTerm.trim()+"%");params.add("%"+searchTerm.trim()+"%");}
        sql.append("ORDER BY CASE r.risk_level WHEN 'BAHAYA' THEN 1 WHEN 'AMARAN' THEN 2 WHEN 'WASPADA' THEN 3 WHEN 'NORMAL' THEN 4 WHEN 'SAFE' THEN 5 ELSE 6 END,r.state,r.station_name");
        ps=conn.prepareStatement(sql.toString());
        for(int i=0;i<params.size();i++) ps.setString(i+1,(String)params.get(i));
        rs=ps.executeQuery();
        while(rs.next()){
            totalCount++;
            String st=rs.getString("state");
            Map<String,Object> row=new HashMap<String,Object>();
            row.put("station_name",rs.getString("station_name")); row.put("location",rs.getString("location")); row.put("risk_level",rs.getString("risk_level"));
            double wlV=rs.getDouble("water_level_m"); row.put("water_level_m",rs.wasNull()?null:wlV);
            double rfV=rs.getDouble("rainfall_mm");   row.put("rainfall_mm",  rs.wasNull()?null:rfV);
            row.put("trend",rs.getString("trend")); row.put("recorded_date",rs.getTimestamp("recorded_date")); row.put("officer_name",rs.getString("officer_name"));
            if(!stateMap.containsKey(st)) stateMap.put(st,new ArrayList<Map<String,Object>>());
            stateMap.get(st).add(row);
        }
    }catch(Exception e){e.printStackTrace();}finally{if(rs!=null)rs.close();if(ps!=null)ps.close();if(conn!=null)conn.close();}
    %>

    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-chart-column"></i> Senarai Bacaan Banjir</div>
        <span style="font-size:13px;color:var(--muted);font-weight:600;background:var(--light);padding:4px 14px;border-radius:20px;"><%= totalCount %> Bacaan</span>
    </div>

    <% if(stateMap.isEmpty()){ %>
    <div class="empty-state"><i class="fa-solid fa-magnifying-glass"></i><p>Tiada bacaan dijumpai dengan penapis yang dipilih.</p></div>
    <% }else{ %>
    <div style="display:flex;flex-direction:column;gap:18px;">
    <% for(Map.Entry<String,List<Map<String,Object>>> entry:stateMap.entrySet()){
        String sn=entry.getKey(); List<Map<String,Object>> rows=entry.getValue(); %>
    <div style="background:#fff;border-radius:18px;border:1px solid rgba(35,47,114,.09);box-shadow:0 6px 22px rgba(18,19,88,.04);padding:22px;">
        <div style="display:flex;justify-content:space-between;align-items:center;border-bottom:2px solid rgba(35,47,114,.09);padding-bottom:12px;margin-bottom:14px;">
            <div style="font-family:'Outfit',sans-serif;font-size:17px;font-weight:700;color:#232F72;text-transform:uppercase;display:flex;align-items:center;gap:8px;"><i class="fa-solid fa-map" style="color:#36ADA3;font-size:15px;"></i> <%= sn %></div>
            <span style="font-size:11px;color:#36ADA3;font-weight:800;background:rgba(54,173,163,.1);padding:3px 12px;border-radius:20px;"><%= rows.size() %> Stesen</span>
        </div>
        <div style="display:flex;flex-direction:column;gap:10px;">
        <% for(Map<String,Object> r:rows){
            String sName=(String)r.get("station_name"),loc=(String)r.get("location"),rl=(String)r.get("risk_level");
            Double wl=(Double)r.get("water_level_m"),rf=(Double)r.get("rainfall_mm");
            String tr=(String)r.get("trend"),officerNm=(String)r.get("officer_name");
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
        <div style="background:#f8fafc;border-radius:11px;border:1px solid rgba(35,47,114,.05);padding:14px 18px;display:flex;align-items:center;justify-content:space-between;gap:14px;flex-wrap:wrap;transition:all .25s;">
            <div style="flex:2;min-width:190px;">
                <div style="font-family:'Outfit',sans-serif;font-size:15px;font-weight:700;color:#232F72;margin-bottom:3px;"><%= river %></div>
                <div style="font-size:12px;color:#64748b;"><i class="fa-solid fa-location-dot" style="color:#e11d48;font-size:11px;margin-right:3px;"></i> <%= site %>, <%= loc %></div>
                <% if(officerNm!=null){ %><div style="font-size:11px;color:#64748b;margin-top:3px;background:rgba(35,47,114,.06);display:inline-block;padding:2px 9px;border-radius:7px;"><i class="fa-solid fa-user-shield" style="font-size:9px;margin-right:3px;"></i><%= officerNm %></div><% } %>
            </div>
            <div style="flex:1.4;min-width:150px;display:flex;gap:18px;">
                <div><div style="font-size:9.5px;font-weight:700;text-transform:uppercase;color:#64748b;letter-spacing:.5px;margin-bottom:2px;">Aras Air</div><div style="font-size:14px;font-weight:700;color:#36ADA3;"><i class="fa-solid fa-droplet"></i> <%= wl!=null?String.format("%.2f",wl)+" m":"N/A" %></div></div>
                <div><div style="font-size:9.5px;font-weight:700;text-transform:uppercase;color:#64748b;letter-spacing:.5px;margin-bottom:2px;">Hujan</div><div style="font-size:14px;font-weight:700;color:#2F578A;"><i class="fa-solid fa-cloud-rain"></i> <%= rf!=null?String.format("%.1f",rf)+" mm":"N/A" %></div></div>
            </div>
            <div style="display:flex;flex-direction:column;align-items:flex-end;gap:5px;">
                <div style="display:flex;gap:7px;align-items:center;">
                    <span style="font-size:11px;font-weight:700;color:<%= tc %>;padding:3px 9px;border-radius:7px;background:#e2e8f0;"><i class="fa-solid <%= ti %>"></i> <%= tt %></span>
                    <span style="background:<%= bbg %>;color:<%= bt %>;border:<%= bb %>;padding:5px 13px;border-radius:20px;font-size:10.5px;font-weight:800;text-transform:uppercase;"><%= stxt %></span>
                </div>
                <div style="font-size:11px;color:#64748b;"><i class="fa-regular fa-clock" style="margin-right:3px;"></i><%= ds %></div>
            </div>
        </div>
        <% } %>
        </div>
    </div>
    <% } %>
    </div>
    <% } %>
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
</body></html>
