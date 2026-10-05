package com.serviceconnect.model;

import java.io.Serializable;

/**
 * Model representing a service booking made by a customer for an allocated provider.
 */
public class Booking implements Serializable {
    private static final long serialVersionUID = 1L;

    private int bookingId;
    private int userId;
    private String userName;
    private int providerId;
    private String providerName;
    private String providerPhone;
    private int serviceId;
    private String serviceName;
    private String locationName;
    private double latitude;
    private double longitude;
    private String requestedTime;
    private double distance;
    private String status; // REQUESTED, CONFIRMED, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED
    private String createdAt;
    private String otp = "1234";
    private boolean isEmergency = false;
    private double totalAmount = 0.0;
    private int rating = 0;
    private String reviewComment;

    public Booking() {
    }

    public Booking(int bookingId, int userId, int providerId, int serviceId, 
                   String locationName, double latitude, double longitude, 
                   String requestedTime, double distance, String status, String createdAt) {
        this.bookingId = bookingId;
        this.userId = userId;
        this.providerId = providerId;
        this.serviceId = serviceId;
        this.locationName = locationName;
        this.latitude = latitude;
        this.longitude = longitude;
        this.requestedTime = requestedTime;
        this.distance = distance;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public int getProviderId() {
        return providerId;
    }

    public void setProviderId(int providerId) {
        this.providerId = providerId;
    }

    public String getProviderName() {
        return providerName;
    }

    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getProviderPhone() {
        return providerPhone;
    }

    public void setProviderPhone(String providerPhone) {
        this.providerPhone = providerPhone;
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

    public String getRequestedTime() {
        return requestedTime;
    }

    public void setRequestedTime(String requestedTime) {
        this.requestedTime = requestedTime;
    }

    public double getDistance() {
        return distance;
    }

    public void setDistance(double distance) {
        this.distance = distance;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getOtp() {
        return otp != null ? otp : "1234";
    }

    public void setOtp(String otp) {
        this.otp = otp;
    }

    public boolean isEmergency() {
        return isEmergency;
    }

    public void setEmergency(boolean emergency) {
        isEmergency = emergency;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getReviewComment() {
        return reviewComment;
    }

    public void setReviewComment(String reviewComment) {
        this.reviewComment = reviewComment;
    }

    @Override
    public String toString() {
        return "Booking [bookingId=" + bookingId + ", service=" + serviceName + 
               ", provider=" + providerName + ", status=" + status + "]";
    }
}
