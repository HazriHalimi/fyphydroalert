<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <title>Tambah Pegawai - HydroAlert</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Outfit:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/portal.css">
</head>
    <style>
        .form-card {
            background: var(--white);
            border-radius: 18px;
            border: 1px solid var(--border);
            box-shadow: 0 6px 22px rgba(18,19,88,.04);
            padding: 30px;
            max-width: 800px;
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
        .sidebar.admin-sb {
            background: linear-gradient(180deg, #0a0726 0%, #14134a 50%, #1a1960 100%);
        }
    </style>
</head>
<body>
<div class="app">
<aside class="sidebar admin-sb">
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
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-user-shield"></i> Tambah Pegawai Baru</div>
        <a href="admin-officers.jsp" class="btn-cancel" style="padding: 8px 16px;"><i class="fa-solid fa-arrow-left"></i> Kembali</a>
    </div>

    <% if(request.getParameter("error") != null) { %>
        <div class="alert alert-error">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <% if("exists".equals(request.getParameter("error"))) { %>
                Nama pengguna (Username) sudah didaftarkan. Sila pilih nama pengguna lain.
            <% } else { %>
                Gagal menambah pegawai baru. Sila cuba lagi.
            <% } %>
        </div>
    <% } %>

    <div class="form-card">
        <form action="AddOfficerServlet" method="post">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Nama Pengguna (Username) *</label>
                    <input type="text" name="username" class="form-input" required placeholder="cth: hhazmi02">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Kata Laluan *</label>
                    <input type="password" name="password" class="form-input" required placeholder="Minimum 6 aksara" minlength="6">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Nama Penuh *</label>
                    <input type="text" name="fullName" class="form-input" required placeholder="cth: Hazmi Bin Ismail">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Alamat E-mel</label>
                    <input type="email" name="email" class="form-input" placeholder="cth: hazmi@contoh.com">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">No. Telefon</label>
                    <input type="text" name="phone" class="form-input" placeholder="cth: 012-3456789">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status *</label>
                    <select name="status" class="form-input" required>
                        <option value="active">Aktif</option>
                        <option value="inactive">Tidak Aktif</option>
                    </select>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn-submit"><i class="fa-solid fa-user-plus"></i> Tambah Pegawai</button>
                <a href="admin-officers.jsp" class="btn-cancel">Batal</a>
            </div>
        </form>
    </div>
</div>
</div>
</div>
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