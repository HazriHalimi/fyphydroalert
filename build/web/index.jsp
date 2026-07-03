<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    String officerUsername = (String) session.getAttribute("officerUsername");
    String adminUsername = (String) session.getAttribute("adminUsername");
    String userEmail = (String) session.getAttribute("userEmail");
    
    // Fetch live statistics from database
    int totalStations = 0;
    int activeCentres = 0;
    int activeEvacuees = 0;
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        stmt = conn.createStatement();
        
        // Count total stations
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT station_name) as total FROM readings");
        if(rs.next()) totalStations = rs.getInt("total");
        rs.close();
        
        // Count active relief centres
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM relief_centres WHERE status = 'active' OR status = 'full'");
        if(rs.next()) activeCentres = rs.getInt("total");
        rs.close();
        
        // Count checked-in evacuees (sum of family_count)
        rs = stmt.executeQuery("SELECT SUM(family_count) as total FROM victims WHERE status = 'checked_in'");
        if(rs.next()) activeEvacuees = rs.getInt("total");
        rs.close();
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if(rs != null) rs.close();
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
        } catch(Exception ex) { ex.printStackTrace(); }
    }
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HydroAlert - Portal Amaran & Maklumat Banjir Negara</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/landing.css">
</head>
<body class="landing-page">

    <!-- Sticky Navigation -->
    <nav class="landing-nav">
        <div class="nav-container">
            <a href="<%= request.getContextPath() %>/index.jsp" class="nav-logo">
                <img src="<%= request.getContextPath() %>/images/logo.png" alt="HydroAlert Logo">
                <span>HydroAlert</span>
            </a>
            
            <input type="checkbox" id="nav-toggle" class="nav-toggle-cb" style="display: none;">
            <label for="nav-toggle" class="nav-toggle-label">
                <span class="bar"></span>
                <span class="bar"></span>
                <span class="bar"></span>
            </label>
            
            <div class="nav-menu">
                <% if (userEmail != null) { %>
                    <a href="<%= request.getContextPath() %>/user-places.jsp" class="nav-link active">Utama</a>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/index.jsp" class="nav-link active">Utama</a>
                <% } %>
                <a href="<%= request.getContextPath() %>/readings.jsp" class="nav-link">Stesen & Bacaan</a>
                <a href="<%= request.getContextPath() %>/semak-status.jsp" class="nav-link">Semak Status</a>
                <a href="<%= request.getContextPath() %>/emergency.jsp" class="nav-link">Talian Kecemasan</a>
                
                <!-- Account Dropdown -->
                <div class="account-dropdown-wrap">
                    <% if (userEmail != null) { %>
                        <select onchange="location = this.value;">
                            <option value=""><%= userEmail %></option>
                            <option value="<%= request.getContextPath() %>/user-places.jsp">Laman Utama</option>
                            <option value="<%= request.getContextPath() %>/user-dashboard.jsp">Dashboard Saya</option>
                            <option value="<%= request.getContextPath() %>/user-places.jsp">Negeri Pilihan</option>
                            <option value="<%= request.getContextPath() %>/logout.jsp">Log Keluar</option>
                        </select>
                    <% } else if (officerUsername != null) { %>
                        <select onchange="location = this.value;">
                            <option value="">Pegawai: <%= officerUsername %></option>
                            <option value="<%= request.getContextPath() %>/officer-dashboard.jsp">Dashboard Pegawai</option>
                            <option value="<%= request.getContextPath() %>/logout.jsp">Log Keluar</option>
                        </select>
                    <% } else if (adminUsername != null) { %>
                        <select onchange="location = this.value;">
                            <option value="">Admin: <%= adminUsername %></option>
                            <option value="<%= request.getContextPath() %>/admin-dashboard.jsp">Dashboard Admin</option>
                            <option value="<%= request.getContextPath() %>/logout.jsp">Log Keluar</option>
                        </select>
                    <% } else { %>
                        <select onchange="location = this.value;">
                            <option value="">Akaun / Log Masuk</option>
                            <option value="<%= request.getContextPath() %>/login.jsp">Log Masuk</option>
                            <option value="<%= request.getContextPath() %>/user-register.jsp">Daftar Pengguna</option>
                        </select>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <header class="landing-hero">
        <div class="hero-container">
            <div class="hero-content">
                <span class="hero-badge">SISTEM INTEGRASI PEMANTAUAN BANJIR</span>
                <h2>HYDROALERT</h2>
                <p>Sistem maklumat dan amaran awal banjir masa nyata negara. Memantau stesen telemetri aras air, meramal risiko kenaikan air sungai, dan mengurus pendaftaran pusat pemindahan (PPS) demi keselamatan komuniti anda.</p>
                <div class="hero-buttons">
                    <a href="readings.jsp" class="btn-hero-primary">Lihat Stesen & Bacaan</a>
                    <a href="semak-status.jsp" class="btn-hero-secondary">Semak Status Mangsa</a>
                </div>
            </div>
            <div class="hero-image">
                <img src="images/hero.png" alt="HydroAlert Digital Dashboard Preview">
            </div>
        </div>
    </header>

    <!-- 3 Callout Cards Below Hero -->
    <section class="landing-callout">
        <div class="callout-container">
            <div class="callout-card teal">
                <div class="callout-icon">📡</div>
                <h4>Sistem Amaran Awal</h4>
                <p>Pemantauan aras air sungai dan curahan hujan terkini secara masa nyata terus dari stesen telemetri di seluruh negeri.</p>
                <a href="readings.jsp" class="callout-link">Pantau Bacaan →</a>
            </div>
            <div class="callout-card navy">
                <div class="callout-icon">🗺️</div>
                <h4>Peta Interaktif</h4>
                <p>Visualisasi pemetaan stesen pemantauan dan taburan lokasi Pusat Pemindahan Sementara (PPS) aktif secara geografi.</p>
                <a href="readings.jsp?tab=maps" class="callout-link">Buka Peta →</a>
            </div>
            <div class="callout-card steel">
                <div class="callout-icon">🏠</div>
                <h4>Pengurusan PPS & Mangsa</h4>
                <p>Semakan status pendaftaran kemasukan mangsa banjir ke Pusat Pemindahan Sementara (PPS) dan baki kapasiti penempatan.</p>
                <a href="semak-status.jsp" class="callout-link">Semak Status PPS →</a>
            </div>
        </div>
    </section>

    <!-- Campaign News Section -->
    <section class="section-padding" style="background-color: var(--white);">
        <div class="section-header">
            <h3>PANDUAN & BERITA KESELAMATAN</h3>
            <p>Dapatkan panduan terkini dan laporan keselamatan persediaan menghadapi musim banjir daripada agensi bertauliah.</p>
        </div>
        
        <div class="news-grid">
            <div class="news-card">
                <div class="news-img">
                    <img src="images/news_safety.png" alt="Panduan Keselamatan Banjir">
                </div>
                <div class="news-body">
                    <div class="news-date">PANDUAN KESELAMATAN</div>
                    <h5>Langkah Keselamatan Sebelum & Semasa Banjir</h5>
                    <p>Sediakan beg kecemasan keluarga, pastikan dokumen penting disimpan di tempat tinggi, dan ketahui laluan pemindahan selamat di kawasan anda.</p>
                </div>
            </div>
            
            <div class="news-card">
                <div class="news-img">
                    <img src="images/news_forecast.png" alt="Laporan Cuaca MetMalaysia">
                </div>
                <div class="news-body">
                    <div class="news-date">LAPORAN CUACA</div>
                    <h5>Ramalan Hujan & Kesiapsiagaan Monsun</h5>
                    <p>Ikuti perkembangan amaran cuaca lebat berterusan dari Jabatan Meteorologi Malaysia (METMalaysia) untuk merancang persediaan awal banjir.</p>
                </div>
            </div>
            
            <div class="news-card">
                <div class="news-img">
                    <img src="images/news_center.png" alt="Pusat Pemindahan Sementara">
                </div>
                <div class="news-body">
                    <div class="news-date">PENGURUSAN PPS</div>
                    <h5>Standard Prosedur Kemasukan PPS</h5>
                    <p>Prosedur pendaftaran mangsa banjir (Check-In) oleh pegawai bertugas bagi memastikan pengagihan bantuan makanan dan logistik berjalan lancar.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Subscription Form Banner -->
    <section class="subscribe-banner">
        <div class="subscribe-container">
            <h4>Dapatkan Notifikasi Amaran Banjir</h4>
            <p>Daftar e-mel atau nombor telefon anda di bawah untuk menerima pemberitahuan amaran awal apabila stesen di kawasan anda mencapai tahap amaran/bahaya.</p>
            <form class="subscribe-form" action="user-register.jsp" method="get">
                <input type="email" placeholder="Masukkan alamat e-mel anda..." required>
                <button type="submit" class="btn-subscribe-submit">Daftar Sekarang</button>
            </form>
        </div>
    </section>

    <!-- Video/Info Split Section -->
    <section id="hotlines" class="section-padding">
        <div class="split-section">
            <div class="split-left">
                <h4>Kesiapsiagaan Bersepadu Pengurusan Banjir</h4>
                <p>Portal HydroAlert mengintegrasikan data telemetry aras air dan stesen hujan bagi memudahkan agensi penyelamat dan komuniti bersiap sedia sebelum limpahan air sungai berlaku.</p>
                <p>Kami bekerjasama rapat dengan agensi pengurusan bencana utama:</p>
                <ul>
                    <li>Jabatan Pengairan dan Saliran (JPS)</li>
                    <li>Jabatan Meteorologi Malaysia (METMalaysia)</li>
                    <li>Agensi Pengurusan Bencana Negara (NADMA)</li>
                </ul>
            </div>
            
            <div class="split-right">
                <div class="hotline-card">
                    <h5>🚨 TALIAN KECEMASAN 24 JAM</h5>
                    <div class="hotline-item">
                        <span class="hotline-name">Kecemasan Malaysia (MERS)</span>
                        <span class="hotline-number">999</span>
                    </div>
                    <div class="hotline-item">
                        <span class="hotline-name">Pusat Kawalan Bencana NADMA</span>
                        <span class="hotline-number">03-8064 2400</span>
                    </div>
                    <div class="hotline-item">
                        <span class="hotline-name">Bilik Laporan Banjir JPS Negara</span>
                        <span class="hotline-number">03-2697 2100</span>
                    </div>
                    <div class="hotline-item">
                        <span class="hotline-name">Angkatan Pertahanan Awam (APM)</span>
                        <span class="hotline-number">999 / 03-8920 6000</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Banner -->
    <section class="stats-banner">
        <div class="stats-banner-container">
            <div class="stat-item">
                <h3><%= totalStations %></h3>
                <p>Stesen Dipantau</p>
            </div>
            <div class="stat-item">
                <h3><%= activeCentres %></h3>
                <p>Pusat Pemindahan Aktif</p>
            </div>
            <div class="stat-item">
                <h3><%= activeEvacuees %></h3>
                <p>Mangsa Berdaftar</p>
            </div>
        </div>
    </section>

    <!-- Gallery Section -->
    <section class="section-padding" style="background-color: var(--white);">
        <div class="section-header">
            <h3>GALERI TINDAKAN BENCANA</h3>
            <p>Lensa aktiviti menyelamat, persediaan logistik, dan pemantauan stesen bencana di lapangan.</p>
        </div>
        
        <div class="gallery-grid">
            <div class="gallery-item">
                <img src="images/news_center.png" alt="Setup Evacuation Tent">
                <div class="gallery-overlay">Penyediaan khemah keluarga di PPS</div>
            </div>
            <div class="gallery-item">
                <img src="images/news_forecast.png" alt="Radar Screen">
                <div class="gallery-overlay">Laporan satelit cuaca METMalaysia</div>
            </div>
            <div class="gallery-item">
                <img src="images/news_safety.png" alt="Emergency Box">
                <div class="gallery-overlay">Peti pertolongan cemas & beg sedia</div>
            </div>
            <div class="gallery-item">
                <img src="images/hero.png" alt="Flood Dashboard App">
                <div class="gallery-overlay">Integrasi peta amaran aras air</div>
            </div>
            <div class="gallery-item">
                <img src="images/news_center.png" alt="Food Distribution">
                <div class="gallery-overlay">Pengagihan barangan keperluan makanan</div>
            </div>
            <div class="gallery-item">
                <img src="images/news_forecast.png" alt="Rain Monitoring">
                <div class="gallery-overlay">Data taburan curahan hujan stesen</div>
            </div>
        </div>
    </section>

    <!-- Footer Section -->
    <footer class="landing-footer">
        <div class="footer-container">
            <div class="footer-col footer-about">
                <img src="images/logo.png" alt="HydroAlert Logo">
                <p>HydroAlert ialah inisiatif sistem pengurusan maklumat banjir bersepadu bagi membekalkan status bencana dan kemasukan PPS secara telus dan tepat kepada rakyat Malaysia.</p>
            </div>
            
            <div class="footer-col">
                <h5>Pautan Pintas</h5>
                <ul class="footer-links">
                    <li><a href="index.jsp">Utama</a></li>
                    <li><a href="readings.jsp">Stesen Bacaan</a></li>
                    <li><a href="semak-status.jsp">Semak Status PPS</a></li>
                    <li><a href="login.jsp">Log Masuk</a></li>
                </ul>
            </div>
            
            <div class="footer-col">
                <h5>Kategori Maklumat</h5>
                <ul class="footer-links">
                    <li><a href="readings.jsp?tab=readings">Aras Sungai Terkini</a></li>
                    <li><a href="readings.jsp?tab=graphs">Ramalan Trend Air</a></li>
                    <li><a href="readings.jsp?tab=maps">Peta Stesen & PPS</a></li>
                    <li><a href="#hotlines">Hubungi Agensi Penyelamat</a></li>
                </ul>
            </div>
            
            <div class="footer-col">
                <h5>Visual Media Sosial</h5>
                <div class="instagram-grid">
                    <div class="instagram-img"><img src="images/news_center.png" alt="Insta 1"></div>
                    <div class="instagram-img"><img src="images/news_forecast.png" alt="Insta 2"></div>
                    <div class="instagram-img"><img src="images/news_safety.png" alt="Insta 3"></div>
                    <div class="instagram-img"><img src="images/hero.png" alt="Insta 4"></div>
                    <div class="instagram-img"><img src="images/news_center.png" alt="Insta 5"></div>
                    <div class="instagram-img"><img src="images/news_forecast.png" alt="Insta 6"></div>
                </div>
            </div>
        </div>
        
        <div class="footer-bottom">
            <p>&copy; 2026 HydroAlert System. Hak Cipta Terpelihara. Dikembangkan untuk Kesiapsiagaan Bencana Negara.</p>
            <div class="social-links">
                <a href="#">Facebook</a> | 
                <a href="#">Twitter</a> | 
                <a href="#">Instagram</a>
            </div>
        </div>
    </footer>

</body>
</html>
