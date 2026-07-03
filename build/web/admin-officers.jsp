<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    String adminUsername=(String)session.getAttribute("adminUsername");
    String userType=(String)session.getAttribute("userType");
    if(adminUsername==null||!"admin".equals(userType)){response.sendRedirect("login.jsp");return;}
    String adminName=(String)session.getAttribute("adminName");
%>
<!DOCTYPE html><html lang="ms"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Manage Officers - HydroAlert</title>
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
        <a href="admin-officers.jsp" class="sb-link active"><i class="fa-solid fa-user-shield"></i> Manage Officers</a>
        <a href="admin-readings.jsp" class="sb-link"><i class="fa-solid fa-chart-column"></i> View Readings</a>
        <a href="admin-users.jsp" class="sb-link"><i class="fa-solid fa-users"></i> Manage Users</a>
        <div class="sb-section">Alerts</div>
        <a href="admin-alerts.jsp" class="sb-link"><i class="fa-solid fa-bell"></i> Send Alerts</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">Manage Officers</div>
    <div class="topbar-user"><div class="tb-avatar admin"><i class="fa-solid fa-crown"></i></div><%= adminName %></div>
</div>
<div class="body-content">
    <% if(request.getParameter("added")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Officer added successfully!</div><% } %>
    <% if(request.getParameter("deleted")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Officer deleted successfully!</div><% } %>
    <% if(request.getParameter("updated")!=null){ %><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Officer updated successfully!</div><% } %>
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-user-shield"></i> Officers List</div>
        <a href="admin-add-officer.jsp" class="btn-add"><i class="fa-solid fa-plus"></i> Add Officer</a>
    </div>
    <div class="data-card">
    <table class="data-table">
        <thead><tr><th>Username</th><th>Full Name</th><th>Email</th><th>Phone</th><th>Status</th><th>Created</th><th>Actions</th></tr></thead>
        <tbody>
        <%
        Connection conn=null; Statement stmt=null; ResultSet rs=null;
        try {
            conn=DBConnection.getConnection(); stmt=conn.createStatement();
            rs=stmt.executeQuery("SELECT * FROM officers ORDER BY created_date DESC");
            boolean hasData=false;
            while(rs.next()){
                hasData=true;
                int officerId=rs.getInt("officer_id"); String status=rs.getString("status");
        %>
        <tr>
            <td><strong><%= rs.getString("username") %></strong></td>
            <td><%= rs.getString("full_name") %></td>
            <td><%= rs.getString("email") %></td>
            <td><%= rs.getString("phone")!=null?rs.getString("phone"):"-" %></td>
            <td><span class="badge badge-<%= status %>"><%= status.substring(0,1).toUpperCase()+status.substring(1) %></span></td>
            <td style="font-size:12px;color:#64748b;"><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("created_date")) %></td>
            <td><div style="display:flex;gap:6px;">
                <a href="admin-edit-officer.jsp?id=<%= officerId %>" class="act-btn act-edit"><i class="fa-solid fa-pen"></i> Edit</a>
                <a href="DeleteOfficerServlet?id=<%= officerId %>" class="act-btn act-delete" onclick="return confirm('Delete this officer?')"><i class="fa-solid fa-trash"></i> Delete</a>
            </div></td>
        </tr>
        <% } if(!hasData){ %>
        <tr><td colspan="7" style="text-align:center;padding:40px;color:#64748b;">No officers registered yet.</td></tr>
        <% }
        }catch(Exception e){e.printStackTrace();}finally{if(rs!=null)rs.close();if(stmt!=null)stmt.close();if(conn!=null)conn.close();}
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