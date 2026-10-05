package com.serviceconnect.service;

import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.model.Provider;
import com.serviceconnect.util.DistanceUtil;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Core business service implementing the Provider Allocation Algorithm:
 * 1. Filter by requested service
 * 2. Check operational hours (available_from to available_until)
 * 3. Verify status (must be AVAILABLE)
 * 4. Compute distance via Haversine formula (DistanceUtil)
 * 5. Filter out providers beyond requested radius
 * 6. Sort remaining eligible providers by distance ascending (closest first)
 */
public class ProviderAllocationService {

    private final ProviderDAO providerDAO;
    private final XMLRuleService xmlRuleService;

    public ProviderAllocationService() {
        this.providerDAO = new ProviderDAO();
        this.xmlRuleService = new XMLRuleService();
    }

    public ProviderAllocationService(ProviderDAO providerDAO, XMLRuleService xmlRuleService) {
        this.providerDAO = providerDAO;
        this.xmlRuleService = xmlRuleService;
    }

    /**
     * Executes the provider allocation algorithm.
     *
     * @param serviceName Service requested by user
     * @param userLat Latitude of user selected location
     * @param userLon Longitude of user selected location
     * @param searchRadiusKm Search radius in kilometers
     * @param requestedTimeStr Preferred time in HH:mm or HH:mm:ss
     * @return List of suitable providers matching all criteria, sorted by distance ascending
     */
    public List<Provider> findSuitableProviders(String serviceName, double userLat, double userLon, 
                                                double searchRadiusKm, String requestedTimeStr) {

        // Validate and clamp radius using XML rules
        int maxRadius = xmlRuleService.getMaximumRadius();
        if (searchRadiusKm <= 0) {
            searchRadiusKm = xmlRuleService.getDefaultRadius();
        } else if (searchRadiusKm > maxRadius) {
            searchRadiusKm = maxRadius;
        }

        // Step 1: Find all providers offering requested service
        List<Provider> candidates = providerDAO.getProvidersByServiceName(serviceName);
        List<Provider> qualified = new ArrayList<>();

        LocalTime requestedTime = parseTime(requestedTimeStr);

        for (Provider provider : candidates) {
            // Step 2: Calculate geographic distance using Haversine formula
            double dist = DistanceUtil.calculateDistance(userLat, userLon, provider.getLatitude(), provider.getLongitude());
            provider.setDistance(dist);

            // Step 3: Check Provider Active Status
            if (!"AVAILABLE".equalsIgnoreCase(provider.getStatus())) {
                provider.setEligible(false);
                provider.setMessage("Provider currently busy");
                continue;
            }

            // Step 4: Check Provider Operational Time Window
            if (requestedTime != null) {
                LocalTime from = parseTime(provider.getAvailableFrom());
                LocalTime until = parseTime(provider.getAvailableUntil());

                if (from != null && until != null) {
                    if (requestedTime.isBefore(from) || requestedTime.isAfter(until)) {
                        provider.setEligible(false);
                        provider.setMessage("Outside working hours (" + formatDisplayTime(from) + " - " + formatDisplayTime(until) + ")");
                        continue;
                    }
                }
            }

            // Step 5: Check Search Radius Boundary
            if (dist > searchRadiusKm) {
                provider.setEligible(false);
                provider.setMessage("Outside selected radius (" + dist + " km > " + searchRadiusKm + " km)");
                continue;
            }

            // Provider passes all allocation checks
            provider.setEligible(true);
            provider.setMessage("Available");
            qualified.add(provider);
        }

        // Step 6: Sort qualifying providers by distance in ascending order (closest first)
        Collections.sort(qualified, Comparator.comparingDouble(Provider::getDistance));

        return qualified;
    }

    /**
     * Helper to safely parse time strings (supports HH:mm, HH:mm:ss, H:mm).
     */
    private LocalTime parseTime(String timeStr) {
        if (timeStr == null || timeStr.trim().isEmpty()) {
            return null;
        }
        timeStr = timeStr.trim();
        try {
            if (timeStr.length() == 5) {
                return LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("HH:mm"));
            } else if (timeStr.length() == 8) {
                return LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("HH:mm:ss"));
            } else if (timeStr.length() == 4) {
                return LocalTime.parse("0" + timeStr, DateTimeFormatter.ofPattern("HH:mm"));
            }
            return LocalTime.parse(timeStr);
        } catch (Exception e) {
            return null;
        }
    }

    private String formatDisplayTime(LocalTime time) {
        return time.format(DateTimeFormatter.ofPattern("hh:mm a"));
    }
}
