package com.serviceconnect.servlet;

import com.google.gson.Gson;
import com.serviceconnect.model.Booking;
import com.serviceconnect.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * AJAX endpoint for checking real-time booking status.
 * Allows client pages to poll or fetch the latest status without page refresh.
 */
@WebServlet(name = "BookingStatusServlet", urlPatterns = {"/api/booking-status"})
public class BookingStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BookingService bookingService;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.bookingService = new BookingService();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String bookingIdStr = request.getParameter("bookingId");
        Map<String, Object> result = new HashMap<>();

        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            result.put("status", "error");
            result.put("message", "Missing bookingId parameter.");
            out.print(gson.toJson(result));
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            Booking booking = bookingService.getBooking(bookingId);

            if (booking != null) {
                result.put("status", "success");
                result.put("bookingId", booking.getBookingId());
                result.put("bookingStatus", booking.getStatus());
                result.put("serviceName", booking.getServiceName());
                result.put("providerName", booking.getProviderName());
                result.put("providerPhone", booking.getProviderPhone());
                result.put("locationName", booking.getLocationName());
                result.put("requestedTime", booking.getRequestedTime());
                result.put("distance", booking.getDistance());
            } else {
                result.put("status", "notFound");
                result.put("message", "Booking not found.");
            }
        } catch (NumberFormatException e) {
            result.put("status", "error");
            result.put("message", "Invalid bookingId format.");
        }

        out.print(gson.toJson(result));
        out.flush();
    }
}
