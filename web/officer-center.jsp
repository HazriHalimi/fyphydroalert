<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    String officerUsername=(String)session.getAttribute("officerUsername");
    String userType=(String)session.getAttribute("userType");
    if(officerUsername==null||!"officer".equals(userType)){response.sendRedirect("login.jsp");return;}
    String officerName=(String)session.getAttribute("officerName");
    Integer officerId=(Integer)session.getAttribute("officerId");
%>
<!DOCTYPE html><html lang="ms"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Pusat Pemindahan - HydroAlert</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Outfit:wght@400;600;700;800;900&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/portal.css">
</head><body><div class="app">
<aside class="sidebar">
    <div class="sb-brand"><img src="images/logo.png" alt="HydroAlert" onerror="this.style.display='none'"><div><div class="sb-brand-name">HydroAlert</div><div class="sb-brand-role">Officer Portal</div></div></div>
    <nav class="sb-nav">
        <div class="sb-section">Overview</div>
        <a href="officer-dashboard.jsp" class="sb-link"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>
        <div class="sb-section">Readings</div>
        <a href="officer-add-reading.jsp" class="sb-link"><i class="fa-solid fa-plus-circle"></i> Add Reading</a>
        <a href="officer-my-readings.jsp" class="sb-link"><i class="fa-solid fa-clipboard-list"></i> My Readings</a>
        <div class="sb-section">Relief Centres</div>
        <a href="officer-center.jsp" class="sb-link active"><i class="fa-solid fa-house-chimney"></i> Centre List</a>
        <a href="officer-add-center.jsp" class="sb-link"><i class="fa-solid fa-plus-circle"></i> Add Centre</a>
        <div class="sb-section">Victims</div>
        <a href="officer-victims.jsp" class="sb-link"><i class="fa-solid fa-users"></i> Victims List</a>
        <a href="officer-add-victim.jsp" class="sb-link"><i class="fa-solid fa-user-plus"></i> Register Victim</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">Pusat Pemindahan</div>
    <div class="topbar-user"><div class="tb-avatar officer"><i class="fa-solid fa-user-shield"></i></div><%= officerName %></div>
</div>
<div class="body-content">
    <% if(request.getParameter("added")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Pusat berjaya ditambah!</div><% } %>
    <% if(request.getParameter("deleted")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Pusat berjaya dipadam!</div><% } %>
    <% if(request.getParameter("updated")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Pusat berjaya dikemaskini!</div><% } %>
    <% if(request.getParameter("error")!=null){ %><div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Ralat berlaku. Sila cuba lagi.</div><% } %>
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-house-chimney"></i> Senarai Pusat Pemindahan</div>
        <a href="officer-add-center.jsp" class="btn-add"><i class="fa-solid fa-plus"></i> Tambah Pusat</a>
    </div>
    <div class="data-card">
    <table class="data-table">
        <thead><tr>
            <th>Nama Pusat</th>
            <th>Lokasi / Negeri</th>
            <th style="text-align:center;">Kapasiti</th>
            <th style="min-width:130px;">Pengisian</th>
            <th>Status</th>
            <th>Tarikh Dicipta</th>
            <th>Tindakan</th>
        </tr></thead>
        <tbody>
        <%
        Connection conn=null; PreparedStatement pstmt=null; ResultSet rs=null; boolean hasData=false;
        try {
            conn=DBConnection.getConnection();
            pstmt=conn.prepareStatement("SELECT rc.*,o.full_name as officer_name FROM relief_centres rc LEFT JOIN officers o ON rc.created_by=o.officer_id ORDER BY rc.created_date DESC");
            rs=pstmt.executeQuery();
            while(rs.next()){
                hasData=true;
                int centreId=rs.getInt("centre_id"),capacity=rs.getInt("capacity"),current=rs.getInt("current_count");
                String status=rs.getString("status");
                int pct=(capacity>0)?(int)((current*100.0)/capacity):0;
                String barClass=pct<50?"cap-low":pct<75?"cap-medium":pct<100?"cap-high":"cap-full";
                String statusBadge="badge-"+status;
        %>
        <tr>
            <td><strong><%= rs.getString("centre_name") %></strong><div class="td-sub"><%= rs.getString("address") %></div></td>
            <td><%= rs.getString("location") %><div class="td-sub"><%= rs.getString("state") %></div></td>
            <td style="text-align:center;font-weight:700;"><%= current %> / <%= capacity %></td>
            <td>
                <div class="cap-bar-wrap"><div class="cap-bar <%= barClass %>" style="width:<%= Math.min(pct,100) %>%;"></div></div>
                <div class="cap-text"><%= pct %>% penuh</div>
            </td>
            <td><span class="badge <%= statusBadge %>"><%= status.toUpperCase() %></span></td>
            <td style="font-size:12px;color:#64748b;"><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("created_date")) %></td>
            <td><div style="display:flex;gap:6px;flex-wrap:wrap;">
                <a href="officer-edit-centre.jsp?id=<%= centreId %>" class="act-btn act-edit"><i class="fa-solid fa-pen"></i> Edit</a>
                <a href="officer-victims.jsp?centre=<%= centreId %>" class="act-btn act-edit" style="background:rgba(35,47,114,0.08);color:var(--navy);"><i class="fa-solid fa-users"></i> Mangsa</a>
                <% if(current < capacity && "active".equals(status)) { %>
                    <a href="officer-add-victim.jsp?centreId=<%= centreId %>" class="act-btn act-checkout"><i class="fa-solid fa-user-plus"></i> Daftar</a>
                <% } else { %>
                    <span class="act-btn" style="background:rgba(100,116,139,0.06);color:#cbd5e1;cursor:not-allowed;border:1px solid rgba(100,116,139,0.1);"><i class="fa-solid fa-user-plus"></i> Daftar (Penuh)</span>
                <% } %>
                <a href="DeleteCentreServlet?id=<%= centreId %>" class="act-btn act-delete" onclick="return confirm('Padam pusat ini?')"><i class="fa-solid fa-trash"></i> Padam</a>
            </div></td>
        </tr>
        <% } if(!hasData){ %>
        <tr><td colspan="7" style="text-align:center;padding:40px;color:#64748b;">Tiada pusat pemindahan didaftarkan lagi.</td></tr>
        <% } } catch(Exception e){ %><tr><td colspan="7" style="text-align:center;padding:30px;color:#e11d48;">Ralat: <%= e.getMessage() %></td></tr>
        <% }finally{if(rs!=null)rs.close();if(pstmt!=null)pstmt.close();if(conn!=null)conn.close();} %>
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
