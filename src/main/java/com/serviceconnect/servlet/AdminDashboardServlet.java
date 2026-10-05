package com.serviceconnect.servlet;

import com.serviceconnect.dao.BookingDAO;
import com.serviceconnect.dao.ComplaintDAO;
import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.dao.ServiceDAO;
import com.serviceconnect.dao.UserDAO;
import com.serviceconnect.model.Booking;
import com.serviceconnect.model.Complaint;
import com.serviceconnect.model.Provider;
import com.serviceconnect.model.Service;
import com.serviceconnect.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet for managing the Admin Dashboard with service statistics,
 * provider listings, booking history, and complaints resolution.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin-dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ProviderDAO providerDAO;
    private BookingDAO bookingDAO;
    private ServiceDAO serviceDAO;
    private UserDAO userDAO;
    private ComplaintDAO complaintDAO;

    @Override
    public void init() throws ServletException {
        this.providerDAO = new ProviderDAO();
        this.bookingDAO = new BookingDAO();
        this.serviceDAO = new ServiceDAO();
        this.userDAO = new UserDAO();
        this.complaintDAO = new ComplaintDAO();
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
        if (!"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
            return;
        }

        List<Provider> providers = providerDAO.getAllProviders();
        List<Booking> bookings = bookingDAO.getAllBookings();
        List<Service> services = serviceDAO.getAllServices();
        List<User> users = userDAO.getAllUsers();
        List<Complaint> complaints = complaintDAO.getAllComplaints();

        request.setAttribute("providers", providers);
        request.setAttribute("bookings", bookings);
        request.setAttribute("services", services);
        request.setAttribute("users", users);
        request.setAttribute("complaints", complaints);

        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}
