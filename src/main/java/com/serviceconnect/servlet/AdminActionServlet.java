package com.serviceconnect.servlet;

import com.serviceconnect.dao.ComplaintDAO;
import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller servlet for administrator privileged operations:
 * - Removing users (customers) from application
 * - Removing workers (providers) from application
 * - Resolving / dismissing grievance complaints
 */
@WebServlet(name = "AdminActionServlet", urlPatterns = {"/admin-action"})
public class AdminActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;
    private ProviderDAO providerDAO;
    private ComplaintDAO complaintDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
        this.providerDAO = new ProviderDAO();
        this.complaintDAO = new ComplaintDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");

        if ("deleteUser".equalsIgnoreCase(action)) {
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null) {
                try {
                    int userId = Integer.parseInt(userIdStr.trim());
                    userDAO.deleteUser(userId);
                    complaintDAO.resolveComplaintsForTarget(userId, "CUSTOMER", "User banned and removed by Administrator.");
                    response.sendRedirect(request.getContextPath() + "/admin-dashboard?msg=userDeleted");
                    return;
                } catch (Exception e) {
                    System.err.println("Error deleting user: " + e.getMessage());
                }
            }
        } else if ("deleteProvider".equalsIgnoreCase(action)) {
            String providerIdStr = request.getParameter("providerId");
            if (providerIdStr != null) {
                try {
                    int providerId = Integer.parseInt(providerIdStr.trim());
                    providerDAO.deleteProvider(providerId);
                    complaintDAO.resolveComplaintsForTarget(providerId, "PROVIDER", "Worker dismissed and expelled by Administrator.");
                    response.sendRedirect(request.getContextPath() + "/admin-dashboard?msg=providerDeleted");
                    return;
                } catch (Exception e) {
                    System.err.println("Error deleting provider: " + e.getMessage());
                }
            }
        } else if ("updateComplaint".equalsIgnoreCase(action)) {
            String complaintIdStr = request.getParameter("complaintId");
            String status = request.getParameter("status");
            String adminNotes = request.getParameter("adminNotes");

            if (complaintIdStr != null) {
                try {
                    int cid = Integer.parseInt(complaintIdStr.trim());
                    complaintDAO.updateComplaintStatus(cid, status != null ? status : "RESOLVED", adminNotes != null ? adminNotes : "Reviewed by Administrator");
                    response.sendRedirect(request.getContextPath() + "/admin-dashboard?msg=complaintUpdated");
                    return;
                } catch (Exception e) {
                    System.err.println("Error updating complaint: " + e.getMessage());
                }
            }
        } else if ("deleteComplaint".equalsIgnoreCase(action)) {
            String complaintIdStr = request.getParameter("complaintId");
            if (complaintIdStr != null) {
                try {
                    int cid = Integer.parseInt(complaintIdStr.trim());
                    complaintDAO.deleteComplaint(cid);
                    response.sendRedirect(request.getContextPath() + "/admin-dashboard?msg=complaintDeleted");
                    return;
                } catch (Exception e) {
                    System.err.println("Error deleting complaint: " + e.getMessage());
                }
            }
        } else if ("resolveAllComplaints".equalsIgnoreCase(action)) {
            complaintDAO.resolveAllPending("Bulk resolved by Administrator.");
            response.sendRedirect(request.getContextPath() + "/admin-dashboard?msg=allResolved");
            return;
        } else if ("clearClosedComplaints".equalsIgnoreCase(action)) {
            complaintDAO.clearClosedComplaints();
            response.sendRedirect(request.getContextPath() + "/admin-dashboard?msg=closedCleared");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin-dashboard");
    }
}
