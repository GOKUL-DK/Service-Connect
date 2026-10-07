package com.serviceconnect.servlet;

import com.serviceconnect.util.CookieUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet handling user logout by invalidating the HTTP Session and clearing auth cookies.
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // Clear session persistence cookies
        CookieUtil.deleteCookie(response, "sc_user_id");
        CookieUtil.deleteCookie(response, "sc_role");
        CookieUtil.deleteCookie(response, "sc_username");
        CookieUtil.deleteCookie(response, "sc_name");
        CookieUtil.deleteCookie(response, "sc_provider_id");
        CookieUtil.deleteCookie(response, "sc_sig");

        response.sendRedirect(request.getContextPath() + "/login.jsp?loggedOut=true");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
