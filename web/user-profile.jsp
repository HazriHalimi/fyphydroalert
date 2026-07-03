<%-- 
    Document   : user-profile
    Created on : Apr 26, 2026, 6:20:43 PM
    Author     : hazzr
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection" %>
<%@ include file="header.jsp" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    Integer userId   = (Integer) session.getAttribute("userId");
    String userType  = (String) session.getAttribute("userType");

    if(userEmail == null || !"user".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Load fresh data from DB
    String dbEmail    = "";
    String dbLocation = "";
    String dbPassword = "";

    Connection conn   = null;
    PreparedStatement pstmt = null;
    ResultSet rs      = null;

    try {
        conn  = DBConnection.getConnection();
        pstmt = conn.prepareStatement("SELECT email, password, location FROM users WHERE user_id = ?");
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        if(rs.next()) {
            dbEmail    = rs.getString("email");
            dbPassword = rs.getString("password");
            dbLocation = rs.getString("location");
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) rs.close();
        if(pstmt != null) pstmt.close();
        if(conn != null) conn.close();
    }
%>

<style>
/* ---- Page Layout ---- */
.profile-wrapper {
    max-width: 600px;
    margin: 40px auto;
    padding: 0 20px 60px;
}

.profile-title {
    text-align: center;
    margin-bottom: 30px;
}

.profile-title h2 {
    font-family: 'Outfit', sans-serif;
    color: var(--navy-blue);
    font-size: 28px;
    font-weight: 800;
    margin-bottom: 6px;
    letter-spacing: -0.5px;
}

.profile-title p {
    color: var(--text-light);
    font-size: 14px;
}

.profile-card {
    background: var(--white);
    border-radius: 18px;
    box-shadow: 0 10px 30px rgba(18, 19, 88, 0.05);
    border: 1px solid var(--border-color);
    padding: 40px;
    transition: var(--transition);
}

.profile-card:hover {
    box-shadow: 0 15px 35px rgba(18, 19, 88, 0.08);
}

.profile-avatar {
    text-align: center;
    margin-bottom: 30px;
}

.profile-avatar .avatar-circle {
    width: 80px;
    height: 80px;
    background: linear-gradient(135deg, var(--teal), var(--navy-blue));
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 36px;
    color: white;
    margin-bottom: 12px;
    box-shadow: 0 8px 20px rgba(54, 173, 163, 0.2);
}

.profile-avatar .avatar-email {
    font-family: 'Outfit', sans-serif;
    font-size: 16px;
    color: var(--navy-blue);
    font-weight: 700;
}

.profile-divider {
    border: none;
    border-top: 1.5px solid var(--border-color);
    margin: 0 0 30px;
}

.profile-form .form-group {
    margin-bottom: 22px;
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.profile-form label {
    display: block;
    font-weight: 700;
    font-size: 11px;
    color: var(--navy-blue);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.profile-form input,
.profile-form select {
    width: 100%;
    padding: 12px 16px;
    border: 1.5px solid var(--border-color);
    background-color: var(--light-gray);
    border-radius: 10px;
    font-size: 14px;
    font-family: 'Inter', sans-serif;
    color: var(--text-dark);
    transition: var(--transition);
    box-sizing: border-box;
}

.profile-form input:focus,
.profile-form select:focus {
    outline: none;
    border-color: var(--teal);
    background-color: var(--white);
    box-shadow: 0 0 0 3px rgba(54, 173, 163, 0.15);
}

.profile-form small {
    font-size: 12px;
    color: var(--text-light);
    margin-top: 4px;
    display: block;
}

.btn-save {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, var(--teal), #2b948a);
    color: white;
    border: none;
    border-radius: 50px;
    font-size: 15px;
    font-weight: 700;
    font-family: 'Outfit', sans-serif;
    cursor: pointer;
    margin-top: 12px;
    box-shadow: 0 8px 20px rgba(54, 173, 163, 0.25);
    transition: var(--transition);
}

.btn-save:hover {
    transform: translateY(-1px);
    box-shadow: 0 12px 25px rgba(54, 173, 163, 0.35);
}

.alert-success {
    background: rgba(22, 163, 74, 0.1);
    color: #16a34a;
    border: 1px solid rgba(22, 163, 74, 0.2);
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 24px;
    font-size: 14px;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;
}

.alert-error {
    background: rgba(225, 29, 72, 0.1);
    color: #e11d48;
    border: 1px solid rgba(225, 29, 72, 0.2);
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 24px;
    font-size: 14px;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;
}
</style>

<div class="profile-wrapper">

    <div class="profile-title">
        <h2>👤 Profil Saya</h2>
        <p>Kemaskini maklumat akaun anda</p>
    </div>

    <div class="profile-card">

        <div class="profile-avatar">
            <div class="avatar-circle">👤</div>
            <div class="avatar-email"><%= dbEmail %></div>
        </div>

        <hr class="profile-divider">

        <% String msg = request.getParameter("msg"); %>
        <% if("updated".equals(msg)) { %>
            <div class="alert-success"><span>✅</span> Profil berjaya dikemaskini!</div>
        <% } else if("emailtaken".equals(msg)) { %>
            <div class="alert-error"><span>⚠️</span> E-mel telah digunakan oleh akaun lain.</div>
        <% } else if("pwmismatch".equals(msg)) { %>
            <div class="alert-error"><span>⚠️</span> Kata laluan tidak padan. Sila cuba lagi.</div>
        <% } else if("error".equals(msg)) { %>
            <div class="alert-error"><span>⚠️</span> Ralat berlaku. Sila cuba lagi.</div>
        <% } %>

        <form action="UpdateProfileServlet" method="post" class="profile-form" onsubmit="return validatePasswords()">

            <div class="form-group">
                <label>Alamat E-mel</label>
                <input type="email" name="email" value="<%= dbEmail %>" required>
            </div>

            <div class="form-group">
                <label>Kata Laluan Baru</label>
                <input type="password" id="newPassword" name="password"
                       placeholder="Masukkan kata laluan baru (biarkan kosong jika tiada perubahan)">
                <small>Biarkan kosong jika anda tidak mahu menukar kata laluan.</small>
            </div>

            <div class="form-group">
                <label>Sahkan Kata Laluan Baru</label>
                <input type="password" id="confirmPassword" name="confirmPassword"
                       placeholder="Sahkan kata laluan baru">
                <small id="pwMatchMsg" style="display:none;"></small>
            </div>

            <div class="form-group">
                <label>Negeri Penempatan</label>
                <select name="location">
                    <option value="">-- Pilih Negeri --</option>
                    <%
                        String[] states = {"Johor","Kedah","Kelantan","Melaka","Negeri Sembilan",
                            "Pahang","Perak","Perlis","Pulau Pinang","Sabah","Sarawak",
                            "Selangor","Terengganu","Wilayah Persekutuan"};
                        for(String s : states) {
                            String sel = s.equals(dbLocation) ? "selected" : "";
                    %>
                    <option value="<%= s %>" <%= sel %>><%= s %></option>
                    <% } %>
                </select>
            </div>

            <button type="submit" class="btn-save">Simpan Perubahan</button>

        </form>
    </div>
</div>

<script>
// Live match indicator
document.getElementById('confirmPassword').addEventListener('input', function() {
    var pw1 = document.getElementById('newPassword').value;
    var pw2 = this.value;
    var msg = document.getElementById('pwMatchMsg');

    if(pw2 === '') {
        msg.style.display = 'none';
        return;
    }

    if(pw1 === pw2) {
        msg.textContent    = '✓ Passwords match';
        msg.style.color    = '#155724';
        msg.style.display  = 'block';
    } else {
        msg.textContent    = '✗ Passwords do not match';
        msg.style.color    = '#721c24';
        msg.style.display  = 'block';
    }
});

// Block submit if passwords don't match
function validatePasswords() {
    var pw1 = document.getElementById('newPassword').value;
    var pw2 = document.getElementById('confirmPassword').value;

    // If both empty — no password change, fine
    if(pw1 === '' && pw2 === '') return true;

    // If only one filled
    if(pw1 !== '' && pw2 === '') {
        alert('Please confirm your new password.');
        return false;
    }
    if(pw1 === '' && pw2 !== '') {
        alert('Please enter your new password first.');
        return false;
    }

    // Both filled but don't match
    if(pw1 !== pw2) {
        alert('Passwords do not match. Please try again.');
        return false;
    }

    return true;
}
</script>

