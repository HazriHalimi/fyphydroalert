<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    String officerUsername=(String)session.getAttribute("officerUsername");
    String userType=(String)session.getAttribute("userType");
    if(officerUsername==null||!"officer".equals(userType)){response.sendRedirect("login.jsp");return;}
    String officerName=(String)session.getAttribute("officerName");
    String filterCentre=request.getParameter("centre");
%>
<!DOCTYPE html><html lang="ms"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Senarai Mangsa - HydroAlert</title>
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
        <a href="officer-center.jsp" class="sb-link"><i class="fa-solid fa-house-chimney"></i> Centre List</a>
        <a href="officer-add-center.jsp" class="sb-link"><i class="fa-solid fa-plus-circle"></i> Add Centre</a>
        <div class="sb-section">Victims</div>
        <a href="officer-victims.jsp" class="sb-link active"><i class="fa-solid fa-users"></i> Victims List</a>
        <a href="officer-add-victim.jsp" class="sb-link"><i class="fa-solid fa-user-plus"></i> Register Victim</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">Victims List</div>
    <div class="topbar-user"><div class="tb-avatar officer"><i class="fa-solid fa-user-shield"></i></div><%= officerName %></div>
</div>
<div class="body-content">
    <% if(request.getParameter("added")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Mangsa berjaya didaftarkan!</div><% } %>
    <% if(request.getParameter("checkout")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Mangsa berjaya Check-Out!</div><% } %>
    <% if(request.getParameter("updated")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Maklumat mangsa dikemaskini!</div><% } %>
    <% if(request.getParameter("error")!=null){ %><div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Ralat berlaku. Sila cuba lagi.</div><% } %>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <form method="get" action="officer-victims.jsp">
            <div class="filter-group">
                <label class="filter-lbl">Tapis Pusat Pemindahan</label>
                <select name="centre" class="filter-select">
                    <option value="">-- Semua Pusat --</option>
                    <%
                    Connection connF=null; PreparedStatement psF=null; ResultSet rsF=null;
                    try { connF=DBConnection.getConnection(); psF=connF.prepareStatement("SELECT centre_id,centre_name FROM relief_centres ORDER BY centre_name"); rsF=psF.executeQuery();
                        while(rsF.next()){String cId=String.valueOf(rsF.getInt("centre_id")),cName=rsF.getString("centre_name"),sel=cId.equals(filterCentre)?"selected":"";
                    %><option value="<%= cId %>" <%= sel %>><%= cName %></option><%
                        }
                    }catch(Exception e){e.printStackTrace();}finally{if(rsF!=null)rsF.close();if(psF!=null)psF.close();if(connF!=null)connF.close();}
                    %>
                </select>
            </div>
            <button type="submit" class="btn-filter"><i class="fa-solid fa-filter"></i> Tapis</button>
            <a href="officer-victims.jsp" class="btn-reset"><i class="fa-solid fa-rotate-left"></i> Reset</a>
        </form>
    </div>

    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-users"></i> Senarai Mangsa Banjir</div>
        <a href="officer-add-victim.jsp" class="btn-add"><i class="fa-solid fa-user-plus"></i> Daftar Mangsa</a>
    </div>
    <div class="data-card">
    <table class="data-table">
        <thead><tr>
            <th>Nama Mangsa</th>
            <th>No. IC</th>
            <th>No. Tel</th>
            <th style="text-align:center;">Bil. Keluarga</th>
            <th>Pusat Pemindahan</th>
            <th>Check-In</th>
            <th>Check-Out</th>
            <th>Status</th>
            <th>Tindakan</th>
        </tr></thead>
        <tbody>
        <%
        Connection conn=null; PreparedStatement pstmt=null; ResultSet rs=null; boolean hasData=false;
        try {
            conn=DBConnection.getConnection();
            String sql;
            if(filterCentre!=null&&!filterCentre.isEmpty()){
                sql="SELECT v.*,rc.centre_name FROM victims v LEFT JOIN relief_centres rc ON v.centre_id=rc.centre_id WHERE v.centre_id=? ORDER BY v.check_in_time DESC";
                pstmt=conn.prepareStatement(sql); pstmt.setInt(1,Integer.parseInt(filterCentre));
            } else {
                sql="SELECT v.*,rc.centre_name FROM victims v LEFT JOIN relief_centres rc ON v.centre_id=rc.centre_id ORDER BY v.check_in_time DESC";
                pstmt=conn.prepareStatement(sql);
            }
            rs=pstmt.executeQuery();
            while(rs.next()){
                hasData=true;
                int victimId=rs.getInt("victim_id"); String vstatus=rs.getString("status");
                Timestamp checkOut=rs.getTimestamp("check_out_time");
                String badgeCls="checked_in".equals(vstatus)?"badge-checked_in":"badge-checked_out";
                String statusLabel="checked_in".equals(vstatus)?"Check In":"Check Out";
        %>
        <tr>
            <td><strong><%= rs.getString("full_name") %></strong></td>
            <td><%= rs.getString("ic_number") %></td>
            <td><%= rs.getString("phone")!=null?rs.getString("phone"):"-" %></td>
            <td style="text-align:center;font-weight:700;"><%= rs.getInt("family_count") %></td>
            <td><%= rs.getString("centre_name")!=null?rs.getString("centre_name"):"-" %></td>
            <td style="font-size:12px;"><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("check_in_time")) %></td>
            <td style="font-size:12px;"><%= checkOut!=null?new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(checkOut):"-" %></td>
            <td><span class="badge <%= badgeCls %>"><%= statusLabel %></span></td>
            <td><div style="display:flex;gap:6px;flex-wrap:wrap;">
                <a href="officer-edit-victim.jsp?id=<%= victimId %>" class="act-btn act-edit"><i class="fa-solid fa-pen"></i> Edit</a>
                <% if("checked_in".equals(vstatus)){ %>
                <a href="CheckOutVictimServlet?id=<%= victimId %>" class="act-btn act-checkout" onclick="return confirm('Sahkan Check-Out?')"><i class="fa-solid fa-right-from-bracket"></i> Check-Out</a>
                <% } %>
            </div></td>
        </tr>
        <% } if(!hasData){ %>
        <tr><td colspan="9" style="text-align:center;padding:40px;color:#64748b;">Tiada rekod mangsa ditemui.</td></tr>
        <% }
        }catch(Exception e){%><tr><td colspan="9" style="text-align:center;padding:30px;color:#e11d48;">Ralat: <%= e.getMessage() %></td></tr>
        <%}finally{if(rs!=null)rs.close();if(pstmt!=null)pstmt.close();if(conn!=null)conn.close();}%>
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
