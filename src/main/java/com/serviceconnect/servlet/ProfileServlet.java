package com.serviceconnect.servlet;

import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.dao.UserDAO;
import com.serviceconnect.model.Provider;
import com.serviceconnect.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller servlet for viewing and editing personal profile information
 * and updating account passwords for both Customers and Workers/Providers.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {
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
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=loginRequired");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");

        User user = userDAO.getUserById(userId);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=userNotFound");
            return;
        }

        request.setAttribute("userProfile", user);

        if ("PROVIDER".equalsIgnoreCase(role)) {
            Provider provider = providerDAO.getProviderByUsername(username);
            if (provider == null) {
                provider = providerDAO.getProviderById(101);
            }
            request.setAttribute("providerProfile", provider);
        }

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
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
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");

        String action = request.getParameter("action");

        if ("updateProfile".equalsIgnoreCase(action)) {
            String name = request.getParameter("name");
            if (name == null || name.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/profile?error=emptyName");
                return;
            }

            name = name.trim();
            userDAO.updateProfile(userId, name);
            session.setAttribute("name", name);

            if ("PROVIDER".equalsIgnoreCase(role)) {
                String phone = request.getParameter("phone");
                String availableFrom = request.getParameter("availableFrom");
                String availableUntil = request.getParameter("availableUntil");

                if (availableFrom != null && availableFrom.length() == 5) availableFrom += ":00";
                if (availableUntil != null && availableUntil.length() == 5) availableUntil += ":00";

                Provider prov = providerDAO.getProviderByUsername(username);
                int provId = (prov != null) ? prov.getProviderId() : 101;

                providerDAO.updateProfile(provId, name, phone != null ? phone.trim() : "9000000001",
                        availableFrom != null ? availableFrom : "09:00:00",
                        availableUntil != null ? availableUntil : "17:00:00");
            }

            response.sendRedirect(request.getContextPath() + "/profile?msg=profileUpdated");
            return;

        } else if ("changePassword".equalsIgnoreCase(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (currentPassword == null || newPassword == null || confirmPassword == null) {
                response.sendRedirect(request.getContextPath() + "/profile?error=missingFields");
                return;
            }

            if (!userDAO.verifyPassword(userId, currentPassword.trim())) {
                response.sendRedirect(request.getContextPath() + "/profile?error=invalidCurrentPassword");
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                response.sendRedirect(request.getContextPath() + "/profile?error=passwordMismatch");
                return;
            }

            if (newPassword.trim().length() < 4) {
                response.sendRedirect(request.getContextPath() + "/profile?error=passwordTooShort");
                return;
            }

            boolean ok = userDAO.updatePassword(userId, newPassword.trim());
            response.sendRedirect(request.getContextPath() + "/profile?msg=" + (ok ? "passwordChanged" : "updateFailed"));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
