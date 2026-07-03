<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String officerUsername = (String) session.getAttribute("officerUsername");
    String userType = (String) session.getAttribute("userType");

    if(officerUsername == null || !"officer".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String officerName = (String) session.getAttribute("officerName");
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Tambah Pusat Pemindahan - HydroAlert</title>
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
        <a href="officer-add-center.jsp" class="sb-link active"><i class="fa-solid fa-plus-circle"></i> Add Centre</a>
        <div class="sb-section">Victims</div>
        <a href="officer-victims.jsp" class="sb-link"><i class="fa-solid fa-users"></i> Victims List</a>
        <a href="officer-add-victim.jsp" class="sb-link"><i class="fa-solid fa-user-plus"></i> Register Victim</a>
    </nav>
    <div class="sb-footer"><a href="logout.jsp" class="sb-logout"><i class="fa-solid fa-right-from-bracket"></i> Log Keluar</a></div>
</aside>
<div class="main">
<div class="topbar">
    <div class="topbar-title">Tambah Pusat</div>
    <div class="topbar-user"><div class="tb-avatar officer"><i class="fa-solid fa-user-shield"></i></div><%= officerName %></div>
</div>
<div class="body-content">
    <div class="sec-header">
        <div class="sec-title"><i class="fa-solid fa-plus-circle"></i> Tambah Pusat Pemindahan Baru</div>
        <a href="officer-center.jsp" class="btn-cancel" style="padding: 8px 16px;"><i class="fa-solid fa-arrow-left"></i> Kembali</a>
    </div>

    <% if(request.getParameter("error") != null) { %>
        <div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Ralat berlaku. Sila cuba lagi.</div>
    <% } %>

    <div class="form-card">
        <form action="AddCentreServlet" method="post">
            <div class="form-group">
                <label class="form-label">Nama Pusat Pemindahan *</label>
                <input type="text" name="centreName" class="form-input" placeholder="cth: SK Taman Maju" required>
            </div>

            <div class="form-group">
                <label class="form-label">Alamat Penuh *</label>
                <input type="text" name="address" class="form-input" placeholder="cth: Jalan Maju 1, Taman Maju" required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Daerah / Kawasan *</label>
                    <input type="text" name="location" class="form-input" placeholder="cth: Hulu Langat" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Negeri *</label>
                    <select name="state" class="form-input" required>
                        <option value="">-- Pilih Negeri --</option>
                        <% String[] states = {"Johor","Kedah","Kelantan","Melaka","Negeri Sembilan",
                           "Pahang","Perak","Perlis","Pulau Pinang","Sabah","Sarawak",
                           "Selangor","Terengganu","Wilayah Persekutuan"};
                           for(String s : states) { %>
                        <option value="<%= s %>"><%= s %></option>
                        <% } %>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Kapasiti Maksimum (orang) *</label>
                    <input type="number" name="capacity" class="form-input" placeholder="cth: 200" min="1" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-input">
                        <option value="active">Aktif</option>
                        <option value="closed">Ditutup</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Latitud</label>
                    <input type="number" name="latitude" class="form-input" placeholder="cth: 3.1234" step="0.000001">
                </div>
                <div class="form-group">
                    <label class="form-label">Longitud</label>
                    <input type="number" name="longitude" class="form-input" placeholder="cth: 101.6789" step="0.000001">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Nota</label>
                <textarea name="notes" class="form-input" rows="3" placeholder="Maklumat tambahan tentang pusat ini..."></textarea>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit"><i class="fa-solid fa-circle-check"></i> Simpan Pusat</button>
                <a href="officer-center.jsp" class="btn-cancel">Batal</a>
            </div>
        </form>
    </div>
</div>
</div>
</div>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const nameInput = document.querySelector('input[name="centreName"]');
    const addressInput = document.querySelector('input[name="address"]');
    const locationInput = document.querySelector('input[name="location"]');
    const stateSelect = document.querySelector('select[name="state"]');
    const latInput = document.querySelector('input[name="latitude"]');
    const lonInput = document.querySelector('input[name="longitude"]');

    // Create status message container next to coordinate fields
    const coordGroup = latInput.closest('.form-row');
    const statusDiv = document.createElement('div');
    statusDiv.style.fontSize = '12px';
    statusDiv.style.color = 'var(--teal)';
    statusDiv.style.marginTop = '-10px';
    statusDiv.style.marginBottom = '15px';
    statusDiv.style.width = '100%';
    statusDiv.id = 'geo-status';
    coordGroup.parentNode.insertBefore(statusDiv, coordGroup.nextSibling);

    // Add search helper button
    const searchBtn = document.createElement('button');
    searchBtn.type = 'button';
    searchBtn.className = 'btn-cancel';
    searchBtn.style.padding = '4px 10px';
    searchBtn.style.fontSize = '11px';
    searchBtn.style.marginLeft = '10px';
    searchBtn.style.height = 'auto';
    searchBtn.style.cursor = 'pointer';
    searchBtn.innerHTML = '<i class="fa-solid fa-map-location-dot"></i> Cari Koordinat';
    
    // Append button next to Latitud label
    const latLabel = latInput.closest('.form-group').querySelector('.form-label');
    latLabel.appendChild(searchBtn);

    async function autoGeocode() {
        const name = nameInput.value.trim();
        const address = addressInput.value.trim();
        const locationVal = locationInput.value.trim();
        const state = stateSelect.value;

        if (!name) return;

        statusDiv.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Mencari koordinat secara automatik...';
        statusDiv.style.color = '#3b82f6';

        // Construct search query
        let queryParts = [];
        queryParts.push(name);
        if (address) queryParts.push(address);
        if (locationVal) queryParts.push(locationVal);
        if (state) queryParts.push(state);
        queryParts.push("Malaysia");

        const query = queryParts.join(", ");
        
        try {
            const url = 'https://nominatim.openstreetmap.org/search?q=' + encodeURIComponent(query) + '&format=json&limit=1';
            const response = await fetch(url, {
                headers: {
                    'User-Agent': 'HydroAlert-Evacuation-Centre-App/1.0'
                }
            });
            const data = await response.json();

            if (data && data.length > 0) {
                const lat = parseFloat(data[0].lat).toFixed(6);
                const lon = parseFloat(data[0].lon).toFixed(6);
                latInput.value = lat;
                lonInput.value = lon;
                statusDiv.innerHTML = '<i class="fa-solid fa-circle-check"></i> Koordinat dijumpai: Lat ' + lat + ', Lon ' + lon + ' (' + data[0].display_name + ')';
                statusDiv.style.color = '#10b981';
            } else {
                // Try a broader search with just name + state + Malaysia
                const broaderQuery = name + ', ' + (state ? state + ', ' : '') + 'Malaysia';
                const broaderResponse = await fetch('https://nominatim.openstreetmap.org/search?q=' + encodeURIComponent(broaderQuery) + '&format=json&limit=1', {
                    headers: {
                        'User-Agent': 'HydroAlert-Evacuation-Centre-App/1.0'
                    }
                });
                const broaderData = await broaderResponse.json();
                
                if (broaderData && broaderData.length > 0) {
                    const lat = parseFloat(broaderData[0].lat).toFixed(6);
                    const lon = parseFloat(broaderData[0].lon).toFixed(6);
                    latInput.value = lat;
                    lonInput.value = lon;
                    statusDiv.innerHTML = '<i class="fa-solid fa-circle-check"></i> Koordinat dijumpai (carian am): Lat ' + lat + ', Lon ' + lon;
                    statusDiv.style.color = '#10b981';
                } else {
                    statusDiv.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> Koordinat tidak dijumpai. Sila masukkan secara manual.';
                    statusDiv.style.color = '#ef4444';
                }
            }
        } catch (error) {
            console.error("Geocoding error:", error);
            statusDiv.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> Ralat sambungan ketika mencari koordinat.';
            statusDiv.style.color = '#ef4444';
        }
    }

    // Trigger on button click
    searchBtn.addEventListener('click', autoGeocode);

    // Trigger auto geocoding on blur of name/location/state fields if they are edited
    nameInput.addEventListener('blur', function() {
        if (nameInput.value.trim() && !latInput.value && !lonInput.value) {
            autoGeocode();
        }
    });
    locationInput.addEventListener('blur', function() {
        if (nameInput.value.trim() && !latInput.value && !lonInput.value) {
            autoGeocode();
        }
    });
    stateSelect.addEventListener('change', function() {
        if (nameInput.value.trim() && !latInput.value && !lonInput.value) {
            autoGeocode();
        }
    });
});
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
