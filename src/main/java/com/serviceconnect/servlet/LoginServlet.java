package com.serviceconnect.servlet;

import com.serviceconnect.dao.UserDAO;
import com.serviceconnect.model.User;
import com.serviceconnect.util.AuthTokenUtil;
import com.serviceconnect.util.CookieUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet handling user login, credential verification, session creation,
 * and remembering username via cookies.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward to login page
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Username and password cannot be empty.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.authenticate(username.trim(), password.trim());

        if (user != null) {
            // Create HTTP Session
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("name", user.getName());
            session.setAttribute("role", user.getRole());

            int provId = 0;
            if ("PROVIDER".equalsIgnoreCase(user.getRole())) {
                com.serviceconnect.dao.ProviderDAO provDAO = new com.serviceconnect.dao.ProviderDAO();
                com.serviceconnect.model.Provider p = provDAO.getProviderByUsername(user.getUsername());
                provId = p != null ? p.getProviderId() : 101;
                session.setAttribute("providerId", provId);
            }

            // Set session persistence cookies for cloud & serverless resilience
            String uidStr = String.valueOf(user.getId());
            String roleStr = user.getRole();
            String unameStr = user.getUsername();
            String provIdStr = String.valueOf(provId);
            String sig = AuthTokenUtil.sign(uidStr + "|" + roleStr + "|" + unameStr + "|" + provIdStr);

            CookieUtil.setCookie(response, "sc_user_id", uidStr, 7 * 24 * 60 * 60, true);
            CookieUtil.setCookie(response, "sc_role", roleStr, 7 * 24 * 60 * 60, true);
            CookieUtil.setCookie(response, "sc_username", unameStr, 7 * 24 * 60 * 60, true);
            CookieUtil.setCookie(response, "sc_sig", sig, 7 * 24 * 60 * 60, true);
            if (provId > 0) {
                CookieUtil.setCookie(response, "sc_provider_id", provIdStr, 7 * 24 * 60 * 60, true);
            }
            try {
                CookieUtil.setCookie(response, "sc_name", java.net.URLEncoder.encode(user.getName(), "UTF-8"), 7 * 24 * 60 * 60, false);
            } catch (Exception ignored) {}

            // Handle Remember Username via HTTP Cookie
            if ("on".equalsIgnoreCase(rememberMe) || "true".equalsIgnoreCase(rememberMe)) {
                CookieUtil.setCookie(response, "rememberedUsername", user.getUsername(), 7 * 24 * 60 * 60, false);
            } else {
                CookieUtil.deleteCookie(response, "rememberedUsername");
            }

            // Redirect based on role
            if ("CUSTOMER".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
            } else if ("PROVIDER".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/provider-dashboard");
            } else if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin-dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            }
        } else {
            request.setAttribute("errorMessage", "Invalid username or password.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
