package com.serviceconnect.model;

import java.io.Serializable;

/**
 * Model representing a service provider in the ServiceConnect system.
 */
public class Provider implements Serializable {
    private static final long serialVersionUID = 1L;

    private int providerId;
    private String name;
    private int serviceId;
    private String serviceName;
    private String phone;
    private double latitude;
    private double longitude;
    private String availableFrom;
    private String availableUntil;
    private String status;
    
    // Dynamic fields populated during distance calculation & allocation
    private double distance;
    private boolean eligible;
    private String message;

    public Provider() {
    }

    public Provider(int providerId, String name, int serviceId, String phone, 
                    double latitude, double longitude, String availableFrom, 
                    String availableUntil, String status) {
        this.providerId = providerId;
        this.name = name;
        this.serviceId = serviceId;
        this.phone = phone;
        this.latitude = latitude;
        this.longitude = longitude;
        this.availableFrom = availableFrom;
        this.availableUntil = availableUntil;
        this.status = status;
    }

    public int getProviderId() {
        return providerId;
    }

    public void setProviderId(int providerId) {
        this.providerId = providerId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
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

    public String getAvailableFrom() {
        return availableFrom;
    }

    public void setAvailableFrom(String availableFrom) {
        this.availableFrom = availableFrom;
    }

    public String getAvailableUntil() {
        return availableUntil;
    }

    public void setAvailableUntil(String availableUntil) {
        this.availableUntil = availableUntil;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getDistance() {
        return distance;
    }

    public void setDistance(double distance) {
        this.distance = distance;
    }

    public boolean isEligible() {
        return eligible;
    }

    public void setEligible(boolean eligible) {
        this.eligible = eligible;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return "Provider [id=" + providerId + ", name=" + name + ", service=" + serviceName + 
               ", distance=" + distance + " km, status=" + status + "]";
    }
}
