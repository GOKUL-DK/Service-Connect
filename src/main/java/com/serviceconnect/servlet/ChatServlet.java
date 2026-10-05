package com.serviceconnect.servlet;

import com.google.gson.Gson;
import com.serviceconnect.dao.ChatMessageDAO;
import com.serviceconnect.model.ChatMessage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST / AJAX API endpoint for live in-app messaging between customer and provider.
 */
import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.model.Provider;

@WebServlet(name = "ChatServlet", urlPatterns = {"/api/chat"})
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ChatMessageDAO chatDAO;
    private ProviderDAO providerDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.chatDAO = new ChatMessageDAO();
        this.providerDAO = new ProviderDAO();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");

        // 1. Notification Polling Endpoint for Real-Time Toast & Audio Alerts
        if ("pollNotifications".equalsIgnoreCase(action) || "poll".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\": \"Unauthorized\"}");
                return;
            }

            int userId = (Integer) session.getAttribute("userId");
            String role = (String) session.getAttribute("role");
            String lastIdStr = request.getParameter("lastMessageId");
            int lastId = 0;
            if (lastIdStr != null && !lastIdStr.trim().isEmpty()) {
                try {
                    lastId = Integer.parseInt(lastIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            // Resolve target ID (Customer user_id OR Provider provider_id)
            int targetEntityId = userId;
            if ("PROVIDER".equalsIgnoreCase(role)) {
                Integer provId = (Integer) session.getAttribute("providerId");
                if (provId == null) {
                    String username = (String) session.getAttribute("username");
                    Provider p = providerDAO.getProviderByUsername(username);
                    provId = (p != null) ? p.getProviderId() : 101;
                    session.setAttribute("providerId", provId);
                }
                targetEntityId = provId;
            }

            // If baseline requested (e.g. on first page load), return latest message ID without alerting old history
            String baseline = request.getParameter("baseline");
            if ("true".equalsIgnoreCase(baseline)) {
                int maxId = chatDAO.getLatestMessageId();
                Map<String, Object> baseMap = new HashMap<>();
                baseMap.put("status", "success");
                baseMap.put("lastMessageId", maxId);
                baseMap.put("count", 0);
                baseMap.put("messages", List.of());
                out.print(gson.toJson(baseMap));
                out.flush();
                return;
            }

            List<ChatMessage> incoming = chatDAO.getNewIncomingMessages(targetEntityId, role, lastId);
            int newMax = lastId;
            for (ChatMessage m : incoming) {
                if (m.getMessageId() > newMax) {
                    newMax = m.getMessageId();
                }
            }

            Map<String, Object> res = new HashMap<>();
            res.put("status", "success");
            res.put("count", incoming.size());
            res.put("lastMessageId", newMax);
            res.put("messages", incoming);
            out.print(gson.toJson(res));
            out.flush();
            return;
        }

        // 2. Booking-Specific Chat Message History
        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Missing bookingId or action\"}");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            List<ChatMessage> messages = chatDAO.getMessagesByBookingId(bookingId);
            out.print(gson.toJson(messages));
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid bookingId\"}");
        }
        out.flush();
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

        int userId = (Integer) session.getAttribute("userId");
        String userName = (String) session.getAttribute("name");
        String role = (String) session.getAttribute("role");

        String bookingIdStr = request.getParameter("bookingId");
        String messageText = request.getParameter("message");

        Map<String, Object> json = new HashMap<>();

        if (bookingIdStr == null || messageText == null || messageText.trim().isEmpty()) {
            json.put("status", "error");
            json.put("message", "Message text and bookingId required");
            out.print(gson.toJson(json));
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            ChatMessage msg = new ChatMessage();
            msg.setBookingId(bookingId);
            msg.setSenderId(userId);
            msg.setSenderName(userName != null ? userName : "User");
            msg.setSenderRole(role != null ? role : "CUSTOMER");
            msg.setMessageText(messageText.trim());

            boolean success = chatDAO.saveMessage(msg);
            json.put("status", success ? "success" : "failed");
            out.print(gson.toJson(json));
        } catch (Exception e) {
            json.put("status", "error");
            json.put("message", e.getMessage());
            out.print(gson.toJson(json));
        }
        out.flush();
    }
}
