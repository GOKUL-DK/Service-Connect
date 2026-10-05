<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.serviceconnect.service.BookingService" %>
<%@ page import="com.serviceconnect.model.Booking" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
        return;
    }

    String bookingIdParam = request.getParameter("bookingId");
    Booking booking = (Booking) request.getAttribute("booking");

    if (booking == null && bookingIdParam != null) {
        try {
            int bid = Integer.parseInt(bookingIdParam);
            BookingService bookingService = new BookingService();
            booking = bookingService.getBooking(bid);
        } catch (NumberFormatException ignored) {}
    }

    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmed - ServiceConnect</title>
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
                <li><a href="customer-dashboard.jsp" class="nav-link">Dashboard</a></li>
                <li><span class="user-badge">👤 <%= session.getAttribute("name") %></span></li>
                <li><a href="logout" class="btn btn-secondary" style="padding: 0.4rem 0.8rem; font-size: 0.85rem;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="container-narrow">
        <div class="card" style="box-shadow: var(--shadow-xl); border: 1px solid var(--border);">
            <!-- In-App Notification Alert Banner for Live Status Changes -->
            <div id="bookingNotificationBanner" class="alert alert-success" style="display: none; margin-bottom: 1.25rem;"></div>

            <div style="text-align: center; margin-bottom: 1.75rem;">
                <div style="width: 64px; height: 64px; background: var(--success-bg); border: 2px solid var(--success-border); color: #16a34a; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 2rem; margin-bottom: 0.85rem; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2);">
                    ✓
                </div>
                <h1 class="card-title" style="font-size: 1.8rem; color: #15803d; justify-content: center; margin-bottom: 0.35rem;" id="bookingConfirmedHeading">
                    Booking Confirmed
                </h1>
                <p style="color: var(--text-muted); font-size: 0.925rem;">
                    Your service allocation request has been dispatched to the nearest provider.
                </p>
            </div>

            <!-- Completion Security OTP Box -->
            <div style="background: linear-gradient(135deg, rgba(79, 70, 229, 0.08) 0%, rgba(6, 182, 212, 0.08) 100%); border: 1.5px dashed var(--primary); border-radius: var(--radius-sm); padding: 1.25rem; margin-bottom: 1.5rem; text-align: center;">
                <div style="font-size: 0.85rem; font-weight: 700; color: var(--primary); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 0.25rem;">🔑 Service Completion OTP</div>
                <div style="font-size: 2.2rem; font-weight: 900; letter-spacing: 6px; color: var(--secondary); font-family: 'JetBrains Mono', monospace;"><%= booking.getOtp() %></div>
                <p style="font-size: 0.8rem; color: var(--text-muted); margin: 0.25rem 0 0;">Share this 4-digit security code with <%= booking.getProviderName() %> upon service completion.</p>
            </div>

            <!-- Digital Receipt Box -->
            <div style="background: var(--bg-card-alt); border: 1px solid var(--border-light); border-radius: var(--radius-sm); padding: 1.5rem; margin-bottom: 1.75rem;">
                <div style="display: flex; justify-content: space-between; border-bottom: 1px solid var(--border); padding-bottom: 0.85rem; margin-bottom: 0.85rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem; font-weight: 600;">Booking Reference</span>
                    <strong id="liveBookingId" style="font-size: 1.2rem; color: var(--secondary); font-family: 'JetBrains Mono', monospace;">#<%= booking.getBookingId() %></strong>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Requested Service:</span>
                    <strong style="color: var(--primary);"><%= booking.getServiceName() %></strong>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Allocated Technician:</span>
                    <strong style="color: var(--secondary);"><%= booking.getProviderName() %></strong>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Provider Phone:</span>
                    <code style="background: #fff; padding: 0.2rem 0.5rem; border-radius: 4px; border: 1px solid var(--border);"><%= booking.getProviderPhone() %></code>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Destination Landmark & Address:</span>
                    <span><%= booking.getLocationName() %></span>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Calculated Distance:</span>
                    <span style="font-weight: 700; color: var(--secondary);"><%= booking.getDistance() %> km</span>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Scheduled Time:</span>
                    <span><%= booking.getRequestedTime() %></span>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Dispatch Priority:</span>
                    <span><%= booking.isEmergency() ? "<span class='badge badge-danger' style='background: #dc2626; color: #fff;'>🚨 EMERGENCY SOS</span>" : "<span class='badge badge-confirmed'>STANDARD</span>" %></span>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 0.6rem; border-top: 1px dashed var(--border); padding-top: 0.65rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem; font-weight: 600;">Total Net Amount (incl. Tax):</span>
                    <strong style="color: var(--success); font-size: 1.25rem;">₹<%= booking.getTotalAmount() > 0 ? booking.getTotalAmount() : "413.0" %></strong>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border); padding-top: 0.85rem; margin-top: 0.85rem;">
                    <span style="color: var(--text-muted); font-size: 0.9rem; font-weight: 600;">Live Dispatch Status:</span>
                    <span id="liveBookingStatus" class="badge badge-<%= booking.getStatus().toLowerCase() %>">
                        <%= booking.getStatus() %>
                    </span>
                </div>
            </div>

            <!-- In-App Live Direct Chat Box -->
            <div style="background: #fff; border: 1px solid var(--border-light); border-radius: var(--radius-sm); padding: 1.25rem; margin-bottom: 1.5rem; box-shadow: var(--shadow-sm);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem;">
                    <strong style="color: var(--secondary); font-size: 0.95rem; display: flex; align-items: center; gap: 0.4rem;">
                        💬 Direct Dispatch Chat with <%= booking.getProviderName() %>
                    </strong>
                    <span class="badge badge-confirmed" style="font-size: 0.75rem;">Live</span>
                </div>
                <div id="chatMessages" style="height: 160px; overflow-y: auto; background: var(--bg-card-alt); border-radius: var(--radius-sm); padding: 0.75rem; border: 1px solid var(--border-light); margin-bottom: 0.75rem; display: flex; flex-direction: column; gap: 0.5rem; font-size: 0.85rem;">
                    <div style="color: var(--text-muted); text-align: center; margin-top: 2rem;">Connecting live chat...</div>
                </div>
                <div style="display: flex; gap: 0.5rem;">
                    <input type="text" id="chatInput" class="form-control" placeholder="Type instructions or message for provider..." style="font-size: 0.875rem;">
                    <button type="button" id="sendChatBtn" class="btn btn-primary" style="padding: 0.6rem 1.2rem;">Send</button>
                </div>
            </div>

            <!-- Post-Service Review Card -->
            <div id="reviewCard" style="background: #fff; border: 1px solid var(--border-light); border-radius: var(--radius-sm); padding: 1.25rem; margin-bottom: 1.5rem; display: <%= "COMPLETED".equalsIgnoreCase(booking.getStatus()) ? "block" : "none" %>;">
                <h3 style="font-size: 1rem; font-weight: 700; color: var(--secondary); margin-bottom: 0.5rem;">⭐ Rate Service & Provider</h3>
                <div id="starContainer" style="font-size: 1.6rem; cursor: pointer; color: #fbbf24; margin-bottom: 0.5rem; user-select: none;">
                    <span onclick="setRating(1)">★</span><span onclick="setRating(2)">★</span><span onclick="setRating(3)">★</span><span onclick="setRating(4)">★</span><span onclick="setRating(5)">★</span>
                </div>
                <input type="hidden" id="ratingValue" value="5">
                <textarea id="reviewComment" class="form-control" rows="2" placeholder="Write feedback or review..." style="margin-bottom: 0.6rem; font-size: 0.85rem;"></textarea>
                <button type="button" id="submitReviewBtn" class="btn btn-success" style="width: 100%; font-size: 0.9rem;">Submit Rating</button>
            </div>

            <div style="display: flex; gap: 0.75rem;">
                <a href="customer-dashboard.jsp" class="btn btn-secondary" style="flex: 1; padding: 0.85rem;">
                    ← Return to Dashboard
                </a>
                <button type="button" class="btn btn-primary" onclick="window.print()" style="flex: 1; padding: 0.85rem;">
                    🖨️ Print Digital Invoice
                </button>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory. Live Status Polling Active.</p>
    </footer>

    <!-- Live status polling script -->
    <script src="js/booking.js"></script>
</body>
</html>
