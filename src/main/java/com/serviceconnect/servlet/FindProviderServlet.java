package com.serviceconnect.servlet;

import com.google.gson.Gson;
import com.serviceconnect.dao.LocationDAO;
import com.serviceconnect.model.Location;
import com.serviceconnect.model.Provider;
import com.serviceconnect.service.ProviderAllocationService;
import com.serviceconnect.util.CookieUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AJAX endpoint for finding suitable service providers.
 * Receives search parameters asynchronously, calculates distances,
 * verifies operational availability, and returns providers formatted as JSON.
 */
@WebServlet(name = "FindProviderServlet", urlPatterns = {"/api/find-providers"})
public class FindProviderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ProviderAllocationService allocationService;
    private LocationDAO locationDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.allocationService = new ProviderAllocationService();
        this.locationDAO = new LocationDAO();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String serviceName = request.getParameter("service");
        String locationName = request.getParameter("location");
        String landmark = request.getParameter("landmark");
        String address = request.getParameter("address");
        String radiusStr = request.getParameter("radius");
        String requestedTime = request.getParameter("requestedTime");

        if ((locationName == null || locationName.trim().isEmpty()) && landmark != null) {
            locationName = landmark.trim();
        }
        if (locationName == null || locationName.trim().isEmpty()) {
            if (address != null && !address.trim().isEmpty()) {
                locationName = address.trim();
            }
        }

        Map<String, Object> jsonResponse = new HashMap<>();

        if (serviceName == null || serviceName.trim().isEmpty() ||
            locationName == null || locationName.trim().isEmpty()) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Please select a service and enter your landmark & address.");
            out.print(gson.toJson(jsonResponse));
            return;
        }

        // Store preferred service and radius in cookies for user convenience
        CookieUtil.setCookie(response, "preferredService", serviceName);
        if (radiusStr != null && !radiusStr.isEmpty()) {
            CookieUtil.setCookie(response, "preferredRadius", radiusStr);
        }

        // Resolve location coordinates from typed landmark and address
        Location loc = null;
        if (locationName != null && !locationName.trim().isEmpty()) {
            loc = locationDAO.getLocationByName(locationName.trim());
        }
        if (loc == null && locationName != null) {
            String lower = locationName.toLowerCase();
            List<Location> allLocs = locationDAO.getAllLocations();
            for (Location l : allLocs) {
                if (lower.contains(l.getLocationName().toLowerCase()) || l.getLocationName().toLowerCase().contains(lower)) {
                    loc = new Location(l.getLocationId(), locationName, l.getLatitude(), l.getLongitude());
                    break;
                }
            }
        }
        if (loc == null && address != null && !address.trim().isEmpty()) {
            String lowerAddr = address.toLowerCase();
            List<Location> allLocs = locationDAO.getAllLocations();
            for (Location l : allLocs) {
                if (lowerAddr.contains(l.getLocationName().toLowerCase())) {
                    loc = new Location(l.getLocationId(), locationName != null ? locationName : address, l.getLatitude(), l.getLongitude());
                    break;
                }
            }
        }
        if (loc == null) {
            // Check if user entered numeric coordinates anywhere in text e.g. "11.0168, 76.9558"
            double[] coords = parseCoords(locationName, address);
            if (coords != null) {
                loc = new Location(0, locationName != null ? locationName : "Custom Location", coords[0], coords[1]);
            }
        }
        if (loc == null) {
            // Fallback: check if location string is an ID
            try {
                int locId = Integer.parseInt(locationName);
                loc = locationDAO.getLocationById(locId);
            } catch (NumberFormatException ignored) {}
        }
        if (loc == null) {
            // Default center coordinate in service area (11.0168, 76.9558) with user-typed landmark
            loc = new Location(1, locationName != null && !locationName.isEmpty() ? locationName : "Location A", 11.0168, 76.9558);
        }

        double radius = 5.0;
        try {
            if (radiusStr != null && !radiusStr.trim().isEmpty()) {
                radius = Double.parseDouble(radiusStr.trim());
            }
        } catch (NumberFormatException e) {
            radius = 5.0;
        }

        // Execute provider allocation algorithm
        List<Provider> providers = allocationService.findSuitableProviders(
            serviceName, loc.getLatitude(), loc.getLongitude(), radius, requestedTime
        );

        String displayLocation = loc.getLocationName();
        if (address != null && !address.trim().isEmpty() && !displayLocation.contains(address.trim())) {
            displayLocation = displayLocation + " (" + address.trim() + ")";
        }

        jsonResponse.put("userLat", loc.getLatitude());
        jsonResponse.put("userLon", loc.getLongitude());

        if (providers == null || providers.isEmpty()) {
            jsonResponse.put("status", "empty");
            jsonResponse.put("count", 0);
            jsonResponse.put("message", "No available " + serviceName + " providers found within " + radius + " km.");
            jsonResponse.put("providers", List.of());
        } else {
            jsonResponse.put("status", "success");
            jsonResponse.put("service", serviceName);
            jsonResponse.put("location", displayLocation);
            jsonResponse.put("landmark", loc.getLocationName());
            jsonResponse.put("address", address != null ? address.trim() : "");
            jsonResponse.put("radius", radius);
            jsonResponse.put("count", providers.size());
            jsonResponse.put("providers", providers);
            jsonResponse.put("message", providers.size() + " suitable provider(s) found near " + displayLocation + ".");
        }

        out.print(gson.toJson(jsonResponse));
        out.flush();
    }

    private double[] parseCoords(String... texts) {
        for (String text : texts) {
            if (text == null) continue;
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("([+-]?\\d+\\.\\d+)[\\s,]+([+-]?\\d+\\.\\d+)").matcher(text);
            if (m.find()) {
                try {
                    double lat = Double.parseDouble(m.group(1));
                    double lon = Double.parseDouble(m.group(2));
                    return new double[]{lat, lon};
                } catch (NumberFormatException ignored) {}
            }
        }
        return null;
    }
}
