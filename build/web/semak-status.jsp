<%-- 
    Document   : semak-status
    Author     : hazzr
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%@ include file="header.jsp" %>
<%
    // Semak Status - accessible to all (no login required)
    String icInput       = request.getParameter("ic");
    String fullName      = null;
    String vstatus       = null;
    String centreName    = null;
    String centreAddress = null;
    String centreState   = null;
    String centreLocation= null;
    int    familyCount   = 0;
    Timestamp checkIn    = null;
    Timestamp checkOut   = null;
    boolean searched     = false;
    boolean found        = false;
    String searchError   = null;

    if(icInput != null && !icInput.trim().isEmpty()) {
        searched = true;
        icInput  = icInput.trim();

        Connection connCheck   = null;
        PreparedStatement pstmtCheck = null;
        ResultSet rsCheck      = null;

        try {
            connCheck  = DBConnection.getConnection();
            String sql = "SELECT v.full_name, v.phone, v.family_count, v.status, " +
                         "v.check_in_time, v.check_out_time, " +
                         "rc.centre_name, rc.address, rc.location, rc.state " +
                         "FROM victims v " +
                         "LEFT JOIN relief_centres rc ON v.centre_id = rc.centre_id " +
                         "WHERE v.ic_number = ? " +
                         "ORDER BY v.check_in_time DESC LIMIT 1";
            pstmtCheck = connCheck.prepareStatement(sql);
            pstmtCheck.setString(1, icInput);
            rsCheck    = pstmtCheck.executeQuery();

            if(rsCheck.next()) {
                found         = true;
                fullName      = rsCheck.getString("full_name");
                familyCount   = rsCheck.getInt("family_count");
                vstatus       = rsCheck.getString("status");
                checkIn       = rsCheck.getTimestamp("check_in_time");
                checkOut      = rsCheck.getTimestamp("check_out_time");
                centreName    = rsCheck.getString("centre_name");
                centreAddress = rsCheck.getString("address");
                centreLocation= rsCheck.getString("location");
                centreState   = rsCheck.getString("state");
            }

        } catch(Exception e) {
            searchError = e.getMessage();
            e.printStackTrace();
        } finally {
            if(rsCheck    != null) { try { rsCheck.close(); } catch(Exception ex) {} }
            if(pstmtCheck != null) { try { pstmtCheck.close(); } catch(Exception ex) {} }
            if(connCheck  != null) { try { connCheck.close(); } catch(Exception ex) {} }
        }
    }
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Semak Status Penempatan Banjir - HydroAlert</title>
    <meta name="description" content="Semak status penempatan mangsa banjir menggunakan No. Kad Pengenalan (IC). HydroAlert - Portal Amaran & Maklumat Banjir Negara.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy-blue:   #121358;
            --deep-blue:   #1a1f6e;
            --teal:        #36ada3;
            --white:       #ffffff;
            --light-gray:  #f4f6fb;
            --border-color:#e8ecf4;
            --text-dark:   #1e293b;
            --text-light:  #64748b;
            --transition:  all 0.25s ease;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--light-gray);
            color: var(--text-dark);
            min-height: 100vh;
        }

        /* ---- Page wrapper ---- */
        .semak-page {
            min-height: calc(100vh - 70px);
            padding: 60px 16px 80px;
        }

        .semak-wrapper {
            max-width: 750px;
            margin: 0 auto;
        }

        /* ---- Title ---- */
        .semak-title {
            text-align: center;
            margin-bottom: 35px;
        }
        .semak-title h1 {
            font-family: 'Outfit', sans-serif;
            color: var(--navy-blue);
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 6px;
            letter-spacing: -0.5px;
        }
        .semak-title p {
            color: var(--text-light);
            font-size: 14px;
        }

        /* ---- Search card ---- */
        .search-card {
            background: var(--white);
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(18,19,88,.05);
            border: 1px solid var(--border-color);
            padding: 35px;
            margin-bottom: 30px;
        }
        .search-card label {
            display: block;
            font-weight: 700;
            color: var(--navy-blue);
            margin-bottom: 10px;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .search-row {
            display: flex;
            gap: 12px;
        }
        .search-row input {
            flex: 1;
            padding: 12px 18px;
            border: 1.5px solid var(--border-color);
            background: var(--light-gray);
            border-radius: 10px;
            font-size: 15px;
            color: var(--text-dark);
            font-family: 'Inter', sans-serif;
            transition: var(--transition);
        }
        .search-row input:focus {
            outline: none;
            border-color: var(--teal);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(54,173,163,.15);
        }
        .btn-search {
            background: linear-gradient(135deg, var(--teal), #2b948a);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 50px;
            font-size: 15px;
            font-weight: 700;
            font-family: 'Outfit', sans-serif;
            cursor: pointer;
            box-shadow: 0 6px 18px rgba(54,173,163,.2);
            transition: var(--transition);
        }
        .btn-search:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 22px rgba(54,173,163,.3);
        }

        /* ---- Info notice ---- */
        .info-notice {
            background: rgba(251,191,36,.08);
            border-left: 4px solid #d97706;
            border-radius: 0 10px 10px 0;
            padding: 16px 20px;
            font-size: 13px;
            color: #b45309;
            border: 1px solid rgba(251,191,36,.15);
            border-left-width: 4px;
            margin-top: 20px;
        }

        /* ---- Result card ---- */
        .result-card {
            background: var(--white);
            border-radius: 18px;
            border: 1px solid var(--border-color);
            box-shadow: 0 10px 30px rgba(18,19,88,.05);
            overflow: hidden;
            margin-bottom: 30px;
        }
        .result-header {
            padding: 24px 30px;
            color: white;
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .result-header.checked_in  { background: linear-gradient(135deg, var(--deep-blue), var(--navy-blue)); }
        .result-header.checked_out { background: linear-gradient(135deg, #475569, #64748b); }
        .result-header h3 {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            font-size: 20px;
            font-weight: 800;
        }
        .result-header p {
            margin: 4px 0 0;
            font-size: 13px;
            opacity: .85;
        }
        .result-icon { font-size: 36px; line-height: 1; }
        .result-body { padding: 30px; }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 24px;
        }
        .info-item label {
            font-size: 11px;
            color: var(--text-light);
            text-transform: uppercase;
            letter-spacing: .5px;
            display: block;
            margin-bottom: 6px;
            font-weight: 700;
        }
        .info-item span {
            font-size: 15px;
            color: var(--text-dark);
            font-weight: 600;
        }

        .divider {
            border: none;
            border-top: 1.5px solid var(--border-color);
            margin: 20px 0;
        }

        .centre-block {
            background: var(--light-gray);
            border-left: 4px solid var(--teal);
            border-radius: 0 12px 12px 0;
            padding: 20px 24px;
            border: 1px solid var(--border-color);
            border-left-width: 4px;
        }
        .centre-block h4 {
            margin: 0 0 10px;
            color: var(--navy-blue);
            font-family: 'Outfit', sans-serif;
            font-size: 16px;
            font-weight: 700;
        }
        .centre-block p {
            margin: 6px 0;
            color: var(--text-dark);
            font-size: 14px;
        }

        .status-pill {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: .5px;
        }
        .status-pill.checked_in  { background: rgba(54,173,163,.1); color: var(--teal); }
        .status-pill.checked_out { background: #e2e8f0; color: var(--text-light); }

        /* ---- Not found card ---- */
        .not-found-card {
            background: var(--white);
            border-radius: 18px;
            border: 1px solid var(--border-color);
            box-shadow: 0 10px 30px rgba(18,19,88,.04);
            padding: 45px 35px;
            text-align: center;
        }
        .not-found-card .nf-icon { font-size: 54px; margin-bottom: 20px; }
        .not-found-card h3 {
            font-family: 'Outfit', sans-serif;
            color: var(--navy-blue);
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 10px;
        }
        .not-found-card p {
            font-size: 14px;
            color: var(--text-light);
            margin: 6px 0;
        }

        /* ---- Responsive ---- */
        @media (max-width: 576px) {
            .semak-title h1 { font-size: 22px; }
            .search-card { padding: 24px 18px; }
            .search-row { flex-direction: column; }
            .btn-search { width: 100%; }
            .info-grid { grid-template-columns: 1fr; }
            .result-body { padding: 20px; }
        }
    </style>
</head>
<body>

<div class="semak-page">
    <div class="semak-wrapper">

        <div class="semak-title">
            <h1>🔍 Semak Status Penempatan Banjir</h1>
            <p>Masukkan No. Kad Pengenalan untuk menyemak status pendaftaran mangsa banjir</p>
        </div>

        <!-- Search Form -->
        <div class="search-card">
            <form method="get" action="<%= request.getContextPath() %>/semak-status.jsp">
                <label for="ic">No. Kad Pengenalan (IC)</label>
                <div class="search-row">
                    <input type="text"
                           id="ic"
                           name="ic"
                           placeholder="cth: 900101-14-5678"
                           maxlength="20"
                           value="<%= icInput != null ? icInput : "" %>"
                           autocomplete="off">
                    <button type="submit" class="btn-search">🔍 Semak</button>
                </div>
            </form>

            <div class="info-notice">
                ℹ️ Maklumat ini hanya untuk rujukan mangsa banjir yang telah didaftarkan oleh pegawai.
                Untuk pertanyaan lanjut, sila hubungi pusat kawalan banjir terdekat.
            </div>
        </div>

        <!-- Results -->
        <% if(searchError != null) { %>
            <div class="not-found-card">
                <div class="nf-icon">⚠️</div>
                <h3>Ralat Sistem</h3>
                <p>Tidak dapat menyambung ke pangkalan data. Sila cuba sebentar lagi.</p>
            </div>

        <% } else if(searched && found) {
               boolean isCheckedIn = "checked_in".equals(vstatus);
        %>
            <div class="result-card">
                <div class="result-header <%= vstatus %>">
                    <div class="result-icon"><%= isCheckedIn ? "🏠" : "✅" %></div>
                    <div>
                        <h3><%= isCheckedIn ? "Sedang Berada di Pusat Pemindahan" : "Telah Keluar dari Pusat Pemindahan" %></h3>
                        <p>Status dikemaskini berdasarkan rekod terkini</p>
                    </div>
                </div>

                <div class="result-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Nama Penuh</label>
                            <span><%= fullName %></span>
                        </div>
                        <div class="info-item">
                            <label>No. IC</label>
                            <span><%= icInput %></span>
                        </div>
                        <div class="info-item">
                            <label>Bil. Ahli Keluarga</label>
                            <span><%= familyCount %> orang</span>
                        </div>
                        <div class="info-item">
                            <label>Status</label>
                            <span class="status-pill <%= vstatus %>">
                                <%= isCheckedIn ? "Sedang Menginap" : "Telah Keluar" %>
                            </span>
                        </div>
                        <div class="info-item">
                            <label>Masa Daftar Masuk</label>
                            <span><%= checkIn != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(checkIn) : "-" %></span>
                        </div>
                        <div class="info-item">
                            <label>Masa Daftar Keluar</label>
                            <span><%= checkOut != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(checkOut) : "-" %></span>
                        </div>
                    </div>

                    <hr class="divider">

                    <% if(centreName != null) { %>
                    <div class="centre-block">
                        <h4>🏫 Maklumat Pusat Pemindahan</h4>
                        <p><strong><%= centreName %></strong></p>
                        <p>📍 <%= centreAddress != null ? centreAddress : "" %></p>
                        <p>🗺️ <%= centreLocation != null ? centreLocation : "" %>, <%= centreState != null ? centreState : "" %></p>
                    </div>
                    <% } else { %>
                    <div class="centre-block">
                        <h4>🏫 Pusat Pemindahan</h4>
                        <p>Maklumat pusat tidak tersedia.</p>
                    </div>
                    <% } %>
                </div>
            </div>

        <% } else if(searched && !found) { %>
            <div class="not-found-card">
                <div class="nf-icon">❌</div>
                <h3>Rekod Tidak Dijumpai</h3>
                <p>Tiada rekod pendaftaran banjir untuk No. IC: <strong><%= icInput %></strong></p>
                <p style="margin-top:12px; font-weight:700;">Kemungkinan sebab:</p>
                <p>• No. IC tidak tepat atau belum didaftarkan</p>
                <p>• Pendaftaran belum dilakukan oleh pegawai bertugas</p>
                <p style="margin-top:20px; color:var(--teal); font-weight:700;">
                    Sila hubungi pegawai PPS terdekat untuk bantuan pendaftaran.
                </p>
            </div>
        <% } %>

    </div>
</div>


</body>
</html>
