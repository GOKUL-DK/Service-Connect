package com.serviceconnect.servlet;

import com.google.gson.Gson;
import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.model.Provider;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * REST / AJAX API endpoint for live provider online/offline availability toggle.
 */
@WebServlet(name = "ProviderStatusServlet", urlPatterns = {"/api/provider-status"})
public class ProviderStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ProviderDAO providerDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.providerDAO = new ProviderDAO();
        this.gson = new Gson();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Unauthorized\"}");
            return;
        }

        String username = (String) session.getAttribute("username");
        Provider provider = providerDAO.getProviderByUsername(username);

        Map<String, Object> json = new HashMap<>();

        if (provider == null) {
            json.put("status", "error");
            json.put("message", "Provider not found");
            out.print(gson.toJson(json));
            return;
        }

        String requestedStatus = request.getParameter("status");
        if (requestedStatus == null || requestedStatus.trim().isEmpty()) {
            // Toggle between AVAILABLE and BUSY
            requestedStatus = "AVAILABLE".equalsIgnoreCase(provider.getStatus()) ? "BUSY" : "AVAILABLE";
        }

        boolean ok = providerDAO.updateStatus(provider.getProviderId(), requestedStatus);
        if (ok) {
            json.put("status", "success");
            json.put("newStatus", requestedStatus);
            json.put("message", "Status updated to " + requestedStatus);
        } else {
            json.put("status", "error");
            json.put("message", "Failed to update status");
        }

        out.print(gson.toJson(json));
        out.flush();
    }
}
