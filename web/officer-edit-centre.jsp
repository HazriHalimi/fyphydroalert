<%-- 
    Document   : officer-edit-centre
    Created on : Apr 27, 2026, 3:20:16 AM
    Author     : hazzr
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    String officerUsername = (String) session.getAttribute("officerUsername");
    String userType = (String) session.getAttribute("userType");

    if(officerUsername == null || !"officer".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String officerName = (String) session.getAttribute("officerName");

    String idStr = request.getParameter("id");
    if(idStr == null) {
        response.sendRedirect("officer-center.jsp");
        return;
    }

    int centreId = Integer.parseInt(idStr);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String centreName = "", address = "", location = "", state = "", status = "", notes = "";
    int capacity = 0;
    double latitude = 0, longitude = 0;
    boolean hasLat = false, hasLng = false;

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement("SELECT * FROM relief_centres WHERE centre_id = ?");
        pstmt.setInt(1, centreId);
        rs = pstmt.executeQuery();

        if(rs.next()) {
            centreName = rs.getString("centre_name");
            address    = rs.getString("address");
            location   = rs.getString("location");
            state      = rs.getString("state");
            capacity   = rs.getInt("capacity");
            status     = rs.getString("status");
            notes      = rs.getString("notes") != null ? rs.getString("notes") : "";
            latitude   = rs.getDouble("latitude");  hasLat = !rs.wasNull();
            longitude  = rs.getDouble("longitude"); hasLng = !rs.wasNull();
        } else {
            response.sendRedirect("officer-center.jsp");
            return;
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
    <title>Edit Pusat Pemindahan - HydroAlert</title>
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
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-pen"></i> Kemaskini Maklumat Pusat Pemindahan</div>
        <a href="officer-center.jsp" class="btn-cancel" style="padding: 8px 16px;"><i class="fa-solid fa-arrow-left"></i> Kembali</a>
    </div>

    <% if(request.getParameter("error") != null) { %>
        <div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Ralat berlaku. Sila cuba lagi.</div>
    <% } %>

    <div class="form-card">
        <form action="UpdateCentreServlet" method="post">
            <input type="hidden" name="centreId" value="<%= centreId %>">

            <div class="form-group">
                <label class="form-label">Nama Pusat Pemindahan *</label>
                <input type="text" name="centreName" class="form-input" value="<%= centreName %>" required>
            </div>

            <div class="form-group">
                <label class="form-label">Alamat Penuh *</label>
                <input type="text" name="address" class="form-input" value="<%= address %>" required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Daerah / Kawasan *</label>
                    <input type="text" name="location" class="form-input" value="<%= location %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Negeri *</label>
                    <select name="state" class="form-input" required>
                        <option value="">-- Pilih Negeri --</option>
                        <% String[] states = {"Johor","Kedah","Kelantan","Melaka","Negeri Sembilan",
                           "Pahang","Perak","Perlis","Pulau Pinang","Sabah","Sarawak",
                           "Selangor","Terengganu","Wilayah Persekutuan"};
                           for(String s : states) { %>
                        <option value="<%= s %>" <%= s.equals(state) ? "selected" : "" %>><%= s %></option>
                        <% } %>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Kapasiti Maksimum (orang) *</label>
                    <input type="number" name="capacity" class="form-input" value="<%= capacity %>" min="1" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-input">
                        <option value="active"  <%= "active".equals(status)  ? "selected" : "" %>>Aktif</option>
                        <option value="full"    <%= "full".equals(status)    ? "selected" : "" %>>Penuh</option>
                        <option value="closed"  <%= "closed".equals(status)  ? "selected" : "" %>>Ditutup</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Latitud</label>
                    <input type="number" name="latitude" class="form-input" value="<%= hasLat ? latitude : "" %>" step="0.000001">
                </div>
                <div class="form-group">
                    <label class="form-label">Longitud</label>
                    <input type="number" name="longitude" class="form-input" value="<%= hasLng ? longitude : "" %>" step="0.000001">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Nota</label>
                <textarea name="notes" class="form-input" rows="3"><%= notes %></textarea>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit"><i class="fa-solid fa-circle-check"></i> Kemaskini Pusat</button>
                <a href="officer-center.jsp" class="btn-cancel">Batal</a>
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
