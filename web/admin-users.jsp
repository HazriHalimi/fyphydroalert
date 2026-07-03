<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%
    String adminUsername=(String)session.getAttribute("adminUsername");
    String userType=(String)session.getAttribute("userType");
    if(adminUsername==null||!"admin".equals(userType)){response.sendRedirect("login.jsp");return;}
    String adminName=(String)session.getAttribute("adminName");
    String filterState=request.getParameter("state");
    String filterSubscribed=request.getParameter("subscribed");
%>
<!DOCTYPE html><html lang="ms"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Manage Users - HydroAlert</title>
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
        <a href="admin-readings.jsp" class="sb-link"><i class="fa-solid fa-chart-column"></i> View Readings</a>
        <a href="admin-users.jsp" class="sb-link active"><i class="fa-solid fa-users"></i> Manage Users</a>
        <div class="sb-section">Alerts</div>
        <a href="admin-alerts.jsp" class="sb-link"><i class="fa-solid fa-bell"></i> Send Alerts</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">Manage Users</div>
    <div class="topbar-user"><div class="tb-avatar admin"><i class="fa-solid fa-crown"></i></div><%= adminName %></div>
</div>
<div class="body-content">
    <%
    int totalUsers=0,subscribedUsers=0,unsubscribedUsers=0;
    Connection connS=null; Statement stmtS=null;
    try {
        connS=DBConnection.getConnection(); stmtS=connS.createStatement();
        ResultSet r1=stmtS.executeQuery("SELECT COUNT(*) FROM users"); r1.next(); totalUsers=r1.getInt(1);
        ResultSet r2=stmtS.executeQuery("SELECT COUNT(*) FROM users WHERE subscribed=1"); r2.next(); subscribedUsers=r2.getInt(1);
        unsubscribedUsers=totalUsers-subscribedUsers;
    }catch(Exception e){e.printStackTrace();}finally{if(stmtS!=null)stmtS.close();if(connS!=null)connS.close();}
    %>
    <!-- Stats Grid -->
    <div class="stats-grid" style="grid-template-columns:repeat(auto-fit,minmax(180px,1fr));margin-bottom:20px;">
        <div class="stat-card"><div class="stat-icon" style="background:rgba(35,47,114,.08);color:var(--navy);"><i class="fa-solid fa-users"></i></div><div><div class="stat-info-label">Total Users</div><div class="stat-info-val"><%= totalUsers %></div></div></div>
        <div class="stat-card"><div class="stat-icon" style="background:rgba(22,163,74,.08);color:#16a34a;"><i class="fa-solid fa-bell"></i></div><div><div class="stat-info-label">Subscribed</div><div class="stat-info-val" style="color:#16a34a"><%= subscribedUsers %></div></div></div>
        <div class="stat-card"><div class="stat-icon" style="background:rgba(225,29,72,.08);color:#e11d48;"><i class="fa-solid fa-bell-slash"></i></div><div><div class="stat-info-label">Unsubscribed</div><div class="stat-info-val" style="color:#e11d48"><%= unsubscribedUsers %></div></div></div>
    </div>
    <!-- Filter -->
    <div class="filter-bar">
        <form method="get" action="admin-users.jsp">
            <div class="filter-group">
                <label class="filter-lbl">Negeri</label>
                <select name="state" class="filter-select">
                    <option value="">All States</option>
                    <% String[] states={"Johor","Kedah","Kelantan","Melaka","Negeri Sembilan","Pahang","Perak","Perlis","Pulau Pinang","Sabah","Sarawak","Selangor","Terengganu","Wilayah Persekutuan"};
                       for(String s:states){%><option value="<%= s %>"<%= s.equals(filterState)?" selected":""%>><%= s %></option><%}%>
                </select>
            </div>
            <div class="filter-group">
                <label class="filter-lbl">Subscription</label>
                <select name="subscribed" class="filter-select">
                    <option value="">All Status</option>
                    <option value="1"<%= "1".equals(filterSubscribed)?" selected":""%>>Subscribed</option>
                    <option value="0"<%= "0".equals(filterSubscribed)?" selected":""%>>Unsubscribed</option>
                </select>
            </div>
            <button type="submit" class="btn-filter"><i class="fa-solid fa-filter"></i> Filter</button>
            <a href="admin-users.jsp" class="btn-reset"><i class="fa-solid fa-rotate-left"></i> Reset</a>
        </form>
    </div>
    <div class="sec-title" style="margin-bottom:16px;"><i class="fa-solid fa-users"></i> Registered Users</div>
    <div class="data-card">
    <table class="data-table">
        <thead><tr><th>Email</th><th>Location (State)</th><th>Subscription</th><th>Registered Date</th><th>Actions</th></tr></thead>
        <tbody>
        <%
        Connection conn=null; PreparedStatement pstmt=null; ResultSet rs=null;
        try {
            conn=DBConnection.getConnection();
            StringBuilder sql=new StringBuilder("SELECT * FROM users WHERE 1=1 ");
            List<Object> params=new java.util.ArrayList<Object>();
            if(filterState!=null&&!filterState.isEmpty()){sql.append("AND location=? ");params.add(filterState);}
            if(filterSubscribed!=null&&!filterSubscribed.isEmpty()){sql.append("AND subscribed=? ");params.add(filterSubscribed);}
            sql.append("ORDER BY created_date DESC");
            pstmt=conn.prepareStatement(sql.toString());
            for(int i=0;i<params.size();i++) pstmt.setString(i+1,(String)params.get(i));
            rs=pstmt.executeQuery();
            boolean hasData=false;
            while(rs.next()){
                hasData=true;
                int userId=rs.getInt("user_id"); boolean subscribed=rs.getBoolean("subscribed");
        %>
        <tr>
            <td><strong><%= rs.getString("email") %></strong></td>
            <td><%= rs.getString("location")!=null?rs.getString("location"):"-" %></td>
            <td><span class="badge <%= subscribed?"badge-subscribed":"badge-unsubscribed" %>"><%= subscribed?"Subscribed":"Unsubscribed" %></span></td>
            <td style="font-size:12px;color:#64748b;"><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("created_date")) %></td>
            <td><a href="DeleteUserServlet?id=<%= userId %>" class="act-btn act-delete" onclick="return confirm('Delete this user?')"><i class="fa-solid fa-trash"></i> Delete</a></td>
        </tr>
        <% } if(!hasData){ %>
        <tr><td colspan="5" style="text-align:center;padding:40px;color:#64748b;">No users found.</td></tr>
        <% }
        }catch(Exception e){e.printStackTrace();}finally{if(rs!=null)rs.close();if(pstmt!=null)pstmt.close();if(conn!=null)conn.close();}
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
</body></html>