package com.serviceconnect.servlet;

import com.google.gson.Gson;
import com.serviceconnect.dao.ComplaintDAO;
import com.serviceconnect.model.Complaint;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller servlet for lodging and resolving complaints between customers and service providers.
 */
@WebServlet(name = "ComplaintServlet", urlPatterns = {"/api/complaint", "/complaint"})
public class ComplaintServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ComplaintDAO complaintDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.complaintDAO = new ComplaintDAO();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Unauthorized\"}");
            return;
        }

        String role = (String) session.getAttribute("role");
        if ("ADMIN".equalsIgnoreCase(role)) {
            List<Complaint> all = complaintDAO.getAllComplaints();
            out.print(gson.toJson(all));
        } else {
            int userId = (Integer) session.getAttribute("userId");
            List<Complaint> myComplaints = complaintDAO.getComplaintsByComplainant(userId);
            out.print(gson.toJson(myComplaints));
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String userName = (String) session.getAttribute("name");
        String userRole = (String) session.getAttribute("role");

        String action = request.getParameter("action");
        if (action == null) action = "file";

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With")) 
                         || request.getRequestURI().contains("/api/");

        if ("file".equalsIgnoreCase(action)) {
            String bookingIdStr = request.getParameter("bookingId");
            String targetIdStr = request.getParameter("targetId");
            String targetName = request.getParameter("targetName");
            String targetRole = request.getParameter("targetRole");
            String complaintType = request.getParameter("complaintType");
            String description = request.getParameter("description");

            int bookingId = 0;
            if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
                try { bookingId = Integer.parseInt(bookingIdStr.trim()); } catch (Exception ignored) {}
            }

            int targetId = 0;
            if (targetIdStr != null && !targetIdStr.trim().isEmpty()) {
                try { targetId = Integer.parseInt(targetIdStr.trim()); } catch (Exception ignored) {}
            }

            Complaint c = new Complaint();
            c.setBookingId(bookingId);
            c.setComplainantId(userId);
            c.setComplainantName(userName != null ? userName : "User");
            c.setComplainantRole(userRole != null ? userRole : "CUSTOMER");
            c.setTargetId(targetId);
            c.setTargetName(targetName != null ? targetName.trim() : "Unknown");
            c.setTargetRole(targetRole != null ? targetRole.trim() : ("CUSTOMER".equalsIgnoreCase(userRole) ? "PROVIDER" : "CUSTOMER"));
            c.setComplaintType(complaintType != null ? complaintType.trim() : "General Grievance");
            c.setDescription(description != null ? description.trim() : "No description provided.");
            c.setStatus("PENDING");

            boolean success = complaintDAO.createComplaint(c);

            if (isAjax) {
                response.setContentType("application/json");
                Map<String, Object> res = new HashMap<>();
                res.put("status", success ? "success" : "failed");
                res.put("message", success ? "Grievance submitted to Administrator." : "Failed to record grievance.");
                response.getWriter().print(gson.toJson(res));
                return;
            }

            String returnUrl = "CUSTOMER".equalsIgnoreCase(userRole) ? "/customer-dashboard.jsp" : "/provider-dashboard";
            response.sendRedirect(request.getContextPath() + returnUrl + "?msg=" + (success ? "complaintFiled" : "complaintFailed"));
            return;
        }

        // Admin Actions on Complaints
        if ("ADMIN".equalsIgnoreCase(userRole)) {
            String complaintIdStr = request.getParameter("complaintId");
            String status = request.getParameter("status");
            String notes = request.getParameter("adminNotes");

            if (complaintIdStr != null) {
                try {
                    int cid = Integer.parseInt(complaintIdStr.trim());
                    if ("delete".equalsIgnoreCase(action)) {
                        complaintDAO.deleteComplaint(cid);
                    } else {
                        complaintDAO.updateComplaintStatus(cid, status != null ? status : "RESOLVED", notes != null ? notes.trim() : "Resolved by Admin");
                    }
                } catch (Exception e) {
                    System.err.println("Error processing complaint action: " + e.getMessage());
                }
            }

            if (isAjax) {
                response.setContentType("application/json");
                Map<String, Object> res = new HashMap<>();
                res.put("status", "success");
                response.getWriter().print(gson.toJson(res));
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin-dashboard?msg=complaintUpdated");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}
