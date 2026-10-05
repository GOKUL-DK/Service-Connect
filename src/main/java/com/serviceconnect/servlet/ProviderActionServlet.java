package com.serviceconnect.servlet;

import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet handling provider workflow actions:
 * - Accept job
 * - Start service
 * - Complete service
 * - Update working hours & availability status
 */
@WebServlet(name = "ProviderActionServlet", urlPatterns = {"/provider-action"})
public class ProviderActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BookingService bookingService;
    private ProviderDAO providerDAO;

    @Override
    public void init() throws ServletException {
        this.bookingService = new BookingService();
        this.providerDAO = new ProviderDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
            return;
        }

        String action = request.getParameter("action");
        String bookingIdStr = request.getParameter("bookingId");
        String providerIdStr = request.getParameter("providerId");

        if ("updateAvailability".equalsIgnoreCase(action)) {
            // Update provider operational time and status
            try {
                int providerId = Integer.parseInt(providerIdStr);
                String from = request.getParameter("availableFrom");
                String until = request.getParameter("availableUntil");
                String status = request.getParameter("status");

                if (from != null && from.length() == 5) from += ":00";
                if (until != null && until.length() == 5) until += ":00";

                providerDAO.updateAvailability(providerId, from, until, status);
                response.sendRedirect(request.getContextPath() + "/provider-dashboard?msg=availabilityUpdated");
                return;
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/provider-dashboard?error=updateFailed");
                return;
            }
        }

        if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr.trim());
                if ("accept".equalsIgnoreCase(action)) {
                    bookingService.updateBookingStatus(bookingId, "ACCEPTED");
                } else if ("start".equalsIgnoreCase(action)) {
                    bookingService.updateBookingStatus(bookingId, "IN_PROGRESS");
                } else if ("complete".equalsIgnoreCase(action)) {
                    String otp = request.getParameter("otp");
                    boolean ok = true;
                    if (otp != null && !otp.trim().isEmpty()) {
                        com.serviceconnect.dao.BookingDAO bDao = new com.serviceconnect.dao.BookingDAO();
                        ok = bDao.verifyAndCompleteBooking(bookingId, otp);
                        if (ok) {
                            com.serviceconnect.model.Booking b = bDao.getBookingById(bookingId);
                            if (b != null) {
                                providerDAO.updateStatus(b.getProviderId(), "AVAILABLE");
                            }
                        }
                    } else {
                        bookingService.updateBookingStatus(bookingId, "COMPLETED");
                    }
                    if (!ok) {
                        response.sendRedirect(request.getContextPath() + "/provider-dashboard?error=invalidOtp");
                        return;
                    }
                } else if ("cancel".equalsIgnoreCase(action)) {
                    bookingService.updateBookingStatus(bookingId, "CANCELLED");
                }
                response.sendRedirect(request.getContextPath() + "/provider-dashboard?msg=jobUpdated");
                return;
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/provider-dashboard?error=actionFailed");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/provider-dashboard");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
