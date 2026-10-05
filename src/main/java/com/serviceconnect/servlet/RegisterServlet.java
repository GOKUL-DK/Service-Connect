package com.serviceconnect.servlet;

import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.dao.UserDAO;
import com.serviceconnect.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet handling user and worker (service provider) registration.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;
    private ProviderDAO providerDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
        this.providerDAO = new ProviderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp?tab=register");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String role = request.getParameter("role");
        String name = request.getParameter("name");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (role == null || (!"CUSTOMER".equalsIgnoreCase(role) && !"PROVIDER".equalsIgnoreCase(role))) {
            role = "CUSTOMER";
        }

        // Validation 1: Required basic fields
        if (name == null || name.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All registration fields are required.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Validation 2: Passwords match
        if (confirmPassword != null && !password.trim().equals(confirmPassword.trim())) {
            request.setAttribute("errorMessage", "Passwords do not match. Please re-enter.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Validation 3: Username availability
        if (userDAO.isUsernameTaken(username.trim())) {
            request.setAttribute("errorMessage", "Username '" + username.trim() + "' is already taken. Please choose another.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if ("CUSTOMER".equalsIgnoreCase(role)) {
            User newUser = userDAO.registerUser(name.trim(), username.trim(), password.trim(), "CUSTOMER");
            if (newUser != null) {
                // Auto login
                HttpSession session = request.getSession(true);
                session.setAttribute("userId", newUser.getId());
                session.setAttribute("username", newUser.getUsername());
                session.setAttribute("name", newUser.getName());
                session.setAttribute("role", "CUSTOMER");

                response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp?msg=welcome");
                return;
            } else {
                request.setAttribute("errorMessage", "Failed to create customer account. Please try again.");
                request.setAttribute("activeTab", "register");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
        } else {
            // Worker / Provider registration
            String serviceIdStr = request.getParameter("serviceId");
            String phone = request.getParameter("phone");
            String availableFrom = request.getParameter("availableFrom");
            String availableUntil = request.getParameter("availableUntil");

            int serviceId = 1; // Default Plumbing
            if (serviceIdStr != null && !serviceIdStr.trim().isEmpty()) {
                try {
                    serviceId = Integer.parseInt(serviceIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            // 1. Create in users table
            User newUser = userDAO.registerUser(name.trim(), username.trim(), password.trim(), "PROVIDER");
            if (newUser != null) {
                // 2. Create in providers table & availability
                int provId = providerDAO.createProvider(name.trim(), serviceId, phone, 11.0168, 76.9558, availableFrom, availableUntil);

                // Auto login as Provider
                HttpSession session = request.getSession(true);
                session.setAttribute("userId", newUser.getId());
                session.setAttribute("username", newUser.getUsername());
                session.setAttribute("name", newUser.getName());
                session.setAttribute("role", "PROVIDER");
                session.setAttribute("providerId", provId > 0 ? provId : 101);

                response.sendRedirect(request.getContextPath() + "/provider-dashboard?msg=welcomeWorker");
                return;
            } else {
                request.setAttribute("errorMessage", "Failed to create worker account. Please try again.");
                request.setAttribute("activeTab", "register");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
        }
    }
}
