package com.serviceconnect.model;

import java.io.Serializable;

/**
 * Model representing a complaint or grievance filed by a customer against a worker,
 * or by a worker against a customer, audited and resolved by the administrator.
 */
public class Complaint implements Serializable {
    private static final long serialVersionUID = 1L;

    private int complaintId;
    private int bookingId;
    private int complainantId;
    private String complainantName;
    private String complainantRole; // CUSTOMER or PROVIDER
    private int targetId;
    private String targetName;
    private String targetRole;      // PROVIDER or CUSTOMER
    private String complaintType;   // e.g. "Unprofessional Behavior", "Payment Dispute", etc.
    private String description;
    private String status;          // PENDING, RESOLVED, DISMISSED
    private String adminNotes;
    private String createdAt;

    public Complaint() {
        this.status = "PENDING";
    }

    public Complaint(int complaintId, int bookingId, int complainantId, String complainantName, 
                     String complainantRole, int targetId, String targetName, String targetRole, 
                     String complaintType, String description, String status, String adminNotes, String createdAt) {
        this.complaintId = complaintId;
        this.bookingId = bookingId;
        this.complainantId = complainantId;
        this.complainantName = complainantName;
        this.complainantRole = complainantRole;
        this.targetId = targetId;
        this.targetName = targetName;
        this.targetRole = targetRole;
        this.complaintType = complaintType;
        this.description = description;
        this.status = status != null ? status : "PENDING";
        this.adminNotes = adminNotes;
        this.createdAt = createdAt;
    }

    public int getComplaintId() {
        return complaintId;
    }

    public void setComplaintId(int complaintId) {
        this.complaintId = complaintId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getComplainantId() {
        return complainantId;
    }

    public void setComplainantId(int complainantId) {
        this.complainantId = complainantId;
    }

    public String getComplainantName() {
        return complainantName;
    }

    public void setComplainantName(String complainantName) {
        this.complainantName = complainantName;
    }

    public String getComplainantRole() {
        return complainantRole;
    }

    public void setComplainantRole(String complainantRole) {
        this.complainantRole = complainantRole;
    }

    public int getTargetId() {
        return targetId;
    }

    public void setTargetId(int targetId) {
        this.targetId = targetId;
    }

    public String getTargetName() {
        return targetName;
    }

    public void setTargetName(String targetName) {
        this.targetName = targetName;
    }

    public String getTargetRole() {
        return targetRole;
    }

    public void setTargetRole(String targetRole) {
        this.targetRole = targetRole;
    }

    public String getComplaintType() {
        return complaintType;
    }

    public void setComplaintType(String complaintType) {
        this.complaintType = complaintType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdminNotes() {
        return adminNotes;
    }

    public void setAdminNotes(String adminNotes) {
        this.adminNotes = adminNotes;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}
