package com.serviceconnect.util;

/**
 * Utility class to calculate geographical distance between two points on Earth
 * using the mathematical Haversine formula.
 */
public class DistanceUtil {

    // Approximate radius of the Earth in kilometers
    private static final double EARTH_RADIUS_KM = 6371.0;

    /**
     * Calculates the great-circle distance between two pairs of latitude and longitude coordinates.
     * 
     * @param lat1 Latitude of point 1 (degrees)
     * @param lon1 Longitude of point 1 (degrees)
     * @param lat2 Latitude of point 2 (degrees)
     * @param lon2 Longitude of point 2 (degrees)
     * @return Distance in kilometers rounded to two decimal places
     */
    public static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        if (lat1 == lat2 && lon1 == lon2) {
            return 0.0;
        }

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double radLat1 = Math.toRadians(lat1);
        double radLat2 = Math.toRadians(lat2);

        // Haversine formula
        double a = Math.sin(dLat / 2.0) * Math.sin(dLat / 2.0) +
                   Math.cos(radLat1) * Math.cos(radLat2) *
                   Math.sin(dLon / 2.0) * Math.sin(dLon / 2.0);

        double c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));
        double distance = EARTH_RADIUS_KM * c;

        // Round to 2 decimal places
        return Math.round(distance * 100.0) / 100.0;
    }
}
