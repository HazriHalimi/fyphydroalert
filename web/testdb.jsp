<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Database Diagnostic</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .ok { color: green; font-weight: bold; }
        .fail { color: red; font-weight: bold; }
        table {
            border-collapse: collapse;
            width: 100%;
        }
        td {
            border: 1px solid #ccc;
            padding: 8px;
        }
        .label {
            font-weight: bold;
            width: 250px;
        }
        pre {
            background: #f4f4f4;
            padding: 10px;
        }
    </style>
</head>
<body>

<h2>Database Connection Diagnostic</h2>

<%
Connection conn = null;

try {

    conn = DBConnection.getConnection();

    if (conn == null) {
%>

<p class="fail">[FAIL] DBConnection.getConnection() returned NULL</p>

<p>Possible causes:</p>
<ul>
    <li>MySQL JDBC driver not found</li>
    <li>Database server not reachable</li>
    <li>Exception swallowed inside DBConnection.java</li>
</ul>

<%
    } else {

        DatabaseMetaData meta = conn.getMetaData();
%>

<p class="ok">[OK] DATABASE CONNECTION SUCCESSFUL</p>

<table>
<tr><td class="label">Database</td><td><%= conn.getCatalog() %></td></tr>
<tr><td class="label">Database Product</td><td><%= meta.getDatabaseProductName() %></td></tr>
<tr><td class="label">Version</td><td><%= meta.getDatabaseProductVersion() %></td></tr>
<tr><td class="label">Connected User</td><td><%= meta.getUserName() %></td></tr>
<tr><td class="label">Driver</td><td><%= meta.getDriverName() %></td></tr>
</table>

<h3>Database Schema Details</h3>
<table style="margin-top: 15px;">
    <tr style="background: #2b7bc4; color: white; font-weight: bold;">
        <td>Table Name</td>
        <td>Columns</td>
        <td>Row Count</td>
    </tr>
    <%
    String[] tables = {"admins", "officers", "users", "relief_centres", "victims", "readings"};
    for (String tbl : tables) {
        String columns = "";
        int rowCount = -1;
        try {
            // Get columns
            ResultSet rsCol = meta.getColumns(null, null, tbl, null);
            List<String> colList = new ArrayList<String>();
            while (rsCol.next()) {
                colList.add(rsCol.getString("COLUMN_NAME") + " (" + rsCol.getString("TYPE_NAME") + ")");
            }
            rsCol.close();
            columns = String.join(", ", colList);
            
            // Get row count
            if (!colList.isEmpty()) {
                Statement st = conn.createStatement();
                ResultSet rsCount = st.executeQuery("SELECT COUNT(*) FROM " + tbl);
                if (rsCount.next()) {
                    rowCount = rsCount.getInt(1);
                }
                rsCount.close();
                st.close();
            } else {
                columns = "<span class='fail'>Table not found / no columns</span>";
            }
        } catch (Exception ex) {
            columns = "<span class='fail'>Error: " + ex.getMessage() + "</span>";
        }
    %>
    <tr>
        <td class="label"><%= tbl %></td>
        <td><%= columns %></td>
        <td><%= rowCount >= 0 ? rowCount : "N/A" %></td>
    </tr>
    <%
    }
    %>
</table>

<%
    }

} catch (SQLException e) {

    String msg = e.getMessage();
    String diagnosis = "Unknown SQL error";

    if (msg != null) {

        if (msg.contains("Access denied")) {
            diagnosis = "Wrong username or password.";
        }
        else if (msg.contains("Communications link failure")) {
            diagnosis = "Cannot reach MySQL server. MySQL may be stopped or host/port is wrong.";
        }
        else if (msg.contains("Unknown database")) {
            diagnosis = "Database 'hydroalertnew' does not exist.";
        }
        else if (msg.contains("Public Key Retrieval")) {
            diagnosis = "MySQL authentication configuration issue.";
        }
        else if (msg.contains("Connection refused")) {
            diagnosis = "MySQL server is not listening on port 3306.";
        }
        else if (msg.contains("Host is not allowed")) {
            diagnosis = "MySQL user is not allowed to connect from this host.";
        }
        else if (msg.contains("Too many connections")) {
            diagnosis = "MySQL connection limit reached.";
        }
    }
%>

<p class="fail">[FAIL] DATABASE CONNECTION FAILED</p>

<table>
<tr>
    <td class="label">Diagnosis</td>
    <td><%= diagnosis %></td>
</tr>
<tr>
    <td class="label">SQL State</td>
    <td><%= e.getSQLState() %></td>
</tr>
<tr>
    <td class="label">Error Code</td>
    <td><%= e.getErrorCode() %></td>
</tr>
<tr>
    <td class="label">Message</td>
    <td><%= e.getMessage() %></td>
</tr>
</table>

<pre><%
e.printStackTrace(new java.io.PrintWriter(out));
%></pre>

<%
} catch (ClassNotFoundException e) {
%>

<p class="fail">[FAIL] MYSQL JDBC DRIVER NOT FOUND</p>

<table>
<tr>
    <td class="label">Diagnosis</td>
    <td>mysql-connector-j.jar is missing from WEB-INF/lib or Tomcat lib folder.</td>
</tr>
<tr>
    <td class="label">Message</td>
    <td><%= e.getMessage() %></td>
</tr>
</table>

<%
} catch (Exception e) {
%>

<p class="fail">[FAIL] GENERAL ERROR</p>

<table>
<tr>
    <td class="label">Class</td>
    <td><%= e.getClass().getName() %></td>
</tr>
<tr>
    <td class="label">Message</td>
    <td><%= e.getMessage() %></td>
</tr>
</table>

<pre><%
e.printStackTrace(new java.io.PrintWriter(out));
%></pre>

<%
} finally {
    try {
        if (conn != null) conn.close();
    } catch(Exception ex){}
}
%>

</body>
</html>