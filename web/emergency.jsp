<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<style>
/* ---- Emergency Page Layout ---- */
.emergency-wrapper {
    max-width: 900px;
    margin: 40px auto;
    padding: 0 20px 60px;
}

.emergency-title {
    text-align: center;
    margin-bottom: 40px;
}

.emergency-title h2 {
    font-family: 'Outfit', sans-serif;
    color: var(--navy-blue);
    font-size: 32px;
    font-weight: 800;
    margin-bottom: 8px;
    letter-spacing: -0.5px;
}

.emergency-title p {
    color: var(--text-light);
    font-size: 15px;
}

/* ---- Hotline Cards ---- */
.hotline-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
}

.hotline-item-card {
    background: var(--white);
    border-radius: 18px;
    border: 1px solid var(--border-color);
    box-shadow: 0 8px 24px rgba(18, 19, 88, 0.02);
    padding: 25px;
    transition: var(--transition);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.hotline-item-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 30px rgba(18, 19, 88, 0.05);
    border-color: rgba(54, 173, 163, 0.2);
}

.hotline-info-top {
    margin-bottom: 20px;
}

.hotline-icon-title {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
}

.hotline-icon {
    font-size: 24px;
    color: #e11d48;
    background: rgba(225, 29, 72, 0.08);
    width: 48px;
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
}

.hotline-item-card.primary-alert .hotline-icon {
    background: rgba(225, 29, 72, 0.1);
    color: #e11d48;
}

.hotline-item-card.agency-alert .hotline-icon {
    background: rgba(35, 47, 114, 0.08);
    color: var(--navy-blue);
}

.hotline-agency-title {
    font-family: 'Outfit', sans-serif;
    font-size: 18px;
    font-weight: 700;
    color: var(--navy-blue);
    margin: 0;
}

.hotline-desc {
    font-size: 13px;
    color: var(--text-light);
    line-height: 1.5;
    margin: 0;
}

.hotline-action {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: var(--light-gray);
    padding: 12px 18px;
    border-radius: 10px;
    border: 1px solid var(--border-color);
}

.hotline-num {
    font-family: 'Outfit', sans-serif;
    font-weight: 800;
    font-size: 18px;
    color: var(--navy-blue);
}

.btn-call {
    background: linear-gradient(135deg, var(--teal), #2b948a);
    color: white !important;
    border: none;
    padding: 6px 14px;
    border-radius: 50px;
    font-size: 12px;
    font-weight: 700;
    text-decoration: none;
    transition: var(--transition);
    display: flex;
    align-items: center;
    gap: 6px;
    box-shadow: 0 4px 10px rgba(54, 173, 163, 0.2);
}

.btn-call:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 15px rgba(54, 173, 163, 0.3);
}

/* ---- Important Notice ---- */
.emergency-notice {
    background: rgba(251, 191, 36, 0.08);
    border-left: 4px solid #d97706;
    border-radius: 0 12px 12px 0;
    padding: 20px;
    font-size: 14px;
    color: #b45309;
    border: 1px solid rgba(251, 191, 36, 0.15);
    border-left-width: 4px;
    margin-top: 30px;
    display: flex;
    gap: 15px;
    align-items: flex-start;
}

.notice-icon {
    font-size: 20px;
    line-height: 1;
}

.notice-text h4 {
    margin: 0 0 5px 0;
    font-family: 'Outfit', sans-serif;
    font-weight: 700;
    font-size: 16px;
    color: #b45309;
}

.notice-text p {
    margin: 0;
    line-height: 1.5;
}
</style>

