<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.serviceconnect.model.Provider" %>
<%@ page import="com.serviceconnect.service.XMLRuleService" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
        return;
    }

    Provider provider = (Provider) request.getAttribute("provider");
    String serviceName = (String) request.getAttribute("serviceName");
    String locationName = (String) request.getAttribute("locationName");
    String landmark = (String) request.getAttribute("landmark");
    String address = (String) request.getAttribute("address");
    String requestedTime = (String) request.getAttribute("requestedTime");
    String distance = (String) request.getAttribute("distance");

    if (provider == null) {
        response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
        return;
    }

    XMLRuleService ruleService = new XMLRuleService();
    int estDuration = ruleService.getAverageDuration(serviceName);
    double baseFee = ruleService.getBaseFee(serviceName);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirm Booking - ServiceConnect</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="navbar">
        <a href="index.jsp" class="nav-brand">
            <span class="brand-icon">⚡</span>
            <span>ServiceConnect</span>
        </a>
        <nav>
            <ul class="nav-menu">
                <li><a href="customer-dashboard.jsp" class="nav-link">Dashboard</a></li>
                <li><span class="user-badge">👤 <%= session.getAttribute("name") %></span></li>
                <li><a href="logout" class="btn btn-secondary" style="padding: 0.4rem 0.8rem; font-size: 0.85rem;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="container-narrow">
        <div class="card" style="box-shadow: var(--shadow-xl); border: 1px solid var(--border);">
            <div class="card-header">
                <div>
                    <h1 class="card-title">📝 Review & Confirm Booking</h1>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                        Verify dispatch details before submitting request to provider
                    </p>
                </div>
                <span class="badge badge-confirmed">Step 2 of 2</span>
            </div>

            <!-- Provider & Booking Breakdown -->
            <div style="background: var(--bg-card-alt); border: 1px solid var(--border-light); border-radius: var(--radius-sm); padding: 1.5rem; margin-bottom: 1.75rem;">
                <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1rem;">
                    <div style="width: 44px; height: 44px; border-radius: 12px; background: linear-gradient(135deg, #4f46e5 0%, #06b6d4 100%); color: #fff; font-weight: 800; font-size: 1.1rem; display: flex; align-items: center; justify-content: center;">
                        <%= provider.getName().substring(0, 1) %>
                    </div>
                    <div>
                        <h3 style="font-size: 1.2rem; font-weight: 800; color: var(--secondary); margin-bottom: 0.15rem;"><%= provider.getName() %></h3>
                        <span class="badge badge-requested" style="font-size: 0.75rem;"><%= serviceName %></span>
                    </div>
                </div>

                <div style="display: flex; flex-direction: column; gap: 0.6rem; font-size: 0.9rem; color: var(--text-muted); border-top: 1px solid var(--border); padding-top: 1rem;">
                    <div style="display: flex; justify-content: space-between;">
                        <span>📍 Landmark:</span>
                        <strong style="color: var(--secondary);"><%= (landmark != null && !landmark.isEmpty()) ? landmark : locationName %></strong>
                    </div>
                    <% if (address != null && !address.trim().isEmpty()) { %>
                    <div style="display: flex; justify-content: space-between;">
                        <span>🏠 Street Address:</span>
                        <strong style="color: var(--secondary);"><%= address %></strong>
                    </div>
                    <% } %>
                    <div style="display: flex; justify-content: space-between;">
                        <span>📏 Calculated Distance:</span>
                        <strong style="color: var(--primary);"><%= distance %> km away</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>⏰ Requested Time:</span>
                        <strong style="color: var(--secondary);"><%= requestedTime %></strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>⏱ Estimated Duration (XML Rule):</span>
                        <strong style="color: var(--secondary);"><%= estDuration %> minutes</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>📞 Provider Contact:</span>
                        <code style="background: #fff; padding: 0.2rem 0.5rem; border-radius: 4px; border: 1px solid var(--border);"><%= provider.getPhone() %></code>
                    </div>
                    <div style="display: flex; justify-content: space-between; border-top: 1px dashed var(--border); padding-top: 0.75rem; margin-top: 0.5rem; font-size: 1.05rem;">
                        <span style="font-weight: 700; color: var(--secondary);">Estimated Service Charge:</span>
                        <strong style="color: var(--success); font-size: 1.25rem;">₹<%= baseFee %></strong>
                    </div>
                </div>
            </div>

            <form action="booking" method="POST">
                <input type="hidden" name="providerId" value="<%= provider.getProviderId() %>">
                <input type="hidden" name="serviceName" value="<%= serviceName %>">
                <input type="hidden" name="locationName" value="<%= locationName %>">
                <input type="hidden" name="landmark" value="<%= landmark != null ? landmark : "" %>">
                <input type="hidden" name="address" value="<%= address != null ? address : "" %>">
                <input type="hidden" name="requestedTime" value="<%= requestedTime %>">
                <input type="hidden" name="distance" value="<%= distance %>">

                <div style="display: flex; gap: 1rem;">
                    <a href="customer-dashboard.jsp" class="btn btn-secondary" style="flex: 1;">
                        ← Cancel
                    </a>
                    <button type="submit" id="confirmBookingBtn" class="btn btn-primary" style="flex: 2; padding: 0.85rem;">
                        Confirm Booking →
                    </button>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory</p>
    </footer>

</body>
</html>
