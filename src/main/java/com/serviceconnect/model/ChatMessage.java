package com.serviceconnect.model;

import java.io.Serializable;

/**
 * Model representing a real-time message exchanged between customer and service provider.
 */
public class ChatMessage implements Serializable {
    private static final long serialVersionUID = 1L;

    private int messageId;
    private int bookingId;
    private int senderId;
    private String senderName;
    private String senderRole;
    private String messageText;
    private String sentAt;

    public ChatMessage() {
    }

    public ChatMessage(int messageId, int bookingId, int senderId, String senderName, 
                       String senderRole, String messageText, String sentAt) {
        this.messageId = messageId;
        this.bookingId = bookingId;
        this.senderId = senderId;
        this.senderName = senderName;
        this.senderRole = senderRole;
        this.messageText = messageText;
        this.sentAt = sentAt;
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public String getMessageText() {
        return messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public String getSentAt() {
        return sentAt;
    }

    public void setSentAt(String sentAt) {
        this.sentAt = sentAt;
    }
}
