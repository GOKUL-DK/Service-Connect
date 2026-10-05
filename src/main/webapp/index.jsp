<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.serviceconnect.dao.ServiceDAO" %>
<%@ page import="com.serviceconnect.model.Service" %>
<%
    ServiceDAO serviceDAO = new ServiceDAO();
    List<Service> services = serviceDAO.getAllServices();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ServiceConnect - Local Multi-Service Allocation System</title>
    <link rel="stylesheet" href="css/style.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="index.jsp" class="nav-brand">
            <span class="brand-icon">⚡</span>
            <span>ServiceConnect</span>
        </a>
        <nav>
            <ul class="nav-menu">
                <li><a href="index.jsp" class="nav-link active">Home</a></li>
                <% if (session.getAttribute("userId") != null) { %>
                    <% String role = (String) session.getAttribute("role"); %>
                    <% if ("CUSTOMER".equalsIgnoreCase(role)) { %>
                        <li><a href="customer-dashboard.jsp" class="nav-link">Dashboard</a></li>
                    <% } else if ("PROVIDER".equalsIgnoreCase(role)) { %>
                        <li><a href="provider-dashboard" class="nav-link">Jobs</a></li>
                    <% } else if ("ADMIN".equalsIgnoreCase(role)) { %>
                        <li><a href="admin-dashboard" class="nav-link">Admin</a></li>
                    <% } %>
                    <li><span class="user-badge">👤 <%= session.getAttribute("name") %> (<%= role %>)</span></li>
                    <li><a href="logout" class="btn btn-secondary" style="padding: 0.4rem 0.8rem; font-size: 0.85rem;">Logout</a></li>
                <% } else { %>
                    <li><a href="login.jsp" class="btn btn-primary" id="navLoginBtn">Login</a></li>
                <% } %>
            </ul>
        </nav>
    </header>

    <!-- Hero Section -->
    <main class="container">
        <section class="hero">
            <div class="hero-pill">⚡ Location-Radius Intelligent Matching</div>
            <h1>Instant Service Providers <br><span class="gradient-text">Right in Your Neighborhood</span></h1>
            <p>
                ServiceConnect matches customers with verified local technicians within your selected radius using real-time GPS coordinates, availability algorithms, and automated workflows.
            </p>
            <div class="hero-cta">
                <a href="login.jsp" class="btn btn-primary" style="padding: 0.85rem 2rem; font-size: 1.05rem;">
                    Find a Service Now →
                </a>
            </div>

            <!-- Feature Highlight Strip -->
            <div class="feature-strip">
                <div class="feature-box">
                    <div class="feature-icon-wrapper" style="background: rgba(79, 70, 229, 0.1); color: var(--primary);">📍</div>
                    <div class="feature-title">Haversine GPS Radius</div>
                    <div class="feature-desc">Accurate spherical distance calculation ensuring closest providers are allocated first.</div>
                </div>
                <div class="feature-box">
                    <div class="feature-icon-wrapper" style="background: rgba(16, 185, 129, 0.1); color: var(--success);">⚡</div>
                    <div class="feature-title">Live AJAX Dispatch</div>
                    <div class="feature-desc">Dynamic DOM card rendering without full page reload via asynchronous Fetch API.</div>
                </div>
                <div class="feature-box">
                    <div class="feature-icon-wrapper" style="background: rgba(6, 182, 212, 0.1); color: var(--accent);">📜</div>
                    <div class="feature-title">XML Rule Engine</div>
                    <div class="feature-desc">Externalized business rules, durations, and fee schedules parsed with Java DOM & XPath.</div>
                </div>
            </div>
        </section>

        <!-- Service Offerings Grid -->
        <section class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">Available Local Services</h2>
                    <p style="font-size: 0.875rem; color: var(--text-muted); margin-top: 0.25rem;">
                        Verified trade experts ready for on-demand residential & commercial dispatch.
                    </p>
                </div>
                <span class="badge badge-available"><%= services.size() %> Services Online</span>
            </div>
            
            <div class="providers-grid">
                <% for (Service s : services) { 
                    String icon = "🛠";
                    String name = s.getServiceName();
                    if (name.contains("Plumb")) icon = "🚰";
                    else if (name.contains("Elect")) icon = "⚡";
                    else if (name.contains("Carp")) icon = "🪚";
                    else if (name.contains("AC")) icon = "❄️";
                    else if (name.contains("Appliance")) icon = "🧺";
                    else if (name.contains("Computer")) icon = "💻";
                    else if (name.contains("Paint")) icon = "🎨";
                    else if (name.contains("Clean")) icon = "🧹";
                    else if (name.contains("Vehicle")) icon = "🚗";
                    else if (name.contains("Home")) icon = "🏠";
                %>
                    <div class="feature-box" style="display: flex; flex-direction: column; justify-content: space-between;">
                        <div>
                            <div style="font-size: 2rem; margin-bottom: 0.75rem;"><%= icon %></div>
                            <h3 style="font-size: 1.15rem; font-weight: 700; color: var(--secondary); margin-bottom: 0.4rem;"><%= s.getServiceName() %></h3>
                            <p style="font-size: 0.875rem; color: var(--text-muted); line-height: 1.5;"><%= s.getDescription() %></p>
                        </div>
                        <div style="margin-top: 1.25rem;">
                            <a href="login.jsp" class="btn btn-secondary btn-block" style="font-size: 0.85rem; padding: 0.5rem 1rem;">
                                Request <%= s.getServiceName() %> →
                            </a>
                        </div>
                    </div>
                <% } %>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory. Built with Jakarta Servlets, JSP 3.1, Pure JDBC, XML XPath, and AJAX.</p>
    </footer>

</body>
</html>
