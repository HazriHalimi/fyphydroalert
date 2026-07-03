<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar Pengguna - HydroAlert</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/landing.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800;900&display=swap');

        body.login-page {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, var(--deep-blue) 0%, var(--navy-blue) 50%, var(--steel-blue) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }

        body.login-page::before {
            content: '';
            position: absolute;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(54, 173, 163, 0.15) 0%, transparent 70%);
            top: -200px;
            right: -100px;
            z-index: 1;
            pointer-events: none;
        }

        body.login-page::after {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(47, 87, 138, 0.2) 0%, transparent 70%);
            bottom: -150px;
            left: -100px;
            z-index: 1;
            pointer-events: none;
        }

        .login-wrapper {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 450px;
            perspective: 1000px;
        }

        .login-glass-card {
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 24px;
            padding: 45px 40px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
            text-align: center;
            color: var(--white);
            transition: var(--transition);
        }

        .login-glass-card:hover {
            border-color: rgba(54, 173, 163, 0.3);
            box-shadow: 0 25px 60px rgba(54, 173, 163, 0.15);
            transform: translateY(-2px);
        }

        .logo-wrap {
            margin-bottom: 25px;
            display: inline-block;
        }

        .logo-wrap img {
            height: 80px;
            width: auto;
            filter: drop-shadow(0 4px 10px rgba(0, 0, 0, 0.2));
            animation: float 4s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }

        .login-glass-card h2 {
            font-family: 'Outfit', sans-serif;
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 8px;
            background: linear-gradient(135deg, #ffffff 0%, var(--teal) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
        }

        .login-glass-card p.subtitle {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.65);
            margin-bottom: 30px;
        }

        .form-group-custom {
            margin-bottom: 22px;
            text-align: left;
        }

        .form-group-custom label {
            display: block;
            margin-bottom: 8px;
            font-size: 13px;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.85);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 16px;
            font-size: 18px;
            color: rgba(255, 255, 255, 0.4);
            pointer-events: none;
            transition: var(--transition);
        }

        .form-group-custom input, .form-group-custom select {
            width: 100%;
            padding: 14px 16px 14px 46px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            color: var(--white);
            font-size: 15px;
            font-family: 'Inter', sans-serif;
            transition: var(--transition);
        }

        .form-group-custom input:focus, .form-group-custom select:focus {
            outline: none;
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--teal);
            box-shadow: 0 0 15px rgba(54, 173, 163, 0.25);
        }

        .form-group-custom input:focus + .input-icon, .form-group-custom select:focus + .input-icon {
            color: var(--teal);
        }

        .form-group-custom input::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        #password, #confirmPassword {
            padding-right: 46px;
        }

        .password-toggle-btn {
            position: absolute;
            right: 16px;
            background: none;
            border: none;
            padding: 0;
            color: rgba(255, 255, 255, 0.4);
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2;
        }

        .password-toggle-btn:hover {
            color: var(--teal);
        }

        .password-toggle-btn:focus {
            outline: none;
            color: var(--teal);
        }

        .form-group-custom select option {
            background-color: var(--deep-blue);
            color: var(--white);
        }

        .alert-custom {
            border-radius: 12px;
            padding: 14px 18px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 25px;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: fadeIn 0.4s ease-out;
        }

        .alert-error {
            background: rgba(225, 29, 72, 0.15);
            border: 1px solid rgba(225, 29, 72, 0.3);
            color: #fda4af;
        }

        .btn-login-custom {
            width: 100%;
            padding: 14px;
            background: var(--teal);
            color: var(--white);
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 700;
            font-family: 'Outfit', sans-serif;
            cursor: pointer;
            transition: var(--transition);
            box-shadow: 0 8px 20px rgba(54, 173, 163, 0.25);
            margin-top: 10px;
        }

        .btn-login-custom:hover {
            background: #2b948a;
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(54, 173, 163, 0.35);
        }

        .footer-links-custom {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            font-size: 14px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .footer-links-custom p {
            color: rgba(255, 255, 255, 0.5);
            margin: 0;
        }

        .footer-links-custom a {
            color: var(--teal);
            text-decoration: none;
            font-weight: 600;
            transition: var(--transition);
        }

        .footer-links-custom a:hover {
            color: #5ce6db;
            text-decoration: underline;
        }

        .back-home {
            color: rgba(255, 255, 255, 0.6) !important;
            font-weight: 500 !important;
            margin-top: 5px;
            display: inline-block;
        }

        .back-home:hover {
            color: var(--white) !important;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body class="login-page">

    <div class="login-wrapper">
        <div class="login-glass-card">
            
            <div class="logo-wrap">
                <a href="index.jsp">
                    <img src="images/logo.png" alt="HydroAlert Logo">
                </a>
            </div>
            
            <h2>Daftar Akaun</h2>
            <p class="subtitle">Sistem Pengurusan & Maklumat Banjir</p>

            <% if(request.getParameter("error") != null) { %>
                <div class="alert-custom alert-error">
                    <span>🚨</span>
                    <div>Alamat e-mel sudah didaftarkan! Sila guna alamat e-mel lain.</div>
                </div>
            <% } %>

            <form action="UserRegisterServlet" method="post" onsubmit="return validateRegisterPasswords()">
                <div class="form-group-custom">
                    <label for="email">Alamat E-mel *</label>
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" required placeholder="nama@contoh.com">
                        <span class="input-icon">✉️</span>
                    </div>
                </div>

                 <div class="form-group-custom">
                    <label for="password">Kata Laluan *</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" required placeholder="Minimum 6 aksara" minlength="6">
                        <span class="input-icon">🔒</span>
                        <button type="button" class="password-toggle-btn" id="togglePassword" aria-label="Papar kata laluan">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-eye">
                              <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0z"/>
                              <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="form-group-custom">
                    <label for="confirmPassword">Sahkan Kata Laluan *</label>
                    <div class="input-wrapper">
                        <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Masukkan semula kata laluan">
                        <span class="input-icon">🔑</span>
                        <button type="button" class="password-toggle-btn" id="toggleConfirmPassword" aria-label="Papar kata laluan">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-eye">
                              <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0z"/>
                              <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                    <small id="pwMatchMsg" style="display:none; font-weight:700; margin-top:6px; font-size:12px;"></small>
                </div>

                <div class="form-group-custom">
                    <label for="location">Negeri Pilihan *</label>
                    <div class="input-wrapper">
                        <select name="location" id="location" required>
                            <option value="">-- Pilih Negeri --</option>
                            <option value="Johor">Johor</option>
                            <option value="Kedah">Kedah</option>
                            <option value="Kelantan">Kelantan</option>
                            <option value="Melaka">Melaka</option>
                            <option value="Negeri Sembilan">Negeri Sembilan</option>
                            <option value="Pahang">Pahang</option>
                            <option value="Perak">Perak</option>
                            <option value="Perlis">Perlis</option>
                            <option value="Pulau Pinang">Pulau Pinang</option>
                            <option value="Sabah">Sabah</option>
                            <option value="Sarawak">Sarawak</option>
                            <option value="Selangor">Selangor</option>
                            <option value="Terengganu">Terengganu</option>
                        </select>
                        <span class="input-icon">📍</span>
                    </div>
                </div>

                <button type="submit" class="btn-login-custom">Daftar Sekarang</button>
            </form>
            
            <div class="footer-links-custom">
                <p>Sudah mempunyai akaun? <a href="login.jsp">Log Masuk</a></p>
                <a href="index.jsp" class="back-home">← Kembali ke Utama</a>
            </div>
        </div>
    </div>

    <script>
    document.getElementById('confirmPassword').addEventListener('input', function() {
        var pw1 = document.getElementById('password').value;
        var pw2 = this.value;
        var msg = document.getElementById('pwMatchMsg');

        if(pw2 === '') {
            msg.style.display = 'none';
            return;
        }

        if(pw1 === pw2) {
            msg.textContent   = '✓ Kata laluan sepadan';
            msg.style.color   = '#86efac';
            msg.style.display = 'block';
        } else {
            msg.textContent   = '✗ Kata laluan tidak sepadan';
            msg.style.color   = '#fda4af';
            msg.style.display = 'block';
        }
    });

    function validateRegisterPasswords() {
        var pw1 = document.getElementById('password').value;
        var pw2 = document.getElementById('confirmPassword').value;
        if(pw1 !== pw2) {
            alert('Kata laluan tidak sepadan! Sila pastikan kedua-dua kata laluan adalah sama.');
            return false;
        }
        return true;
    }

    function setupPasswordToggle(inputElementId, buttonElementId) {
        const input = document.getElementById(inputElementId);
        const btn = document.getElementById(buttonElementId);
        
        if (input && btn) {
            btn.addEventListener('click', function() {
                const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
                input.setAttribute('type', type);
                
                if (type === 'password') {
                    btn.innerHTML = `
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-eye">
                          <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0z"/>
                          <circle cx="12" cy="12" r="3"/>
                        </svg>
                    `;
                    btn.setAttribute('aria-label', 'Papar kata laluan');
                } else {
                    btn.innerHTML = `
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-eye-off">
                          <path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/>
                          <path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/>
                          <path d="M6.61 6.61A13.52 13.52 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/>
                          <line x1="2" y1="2" x2="22" y2="22"/>
                        </svg>
                    `;
                    btn.setAttribute('aria-label', 'Sembunyi kata laluan');
                }
            });
        }
    }
    setupPasswordToggle('password', 'togglePassword');
    setupPasswordToggle('confirmPassword', 'toggleConfirmPassword');
    </script>
</body>
</html>