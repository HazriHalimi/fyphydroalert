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
        response.sendRedirect("officer-victims.jsp");
        return;
    }

    int victimId = Integer.parseInt(idStr);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String fullName = "", icNumber = "", phone = "", notes = "", vstatus = "";
    int familyCount = 1, centreId = 0;

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement("SELECT * FROM victims WHERE victim_id = ?");
        pstmt.setInt(1, victimId);
        rs = pstmt.executeQuery();

        if(rs.next()) {
            fullName    = rs.getString("full_name");
            icNumber    = rs.getString("ic_number");
            phone       = rs.getString("phone") != null ? rs.getString("phone") : "";
            familyCount = rs.getInt("family_count");
            centreId    = rs.getInt("centre_id");
            vstatus     = rs.getString("status");
            notes       = rs.getString("notes") != null ? rs.getString("notes") : "";
        } else {
            response.sendRedirect("officer-victims.jsp");
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
    <title>Edit Mangsa - HydroAlert</title>
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
    <div class="topbar-title">Edit Mangsa</div>
    <div class="topbar-user"><div class="tb-avatar officer"><i class="fa-solid fa-user-shield"></i></div><%= officerName %></div>
</div>
<div class="body-content">
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-pen-to-square"></i> Edit Maklumat Mangsa</div>
        <a href="officer-victims.jsp" class="btn-cancel" style="padding: 8px 16px;"><i class="fa-solid fa-arrow-left"></i> Kembali</a>
    </div>

    <% if(request.getParameter("error") != null) { %>
        <% String err = request.getParameter("error"); %>
        <% if("overcapacity".equals(err)) { %>
            <div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Kapasiti pusat pemindahan tidak mencukupi! Baki sisa kapasiti: <%= request.getParameter("remaining") %> orang.</div>
        <% } else { %>
            <div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Ralat berlaku. Sila cuba lagi.</div>
        <% } %>
    <% } %>

    <div class="form-card">
        <form action="UpdateVictimServlet" method="post">
            <input type="hidden" name="victimId" value="<%= victimId %>">

            <div class="form-row">
                <div class="form-group" style="flex:2;">
                    <label class="form-label">Nama Penuh Ketua Keluarga *</label>
                    <input type="text" name="fullName" class="form-input" value="<%= fullName %>" required>
                </div>
                <div class="form-group" style="flex:1;">
                    <label class="form-label">No. Kad Pengenalan *</label>
                    <input type="text" name="icNumber" class="form-input" value="<%= icNumber %>" maxlength="20" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">No. Telefon</label>
                    <input type="text" name="phone" class="form-input" value="<%= phone %>">
                </div>
                <div class="form-group">
                    <label class="form-label">Bilangan Ahli Keluarga *</label>
                    <input type="number" name="familyCount" class="form-input" value="<%= familyCount %>" min="1" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group" style="flex:2;">
                    <label class="form-label">Pusat Pemindahan *</label>
                    <select name="centreId" class="form-input" required>
                        <option value="">-- Pilih Pusat --</option>
                        <%
                            Connection conn2 = null;
                            PreparedStatement pstmt2 = null;
                            ResultSet rs2 = null;
                            try {
                                conn2 = DBConnection.getConnection();
                                pstmt2 = conn2.prepareStatement(
                                    "SELECT centre_id, centre_name, location, state, current_count, capacity " +
                                    "FROM relief_centres WHERE (status = 'active' AND current_count < capacity) OR centre_id = ? ORDER BY centre_name");
                                pstmt2.setInt(1, centreId);
                                rs2 = pstmt2.executeQuery();
                                while(rs2.next()) {
                                    int cid = rs2.getInt("centre_id");
                                    int cap = rs2.getInt("capacity");
                                    int cur = rs2.getInt("current_count");
                                    int remaining = cap - cur;
                                    String sel = (cid == centreId) ? "selected" : "";
                        %>
                        <option value="<%= cid %>" <%= sel %>>
                            <%= rs2.getString("centre_name") %> — <%= rs2.getString("location") %>, <%= rs2.getString("state") %> (Sisa: <%= remaining %> / <%= cap %>)
                        </option>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            } finally {
                                if(rs2 != null) rs2.close();
                                if(pstmt2 != null) pstmt2.close();
                                if(conn2 != null) conn2.close();
                            }
                        %>
                    </select>
                </div>
                <div class="form-group" style="flex:1;">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-input">
                        <option value="checked_in"  <%= "checked_in".equals(vstatus)  ? "selected" : "" %>>Check In</option>
                        <option value="checked_out" <%= "checked_out".equals(vstatus) ? "selected" : "" %>>Check Out</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Nota</label>
                <textarea name="notes" class="form-input" rows="3"><%= notes %></textarea>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit"><i class="fa-solid fa-circle-check"></i> Kemaskini Maklumat</button>
                <a href="officer-victims.jsp" class="btn-cancel">Batal</a>
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
