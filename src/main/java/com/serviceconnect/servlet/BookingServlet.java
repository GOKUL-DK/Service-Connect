package com.serviceconnect.servlet;

import com.serviceconnect.dao.LocationDAO;
import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.dao.ServiceDAO;
import com.serviceconnect.model.Booking;
import com.serviceconnect.model.Location;
import com.serviceconnect.model.Provider;
import com.serviceconnect.model.Service;
import com.serviceconnect.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet handling service booking creation, review, and confirmation.
 */
@WebServlet(name = "BookingServlet", urlPatterns = {"/booking"})
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BookingService bookingService;
    private ProviderDAO providerDAO;
    private ServiceDAO serviceDAO;
    private LocationDAO locationDAO;

    @Override
    public void init() throws ServletException {
        this.bookingService = new BookingService();
        this.providerDAO = new ProviderDAO();
        this.serviceDAO = new ServiceDAO();
        this.locationDAO = new LocationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
            return;
        }

        String bookingIdStr = request.getParameter("id");
        if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr.trim());
                Booking booking = bookingService.getBooking(bookingId);
                request.setAttribute("booking", booking);
                request.getRequestDispatcher("/confirmation.jsp").forward(request, response);
                return;
            } catch (NumberFormatException ignored) {}
        }

        // Show review page before confirmation if parameters exist
        String providerIdStr = request.getParameter("providerId");
        String serviceName = request.getParameter("service");
        String locationName = request.getParameter("location");
        String landmark = request.getParameter("landmark");
        String address = request.getParameter("address");
        String requestedTime = request.getParameter("requestedTime");
        String distanceStr = request.getParameter("distance");

        if (providerIdStr != null) {
            try {
                int providerId = Integer.parseInt(providerIdStr);
                Provider provider = providerDAO.getProviderById(providerId);
                request.setAttribute("provider", provider);
                request.setAttribute("serviceName", serviceName);
                request.setAttribute("locationName", locationName != null ? locationName : landmark);
                request.setAttribute("landmark", landmark != null ? landmark : locationName);
                request.setAttribute("address", address != null ? address : "");
                request.setAttribute("requestedTime", requestedTime);
                request.setAttribute("distance", distanceStr);
                request.getRequestDispatcher("/booking.jsp").forward(request, response);
                return;
            } catch (Exception ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
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
        String providerIdStr = request.getParameter("providerId");
        String serviceName = request.getParameter("serviceName");
        String locationName = request.getParameter("locationName");
        String landmark = request.getParameter("landmark");
        String address = request.getParameter("address");
        String requestedTime = request.getParameter("requestedTime");
        String distanceStr = request.getParameter("distance");

        try {
            int providerId = Integer.parseInt(providerIdStr.trim());
            Provider provider = providerDAO.getProviderById(providerId);

            if (provider == null) {
                response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp?error=providerNotFound");
                return;
            }

            // Resolve Service ID
            Service service = serviceDAO.getServiceByName(serviceName);
            int serviceId = (service != null) ? service.getServiceId() : provider.getServiceId();

            // Construct full descriptive location name
            String finalLocationName = locationName;
            if (landmark != null && !landmark.trim().isEmpty()) {
                if (address != null && !address.trim().isEmpty()) {
                    finalLocationName = landmark.trim() + " (" + address.trim() + ")";
                } else {
                    finalLocationName = landmark.trim();
                }
            } else if (finalLocationName == null || finalLocationName.trim().isEmpty()) {
                finalLocationName = (address != null && !address.trim().isEmpty()) ? address.trim() : "Location A";
            }
            if (finalLocationName.length() > 95) {
                finalLocationName = finalLocationName.substring(0, 95);
            }

            // Resolve Location coordinates
            Location loc = null;
            if (landmark != null && !landmark.trim().isEmpty()) {
                loc = locationDAO.getLocationByName(landmark.trim());
            }
            if (loc == null && locationName != null) {
                loc = locationDAO.getLocationByName(locationName);
            }
            double lat = (loc != null) ? loc.getLatitude() : 11.0168;
            double lon = (loc != null) ? loc.getLongitude() : 76.9558;
            double distance = 1.0;
            if (distanceStr != null && !distanceStr.trim().isEmpty()) {
                distance = Double.parseDouble(distanceStr.trim());
            }

            if (requestedTime == null || requestedTime.trim().isEmpty()) {
                requestedTime = "11:00:00";
            }
            if (requestedTime.length() == 5) {
                requestedTime = requestedTime + ":00";
            }

            boolean isEmergency = "true".equalsIgnoreCase(request.getParameter("isEmergency"));

            // Calculate dynamic bill breakdown
            com.serviceconnect.service.XMLRuleService ruleService = new com.serviceconnect.service.XMLRuleService();
            double baseFee = ruleService.getBaseFee(serviceName);
            double distanceSurcharge = (distance > 2.0) ? Math.round((distance - 2.0) * 15.0) : 0.0;
            double emergencySurcharge = isEmergency ? 150.0 : 0.0;
            double subtotal = baseFee + distanceSurcharge + emergencySurcharge;
            double gst = Math.round(subtotal * 0.18);
            double totalAmount = subtotal + gst;

            // Generate 4-digit security completion OTP
            String otp = String.format("%04d", new java.util.Random().nextInt(9000) + 1000);

            Booking booking = new Booking();
            booking.setUserId(userId);
            booking.setProviderId(providerId);
            booking.setServiceId(serviceId);
            booking.setLocationName(finalLocationName);
            booking.setLatitude(lat);
            booking.setLongitude(lon);
            booking.setRequestedTime(requestedTime);
            booking.setDistance(distance);
            booking.setStatus("CONFIRMED");
            booking.setEmergency(isEmergency);
            booking.setTotalAmount(totalAmount);
            booking.setOtp(otp);

            Booking created = bookingService.createBooking(booking);

            if (created != null) {
                response.sendRedirect(request.getContextPath() + "/confirmation.jsp?bookingId=" + created.getBookingId());
            } else {
                response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp?error=bookingFailed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp?error=invalidRequest");
        }
    }
}
