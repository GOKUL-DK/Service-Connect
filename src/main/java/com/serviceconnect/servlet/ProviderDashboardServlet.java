package com.serviceconnect.servlet;

import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.model.Booking;
import com.serviceconnect.model.Provider;
import com.serviceconnect.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet for managing the Provider Dashboard.
 * Displays assigned customer requests and current working hours.
 */
@WebServlet(name = "ProviderDashboardServlet", urlPatterns = {"/provider-dashboard"})
public class ProviderDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ProviderDAO providerDAO;
    private BookingService bookingService;

    @Override
    public void init() throws ServletException {
        this.providerDAO = new ProviderDAO();
        this.bookingService = new BookingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"PROVIDER".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp?error=accessDenied");
            return;
        }

        String username = (String) session.getAttribute("username");
        Provider provider = providerDAO.getProviderByUsername(username);

        // If provider record not directly matched, fallback to provider 101 (Arun Kumar) for demo
        if (provider == null) {
            provider = providerDAO.getProviderById(101);
        }

        List<Booking> jobs = bookingService.getProviderBookings(provider.getProviderId());

        request.setAttribute("provider", provider);
        request.setAttribute("jobs", jobs);
        request.getRequestDispatcher("/provider-dashboard.jsp").forward(request, response);
    }
}
