<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.serviceconnect.dao.ServiceDAO" %>
<%@ page import="com.serviceconnect.dao.LocationDAO" %>
<%@ page import="com.serviceconnect.dao.BookingDAO" %>
<%@ page import="com.serviceconnect.model.Service" %>
<%@ page import="com.serviceconnect.model.Location" %>
<%@ page import="com.serviceconnect.model.Booking" %>
<%@ page import="com.serviceconnect.util.CookieUtil" %>
<%
    // Session Verification
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
        return;
    }

    String customerName = (String) session.getAttribute("name");
    int customerId = (Integer) session.getAttribute("userId");

    // Load available services & locations
    ServiceDAO serviceDAO = new ServiceDAO();
    LocationDAO locationDAO = new LocationDAO();
    BookingDAO bookingDAO = new BookingDAO();

    List<Service> services = serviceDAO.getAllServices();
    List<Location> locations = locationDAO.getAllLocations();
    List<Booking> myBookings = bookingDAO.getBookingsByUser(customerId);

    // Retrieve preferences saved in Cookies
    String preferredService = CookieUtil.getCookieValue(request, "preferredService");
    String preferredRadius = CookieUtil.getCookieValue(request, "preferredRadius");

    int activeBookingsCount = 0;
    int completedBookingsCount = 0;
    double totalSpent = 0.0;
    if (myBookings != null) {
        for (Booking b : myBookings) {
            String st = b.getStatus();
            if ("COMPLETED".equalsIgnoreCase(st)) {
                completedBookingsCount++;
                totalSpent += (b.getTotalAmount() > 0 ? b.getTotalAmount() : 354.00);
            } else if (!"CANCELLED".equalsIgnoreCase(st)) {
                activeBookingsCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - ServiceConnect</title>
    <link rel="stylesheet" href="css/style.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        .modal-overlay {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            right: 0 !important;
            bottom: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            background: rgba(15, 23, 42, 0.75) !important;
            backdrop-filter: blur(8px) !important;
            -webkit-backdrop-filter: blur(8px) !important;
            display: none;
            align-items: center !important;
            justify-content: center !important;
            z-index: 999999 !important;
            padding: 1rem !important;
            box-sizing: border-box !important;
            margin: 0 !important;
        }
        .modal-dialog {
            background: rgba(15, 23, 42, 0.95) !important;
            backdrop-filter: blur(24px) !important;
            -webkit-backdrop-filter: blur(24px) !important;
            width: 100% !important;
            max-width: 520px !important;
            border-radius: 16px !important;
            border: 1px solid var(--border) !important;
            box-shadow: 0 16px 40px -10px rgba(0, 0, 0, 0.6) !important;
            color: var(--text-main) !important;
            display: flex !important;
            flex-direction: column !important;
            overflow: hidden !important;
            position: relative !important;
            max-height: 90vh !important;
            margin: auto !important;
            z-index: 1000000 !important;
            animation: modalPopAnim 0.22s cubic-bezier(0.16, 1, 0.3, 1) forwards !important;
        }
    </style>
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="index.jsp" class="nav-brand">
            <span class="brand-icon">⚡</span>
            <span>ServiceConnect</span>
        </a>
        <nav>
            <ul class="nav-menu" style="display: flex; align-items: center; gap: 0.85rem;">
                <li><a href="customer-dashboard.jsp" class="nav-link active">Dashboard</a></li>
                <li><a href="profile" class="nav-link">👤 My Profile</a></li>
                <li class="nav-bell-container">
                    <button type="button" class="nav-bell-btn" title="Live Message Alerts" onclick="focusLatestMessage()">
                        🔔
                        <span id="navUnreadBadge" class="nav-bell-badge">0</span>
                    </button>
                </li>
                <li><span class="user-badge">👤 Welcome, <%= customerName %></span></li>
                <li><a href="logout" class="btn btn-secondary" style="padding: 0.4rem 0.8rem; font-size: 0.85rem;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="container">
        <% 
            String cMsg = request.getParameter("msg");
            if ("complaintFiled".equalsIgnoreCase(cMsg)) { 
        %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                ✅ Your grievance complaint has been securely escalated to the Administrator for investigation.
            </div>
        <% } %>

        <!-- Executive KPI Metrics Grid -->
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Active Requests</span>
                    <span class="kpi-card-value"><%= activeBookingsCount %></span>
                    <span class="kpi-card-sub">⚡ Dispatched & In-Progress</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(79, 70, 229, 0.1); color: var(--primary);">📋</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Completed Services</span>
                    <span class="kpi-card-value"><%= completedBookingsCount %></span>
                    <span class="kpi-card-sub">✓ Verified by Secure OTP</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(16, 185, 129, 0.1); color: var(--success);">✅</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Total Expenditure</span>
                    <span class="kpi-card-value">₹<%= String.format("%.2f", totalSpent) %></span>
                    <span class="kpi-card-sub">💳 Digital Invoice Receipts</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(245, 158, 11, 0.1); color: var(--warning);">💰</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Current Radius</span>
                    <span class="kpi-card-value"><%= preferredRadius != null ? preferredRadius : "5" %> km</span>
                    <span class="kpi-card-sub">📍 Haversine GPS Range</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(6, 182, 212, 0.1); color: var(--accent);">🎯</div>
            </div>
        </div>

        <!-- Service Search Panel -->
        <section class="card" style="border-top: 4px solid var(--primary); box-shadow: var(--shadow-lg);">
            <div class="card-header">
                <div>
                    <h1 class="card-title">🔍 Find & Book a Local Service</h1>
                    <p style="font-size: 0.875rem; color: var(--text-muted); margin-top: 0.25rem;">
                        Select trade category, enter your landmark or use GPS, and set radius to locate verified nearby technicians.
                    </p>
                </div>
                <span class="badge badge-confirmed">Haversine GPS Engine Active</span>
            </div>

            <form id="providerSearchForm">
                <div class="form-row">
                    <!-- Service Selection Dropdown -->
                    <div class="form-group">
                        <label class="form-label" for="serviceSelect">🛠 Service Type</label>
                        <select id="serviceSelect" name="service" class="form-select" required>
                            <option value="">-- Choose Service --</option>
                            <% for (Service s : services) { 
                                boolean isSelected = (preferredService != null && preferredService.equalsIgnoreCase(s.getServiceName())) 
                                                    || (preferredService == null && "Plumbing".equalsIgnoreCase(s.getServiceName()));
                            %>
                                <option value="<%= s.getServiceName() %>" <%= isSelected ? "selected" : "" %>><%= s.getServiceName() %></option>
                            <% } %>
                        </select>
                    </div>

                    <!-- Landmark Text Input with GPS button -->
                    <div class="form-group">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.35rem;">
                            <label class="form-label" for="landmarkInput" style="margin-bottom: 0;">📍 Landmark</label>
                            <button type="button" id="useGpsBtn" class="btn btn-secondary" style="padding: 0.2rem 0.5rem; font-size: 0.75rem; border-radius: 4px;">
                                🎯 Use My GPS
                            </button>
                        </div>
                        <input type="text" id="landmarkInput" name="landmark" class="form-control" 
                               list="landmarkSuggestions" placeholder="e.g. Location A, Central Clock Tower" 
                               value="Location A" required
                               oninput="var el = document.getElementById('locationSelect'); if(el) el.value = this.value;">
                        <input type="hidden" id="locationSelect" name="location" value="Location A">
                        <datalist id="landmarkSuggestions">
                            <% for (Location loc : locations) { %>
                                <option value="<%= loc.getLocationName() %>">
                            <% } %>
                        </datalist>
                    </div>

                    <!-- Address Text Input -->
                    <div class="form-group">
                        <label class="form-label" for="addressInput">🏠 Address / Street</label>
                        <input type="text" id="addressInput" name="address" class="form-control" 
                               placeholder="e.g. 42 North Cross Road, 2nd Floor" 
                               value="42 North Cross Road" required>
                    </div>

                    <!-- Search Radius Dropdown -->
                    <div class="form-group">
                        <label class="form-label" for="radiusSelect">📏 Search Radius</label>
                        <select id="radiusSelect" name="radius" class="form-select">
                            <option value="2" <%= "2".equals(preferredRadius) ? "selected" : "" %>>2 km (Immediate Area)</option>
                            <option value="5" <%= preferredRadius == null || "5".equals(preferredRadius) ? "selected" : "" %>>5 km (Standard Radius)</option>
                            <option value="10" <%= "10".equals(preferredRadius) ? "selected" : "" %>>10 km (Extended City)</option>
                            <option value="15" <%= "15".equals(preferredRadius) ? "selected" : "" %>>15 km (XML Maximum Limit)</option>
                        </select>
                    </div>

                    <!-- Required Time Picker -->
                    <div class="form-group">
                        <label class="form-label" for="timeInput">⏰ Requested Time</label>
                        <input type="time" id="timeInput" name="requestedTime" class="form-control" value="11:00" required>
                    </div>
                </div>

                <!-- Emergency SOS Priority Booking Checkbox -->
                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem; margin-top: 1.25rem; padding-top: 1rem; border-top: 1px solid var(--border-light);">
                    <div style="display: flex; align-items: center; gap: 0.6rem; padding: 0.5rem 0.85rem; background: rgba(239, 68, 68, 0.06); border: 1px dashed rgba(239, 68, 68, 0.35); border-radius: var(--radius-sm);">
                        <input type="checkbox" id="emergencyToggle" name="isEmergency" value="true" style="width: 18px; height: 18px; cursor: pointer;">
                        <label for="emergencyToggle" style="font-size: 0.9rem; font-weight: 700; color: #dc2626; cursor: pointer; display: flex; align-items: center; gap: 0.35rem;">
                            🚨 Emergency SOS Booking <span style="font-weight: 400; font-size: 0.8rem; color: var(--text-muted);">(Priority dispatch + ₹150)</span>
                        </label>
                    </div>

                    <button type="button" id="findProvidersBtn" class="btn btn-primary" style="padding: 0.85rem 2.25rem; font-size: 1rem;">
                        FIND PROVIDERS
                    </button>
                </div>
            </form>
        </section>

        <!-- Status Alert Notification Box -->
        <div id="searchStatusAlert" class="alert" style="display: none;"></div>

        <!-- Interactive Leaflet Map Section -->
        <section class="card" id="mapSection" style="box-shadow: var(--shadow-md);">
            <div class="card-header">
                <div>
                    <h2 class="card-title">🗺️ Live GPS Service Radar & Provider Map</h2>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                        Interactive OpenStreetMap rendering provider positions, live distance radius, and target coordinates.
                    </p>
                </div>
                <span class="badge badge-confirmed" id="mapCoordinatesBadge">Coimbatore GPS (11.0168° N, 76.9558° E)</span>
            </div>
            <div id="serviceMap" style="height: 360px; width: 100%; border-radius: var(--radius-sm); border: 1px solid var(--border-light); z-index: 1;"></div>
        </section>

        <!-- Dynamic Results Container for AJAX-loaded Provider Cards -->
        <section class="card" id="resultsCard">
            <div class="card-header">
                <div>
                    <h2 class="card-title">⚡ Available Verified Providers</h2>
                    <span style="font-size: 0.85rem; color: var(--text-muted); display: block; margin-top: 0.2rem;">
                        Asynchronously loaded & distance-sorted via AJAX
                    </span>
                </div>
                <span class="badge badge-requested">Live Dispatch</span>
            </div>

            <div id="providerResultsContainer">
                <div style="text-align: center; padding: 3rem 1.5rem; color: var(--text-muted); background: var(--bg-card-alt); border-radius: var(--radius-sm); border: 1px dashed var(--border);">
                    <div style="font-size: 2.2rem; margin-bottom: 0.75rem;">📡</div>
                    <p style="font-size: 1.1rem; font-weight: 700; color: var(--secondary); margin-bottom: 0.25rem;">Ready to locate nearby experts</p>
                    <p style="font-size: 0.9rem;">Click <strong>FIND PROVIDERS</strong> above to run real-time GPS allocation and inspect provider availability.</p>
                </div>
            </div>
        </section>

        <!-- Customer Booking History -->
        <section class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">📋 Your Service Booking History</h2>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                        Track appointments, view Completion Security OTPs, download digital invoices, and message providers.
                    </p>
                </div>
                <span class="badge badge-requested"><%= myBookings.size() %> Total Bookings</span>
            </div>

            <% if (myBookings.isEmpty()) { %>
                <div style="text-align: center; padding: 2.5rem 1rem; color: var(--text-muted);">
                    <p style="font-size: 1rem;">No service requests logged yet. Use the search tool above to book your first service!</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Booking ID</th>
                                <th>Service</th>
                                <th>Provider</th>
                                <th>Contact</th>
                                <th>Location</th>
                                <th>Security OTP</th>
                                <th>Total Bill</th>
                                <th>Status</th>
                                <th style="min-width: 320px; width: 320px; text-align: center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Booking b : myBookings) { 
                                String pSafeName = b.getProviderName() != null ? b.getProviderName().replace("'", "\\'") : "Technician";
                            %>
                                <tr>
                                    <td><code style="font-family: 'JetBrains Mono', monospace; font-weight: 700; color: var(--secondary); background: var(--bg-card-alt); padding: 0.25rem 0.5rem; border-radius: 6px; border: 1px solid var(--border);">#<%= b.getBookingId() %></code></td>
                                    <td>
                                        <span style="font-weight: 700; color: var(--primary);"><%= b.getServiceName() %></span>
                                        <% if (b.isEmergency()) { %>
                                            <span class="badge badge-emergency" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; margin-left: 0.25rem;">SOS</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 0.6rem;">
                                            <div class="avatar-circle-sm">
                                                <%= (b.getProviderName() != null && !b.getProviderName().isEmpty()) ? b.getProviderName().substring(0, 1).toUpperCase() : "P" %>
                                            </div>
                                            <strong><%= b.getProviderName() != null ? b.getProviderName() : "Technician" %></strong>
                                        </div>
                                    </td>
                                    <td><code style="background: var(--bg-card-alt); padding: 0.2rem 0.5rem; border-radius: 4px; font-family: 'JetBrains Mono', monospace;"><%= b.getProviderPhone() %></code></td>
                                    <td><%= b.getLocationName() %></td>
                                    <td>
                                        <span class="badge badge-warning" style="font-size: 0.85rem; font-family: 'JetBrains Mono', monospace; letter-spacing: 2px;">
                                            🔑 <%= b.getOtp() != null ? b.getOtp() : "1234" %>
                                        </span>
                                    </td>
                                    <td>
                                        <strong style="color: var(--success); font-size: 0.95rem; font-family: 'Outfit', sans-serif;">
                                            ₹<%= String.format("%.2f", b.getTotalAmount() > 0 ? b.getTotalAmount() : 354.00) %>
                                        </strong>
                                    </td>
                                    <td>
                                        <span class="status-pill badge-<%= b.getStatus().toLowerCase() %>">
                                            <span class="status-pill-dot <%= "IN_PROGRESS".equalsIgnoreCase(b.getStatus()) || "REQUESTED".equalsIgnoreCase(b.getStatus()) ? "pulse" : "" %>"></span>
                                            <%= b.getStatus() %>
                                        </span>
                                    </td>
                                    <td style="white-space: nowrap; text-align: center;">
                                        <div class="action-btn-group">
                                            <a href="confirmation.jsp?bookingId=<%= b.getBookingId() %>" class="btn btn-secondary action-pill" title="Digital Receipt">
                                                📄 Receipt
                                            </a>
                                            <button type="button" id="chatBtn-<%= b.getBookingId() %>" class="btn btn-primary action-pill" onclick="openChatModal(<%= b.getBookingId() %>, '<%= pSafeName %>')" title="Live Direct Chat">
                                                💬 Chat
                                            </button>
                                            <% if ("COMPLETED".equalsIgnoreCase(b.getStatus())) { %>
                                                <% if (b.getRating() > 0) { %>
                                                    <span style="color: #fbbf24; font-size: 0.82rem; font-weight: 700; padding: 0.25rem 0.5rem; background: rgba(245, 158, 11, 0.14); border-radius: 6px; border: 1px solid rgba(245, 158, 11, 0.35);">★ <%= b.getRating() %></span>
                                                <% } else { %>
                                                    <button type="button" class="btn btn-success action-pill" onclick="openReviewModal(<%= b.getBookingId() %>)" title="Rate & Review">
                                                        ⭐ Rate
                                                    </button>
                                                <% } %>
                                            <% } %>
                                            <button type="button" class="btn btn-danger-outline action-pill" onclick="openComplaintModal(<%= b.getBookingId() %>, <%= b.getProviderId() %>, '<%= pSafeName %>')" title="Report Worker Misconduct">
                                                ⚠️ Report
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>
    </main>

    <!-- Real-time Floating Notification Toast Container -->
    <div id="notificationToastContainer"></div>

    <!-- In-App Live Direct Chat Modal -->
    <div id="chatModal" class="modal-overlay" style="display: none;">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 id="chatModalTitle">💬 Live Dispatch Chat</h3>
                <button type="button" class="modal-close-btn" onclick="closeChatModal()">✕</button>
            </div>
            <div class="modal-body" style="display: flex; flex-direction: column;">
                <div id="modalChatMessages" class="chat-messages-container">
                    <div style="color: var(--text-muted); text-align: center; margin: auto;">Loading live conversation...</div>
                </div>
                <div style="display: flex; gap: 0.5rem; margin-top: 0.25rem;">
                    <input type="text" id="modalChatInput" class="form-control" placeholder="Type a message to provider..." onkeydown="if(event.key === 'Enter') { event.preventDefault(); sendModalChatMessage(); }">
                    <button type="button" id="modalSendChatBtn" class="btn btn-primary" onclick="sendModalChatMessage()" style="padding: 0.6rem 1.25rem;">Send</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Customer Star Rating Modal -->
    <div id="reviewModal" class="modal-overlay" style="display: none;">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3>⭐ Rate & Review Service</h3>
                <button type="button" class="modal-close-btn" onclick="closeReviewModal()">✕</button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="modalReviewBookingId" value="">
                <div style="text-align: center; margin-bottom: 1.25rem;">
                    <p style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 0.5rem;">How was your experience?</p>
                    <div class="star-rating" id="modalStarRating">
                        <span class="star active" data-val="1" onclick="setModalRating(1)">★</span>
                        <span class="star active" data-val="2" onclick="setModalRating(2)">★</span>
                        <span class="star active" data-val="3" onclick="setModalRating(3)">★</span>
                        <span class="star active" data-val="4" onclick="setModalRating(4)">★</span>
                        <span class="star active" data-val="5" onclick="setModalRating(5)">★</span>
                    </div>
                    <input type="hidden" id="modalRatingScore" value="5">
                </div>
                <div class="form-group">
                    <label class="form-label" for="modalReviewComment">Comments / Feedback</label>
                    <textarea id="modalReviewComment" class="form-control" rows="3" placeholder="Share your experience with this provider..."></textarea>
                </div>
                <div id="modalReviewAlert" class="alert" style="display: none; margin-top: 0.75rem;"></div>
                <button type="button" id="modalSubmitReviewBtn" class="btn btn-success btn-block" onclick="submitModalReview()" style="margin-top: 1rem;">
                    Submit Rating & Review
                </button>
            </div>
        </div>
    </div>

    <!-- Customer Grievance / Complaint Filing Modal -->
    <div id="complaintModal" class="modal-overlay" style="display: none;">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 id="complaintModalTitle" style="color: var(--danger);">⚠️ Report Worker to Admin</h3>
                <button type="button" class="modal-close-btn" onclick="closeComplaintModal()">✕</button>
            </div>
            <div class="modal-body">
                <form id="complaintForm" action="complaint" method="POST">
                    <input type="hidden" name="action" value="file">
                    <input type="hidden" id="complaintBookingId" name="bookingId" value="0">
                    <input type="hidden" id="complaintTargetId" name="targetId" value="0">
                    <input type="hidden" id="complaintTargetName" name="targetName" value="">
                    <input type="hidden" name="targetRole" value="PROVIDER">

                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1rem;">
                        Submit your grievance directly to the platform Administrator for investigation. Administrators review all incidents and can penalize or expel providers.
                    </p>

                    <div class="form-group">
                        <label class="form-label" for="complaintType">Grievance Category</label>
                        <select id="complaintType" name="complaintType" class="form-select" required>
                            <option value="Unprofessional Conduct">Unprofessional / Rude Behavior</option>
                            <option value="Late or No-Show">Technician was late or failed to show up</option>
                            <option value="Poor Service Quality">Substandard or incomplete workmanship</option>
                            <option value="Billing / Overcharging Dispute">Dispute regarding service fee or billing</option>
                            <option value="Safety / Property Concern">Safety violation or property damage</option>
                            <option value="Other">Other dispute</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="complaintDescription">Detailed Explanation</label>
                        <textarea id="complaintDescription" name="description" class="form-control" rows="4" placeholder="Describe what occurred with as much specific detail as possible..." required></textarea>
                    </div>

                    <div style="display: flex; gap: 0.75rem; margin-top: 1.25rem;">
                        <button type="button" class="btn btn-secondary" onclick="closeComplaintModal()" style="flex: 1;">Cancel</button>
                        <button type="submit" class="btn btn-danger" style="flex: 2;">Submit Grievance to Admin 🚨</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory. Powered by Jakarta Servlets, AJAX, and XML Rules.</p>
    </footer>

    <!-- Client-side script handling AJAX search, Leaflet GPS Map, and DOM generation -->
    <script src="js/provider-search.js?v=<%= System.currentTimeMillis() %>"></script>
    <script>
        // Modal & Interactive Utilities
        let activeChatBookingId = null;
        let chatPollTimer = null;

        function closeAllModals() {
            const cm = document.getElementById("chatModal");
            const rm = document.getElementById("reviewModal");
            const pm = document.getElementById("complaintModal");
            if (cm) cm.style.display = "none";
            if (rm) rm.style.display = "none";
            if (pm) pm.style.display = "none";
            if (chatPollTimer) { clearInterval(chatPollTimer); chatPollTimer = null; }
            activeChatBookingId = null;
        }

        function openChatModal(bookingId, providerName) {
            closeAllModals();
            activeChatBookingId = bookingId;
            document.getElementById("chatModalTitle").textContent = "💬 Chat with " + providerName + " (Booking #" + bookingId + ")";
            document.getElementById("chatModal").style.display = "flex";

            // Clear unread pulse dot on this booking row
            const chatBtn = document.getElementById("chatBtn-" + bookingId);
            if (chatBtn) {
                const dot = chatBtn.querySelector(".pulse-dot");
                if (dot) dot.remove();
            }
            if (unreadNotificationCount > 0) {
                updateUnreadBadge(unreadNotificationCount - 1);
            }

            loadModalChatMessages();
            if (chatPollTimer) clearInterval(chatPollTimer);
            chatPollTimer = setInterval(loadModalChatMessages, 2500);
            setTimeout(() => {
                const inp = document.getElementById("modalChatInput");
                if (inp) inp.focus();
            }, 100);
        }

        function closeChatModal() {
            closeAllModals();
        }

        function loadModalChatMessages() {
            if (!activeChatBookingId) return;
            fetch("<%= request.getContextPath() %>/api/chat?bookingId=" + activeChatBookingId, { credentials: "same-origin" })
                .then(r => r.json())
                .then(messages => {
                    const container = document.getElementById("modalChatMessages");
                    if (!messages || messages.length === 0) {
                        container.innerHTML = "<div style='color: var(--text-muted); text-align: center; margin: auto;'>No messages yet. Send a message to begin!</div>";
                        return;
                    }
                    container.innerHTML = "";
                    messages.forEach(m => {
                        const isMe = m.senderRole && m.senderRole.toUpperCase() === "CUSTOMER";
                        const bubble = document.createElement("div");
                        bubble.className = "chat-bubble " + (isMe ? "chat-bubble-me" : "chat-bubble-them");
                        bubble.innerHTML = "<strong>" + (m.senderName || "User") + ":</strong> " + m.messageText + 
                                          "<div class='chat-bubble-meta'>" + (m.sentAt || "") + "</div>";
                        container.appendChild(bubble);
                    });
                    setTimeout(() => { container.scrollTop = container.scrollHeight; }, 60);
                })
                .catch(e => console.warn("Chat fetch error", e));
        }

        function sendModalChatMessage() {
            const input = document.getElementById("modalChatInput");
            const btn = document.getElementById("modalSendChatBtn");
            const text = input.value.trim();
            if (!text || !activeChatBookingId) return;

            const params = new URLSearchParams();
            params.append("bookingId", activeChatBookingId);
            params.append("message", text);

            if (btn) btn.disabled = true;
            fetch("<%= request.getContextPath() %>/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                credentials: "same-origin",
                body: params.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (btn) btn.disabled = false;
                if (data.status === "success") {
                    input.value = "";
                    loadModalChatMessages();
                } else {
                    alert("Unable to deliver message: " + (data.message || "Booking session error"));
                }
            })
            .catch(err => {
                if (btn) btn.disabled = false;
                console.error("Chat send error", err);
                alert("Network error: Could not reach chat server.");
            });
        }

        function openReviewModal(bookingId) {
            closeAllModals();
            document.getElementById("modalReviewBookingId").value = bookingId;
            document.getElementById("modalReviewComment").value = "";
            document.getElementById("modalReviewAlert").style.display = "none";
            setModalRating(5);
            document.getElementById("reviewModal").style.display = "flex";
        }

        function closeReviewModal() {
            closeAllModals();
        }

        function setModalRating(val) {
            document.getElementById("modalRatingScore").value = val;
            const stars = document.querySelectorAll("#modalStarRating .star");
            stars.forEach((s, idx) => {
                if (idx < val) s.classList.add("active");
                else s.classList.remove("active");
            });
        }

        function submitModalReview() {
            const bookingId = document.getElementById("modalReviewBookingId").value;
            const rating = document.getElementById("modalRatingScore").value;
            const comment = document.getElementById("modalReviewComment").value;
            const alertEl = document.getElementById("modalReviewAlert");

            const params = new URLSearchParams();
            params.append("bookingId", bookingId);
            params.append("rating", rating);
            params.append("comment", comment);

            fetch("<%= request.getContextPath() %>/api/review", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                credentials: "same-origin",
                body: params.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (data.status === "success") {
                    alertEl.className = "alert alert-success";
                    alertEl.textContent = "✓ Review saved successfully!";
                    alertEl.style.display = "block";
                    setTimeout(() => {
                        closeReviewModal();
                        window.location.reload();
                    }, 1000);
                } else {
                    alertEl.className = "alert alert-danger";
                    alertEl.textContent = "⚠️ " + (data.message || "Failed to save review");
                    alertEl.style.display = "block";
                }
            });
        }

        function openComplaintModal(bookingId, providerId, providerName) {
            closeAllModals();
            document.getElementById("complaintBookingId").value = bookingId;
            document.getElementById("complaintTargetId").value = providerId;
            document.getElementById("complaintTargetName").value = providerName;
            document.getElementById("complaintModalTitle").textContent = "⚠️ Report " + providerName + " (#" + bookingId + ")";
            document.getElementById("complaintModal").style.display = "flex";
        }

        function closeComplaintModal() {
            closeAllModals();
        }

        window.addEventListener("click", function(event) {
            const cm = document.getElementById("chatModal");
            const rm = document.getElementById("reviewModal");
            const pm = document.getElementById("complaintModal");
            if (event.target === cm || event.target === rm || event.target === pm) {
                closeAllModals();
            }
        });

        window.addEventListener("keydown", function(event) {
            if (event.key === "Escape") {
                closeAllModals();
            }
        });

        // ==========================================================
        // Real-Time Notification Toast & Audio Alert System
        // ==========================================================
        let lastKnownMessageId = 0;
        let latestNotifiedBookingId = null;
        let latestNotifiedSenderName = "";
        let unreadNotificationCount = 0;

        function playNotificationChime() {
            try {
                const AudioContext = window.AudioContext || window.webkitAudioContext;
                if (!AudioContext) return;
                const ctx = new AudioContext();
                if (ctx.state === 'suspended') {
                    ctx.resume();
                }
                const now = ctx.currentTime;
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();

                osc.type = "sine";
                osc.frequency.setValueAtTime(587.33, now); // D5
                osc.frequency.exponentialRampToValueAtTime(880, now + 0.12); // A5

                gain.gain.setValueAtTime(0.18, now);
                gain.gain.exponentialRampToValueAtTime(0.001, now + 0.45);

                osc.connect(gain);
                gain.connect(ctx.destination);

                osc.start(now);
                osc.stop(now + 0.45);
            } catch(e) {
                console.warn("Audio chime unsupported or muted", e);
            }
        }

        function escapeHtml(str) {
            if (!str) return "";
            return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        function showNotificationToast(bookingId, senderName, text, time) {
            const container = document.getElementById("notificationToastContainer");
            if (!container) return;

            latestNotifiedBookingId = bookingId;
            latestNotifiedSenderName = senderName;

            const toast = document.createElement("div");
            toast.className = "notification-toast";
            toast.innerHTML = `
                <div class="toast-header">
                    <div class="toast-sender-info">
                        <div class="toast-avatar">\${(senderName || "P").substring(0, 1).toUpperCase()}</div>
                        <div>
                            <div class="toast-title">\${escapeHtml(senderName || "Provider")} <span style="font-weight: 500; font-size: 0.75rem; color: var(--primary);">#\${bookingId}</span></div>
                            <div class="toast-time">\${escapeHtml(time || "Just now")}</div>
                        </div>
                    </div>
                    <button type="button" class="toast-close-btn" title="Dismiss">✕</button>
                </div>
                <div class="toast-body">
                    "\${escapeHtml(text)}"
                </div>
                <div class="toast-actions">
                    <button type="button" class="toast-action-btn">
                        <span>View Message</span> 💬
                    </button>
                </div>
            `;

            const openChat = () => {
                openChatModal(bookingId, senderName);
                dismissToast(toast);
            };

            toast.querySelector(".toast-action-btn").addEventListener("click", (e) => {
                e.stopPropagation();
                openChat();
            });

            toast.querySelector(".toast-body").addEventListener("click", openChat);

            toast.querySelector(".toast-close-btn").addEventListener("click", (e) => {
                e.stopPropagation();
                dismissToast(toast);
            });

            container.appendChild(toast);

            setTimeout(() => {
                if (toast.parentNode) dismissToast(toast);
            }, 8000);
        }

        function dismissToast(toast) {
            toast.classList.add("toast-closing");
            setTimeout(() => {
                if (toast.parentNode) toast.parentNode.removeChild(toast);
            }, 280);
        }

        function updateUnreadBadge(count) {
            unreadNotificationCount = Math.max(0, count);
            const badge = document.getElementById("navUnreadBadge");
            if (badge) {
                if (unreadNotificationCount > 0) {
                    badge.textContent = unreadNotificationCount > 9 ? "9+" : unreadNotificationCount;
                    badge.style.display = "inline-flex";
                } else {
                    badge.style.display = "none";
                }
            }
        }

        function focusLatestMessage() {
            if (latestNotifiedBookingId) {
                openChatModal(latestNotifiedBookingId, latestNotifiedSenderName || "Provider");
            } else {
                const table = document.querySelector(".data-table");
                if (table) table.scrollIntoView({ behavior: 'smooth' });
            }
        }

        function pollMessageNotifications() {
            fetch("<%= request.getContextPath() %>/api/chat?action=pollNotifications&lastMessageId=" + lastKnownMessageId, { credentials: "same-origin" })
                .then(r => r.json())
                .then(data => {
                    if (data && data.status === "success") {
                        if (data.lastMessageId > lastKnownMessageId) {
                            lastKnownMessageId = data.lastMessageId;
                        }
                        if (data.messages && data.messages.length > 0) {
                            let hasNewAlert = false;
                            data.messages.forEach(msg => {
                                if (activeChatBookingId && activeChatBookingId == msg.bookingId) {
                                    loadModalChatMessages();
                                } else {
                                    hasNewAlert = true;
                                    showNotificationToast(msg.bookingId, msg.senderName, msg.messageText, msg.sentAt);

                                    const chatBtn = document.getElementById("chatBtn-" + msg.bookingId);
                                    if (chatBtn && !chatBtn.querySelector(".pulse-dot")) {
                                        const dot = document.createElement("span");
                                        dot.className = "pulse-dot";
                                        dot.title = "New unread message!";
                                        chatBtn.appendChild(dot);
                                    }
                                }
                            });

                            if (hasNewAlert) {
                                playNotificationChime();
                                updateUnreadBadge(unreadNotificationCount + data.messages.length);
                            }
                        }
                    }
                })
                .catch(err => console.warn("Customer notification poll error", err));
        }

        // Initialize baseline poll ID on page load
        fetch("<%= request.getContextPath() %>/api/chat?action=pollNotifications&baseline=true", { credentials: "same-origin" })
            .then(r => r.json())
            .then(d => {
                if (d && d.lastMessageId) lastKnownMessageId = d.lastMessageId;
                setInterval(pollMessageNotifications, 3000);
            })
            .catch(() => {
                setInterval(pollMessageNotifications, 3000);
            });
    </script>
</body>
</html>
