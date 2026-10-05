package com.serviceconnect.dao;

import com.serviceconnect.model.ChatMessage;
import com.serviceconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for in-app chat messages using pure JDBC.
 */
public class ChatMessageDAO {

    public boolean saveMessage(ChatMessage msg) {
        String sql = "INSERT INTO booking_messages (booking_id, sender_id, sender_name, sender_role, message_text) " +
                     "VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, msg.getBookingId());
            ps.setInt(2, msg.getSenderId());
            ps.setString(3, msg.getSenderName());
            ps.setString(4, msg.getSenderRole());
            ps.setString(5, msg.getMessageText());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ChatMessageDAO.saveMessage: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    public List<ChatMessage> getMessagesByBookingId(int bookingId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT message_id, booking_id, sender_id, sender_name, sender_role, message_text, " +
                     "DATE_FORMAT(sent_at, '%h:%i %p') AS sent_at_formatted " +
                     "FROM booking_messages WHERE booking_id = ? ORDER BY message_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookingId);
            rs = ps.executeQuery();

            while (rs.next()) {
                ChatMessage m = new ChatMessage(
                    rs.getInt("message_id"),
                    rs.getInt("booking_id"),
                    rs.getInt("sender_id"),
                    rs.getString("sender_name"),
                    rs.getString("sender_role"),
                    rs.getString("message_text"),
                    rs.getString("sent_at_formatted")
                );
                list.add(m);
            }
        } catch (SQLException e) {
            System.err.println("Error in ChatMessageDAO.getMessagesByBookingId: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    public int getLatestMessageId() {
        String sql = "SELECT COALESCE(MAX(message_id), 0) AS max_id FROM booking_messages";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("max_id");
            }
        } catch (SQLException e) {
            System.err.println("Error in ChatMessageDAO.getLatestMessageId: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Retrieves new incoming messages directed to the specified customer or provider.
     * For CUSTOMER: returns messages on their bookings sent by PROVIDER where message_id > afterMessageId.
     * For PROVIDER: returns messages on their bookings sent by CUSTOMER where message_id > afterMessageId.
     */
    public List<ChatMessage> getNewIncomingMessages(int targetId, String role, int afterMessageId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql;
        if ("CUSTOMER".equalsIgnoreCase(role)) {
            sql = "SELECT bm.message_id, bm.booking_id, bm.sender_id, bm.sender_name, bm.sender_role, bm.message_text, " +
                  "DATE_FORMAT(bm.sent_at, '%h:%i %p') AS sent_at_formatted " +
                  "FROM booking_messages bm " +
                  "JOIN bookings b ON bm.booking_id = b.booking_id " +
                  "WHERE b.user_id = ? " +
                  "  AND bm.sender_role != 'CUSTOMER' " +
                  "  AND bm.message_id > ? " +
                  "ORDER BY bm.message_id ASC";
        } else {
            sql = "SELECT bm.message_id, bm.booking_id, bm.sender_id, bm.sender_name, bm.sender_role, bm.message_text, " +
                  "DATE_FORMAT(bm.sent_at, '%h:%i %p') AS sent_at_formatted " +
                  "FROM booking_messages bm " +
                  "JOIN bookings b ON bm.booking_id = b.booking_id " +
                  "WHERE (b.provider_id = ? OR b.provider_id IN (SELECT provider_id FROM providers WHERE provider_id = ?)) " +
                  "  AND bm.sender_role != 'PROVIDER' " +
                  "  AND bm.message_id > ? " +
                  "ORDER BY bm.message_id ASC";
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            if ("CUSTOMER".equalsIgnoreCase(role)) {
                ps.setInt(1, targetId);
                ps.setInt(2, afterMessageId);
            } else {
                ps.setInt(1, targetId);
                ps.setInt(2, targetId);
                ps.setInt(3, afterMessageId);
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                ChatMessage m = new ChatMessage(
                    rs.getInt("message_id"),
                    rs.getInt("booking_id"),
                    rs.getInt("sender_id"),
                    rs.getString("sender_name"),
                    rs.getString("sender_role"),
                    rs.getString("message_text"),
                    rs.getString("sent_at_formatted")
                );
                list.add(m);
            }
        } catch (SQLException e) {
            System.err.println("Error in ChatMessageDAO.getNewIncomingMessages: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }
}

