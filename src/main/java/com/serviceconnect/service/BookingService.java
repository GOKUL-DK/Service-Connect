package com.serviceconnect.service;

import com.serviceconnect.dao.BookingDAO;
import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.model.Booking;

import java.util.List;

/**
 * Service orchestrating booking lifecycle management, customer requests,
 * and provider job status transitions.
 */
public class BookingService {

    private final BookingDAO bookingDAO;
    private final ProviderDAO providerDAO;

    public BookingService() {
        this.bookingDAO = new BookingDAO();
        this.providerDAO = new ProviderDAO();
    }

    public BookingService(BookingDAO bookingDAO, ProviderDAO providerDAO) {
        this.bookingDAO = bookingDAO;
        this.providerDAO = providerDAO;
    }

    /**
     * Creates a new booking request.
     * @return Created booking with generated ID or null on failure.
     */
    public Booking createBooking(Booking booking) {
        if (booking.getStatus() == null || booking.getStatus().isEmpty()) {
            booking.setStatus("CONFIRMED");
        }
        int bookingId = bookingDAO.createBooking(booking);
        if (bookingId > 0) {
            return bookingDAO.getBookingById(bookingId);
        }
        return null;
    }

    public Booking getBooking(int bookingId) {
        return bookingDAO.getBookingById(bookingId);
    }

    public List<Booking> getCustomerBookings(int userId) {
        return bookingDAO.getBookingsByUser(userId);
    }

    public List<Booking> getProviderBookings(int providerId) {
        return bookingDAO.getBookingsByProvider(providerId);
    }

    public List<Booking> getAllBookings() {
        return bookingDAO.getAllBookings();
    }

    /**
     * Transitions the status of a booking and updates provider availability accordingly.
     *
     * @param bookingId Booking identifier
     * @param newStatus Target status (ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED)
     * @return true if updated successfully
     */
    public boolean updateBookingStatus(int bookingId, String newStatus) {
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            return false;
        }

        boolean updated = bookingDAO.updateStatus(bookingId, newStatus);
        if (updated) {
            // Update provider status dynamically based on job state
            if ("ACCEPTED".equalsIgnoreCase(newStatus) || "IN_PROGRESS".equalsIgnoreCase(newStatus)) {
                providerDAO.updateStatus(booking.getProviderId(), "BUSY");
            } else if ("COMPLETED".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus)) {
                providerDAO.updateStatus(booking.getProviderId(), "AVAILABLE");
            }
        }
        return updated;
    }
}
