<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.serviceconnect.model.User" %>
<%@ page import="com.serviceconnect.model.Provider" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
        return;
    }

    User user = (User) request.getAttribute("userProfile");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/profile");
        return;
    }

    Provider provider = (Provider) request.getAttribute("providerProfile");
    String role = user.getRole();
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

    String dashboardUrl = "admin-dashboard";
    if ("CUSTOMER".equalsIgnoreCase(role)) {
        dashboardUrl = "customer-dashboard.jsp";
    } else if ("PROVIDER".equalsIgnoreCase(role)) {
        dashboardUrl = "provider-dashboard";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Profile & Security - ServiceConnect</title>
    <link rel="stylesheet" href="css/style.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>

    <header class="navbar">
        <a href="index.jsp" class="nav-brand">
            <span class="brand-icon">⚡</span>
            <span>ServiceConnect</span>
        </a>
        <nav>
            <ul class="nav-menu">
                <li><a href="<%= dashboardUrl %>" class="nav-link">← Return to Dashboard</a></li>
                <li><span class="user-badge">👤 <%= user.getName() %> (<%= role %>)</span></li>
                <li><a href="logout" class="btn btn-secondary" style="padding: 0.4rem 0.8rem; font-size: 0.85rem;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="container-narrow" style="padding-top: 2rem; padding-bottom: 3rem;">
        
        <!-- Status Alert Messages -->
        <% if ("profileUpdated".equals(msg)) { %>
            <div class="alert alert-success">✓ Personal information updated successfully!</div>
        <% } else if ("passwordChanged".equals(msg)) { %>
            <div class="alert alert-success">✓ Security password changed successfully!</div>
        <% } else if ("invalidCurrentPassword".equals(error)) { %>
            <div class="alert alert-danger">⚠️ Current password entered is incorrect. Please verify and retry.</div>
        <% } else if ("passwordMismatch".equals(error)) { %>
            <div class="alert alert-danger">⚠️ New password and confirmation do not match.</div>
        <% } else if ("passwordTooShort".equals(error)) { %>
            <div class="alert alert-danger">⚠️ New password must be at least 4 characters in length.</div>
        <% } else if (error != null) { %>
            <div class="alert alert-danger">⚠️ Action could not be processed. Please check input.</div>
        <% } %>

        <div style="display: flex; flex-direction: column; gap: 2rem;">
            
            <!-- Card 1: Personal Profile Details -->
            <section class="card" style="box-shadow: var(--shadow-lg); border-top: 4px solid var(--primary);">
                <div class="card-header">
                    <div>
                        <h1 class="card-title" style="font-size: 1.5rem;">👤 Edit Personal Information</h1>
                        <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                            Update your public display name, contact phone, and operating preferences.
                        </p>
                    </div>
                    <span class="badge badge-confirmed"><%= role %> Profile</span>
                </div>

                <form action="profile" method="POST">
                    <input type="hidden" name="action" value="updateProfile">

                    <div class="form-group">
                        <label class="form-label" for="usernameField">🆔 Account Username (System ID)</label>
                        <input type="text" id="usernameField" class="form-control" value="<%= user.getUsername() %>" disabled style="background: var(--bg-card-alt); cursor: not-allowed;">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="nameField">✏️ Full Legal / Display Name</label>
                        <input type="text" id="nameField" name="name" class="form-control" value="<%= user.getName() %>" required placeholder="Enter full name">
                    </div>

                    <% if ("PROVIDER".equalsIgnoreCase(role) && provider != null) { %>
                        <div class="form-group">
                            <label class="form-label" for="serviceField">🛠 Trade Specialization</label>
                            <input type="text" id="serviceField" class="form-control" value="<%= provider.getServiceName() != null ? provider.getServiceName() : "General Trade" %>" disabled style="background: var(--bg-card-alt); cursor: not-allowed;">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="phoneField">📞 Contact Phone Number</label>
                            <input type="text" id="phoneField" name="phone" class="form-control" value="<%= provider.getPhone() %>" required placeholder="e.g. 9000000001">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="fromField">⏰ Shift Start Time</label>
                                <input type="time" id="fromField" name="availableFrom" class="form-control" value="<%= provider.getAvailableFrom() != null ? provider.getAvailableFrom().substring(0, 5) : "09:00" %>" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="untilField">⏰ Shift End Time</label>
                                <input type="time" id="untilField" name="availableUntil" class="form-control" value="<%= provider.getAvailableUntil() != null ? provider.getAvailableUntil().substring(0, 5) : "18:00" %>" required>
                            </div>
                        </div>
                    <% } %>

                    <div style="margin-top: 1.5rem; display: flex; justify-content: flex-end;">
                        <button type="submit" id="saveProfileBtn" class="btn btn-primary" style="padding: 0.85rem 2rem;">
                            SAVE CHANGES →
                        </button>
                    </div>
                </form>
            </section>

            <!-- Card 2: Security & Password Update -->
            <section class="card" style="box-shadow: var(--shadow-lg); border-top: 4px solid var(--accent);">
                <div class="card-header">
                    <div>
                        <h2 class="card-title" style="font-size: 1.5rem;">🔒 Change Account Password</h2>
                        <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                            Ensure your ServiceConnect account stays protected with a strong password.
                        </p>
                    </div>
                    <span class="badge badge-available">Security Shield</span>
                </div>

                <form action="profile" method="POST">
                    <input type="hidden" name="action" value="changePassword">

                    <div class="form-group">
                        <label class="form-label" for="currentPass">🔑 Current Password</label>
                        <input type="password" id="currentPass" name="currentPassword" class="form-control" required placeholder="Enter current password">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="newPass">✨ New Password</label>
                            <input type="password" id="newPass" name="newPassword" class="form-control" required placeholder="Enter new password (min. 4 chars)">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="confirmPass">🔒 Confirm New Password</label>
                            <input type="password" id="confirmPass" name="confirmPassword" class="form-control" required placeholder="Re-enter new password">
                        </div>
                    </div>

                    <div style="margin-top: 1.5rem; display: flex; justify-content: flex-end;">
                        <button type="submit" id="changePasswordBtn" class="btn btn-success" style="padding: 0.85rem 2rem;">
                            UPDATE PASSWORD →
                        </button>
                    </div>
                </form>
            </section>

        </div>
    </main>

    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory. Account Management Suite.</p>
    </footer>

</body>
</html>
