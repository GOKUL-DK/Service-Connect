package com.serviceconnect.servlet;

import com.google.gson.Gson;
import com.serviceconnect.dao.BookingDAO;
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
 * REST / AJAX API endpoint for submitting customer reviews and ratings.
 */
@WebServlet(name = "ReviewServlet", urlPatterns = {"/api/review"})
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BookingDAO bookingDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.bookingDAO = new BookingDAO();
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

        String bookingIdStr = request.getParameter("bookingId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        Map<String, Object> json = new HashMap<>();

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            int rating = Integer.parseInt(ratingStr.trim());
            if (rating < 1) rating = 1;
            if (rating > 5) rating = 5;

            boolean success = bookingDAO.submitRating(bookingId, rating, comment != null ? comment.trim() : "");
            json.put("status", success ? "success" : "failed");
            json.put("message", success ? "Review submitted successfully!" : "Could not save review.");
            out.print(gson.toJson(json));
        } catch (Exception e) {
            json.put("status", "error");
            json.put("message", e.getMessage());
            out.print(gson.toJson(json));
        }
        out.flush();
    }
}
