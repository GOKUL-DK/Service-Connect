<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.serviceconnect.model.Provider" %>
<%@ page import="com.serviceconnect.model.Booking" %>
<%
    // Session Verification
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
        return;
    }

    String role = (String) session.getAttribute("role");
    if (!"PROVIDER".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp?error=accessDenied");
        return;
    }

    Provider provider = (Provider) request.getAttribute("provider");
    @SuppressWarnings("unchecked")
    List<Booking> jobs = (List<Booking>) request.getAttribute("jobs");

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

    String provStatus = (provider != null && provider.getStatus() != null) ? provider.getStatus() : "AVAILABLE";
    String fromTime = (provider != null && provider.getAvailableFrom() != null) ? provider.getAvailableFrom().substring(0, 5) : "09:00";
    String untilTime = (provider != null && provider.getAvailableUntil() != null) ? provider.getAvailableUntil().substring(0, 5) : "18:00";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Provider Dashboard - ServiceConnect</title>
    <link rel="stylesheet" href="css/style.css?v=<%= System.currentTimeMillis() %>">
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
            background: #ffffff !important;
            width: 100% !important;
            max-width: 520px !important;
            border-radius: 14px !important;
            box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.45), 0 0 0 1px rgba(226, 232, 240, 0.8) !important;
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
            <ul class="nav-menu" style="display: flex; align-items: center; gap: 1rem;">
                <li><a href="provider-dashboard" class="nav-link active">Jobs & Tasks</a></li>
                <li><a href="profile" class="nav-link">👤 My Profile</a></li>
                <li class="nav-bell-container">
                    <button type="button" class="nav-bell-btn" title="Live Customer Messages" onclick="focusLatestProviderMessage()">
                        🔔
                        <span id="navUnreadBadge" class="nav-bell-badge">0</span>
                    </button>
                </li>
                <li>
                    <button type="button" id="liveToggleHeaderBtn" 
                            class="status-toggle-btn <%= "AVAILABLE".equalsIgnoreCase(provStatus) ? "is-online" : "is-offline" %>" 
                            onclick="toggleProviderStatus()">
                        <%= "AVAILABLE".equalsIgnoreCase(provStatus) ? "🟢 Available" : "🔴 Unavailable" %>
                    </button>
                </li>
                <li><span class="user-badge">🛠 <%= provider != null ? provider.getName() : "Provider" %> (<%= provider != null ? provider.getServiceName() : "Service" %>)</span></li>
                <li><a href="logout" class="btn btn-secondary" style="padding: 0.4rem 0.8rem; font-size: 0.85rem;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="container">
        <!-- Top Status Alert -->
        <div id="liveStatusAlert" class="alert alert-success" style="display: none;"></div>
        <% if ("jobUpdated".equals(msg)) { %>
            <div class="alert alert-success">✓ Job status updated successfully!</div>
        <% } else if ("availabilityUpdated".equals(msg)) { %>
            <div class="alert alert-success">✓ Operating hours and availability status saved!</div>
        <% } else if ("complaintFiled".equals(msg)) { %>
            <div class="alert alert-success" style="background: #ecfdf5; border-left: 4px solid var(--success); color: #065f46; padding: 0.85rem 1.25rem; border-radius: 8px;">
                ✅ Your grievance regarding customer conduct has been escalated to Administration for review.
            </div>
        <% } else if (error != null) { %>
            <div class="alert alert-danger">⚠️ Action could not be processed. Please try again.</div>
        <% } %>

        <!-- Executive KPI Metrics Strip -->
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Assigned Queue</span>
                    <span class="kpi-card-value"><%= jobs != null ? jobs.size() : 0 %></span>
                    <span class="kpi-card-sub">⚡ Customer Task Dispatches</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(79, 70, 229, 0.1); color: var(--primary);">📋</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Operating Shift</span>
                    <span class="kpi-card-value" style="font-size: 1.5rem;"><%= fromTime %> - <%= untilTime %></span>
                    <span class="kpi-card-sub">⏱️ Active Daily Schedule</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(16, 185, 129, 0.1); color: var(--success);">⏱️</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Dispatch Status</span>
                    <span class="kpi-card-value" style="font-size: 1.35rem;">
                        <span id="metricStatusBadge" class="status-pill badge-<%= provStatus.toLowerCase() %>">
                            <span class="status-pill-dot <%= "AVAILABLE".equalsIgnoreCase(provStatus) ? "pulse" : "" %>"></span>
                            <%= provStatus %>
                        </span>
                    </span>
                    <span class="kpi-card-sub">📡 Live Radar Signal</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(6, 182, 212, 0.1); color: var(--accent);">📡</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Technician Profile</span>
                    <span class="kpi-card-value" style="font-size: 1.35rem; color: var(--primary);"><%= provider != null ? provider.getServiceName() : "Service" %></span>
                    <span class="kpi-card-sub">🛠️ Verified Trade</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(245, 158, 11, 0.1); color: var(--warning);">⭐</div>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.75rem;">
            <!-- Left Column: Assigned Jobs -->
            <section class="card" style="box-shadow: var(--shadow-md);">
                <div class="card-header">
                    <div>
                        <h1 class="card-title">⚡ Today's Assigned Service Queue</h1>
                        <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                            Live dispatch requests assigned to your service profile by customers.
                        </p>
                    </div>
                    <span class="badge badge-requested"><%= jobs != null ? jobs.size() : 0 %> Active Jobs</span>
                </div>

                <% if (jobs == null || jobs.isEmpty()) { %>
                    <div style="text-align: center; padding: 3rem 1rem; color: var(--text-muted); background: var(--bg-card-alt); border-radius: var(--radius-sm); border: 1px dashed var(--border);">
                        <div style="font-size: 2rem; margin-bottom: 0.5rem;">🎉</div>
                        <p style="font-weight: 700; color: var(--secondary); margin-bottom: 0.25rem;">All tasks up to date</p>
                        <p style="font-size: 0.9rem;">No pending customer requests at the moment. Keep status ACTIVE to receive bookings.</p>
                    </div>
                <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                        <% for (Booking job : jobs) { %>
                            <div style="border: 1px solid var(--border-light); border-left: 4px solid var(--primary); border-radius: var(--radius-sm); padding: 1.5rem; background: #fff; box-shadow: var(--shadow-sm); transition: var(--transition);">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.85rem; flex-wrap: wrap; gap: 0.5rem;">
                                    <div style="display: flex; align-items: center; gap: 0.75rem;">
                                        <code style="font-family: 'JetBrains Mono', monospace; font-size: 1.05rem; font-weight: 700; color: var(--secondary); background: var(--bg-card-alt); padding: 0.2rem 0.55rem; border-radius: 6px; border: 1px solid var(--border);">#<%= job.getBookingId() %></code>
                                        <span class="badge badge-requested" style="font-size: 0.75rem;"><%= job.getServiceName() %></span>
                                        <% if (job.isEmergency()) { %>
                                            <span class="badge badge-emergency" style="font-size: 0.75rem;">🚨 EMERGENCY SOS</span>
                                        <% } %>
                                    </div>
                                    <span class="status-pill badge-<%= job.getStatus().toLowerCase() %>">
                                        <span class="status-pill-dot <%= "IN_PROGRESS".equalsIgnoreCase(job.getStatus()) || "REQUESTED".equalsIgnoreCase(job.getStatus()) ? "pulse" : "" %>"></span>
                                        <%= job.getStatus() %>
                                    </span>
                                </div>

                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; font-size: 0.9rem; color: var(--text-muted); background: var(--bg-card-alt); padding: 0.9rem 1.1rem; border-radius: var(--radius-sm); margin-bottom: 1.25rem;">
                                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                                        <div class="avatar-circle-sm">
                                            <%= (job.getUserName() != null && !job.getUserName().isEmpty()) ? job.getUserName().substring(0, 1).toUpperCase() : "C" %>
                                        </div>
                                        <div>
                                            <span style="font-size: 0.75rem; text-transform: uppercase; font-weight: 700; color: var(--text-light); display: block;">Customer</span>
                                            <strong style="color: var(--secondary);"><%= job.getUserName() %></strong>
                                        </div>
                                    </div>
                                    <div>
                                        <span style="font-size: 0.75rem; text-transform: uppercase; font-weight: 700; color: var(--text-light); display: block;">Destination & Range</span>
                                        <strong style="color: var(--secondary);"><%= job.getLocationName() %></strong> <span class="badge badge-confirmed" style="font-size: 0.65rem; padding: 0.1rem 0.4rem;"><%= job.getDistance() %> km</span>
                                    </div>
                                    <div>
                                        <span style="font-size: 0.75rem; text-transform: uppercase; font-weight: 700; color: var(--text-light); display: block;">Appointment Time</span>
                                        <strong style="color: var(--secondary);"><%= job.getRequestedTime() %></strong>
                                    </div>
                                    <div>
                                        <span style="font-size: 0.75rem; text-transform: uppercase; font-weight: 700; color: var(--text-light); display: block;">Total Fare</span>
                                        <strong style="color: var(--success); font-family: 'Outfit', sans-serif; font-size: 1.05rem;">₹<%= String.format("%.2f", job.getTotalAmount() > 0 ? job.getTotalAmount() : 354.00) %></strong>
                                    </div>
                                </div>

                                <!-- Workflow Buttons: ACCEPT -> START -> COMPLETE & In-App Chat -->
                                <div style="display: flex; gap: 0.65rem; justify-content: flex-end; align-items: center; flex-wrap: wrap;">
                                    <button type="button" id="providerChatBtn-<%= job.getBookingId() %>" class="btn btn-secondary action-pill" onclick="openProviderChatModal(<%= job.getBookingId() %>, '<%= job.getUserName() != null ? job.getUserName().replace("'", "\\'") : "Customer" %>')">
                                        💬 Message Customer
                                    </button>
                                    <button type="button" class="btn btn-danger-outline action-pill" onclick="toggleInlineReport(<%= job.getBookingId() %>)">
                                        ⚠️ Report Customer
                                    </button>

                                    <% if ("CONFIRMED".equalsIgnoreCase(job.getStatus()) || "REQUESTED".equalsIgnoreCase(job.getStatus())) { %>
                                        <form action="provider-action" method="POST" style="margin: 0;">
                                            <input type="hidden" name="action" value="accept">
                                            <input type="hidden" name="bookingId" value="<%= job.getBookingId() %>">
                                            <button type="submit" class="btn btn-success action-pill accept-job-btn" id="acceptBtn-<%= job.getBookingId() %>">
                                                ✓ ACCEPT
                                            </button>
                                        </form>
                                    <% } else if ("ACCEPTED".equalsIgnoreCase(job.getStatus())) { %>
                                        <form action="provider-action" method="POST" style="margin: 0;">
                                            <input type="hidden" name="action" value="start">
                                            <input type="hidden" name="bookingId" value="<%= job.getBookingId() %>">
                                            <button type="submit" class="btn btn-warning action-pill start-job-btn" id="startBtn-<%= job.getBookingId() %>">
                                                ▶ START SERVICE
                                            </button>
                                        </form>
                                    <% } else if ("IN_PROGRESS".equalsIgnoreCase(job.getStatus())) { %>
                                        <form action="provider-action" method="POST" style="margin: 0; display: flex; align-items: center; gap: 0.4rem;">
                                            <input type="hidden" name="action" value="complete">
                                            <input type="hidden" name="bookingId" value="<%= job.getBookingId() %>">
                                            <input type="text" name="otp" class="form-control" placeholder="OTP" 
                                                   value="<%= job.getOtp() != null ? job.getOtp() : "1234" %>" 
                                                   title="Enter 4-digit customer OTP"
                                                   style="width: 100px; text-align: center; font-weight: 700; letter-spacing: 2px; font-size: 0.85rem; padding: 0.35rem 0.5rem;" required>
                                            <button type="submit" class="btn btn-primary action-pill complete-job-btn" id="completeBtn-<%= job.getBookingId() %>">
                                                ✓ COMPLETE
                                            </button>
                                        </form>
                                    <% } else if ("COMPLETED".equalsIgnoreCase(job.getStatus())) { %>
                                        <span class="badge badge-completed" style="padding: 0.4rem 0.95rem; font-size: 0.8rem;">
                                            ✓ COMPLETED
                                        </span>
                                    <% } %>
                                </div>

                                <!-- Inline Incident Reporting Drawer directly inside Service Card -->
                                <div id="inlineReport-<%= job.getBookingId() %>" class="inline-report-panel" style="display: none;">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; border-bottom: 1px solid #fecaca; padding-bottom: 0.5rem;">
                                        <div style="font-weight: 700; color: #b91c1c; font-size: 0.92rem; display: flex; align-items: center; gap: 0.4rem;">
                                            <span>⚠️ Report Customer: <%= job.getUserName() %></span>
                                            <span class="badge badge-requested" style="font-size: 0.7rem;">Job #<%= job.getBookingId() %></span>
                                        </div>
                                        <button type="button" class="modal-close-btn" onclick="toggleInlineReport(<%= job.getBookingId() %>)" title="Close" style="font-size: 1.1rem; width: 24px; height: 24px;">✕</button>
                                    </div>
                                    <form action="complaint" method="POST">
                                        <input type="hidden" name="action" value="file">
                                        <input type="hidden" name="bookingId" value="<%= job.getBookingId() %>">
                                        <input type="hidden" name="targetId" value="<%= job.getUserId() %>">
                                        <input type="hidden" name="targetName" value="<%= job.getUserName() %>">
                                        <input type="hidden" name="targetRole" value="CUSTOMER">

                                        <div class="form-group" style="margin-bottom: 0.65rem;">
                                            <label class="form-label" style="font-size: 0.8rem; font-weight: 700; color: #991b1b;">Grievance Category</label>
                                            <select name="complaintType" class="form-select" style="font-size: 0.85rem; padding: 0.4rem 0.65rem;" required>
                                                <option value="Customer Abusive Behavior">Abusive or Threatening Behavior</option>
                                                <option value="Payment Refusal / Rate Dispute">Refusal to pay or disputing agreed rate</option>
                                                <option value="Unsafe Premises / Work Environment">Unsafe, hazardous, or unsanitary environment</option>
                                                <option value="Customer Not Available / No-Show">Customer absent at specified location</option>
                                                <option value="False Scope / Prank Booking">False job description or prank booking</option>
                                                <option value="Other">Other customer grievance</option>
                                            </select>
                                        </div>

                                        <div class="form-group" style="margin-bottom: 0.75rem;">
                                            <label class="form-label" style="font-size: 0.8rem; font-weight: 700; color: #991b1b;">Incident Description</label>
                                            <textarea name="description" class="form-control" rows="3" style="font-size: 0.85rem;" placeholder="Detail what occurred with the customer directly on this service..." required></textarea>
                                        </div>

                                        <div style="display: flex; gap: 0.5rem; justify-content: flex-end;">
                                            <button type="button" class="btn btn-secondary action-pill" onclick="toggleInlineReport(<%= job.getBookingId() %>)">
                                                Cancel
                                            </button>
                                            <button type="submit" class="btn btn-danger action-pill">
                                                Submit Incident to Admin 🚨
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </section>

            <!-- Right Column: Provider Availability Settings -->
            <section class="card" style="height: fit-content; box-shadow: var(--shadow-md);">
                <div class="card-header">
                    <div>
                        <h2 class="card-title">⚙️ Availability</h2>
                        <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 0.2rem;">Operational hours & status</p>
                    </div>
                    <span id="rightStatusBadge" class="badge badge-<%= provStatus.toLowerCase() %>"><%= provStatus %></span>
                </div>

                <form action="provider-action" method="POST">
                    <input type="hidden" name="action" value="updateAvailability">
                    <input type="hidden" name="providerId" value="<%= provider != null ? provider.getProviderId() : 101 %>">

                    <div class="form-group">
                        <label class="form-label" for="availableFrom">⏰ Shift Start Time</label>
                        <input type="time" id="availableFrom" name="availableFrom" class="form-control" value="<%= fromTime %>" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="availableUntil">⏰ Shift End Time</label>
                        <input type="time" id="availableUntil" name="availableUntil" class="form-control" value="<%= untilTime %>" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="providerStatus">📡 Availability State</label>
                        <select id="providerStatus" name="status" class="form-select">
                            <option value="AVAILABLE" <%= "AVAILABLE".equalsIgnoreCase(provStatus) ? "selected" : "" %>>AVAILABLE (Accepting Dispatches)</option>
                            <option value="BUSY" <%= "BUSY".equalsIgnoreCase(provStatus) ? "selected" : "" %>>BUSY (Currently On Task)</option>
                            <option value="OFFLINE" <%= "OFFLINE".equalsIgnoreCase(provStatus) ? "selected" : "" %>>OFFLINE (Shift Ended)</option>
                        </select>
                    </div>

                    <button type="submit" id="saveAvailabilityBtn" class="btn btn-primary btn-block" style="margin-top: 1.25rem;">
                        SAVE AVAILABILITY →
                    </button>
                </form>
            </section>
        </div>
    </main>

    <!-- Real-time Floating Notification Toast Container -->
    <div id="notificationToastContainer"></div>

    <!-- Provider In-App Live Direct Chat Modal -->
    <div id="providerChatModal" class="modal-overlay" style="display: none;">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 id="providerChatModalTitle">💬 Live Customer Chat</h3>
                <button type="button" class="modal-close-btn" onclick="closeProviderChatModal()">✕</button>
            </div>
            <div class="modal-body" style="display: flex; flex-direction: column;">
                <div id="providerChatMessages" class="chat-messages-container">
                    <div style="color: var(--text-muted); text-align: center; margin: auto;">Loading messages...</div>
                </div>
                <div style="display: flex; gap: 0.5rem; margin-top: 0.25rem;">
                    <input type="text" id="providerChatInput" class="form-control" placeholder="Type a message to customer..." onkeydown="if(event.key === 'Enter') { event.preventDefault(); sendProviderChatMessage(); }">
                    <button type="button" class="btn btn-primary" onclick="sendProviderChatMessage()" style="padding: 0.6rem 1.25rem;">Send</button>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory. Provider Task Allocation Suite.</p>
    </footer>

    <script>
        let currentProviderChatBookingId = null;
        let providerChatPollTimer = null;

        function openProviderChatModal(bookingId, customerName) {
            currentProviderChatBookingId = bookingId;
            document.getElementById("providerChatModalTitle").textContent = "💬 Chat with " + customerName + " (Job #" + bookingId + ")";
            document.getElementById("providerChatModal").style.display = "flex";
            loadProviderChatMessages();
            if (providerChatPollTimer) clearInterval(providerChatPollTimer);
            providerChatPollTimer = setInterval(loadProviderChatMessages, 2000);
            setTimeout(() => {
                const inp = document.getElementById("providerChatInput");
                if (inp) inp.focus();
            }, 100);
        }

        function closeProviderChatModal() {
            document.getElementById("providerChatModal").style.display = "none";
            if (providerChatPollTimer) clearInterval(providerChatPollTimer);
            currentProviderChatBookingId = null;
        }

        function toggleInlineReport(bookingId) {
            const panel = document.getElementById("inlineReport-" + bookingId);
            if (!panel) return;
            if (panel.style.display === "none" || panel.style.display === "") {
                panel.style.display = "block";
                const ta = panel.querySelector("textarea");
                if (ta) ta.focus();
            } else {
                panel.style.display = "none";
            }
        }

        function loadProviderChatMessages() {
            if (!currentProviderChatBookingId) return;
            fetch("<%= request.getContextPath() %>/api/chat?bookingId=" + currentProviderChatBookingId, { credentials: "same-origin" })
                .then(r => r.json())
                .then(messages => {
                    const container = document.getElementById("providerChatMessages");
                    if (!messages || messages.length === 0) {
                        container.innerHTML = "<div style='color: var(--text-muted); text-align: center; margin: auto;'>No messages yet. Send a message to customer!</div>";
                        return;
                    }
                    container.innerHTML = "";
                    messages.forEach(m => {
                        const isMe = m.senderRole && m.senderRole.toUpperCase() === "PROVIDER";
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

        function sendProviderChatMessage() {
            const input = document.getElementById("providerChatInput");
            const btn = document.querySelector("#providerChatModal button.btn-primary");
            const text = input.value.trim();
            if (!text || !currentProviderChatBookingId) return;

            const params = new URLSearchParams();
            params.append("bookingId", currentProviderChatBookingId);
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
                    loadProviderChatMessages();
                } else {
                    alert("Unable to deliver message: " + (data.message || "Session error"));
                }
            })
            .catch(err => {
                if (btn) btn.disabled = false;
                console.error("Chat send error", err);
                alert("Network error: Could not reach chat server.");
            });
        }

        function toggleProviderStatus() {
            fetch("api/provider-status", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                credentials: "same-origin"
            })
            .then(r => r.json())
            .then(data => {
                if (data.status === "success") {
                    const newStatus = data.newStatus;
                    const isAvailable = newStatus === "AVAILABLE";
                    const btn = document.getElementById("liveToggleHeaderBtn");
                    btn.className = "status-toggle-btn " + (isAvailable ? "is-online" : "is-offline");
                    btn.textContent = isAvailable ? "🟢 Available" : "🔴 Unavailable";

                    const badge1 = document.getElementById("metricStatusBadge");
                    if (badge1) {
                        badge1.className = "badge badge-" + newStatus.toLowerCase();
                        badge1.textContent = newStatus;
                    }
                    const badge2 = document.getElementById("rightStatusBadge");
                    if (badge2) {
                        badge2.className = "badge badge-" + newStatus.toLowerCase();
                        badge2.textContent = newStatus;
                    }

                    const alert = document.getElementById("liveStatusAlert");
                    alert.textContent = "✓ Status updated to " + newStatus;
                    alert.style.display = "block";
                    setTimeout(() => alert.style.display = "none", 3000);
                }
            })
            .catch(e => console.error("Toggle error", e));
        }

        window.addEventListener("click", function(event) {
            const pcm = document.getElementById("providerChatModal");
            if (event.target === pcm) closeProviderChatModal();
        });

        window.addEventListener("keydown", function(event) {
            if (event.key === "Escape") closeProviderChatModal();
        });

        // ==========================================================
        // Real-Time Notification Toast & Audio Alert System
        // ==========================================================
        let lastKnownProviderMessageId = 0;
        let latestNotifiedCustomerBookingId = null;
        let latestNotifiedCustomerName = "";
        let providerUnreadCount = 0;

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
                console.warn("Audio chime prevented", e);
            }
        }

        function escapeHtml(str) {
            if (!str) return "";
            return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        function showNotificationToast(bookingId, senderName, text, time) {
            const container = document.getElementById("notificationToastContainer");
            if (!container) return;

            latestNotifiedCustomerBookingId = bookingId;
            latestNotifiedCustomerName = senderName;

            const toast = document.createElement("div");
            toast.className = "notification-toast";
            toast.innerHTML = `
                <div class="toast-header">
                    <div class="toast-sender-info">
                        <div class="toast-avatar">\${(senderName || "C").substring(0, 1).toUpperCase()}</div>
                        <div>
                            <div class="toast-title">\${escapeHtml(senderName || "Customer")} <span style="font-weight: 500; font-size: 0.75rem; color: var(--primary);">Job #\${bookingId}</span></div>
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
                        <span>Reply Message</span> 💬
                    </button>
                </div>
            `;

            const openChat = () => {
                openProviderChatModal(bookingId, senderName);
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
            providerUnreadCount = Math.max(0, count);
            const badge = document.getElementById("navUnreadBadge");
            if (badge) {
                if (providerUnreadCount > 0) {
                    badge.textContent = providerUnreadCount > 9 ? "9+" : providerUnreadCount;
                    badge.style.display = "inline-flex";
                } else {
                    badge.style.display = "none";
                }
            }
        }

        function focusLatestProviderMessage() {
            if (latestNotifiedCustomerBookingId) {
                openProviderChatModal(latestNotifiedCustomerBookingId, latestNotifiedCustomerName || "Customer");
            } else {
                const list = document.querySelector(".job-card");
                if (list) list.scrollIntoView({ behavior: 'smooth' });
            }
        }

        function pollProviderNotifications() {
            fetch("<%= request.getContextPath() %>/api/chat?action=pollNotifications&lastMessageId=" + lastKnownProviderMessageId, { credentials: "same-origin" })
                .then(r => r.json())
                .then(data => {
                    if (data && data.status === "success") {
                        if (data.lastMessageId > lastKnownProviderMessageId) {
                            lastKnownProviderMessageId = data.lastMessageId;
                        }
                        if (data.messages && data.messages.length > 0) {
                            let hasNewAlert = false;
                            data.messages.forEach(msg => {
                                if (currentProviderChatBookingId && currentProviderChatBookingId == msg.bookingId) {
                                    loadProviderChatMessages();
                                } else {
                                    hasNewAlert = true;
                                    showNotificationToast(msg.bookingId, msg.senderName, msg.messageText, msg.sentAt);

                                    const chatBtn = document.getElementById("providerChatBtn-" + msg.bookingId);
                                    if (chatBtn && !chatBtn.querySelector(".pulse-dot")) {
                                        const dot = document.createElement("span");
                                        dot.className = "pulse-dot";
                                        dot.title = "New customer message!";
                                        chatBtn.appendChild(dot);
                                    }
                                }
                            });

                            if (hasNewAlert) {
                                playNotificationChime();
                                updateUnreadBadge(providerUnreadCount + data.messages.length);
                            }
                        }
                    }
                })
                .catch(err => console.warn("Provider notification poll error", err));
        }

        // Initialize baseline poll ID on page load
        fetch("<%= request.getContextPath() %>/api/chat?action=pollNotifications&baseline=true", { credentials: "same-origin" })
            .then(r => r.json())
            .then(d => {
                if (d && d.lastMessageId) lastKnownProviderMessageId = d.lastMessageId;
                setInterval(pollProviderNotifications, 3000);
            })
            .catch(() => {
                setInterval(pollProviderNotifications, 3000);
            });
    </script>
</body>
</html>
