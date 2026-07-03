<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    String officerUsername = (String) session.getAttribute("officerUsername");
    String userType        = (String) session.getAttribute("userType");
    Integer officerId      = (Integer) session.getAttribute("officerId");

    if(officerUsername == null || !"officer".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String officerName = (String) session.getAttribute("officerName");

    // Load fresh data from DB
    String dbEmail    = "";
    String dbPhone    = "";
    String dbFullName = "";

    Connection conn   = null;
    PreparedStatement pstmt = null;
    ResultSet rs      = null;

    try {
        conn  = DBConnection.getConnection();
        pstmt = conn.prepareStatement(
            "SELECT full_name, email, phone FROM officers WHERE officer_id = ?");
        pstmt.setInt(1, officerId);
        rs = pstmt.executeQuery();
        if(rs.next()) {
            dbFullName = rs.getString("full_name");
            dbEmail    = rs.getString("email")    != null ? rs.getString("email") : "";
            dbPhone    = rs.getString("phone")    != null ? rs.getString("phone") : "";
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
    <title>Profil Pegawai - HydroAlert</title>
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
            max-width: 650px;
            margin: 0 auto;
        }
        .form-group {
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
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
        .form-input[readonly] {
            background: #f1f5f9;
            color: #64748b;
            cursor: not-allowed;
            border-color: #e2e8f0;
        }
        .form-hint {
            font-size: 11px;
            color: var(--muted);
            margin-top: 2px;
        }
        .section-title-bar {
            font-size: 12px;
            font-weight: 700;
            color: var(--teal);
            text-transform: uppercase;
            letter-spacing: .5px;
            margin: 28px 0 14px;
            padding-bottom: 6px;
            border-bottom: 2px solid rgba(54,173,163,.15);
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .btn-submit {
            background: linear-gradient(135deg, var(--teal), #2b948a);
            color: #fff;
            padding: 11px 24px;
            border: none;
            border-radius: 50px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: var(--tr);
            display: inline-flex;
            align-items: center;
            gap: 6px;
            width: 100%;
            justify-content: center;
        }
        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(54,173,163,.25);
        }
        .profile-avatar-sec {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 24px;
        }
        .avatar-circle {
            width: 76px;
            height: 76px;
            background: linear-gradient(135deg, var(--teal), var(--navy));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            color: white;
            margin-bottom: 12px;
            border: 3px solid rgba(255,255,255,0.8);
            box-shadow: 0 4px 12px rgba(18,19,88,0.15);
        }
        .avatar-name {
            font-family: 'Outfit', sans-serif;
            font-size: 17px;
            font-weight: 700;
            color: var(--navy);
        }
        .avatar-user {
            font-size: 12px;
            color: var(--muted);
            margin-top: 2px;
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
    <div class="topbar-title">Profil Pegawai</div>
    <div class="topbar-user"><div class="tb-avatar officer"><i class="fa-solid fa-user-shield"></i></div><%= officerName %></div>
</div>
<div class="body-content">
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-user-gear"></i> Tetapan Profil Peribadi</div>
        <a href="officer-dashboard.jsp" class="btn-reset" style="padding: 8px 16px;"><i class="fa-solid fa-arrow-left"></i> Kembali</a>
    </div>

    <%
        String msg = request.getParameter("msg");
    %>
    <% if("updated".equals(msg)) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Profil berjaya dikemaskini!</div>
    <% } else if("emailtaken".equals(msg)) { %>
        <div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Alamat e-mel sudah didaftarkan oleh pegawai lain.</div>
    <% } else if("pwmismatch".equals(msg)) { %>
        <div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Kata laluan pengesahan tidak sepadan. Sila cuba lagi.</div>
    <% } else if("error".equals(msg)) { %>
        <div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Ralat berlaku. Sila cuba lagi.</div>
    <% } %>

    <div class="form-card">
        <div class="profile-avatar-sec">
            <div class="avatar-circle"><i class="fa-solid fa-user-shield"></i></div>
            <div class="avatar-name"><%= dbFullName %></div>
            <div class="avatar-user">@<%= officerUsername %></div>
        </div>

        <form action="UpdateOfficerProfileServlet" method="post" onsubmit="return validatePasswords()">
            <!-- Account Info -->
            <div class="section-title-bar"><i class="fa-solid fa-lock"></i> Maklumat Akaun</div>
            <div class="form-group">
                <label class="form-label">Username</label>
                <input type="text" class="form-input" value="<%= officerUsername %>" readonly>
                <span class="form-hint">Nama pengguna (username) tidak boleh diubah.</span>
            </div>

            <!-- Contact Info -->
            <div class="section-title-bar"><i class="fa-solid fa-address-book"></i> Hubungan & Komunikasi</div>
            <div class="form-group">
                <label class="form-label">Alamat E-mel *</label>
                <input type="email" name="email" class="form-input" value="<%= dbEmail %>" required>
            </div>
            <div class="form-group">
                <label class="form-label">No. Telefon</label>
                <input type="text" name="phone" class="form-input" value="<%= dbPhone %>" placeholder="e.g., 012-3456789">
            </div>

            <!-- Change Password -->
            <div class="section-title-bar"><i class="fa-solid fa-key"></i> Kemaskini Kata Laluan</div>
            <div class="form-group">
                <label class="form-label">Kata Laluan Baru</label>
                <input type="password" id="newPassword" name="password" class="form-input" placeholder="Masukkan kata laluan baru (biarkan kosong jika tidak mahu tukar)">
                <span class="form-hint">Biarkan kosong jika tiada perubahan kata laluan.</span>
            </div>
            <div class="form-group">
                <label class="form-label">Sahkan Kata Laluan Baru</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-input" placeholder="Masukkan semula kata laluan baru">
                <small id="pwMatchMsg" style="display:none; font-weight:700; margin-top:4px; font-size:12px;"></small>
            </div>

            <button type="submit" class="btn-submit" style="margin-top: 15px;"><i class="fa-solid fa-floppy-disk"></i> Simpan Perubahan</button>
        </form>
    </div>
</div>
</div>
</div>

<script>
document.getElementById('confirmPassword').addEventListener('input', function() {
    var pw1 = document.getElementById('newPassword').value;
    var pw2 = this.value;
    var msg = document.getElementById('pwMatchMsg');

    if(pw2 === '') { msg.style.display = 'none'; return; }

    if(pw1 === pw2) {
        msg.textContent   = '✓ Kata laluan sepadan';
        msg.style.color   = '#166534';
        msg.style.display = 'block';
    } else {
        msg.textContent   = '✗ Kata laluan tidak sepadan';
        msg.style.color   = '#991b1b';
        msg.style.display = 'block';
    }
});

function validatePasswords() {
    var pw1 = document.getElementById('newPassword').value;
    var pw2 = document.getElementById('confirmPassword').value;

    if(pw1 === '' && pw2 === '') return true;

    if(pw1 !== '' && pw2 === '') {
        alert('Sila sahkan kata laluan baru anda.');
        return false;
    }
    if(pw1 === '' && pw2 !== '') {
        alert('Sila masukkan kata laluan baru terlebih dahulu.');
        return false;
    }
    if(pw1 !== pw2) {
        alert('Kata laluan tidak sepadan. Sila cuba lagi.');
        return false;
    }
    return true;
}
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
</body>
</html>
