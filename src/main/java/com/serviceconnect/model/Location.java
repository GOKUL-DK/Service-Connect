package com.serviceconnect.model;

import java.io.Serializable;

/**
 * Model representing a predefined location/landmark with geographic coordinates.
 */
public class Location implements Serializable {
    private static final long serialVersionUID = 1L;

    private int locationId;
    private String locationName;
    private double latitude;
    private double longitude;

    public Location() {
    }

    public Location(int locationId, String locationName, double latitude, double longitude) {
        this.locationId = locationId;
        this.locationName = locationName;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public int getLocationId() {
        return locationId;
    }

    public void setLocationId(int locationId) {
        this.locationId = locationId;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    @Override
    public String toString() {
        return "Location [locationId=" + locationId + ", locationName=" + locationName + 
               ", lat=" + latitude + ", lon=" + longitude + "]";
    }
}