<div class="emergency-wrapper">
    <div class="emergency-title">
        <h2>🚨 Talian Kecemasan Bencana Banjir</h2>
        <p>Hubungi talian di bawah dengan segera untuk mendapatkan bantuan kecemasan dan menyelamat</p>
    </div>

    <div class="hotline-grid">
        <!-- 999 MERS -->
        <div class="hotline-item-card primary-alert">
            <div class="hotline-info-top">
                <div class="hotline-icon-title">
                    <div class="hotline-icon">🚑</div>
                    <h3 class="hotline-agency-title">MERS 999</h3>
                </div>
                <p class="hotline-desc">Talian Kecemasan Malaysia utama. Hubungi untuk Polis, Bomba, Hospital, atau Angkatan Pertahanan Awam.</p>
            </div>
            <div class="hotline-action">
                <span class="hotline-num">999</span>
                <a href="tel:999" class="btn-call"><i class="fa-solid fa-phone"></i> Hubungi</a>
            </div>
        </div>

        <!-- NADMA -->
        <div class="hotline-item-card agency-alert">
            <div class="hotline-info-top">
                <div class="hotline-icon-title">
                    <div class="hotline-icon">🏢</div>
                    <h3 class="hotline-agency-title">Pusat Bencana NADMA</h3>
                </div>
                <p class="hotline-desc">Pusat Pengurusan Operasi Bencana Negara (Agensi Pengurusan Bencana Negara).</p>
            </div>
            <div class="hotline-action">
                <span class="hotline-num">03-8064 2400</span>
                <a href="tel:03-80642400" class="btn-call"><i class="fa-solid fa-phone"></i> Hubungi</a>
            </div>
        </div>

        <!-- JPS Flood Info -->
        <div class="hotline-item-card agency-alert">
            <div class="hotline-info-top">
                <div class="hotline-icon-title">
                    <div class="hotline-icon">💧</div>
                    <h3 class="hotline-agency-title">Bilik Laporan JPS</h3>
                </div>
                <p class="hotline-desc">Jabatan Pengairan dan Saliran. Dapatkan laporan terkini mengenai aras air sungai dan ramalan banjir.</p>
            </div>
            <div class="hotline-action">
                <span class="hotline-num">03-2697 2100</span>
                <a href="tel:03-26972100" class="btn-call"><i class="fa-solid fa-phone"></i> Hubungi</a>
            </div>
        </div>

        <!-- APM -->
        <div class="hotline-item-card agency-alert">
            <div class="hotline-info-top">
                <div class="hotline-icon-title">
                    <div class="hotline-icon">🛡️</div>
                    <h3 class="hotline-agency-title">Pertahanan Awam (APM)</h3>
                </div>
                <p class="hotline-desc">Angkatan Pertahanan Awam Malaysia. Sedia membantu dalam operasi menyelamat dan perpindahan mangsa.</p>
            </div>
            <div class="hotline-action">
                <span class="hotline-num">03-8920 6000</span>
                <a href="tel:03-89206000" class="btn-call"><i class="fa-solid fa-phone"></i> Hubungi</a>
            </div>
        </div>
        
        <!-- Bomba -->
        <div class="hotline-item-card agency-alert">
            <div class="hotline-info-top">
                <div class="hotline-icon-title">
                    <div class="hotline-icon">🚒</div>
                    <h3 class="hotline-agency-title">Bomba & Penyelamat</h3>
                </div>
                <p class="hotline-desc">Jabatan Bomba dan Penyelamat Malaysia. Respons pantas untuk operasi mencari dan menyelamat mangsa banjir.</p>
            </div>
            <div class="hotline-action">
                <span class="hotline-num">999 / 03-8888 0036</span>
                <a href="tel:0388880036" class="btn-call"><i class="fa-solid fa-phone"></i> Hubungi</a>
            </div>
        </div>

        <!-- PDRM -->
        <div class="hotline-item-card agency-alert">
            <div class="hotline-info-top">
                <div class="hotline-icon-title">
                    <div class="hotline-icon">🚓</div>
                    <h3 class="hotline-agency-title">Pusat Kawalan PDRM</h3>
                </div>
                <p class="hotline-desc">Polis Diraja Malaysia. Kawalan keselamatan kawasan terjejas dan penyelarasan laluan kecemasan.</p>
            </div>
            <div class="hotline-action">
                <span class="hotline-num">03-2266 2222</span>
                <a href="tel:03-22662222" class="btn-call"><i class="fa-solid fa-phone"></i> Hubungi</a>
            </div>
        </div>
    </div>

    <div class="emergency-notice">
        <div class="notice-icon">⚠️</div>
        <div class="notice-text">
            <h4>PANDUAN KESELAMATAN SEMASA KECEMASAN</h4>
            <p>1. Patuhi arahan pihak berkuasa keselamatan (APM, Bomba, Polis) dengan kadar segera jika diarahkan berpindah.</p>
            <p>2. Sentiasa simpan dokumen penting (seperti Kad Pengenalan dan Geran) di dalam beg kalis air.</p>
            <p>3. Matikan suis elektrik utama sebelum meninggalkan premis kediaman anda.</p>
        </div>
    </div>
</div>

</body>
</html>
