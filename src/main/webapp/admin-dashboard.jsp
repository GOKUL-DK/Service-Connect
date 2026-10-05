<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.serviceconnect.model.Provider" %>
<%@ page import="com.serviceconnect.model.Booking" %>
<%@ page import="com.serviceconnect.model.Service" %>
<%@ page import="com.serviceconnect.model.User" %>
<%@ page import="com.serviceconnect.model.Complaint" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
        return;
    }

    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Provider> providers = (List<Provider>) request.getAttribute("providers");
    @SuppressWarnings("unchecked")
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    @SuppressWarnings("unchecked")
    List<Service> services = (List<Service>) request.getAttribute("services");
    @SuppressWarnings("unchecked")
    List<User> users = (List<User>) request.getAttribute("users");
    @SuppressWarnings("unchecked")
    List<Complaint> complaints = (List<Complaint>) request.getAttribute("complaints");

    // Dynamic Analytics Calculation
    double totalRevenue = 0.0;
    Map<String, Integer> serviceCounts = new HashMap<>();
    Map<String, Integer> statusCounts = new HashMap<>();

    if (bookings != null) {
        for (Booking b : bookings) {
            double amt = b.getTotalAmount() > 0 ? b.getTotalAmount() : 354.00;
            totalRevenue += amt;

            String sName = (b.getServiceName() != null && !b.getServiceName().isEmpty()) ? b.getServiceName() : "General";
            serviceCounts.put(sName, serviceCounts.getOrDefault(sName, 0) + 1);

            String st = (b.getStatus() != null && !b.getStatus().isEmpty()) ? b.getStatus() : "CONFIRMED";
            statusCounts.put(st, statusCounts.getOrDefault(st, 0) + 1);
        }
    }

    int pendingComplaintsCount = 0;
    if (complaints != null) {
        for (Complaint c : complaints) {
            if ("PENDING".equalsIgnoreCase(c.getStatus())) pendingComplaintsCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - ServiceConnect</title>
    <link rel="stylesheet" href="css/style.css?v=<%= System.currentTimeMillis() %>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

    <header class="navbar">
        <a href="index.jsp" class="nav-brand">
            <span class="brand-icon">⚡</span>
            <span>ServiceConnect</span>
        </a>
        <nav>
            <ul class="nav-menu">
                <li><a href="admin-dashboard" class="nav-link active">Admin Console</a></li>
                <li><a href="profile" class="nav-link">👤 My Profile</a></li>
                <li><span class="user-badge">🛡 <%= session.getAttribute("name") %> (ADMIN)</span></li>
                <li><a href="logout" class="btn btn-secondary" style="padding: 0.4rem 0.8rem; font-size: 0.85rem;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="container">
        <% 
            String msg = request.getParameter("msg");
            if ("userDeleted".equalsIgnoreCase(msg)) { 
        %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                ✅ User account has been successfully removed from the system.
            </div>
        <%  } else if ("providerDeleted".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                ✅ Worker/Service Provider has been successfully removed from the application roster.
            </div>
        <%  } else if ("complaintUpdated".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                ✅ Grievance complaint status updated successfully.
            </div>
        <%  } else if ("complaintDeleted".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                ✅ Grievance complaint record has been permanently deleted.
            </div>
        <%  } else if ("allResolved".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                ✅ All pending grievances have been marked as Resolved.
            </div>
        <%  } else if ("closedCleared".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                ✅ Closed and dismissed grievance records have been cleared from the queue.
            </div>
        <%  } %>

        <!-- Executive KPI Intelligence Grid -->
        <div class="kpi-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));">
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Active Services</span>
                    <span class="kpi-card-value"><%= services != null ? services.size() : 0 %></span>
                    <span class="kpi-card-sub">🛠️ Catalog Trades</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(79, 70, 229, 0.1); color: var(--primary);">🛠</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Technicians</span>
                    <span class="kpi-card-value"><%= providers != null ? providers.size() : 0 %></span>
                    <span class="kpi-card-sub">👷 Registered Roster</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(16, 185, 129, 0.1); color: var(--success);">👷</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Total Bookings</span>
                    <span class="kpi-card-value"><%= bookings != null ? bookings.size() : 0 %></span>
                    <span class="kpi-card-sub">📊 Total Dispatches</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(6, 182, 212, 0.1); color: var(--accent);">📊</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">User Accounts</span>
                    <span class="kpi-card-value"><%= users != null ? users.size() : 0 %></span>
                    <span class="kpi-card-sub">👥 Customer Logins</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(245, 158, 11, 0.1); color: var(--warning);">👥</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Pending Disputes</span>
                    <span class="kpi-card-value" style="color: var(--danger);"><%= pendingComplaintsCount %></span>
                    <span class="kpi-card-sub">🚨 Action Needed</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(239, 68, 68, 0.1); color: var(--danger);">🚨</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-card-content">
                    <span class="kpi-card-title">Gross Volume</span>
                    <span class="kpi-card-value" style="font-size: 1.55rem; color: #059669;">₹<%= String.format("%.0f", totalRevenue) %></span>
                    <span class="kpi-card-sub">💰 Total GMV</span>
                </div>
                <div class="kpi-card-icon" style="background: rgba(16, 185, 129, 0.15); color: #059669;">💰</div>
            </div>
        </div>

        <!-- Chart.js Visual Intelligence Analytics Section -->
        <section style="display: grid; grid-template-columns: repeat(auto-fit, minmax(420px, 1fr)); gap: 1.5rem; margin-bottom: 2.25rem;">
            <div class="card" style="margin-bottom: 0; box-shadow: var(--shadow-md);">
                <div class="card-header">
                    <div>
                        <h2 class="card-title" style="font-size: 1.15rem;">🍩 Bookings by Service Category</h2>
                        <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 0.2rem;">Real-time trade category allocation demand</p>
                    </div>
                </div>
                <div style="height: 270px; display: flex; align-items: center; justify-content: center; padding: 0.5rem;">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
            <div class="card" style="margin-bottom: 0; box-shadow: var(--shadow-md);">
                <div class="card-header">
                    <div>
                        <h2 class="card-title" style="font-size: 1.15rem;">📊 Booking Status Breakdown</h2>
                        <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 0.2rem;">Pipeline lifecycle fulfillment status</p>
                    </div>
                </div>
                <div style="height: 270px; display: flex; align-items: center; justify-content: center; padding: 0.5rem;">
                    <canvas id="statusChart"></canvas>
                </div>
            </div>
        </section>

        <!-- All System Bookings -->
        <section class="card" style="box-shadow: var(--shadow-md);">
            <div class="card-header">
                <div>
                    <h2 class="card-title">⚡ Live Service Bookings Audit Queue</h2>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                        Real-time transaction log of customer allocations, provider assignments, and status transitions.
                    </p>
                </div>
                <span class="badge badge-requested">Live Database Stream</span>
            </div>

            <% if (bookings == null || bookings.isEmpty()) { %>
                <div style="text-align: center; padding: 2.5rem 1rem; color: var(--text-muted);">
                    <p>No bookings logged in the system yet.</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Booking ID</th>
                                <th>Customer</th>
                                <th>Provider</th>
                                <th>Service</th>
                                <th>Location</th>
                                <th>Total Bill</th>
                                <th>Status</th>
                                <th>Timestamp</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Booking b : bookings) { %>
                                <tr>
                                    <td><strong style="color: var(--secondary);">#<%= b.getBookingId() %></strong></td>
                                    <td>
                                        <div style="font-weight: 600;"><%= b.getUserName() %></div>
                                    </td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 0.45rem;">
                                            <div style="width: 24px; height: 24px; border-radius: 50%; background: var(--primary-light); color: var(--primary); font-size: 0.75rem; font-weight: 700; display: flex; align-items: center; justify-content: center;">
                                                <%= (b.getProviderName() != null && !b.getProviderName().isEmpty()) ? b.getProviderName().substring(0, 1) : "P" %>
                                            </div>
                                            <span><%= b.getProviderName() != null ? b.getProviderName() : "Technician" %></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="color: var(--primary); font-weight: 600;"><%= b.getServiceName() %></span>
                                        <% if (b.isEmergency()) { %>
                                            <span class="badge badge-emergency" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; margin-left: 0.25rem;">SOS</span>
                                        <% } %>
                                    </td>
                                    <td><%= b.getLocationName() %> (<%= b.getDistance() %> km)</td>
                                    <td><strong style="color: var(--success);">₹<%= String.format("%.2f", b.getTotalAmount() > 0 ? b.getTotalAmount() : 354.00) %></strong></td>
                                    <td><span class="badge badge-<%= b.getStatus().toLowerCase() %>"><%= b.getStatus() %></span></td>
                                    <td><code style="font-size: 0.8rem;"><%= b.getCreatedAt() %></code></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>

        <!-- Two-Way Grievance & Complaints Review Queue -->
        <section class="card" style="box-shadow: var(--shadow-md); border-top: 4px solid var(--danger);">
            <div class="card-header" style="flex-wrap: wrap; gap: 0.75rem;">
                <div>
                    <h2 class="card-title">🚨 Two-Way Complaints & Grievance Resolution</h2>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                        Real-time disputes logged by customers about workers, and by workers about customers. Review claims, apply resolutions, or expel offenders.
                    </p>
                </div>
                <div style="display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap;">
                    <% if (pendingComplaintsCount > 0) { %>
                        <form action="admin-action" method="POST" style="margin: 0;" onsubmit="return confirm('Resolve all pending grievances?');">
                            <input type="hidden" name="action" value="resolveAllComplaints">
                            <button type="submit" class="btn btn-secondary action-pill" style="color: #059669; border-color: #059669; font-size: 0.75rem;">
                                ✓ Resolve All
                            </button>
                        </form>
                    <% } %>
                    <% if (complaints != null && complaints.size() > pendingComplaintsCount) { %>
                        <form action="admin-action" method="POST" style="margin: 0;" onsubmit="return confirm('Clear all closed and dismissed grievances from queue?');">
                            <input type="hidden" name="action" value="clearClosedComplaints">
                            <button type="submit" class="btn btn-secondary action-pill" style="color: #64748b; font-size: 0.75rem;">
                                🗑️ Clear Closed
                            </button>
                        </form>
                    <% } %>
                    <span class="badge <%= pendingComplaintsCount > 0 ? "badge-emergency" : "badge-confirmed" %>">
                        <%= pendingComplaintsCount %> Pending Grievance<%= pendingComplaintsCount == 1 ? "" : "s" %>
                    </span>
                </div>
            </div>

            <% if (complaints == null || complaints.isEmpty()) { %>
                <div style="text-align: center; padding: 2.5rem 1rem; color: var(--text-muted);">
                    <p style="font-size: 1.1rem; margin-bottom: 0.4rem;">🎉 No grievances logged.</p>
                    <p style="font-size: 0.85rem;">All customer and worker interactions are currently running smoothly without disputes.</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Case #</th>
                                <th>Complainant</th>
                                <th>Reported Party</th>
                                <th>Category</th>
                                <th>Description</th>
                                <th>Booking Ref</th>
                                <th>Status</th>
                                <th>Logged At</th>
                                <th style="min-width: 220px;">Admin Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Complaint c : complaints) { %>
                                <tr>
                                    <td><strong style="color: var(--secondary);">#<%= c.getComplaintId() %></strong></td>
                                    <td>
                                        <div style="font-weight: 600;"><%= c.getComplainantName() %></div>
                                        <span class="badge" style="font-size: 0.7rem; padding: 0.1rem 0.4rem; background: var(--bg-card-alt); color: var(--text-muted);">
                                            <%= c.getComplainantRole() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: var(--danger);"><%= c.getTargetName() %></div>
                                        <span class="badge" style="font-size: 0.7rem; padding: 0.1rem 0.4rem; background: rgba(239, 68, 68, 0.1); color: var(--danger);">
                                            <%= c.getTargetRole() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-weight: 600; color: var(--primary);"><%= c.getComplaintType() %></span>
                                    </td>
                                    <td style="max-width: 260px;">
                                        <div style="font-size: 0.85rem; line-height: 1.4; color: var(--text-main);"><%= c.getDescription() %></div>
                                        <% if (c.getAdminNotes() != null && !c.getAdminNotes().trim().isEmpty()) { %>
                                            <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 0.3rem; font-style: italic;">
                                                Note: <%= c.getAdminNotes() %>
                                            </div>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (c.getBookingId() > 0) { %>
                                            <code>#<%= c.getBookingId() %></code>
                                        <% } else { %>
                                            <span style="color: var(--text-muted); font-size: 0.8rem;">N/A</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if ("PENDING".equalsIgnoreCase(c.getStatus())) { %>
                                            <span class="badge badge-emergency">PENDING</span>
                                        <% } else if ("RESOLVED".equalsIgnoreCase(c.getStatus())) { %>
                                            <span class="badge badge-confirmed">RESOLVED</span>
                                        <% } else { %>
                                            <span class="badge" style="background: #94a3b8; color: white;">DISMISSED</span>
                                        <% } %>
                                    </td>
                                    <td><code style="font-size: 0.75rem;"><%= c.getCreatedAt() %></code></td>
                                    <td>
                                        <% if ("PENDING".equalsIgnoreCase(c.getStatus())) { %>
                                            <div style="display: flex; gap: 0.4rem; flex-wrap: wrap;">
                                                <form action="admin-action" method="POST" style="display: inline;">
                                                    <input type="hidden" name="action" value="updateComplaint">
                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                    <input type="hidden" name="status" value="RESOLVED">
                                                    <input type="hidden" name="adminNotes" value="Case investigated and resolved by Admin.">
                                                    <button type="submit" class="btn btn-secondary action-pill" style="padding: 0.25rem 0.5rem; font-size: 0.75rem; color: #059669; border-color: #059669;">
                                                        ✓ Resolve
                                                    </button>
                                                </form>
                                                <form action="admin-action" method="POST" style="display: inline;">
                                                    <input type="hidden" name="action" value="updateComplaint">
                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                    <input type="hidden" name="status" value="DISMISSED">
                                                    <input type="hidden" name="adminNotes" value="Dismissed as unsubstantiated.">
                                                    <button type="submit" class="btn btn-secondary action-pill" style="padding: 0.25rem 0.5rem; font-size: 0.75rem; color: #64748b;">
                                                        ✕ Dismiss
                                                    </button>
                                                </form>
                                                <form action="admin-action" method="POST" style="display: inline;" onsubmit="return confirm('Permanently delete grievance #<%= c.getComplaintId() %>?');">
                                                    <input type="hidden" name="action" value="deleteComplaint">
                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                    <button type="submit" class="btn btn-secondary action-pill" style="padding: 0.25rem 0.5rem; font-size: 0.75rem; color: #dc2626; border-color: #fca5a5;" title="Delete grievance record">
                                                        🗑️ Delete
                                                    </button>
                                                </form>
                                                <% if (c.getTargetId() > 0) { %>
                                                    <% if ("PROVIDER".equalsIgnoreCase(c.getTargetRole())) { %>
                                                        <form action="admin-action" method="POST" style="display: inline;" onsubmit="return confirm('Expel worker <%= c.getTargetName() %> from the application?');">
                                                            <input type="hidden" name="action" value="deleteProvider">
                                                            <input type="hidden" name="providerId" value="<%= c.getTargetId() %>">
                                                            <button type="submit" class="btn btn-danger action-pill" style="padding: 0.25rem 0.5rem; font-size: 0.75rem;">
                                                                Dismiss Worker 🗑️
                                                            </button>
                                                        </form>
                                                    <% } else if ("CUSTOMER".equalsIgnoreCase(c.getTargetRole())) { %>
                                                        <form action="admin-action" method="POST" style="display: inline;" onsubmit="return confirm('Ban user <%= c.getTargetName() %> from the application?');">
                                                            <input type="hidden" name="action" value="deleteUser">
                                                            <input type="hidden" name="userId" value="<%= c.getTargetId() %>">
                                                            <button type="submit" class="btn btn-danger action-pill" style="padding: 0.25rem 0.5rem; font-size: 0.75rem;">
                                                                Ban User 🗑️
                                                            </button>
                                                        </form>
                                                    <% } %>
                                                <% } %>
                                            </div>
                                        <% } else { %>
                                            <div style="display: flex; align-items: center; gap: 0.5rem;">
                                                <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 500;">Closed</span>
                                                <form action="admin-action" method="POST" style="display: inline;" onsubmit="return confirm('Remove closed record #<%= c.getComplaintId() %>?');">
                                                    <input type="hidden" name="action" value="deleteComplaint">
                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                    <button type="submit" class="btn btn-secondary action-pill" style="padding: 0.2rem 0.45rem; font-size: 0.7rem; color: #dc2626;" title="Remove closed grievance">
                                                        🗑️ Remove
                                                    </button>
                                                </form>
                                            </div>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>

        <!-- Provider Directory with Removal Options -->
        <section class="card" style="box-shadow: var(--shadow-md);">
            <div class="card-header">
                <div>
                    <h2 class="card-title">🛠 Predefined Provider Registry</h2>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                        Verified trade experts registered in the system with geographic coordinates, operational shifts, and removal administration.
                    </p>
                </div>
                <span class="badge badge-available">Verified Database Roster</span>
            </div>

            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Technician</th>
                            <th>Service Category</th>
                            <th>Phone Contact</th>
                            <th>GPS Coordinates</th>
                            <th>Working Hours</th>
                            <th>Dispatch Status</th>
                            <th style="text-align: right;">Administrative Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (providers != null) { 
                            for (Provider p : providers) { %>
                                <tr>
                                    <td><code><%= p.getProviderId() %></code></td>
                                    <td>
                                        <strong style="color: var(--secondary);"><%= p.getName() %></strong>
                                    </td>
                                    <td><span style="font-weight: 600; color: var(--primary);"><%= p.getServiceName() %></span></td>
                                    <td><code style="background: var(--bg-card-alt); padding: 0.2rem 0.5rem; border-radius: 4px;"><%= p.getPhone() %></code></td>
                                    <td><code style="font-family: 'JetBrains Mono', monospace; font-size: 0.8rem;"><%= p.getLatitude() %>, <%= p.getLongitude() %></code></td>
                                    <td><%= p.getAvailableFrom() %> - <%= p.getAvailableUntil() %></td>
                                    <td><span class="badge badge-<%= p.getStatus().toLowerCase() %>"><%= p.getStatus() %></span></td>
                                    <td style="text-align: right;">
                                        <form action="admin-action" method="POST" style="display: inline;" onsubmit="return confirm('Permanently remove provider <%= p.getName() %>? All active assignments will be detached.');">
                                            <input type="hidden" name="action" value="deleteProvider">
                                            <input type="hidden" name="providerId" value="<%= p.getProviderId() %>">
                                            <button type="submit" class="btn btn-danger" style="padding: 0.3rem 0.65rem; font-size: 0.8rem;">
                                                Remove Worker 🗑️
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                        <%  } 
                           } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Registered User Accounts Management -->
        <section class="card" style="box-shadow: var(--shadow-md);">
            <div class="card-header">
                <div>
                    <h2 class="card-title">👥 Registered User Accounts Management</h2>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.2rem;">
                        View all user, provider, and administrator accounts with privileges to remove accounts from the platform.
                    </p>
                </div>
                <span class="badge badge-confirmed"><%= users != null ? users.size() : 0 %> Registered Accounts</span>
            </div>

            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Full Name</th>
                            <th>Username</th>
                            <th>Account Role</th>
                            <th style="text-align: right;">Administrative Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (users != null) {
                            int currentAdminId = (Integer) session.getAttribute("userId");
                            for (User u : users) { %>
                                <tr>
                                    <td><code>#<%= u.getId() %></code></td>
                                    <td><strong style="color: var(--secondary);"><%= u.getName() %></strong></td>
                                    <td><code style="background: var(--bg-card-alt); padding: 0.2rem 0.5rem; border-radius: 4px;"><%= u.getUsername() %></code></td>
                                    <td>
                                        <span class="badge" style="font-size: 0.75rem; 
                                            background: <%= "ADMIN".equalsIgnoreCase(u.getRole()) ? "rgba(239, 68, 68, 0.1)" : "PROVIDER".equalsIgnoreCase(u.getRole()) ? "rgba(79, 70, 229, 0.1)" : "rgba(16, 185, 129, 0.1)" %>;
                                            color: <%= "ADMIN".equalsIgnoreCase(u.getRole()) ? "var(--danger)" : "PROVIDER".equalsIgnoreCase(u.getRole()) ? "var(--primary)" : "var(--success)" %>;">
                                            <%= u.getRole() %>
                                        </span>
                                    </td>
                                    <td style="text-align: right;">
                                        <% if (u.getId() == currentAdminId) { %>
                                            <span class="badge badge-primary" style="font-size: 0.75rem;">Current Admin (You)</span>
                                        <% } else { %>
                                            <form action="admin-action" method="POST" style="display: inline;" onsubmit="return confirm('Permanently remove user <%= u.getUsername() %>? All associated bookings and data will be removed.');">
                                                <input type="hidden" name="action" value="deleteUser">
                                                <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                <button type="submit" class="btn btn-danger" style="padding: 0.3rem 0.65rem; font-size: 0.8rem;">
                                                    Remove User 🗑️
                                                </button>
                                            </form>
                                        <% } %>
                                    </td>
                                </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <footer class="footer">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory. Admin Operations Center.</p>
    </footer>

    <script>
        // Chart.js Category Breakdown Doughnut Chart
        const catLabels = [
            <% boolean firstCat = true; for (Map.Entry<String, Integer> e : serviceCounts.entrySet()) { 
                if (!firstCat) out.print(","); firstCat = false;
                out.print("'" + e.getKey() + "'");
            } %>
        ];
        const catData = [
            <% boolean firstCatD = true; for (Map.Entry<String, Integer> e : serviceCounts.entrySet()) { 
                if (!firstCatD) out.print(","); firstCatD = false;
                out.print(e.getValue());
            } %>
        ];

        const ctxCat = document.getElementById('categoryChart').getContext('2d');
        new Chart(ctxCat, {
            type: 'doughnut',
            data: {
                labels: catLabels.length > 0 ? catLabels : ['Plumbing', 'Electrical', 'Cleaning'],
                datasets: [{
                    data: catData.length > 0 ? catData : [5, 3, 2],
                    backgroundColor: [
                        '#6366f1', '#06b6d4', '#10b981', '#f59e0b', '#ec4899', '#8b5cf6', '#14b8a6'
                    ],
                    borderWidth: 2,
                    borderColor: 'rgba(15, 23, 42, 0.95)'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { 
                        position: 'bottom', 
                        labels: { 
                            color: '#cbd5e1',
                            font: { family: 'Plus Jakarta Sans', size: 12, weight: 600 },
                            padding: 14,
                            usePointStyle: true,
                            pointStyle: 'circle'
                        } 
                    }
                }
            }
        });

        // Chart.js Status Distribution Bar Chart
        const statusLabels = [
            <% boolean firstSt = true; for (Map.Entry<String, Integer> e : statusCounts.entrySet()) { 
                if (!firstSt) out.print(","); firstSt = false;
                out.print("'" + e.getKey() + "'");
            } %>
        ];
        const statusData = [
            <% boolean firstStD = true; for (Map.Entry<String, Integer> e : statusCounts.entrySet()) { 
                if (!firstStD) out.print(","); firstStD = false;
                out.print(e.getValue());
            } %>
        ];

        const ctxStatus = document.getElementById('statusChart').getContext('2d');
        new Chart(ctxStatus, {
            type: 'bar',
            data: {
                labels: statusLabels.length > 0 ? statusLabels : ['CONFIRMED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED'],
                datasets: [{
                    label: 'Bookings',
                    data: statusData.length > 0 ? statusData : [4, 3, 2, 5],
                    backgroundColor: '#6366f1',
                    hoverBackgroundColor: '#818cf8',
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, color: '#94a3b8', font: { family: 'JetBrains Mono', size: 11 } },
                        grid: { color: 'rgba(255, 255, 255, 0.06)' }
                    },
                    x: {
                        ticks: { color: '#cbd5e1', font: { family: 'Plus Jakarta Sans', size: 11, weight: 600 } },
                        grid: { display: false }
                    }
                },
                plugins: {
                    legend: { display: false }
                }
            }
        });
    </script>
</body>
</html>
