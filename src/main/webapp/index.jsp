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
            <div class="hero-pill">⚡ Location-Radius Intelligent Matching & Dispatch</div>
            <h1>Instant Service Experts <br><span class="gradient-text">Right in Your Neighborhood</span></h1>
            <p>
                ServiceConnect matches residents with verified local technicians within your selected radius using real-time GPS coordinates, live availability tracking, and automated dispatch workflows.
            </p>
            <div class="hero-cta">
                <a href="login.jsp" class="btn btn-primary" style="padding: 0.9rem 2.25rem; font-size: 1.05rem;">
                    🔍 Find a Service Now →
                </a>
                <a href="login.jsp" class="btn btn-secondary" style="padding: 0.9rem 1.85rem; font-size: 1.025rem;">
                    🛠️ Join as Service Worker
                </a>
            </div>

            <!-- Platform Live Stats Strip -->
            <div class="hero-stat-strip">
                <div class="hero-stat-item">
                    <div class="hero-stat-number">15 Min</div>
                    <div class="hero-stat-label">⚡ Average Dispatch Time</div>
                </div>
                <div class="hero-stat-item">
                    <div class="hero-stat-number">1,200+</div>
                    <div class="hero-stat-label">🏠 Bookings Fulfilled</div>
                </div>
                <div class="hero-stat-item">
                    <div class="hero-stat-number">4.9 ★</div>
                    <div class="hero-stat-label">⭐ Customer Rating</div>
                </div>
                <div class="hero-stat-item">
                    <div class="hero-stat-number">100%</div>
                    <div class="hero-stat-label">🛡️ Verified Technicians</div>
                </div>
            </div>

            <!-- 3-Step Interactive Process -->
            <div class="workflow-section">
                <div style="display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.35rem 0.9rem; background: rgba(79, 91, 232, 0.08); border: 1px solid rgba(79, 91, 232, 0.2); border-radius: 9999px; color: #93c5fd; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; margin-bottom: 0.75rem;">
                    💡 Simple & Seamless
                </div>
                <h2 style="font-size: 2.2rem; font-weight: 800; color: var(--secondary); letter-spacing: -0.02em;">How ServiceConnect Operates</h2>
                <p style="color: var(--text-muted); font-size: 1rem; max-width: 600px; margin: 0.5rem auto 0;">Three automated stages ensuring rapid, safe, and transparent local technician allocation.</p>

                <div class="workflow-grid">
                    <div class="workflow-card">
                        <div class="workflow-step-num">01</div>
                        <div class="workflow-card-icon" style="background: rgba(79, 91, 232, 0.1); color: #93c5fd;">📍</div>
                        <div class="workflow-card-title">1. Set Radius & Landmark</div>
                        <div class="workflow-card-desc">Enter your street or tap <em>Use My GPS</em>. The Haversine spherical algorithm calculates exact distances to available providers within 2km - 15km.</div>
                    </div>
                    <div class="workflow-card">
                        <div class="workflow-step-num">02</div>
                        <div class="workflow-card-icon" style="background: rgba(56, 189, 248, 0.1); color: var(--accent);">💬</div>
                        <div class="workflow-card-title">2. Real-Time Allocation & Chat</div>
                        <div class="workflow-card-desc">Review technician profiles and rates calculated by the XML Rule Engine. Message directly via live chat with sound chime alerts.</div>
                    </div>
                    <div class="workflow-card">
                        <div class="workflow-step-num">03</div>
                        <div class="workflow-card-icon" style="background: rgba(16, 185, 129, 0.1); color: var(--success);">🔑</div>
                        <div class="workflow-card-title">3. Secure OTP Handshake</div>
                        <div class="workflow-card-desc">Upon job completion, exchange your confidential 4-digit security code for verification, instant billing receipt, and review logging.</div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Service Offerings Catalog -->
        <section class="card" style="box-shadow: var(--shadow-md); border-top: 2px solid var(--primary);">
            <div class="card-header">
                <div>
                    <h2 class="card-title">🛠️ Available Trade Specializations</h2>
                    <p style="font-size: 0.875rem; color: var(--text-muted); margin-top: 0.25rem;">
                        Verified local professionals ready for immediate dispatch across residential and commercial properties.
                    </p>
                </div>
                <span class="badge badge-available"><%= services.size() %> Trades Active</span>
            </div>
            
            <div class="providers-grid">
                <% for (Service s : services) { 
                    String icon = "🛠";
                    String name = s.getServiceName();
                    String startingPrice = "₹299";
                    if (name.contains("Plumb")) { icon = "🚰"; startingPrice = "₹249"; }
                    else if (name.contains("Elect")) { icon = "⚡"; startingPrice = "₹299"; }
                    else if (name.contains("Carp")) { icon = "🪚"; startingPrice = "₹349"; }
                    else if (name.contains("AC")) { icon = "❄️"; startingPrice = "₹499"; }
                    else if (name.contains("Appliance")) { icon = "🧺"; startingPrice = "₹399"; }
                    else if (name.contains("Computer")) { icon = "💻"; startingPrice = "₹449"; }
                    else if (name.contains("Paint")) { icon = "🎨"; startingPrice = "₹599"; }
                    else if (name.contains("Clean")) { icon = "🧹"; startingPrice = "₹349"; }
                    else if (name.contains("Vehicle")) { icon = "🚗"; startingPrice = "₹399"; }
                    else if (name.contains("Home")) { icon = "🏠"; startingPrice = "₹499"; }
                %>
                    <div class="service-card-modern">
                        <div>
                            <div class="service-card-header">
                                <div class="service-icon-box"><%= icon %></div>
                                <span class="service-price-pill">From <%= startingPrice %></span>
                            </div>
                            <h3 class="service-card-title"><%= s.getServiceName() %></h3>
                            <p class="service-card-desc"><%= s.getDescription() %></p>
                        </div>
                        <div style="margin-top: 1rem;">
                            <a href="login.jsp" class="btn btn-secondary btn-block" style="font-size: 0.885rem; padding: 0.6rem 1rem;">
                                Request <%= s.getServiceName() %> →
                            </a>
                        </div>
                    </div>
                <% } %>
            </div>
        </section>

        <!-- Trust & Security Commitment Strip -->
        <section class="card" style="background: var(--bg-card); border: 1px solid var(--border); box-shadow: var(--shadow-md);">
            <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1.5rem;">
                <div style="max-width: 650px;">
                    <div style="font-size: 0.8rem; font-weight: 800; color: var(--accent); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 0.35rem;">
                        🛡️ Safety, Transparency & Dispute Protection
                    </div>
                    <h3 style="font-size: 1.35rem; font-weight: 800; color: var(--secondary); margin-bottom: 0.4rem;">
                        Built with Customer & Provider Protection at Core
                    </h3>
                    <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.5;">
                        Every service request is governed by external XML business rules with fixed duration estimates and fair pricing. In case of issues, our dedicated Administrator Grievance Console provides quick dispute review and worker roster moderation.
                    </p>
                </div>
                <div>
                    <a href="login.jsp" class="btn btn-primary" style="padding: 0.85rem 1.85rem;">
                        Get Started Today →
                    </a>
                </div>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory. Built with Jakarta Servlets, JSP 3.1, Pure JDBC, XML XPath, and AJAX.</p>
    </footer>

</body>
</html>
