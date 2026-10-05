package com.serviceconnect.dao;

import com.serviceconnect.model.Complaint;
import com.serviceconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Complaints & Grievances.
 * Supports cross-complaints between customers and providers,
 * as well as administrative review and resolution.
 */
public class ComplaintDAO {

    public boolean createComplaint(Complaint c) {
        String sql = "INSERT INTO complaints (booking_id, complainant_id, complainant_name, complainant_role, " +
                     "target_id, target_name, target_role, complaint_type, description, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, c.getBookingId());
            ps.setInt(2, c.getComplainantId());
            ps.setString(3, c.getComplainantName());
            ps.setString(4, c.getComplainantRole());
            ps.setInt(5, c.getTargetId());
            ps.setString(6, c.getTargetName());
            ps.setString(7, c.getTargetRole());
            ps.setString(8, c.getComplaintType());
            ps.setString(9, c.getDescription());
            ps.setString(10, c.getStatus() != null ? c.getStatus() : "PENDING");

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.createComplaint: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    public List<Complaint> getAllComplaints() {
        List<Complaint> list = new ArrayList<>();
        String sql = "SELECT complaint_id, booking_id, complainant_id, complainant_name, complainant_role, " +
                     "target_id, target_name, target_role, complaint_type, description, status, admin_notes, created_at " +
                     "FROM complaints ORDER BY complaint_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapComplaint(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.getAllComplaints: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    public List<Complaint> getComplaintsByComplainant(int complainantId) {
        List<Complaint> list = new ArrayList<>();
        String sql = "SELECT complaint_id, booking_id, complainant_id, complainant_name, complainant_role, " +
                     "target_id, target_name, target_role, complaint_type, description, status, admin_notes, created_at " +
                     "FROM complaints WHERE complainant_id = ? ORDER BY complaint_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, complainantId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapComplaint(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.getComplaintsByComplainant: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    public boolean updateComplaintStatus(int complaintId, String status, String adminNotes) {
        String sql = "UPDATE complaints SET status = ?, admin_notes = ? WHERE complaint_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, adminNotes);
            ps.setInt(3, complaintId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.updateComplaintStatus: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    public boolean deleteComplaint(int complaintId) {
        String sql = "DELETE FROM complaints WHERE complaint_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, complaintId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.deleteComplaint: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    public boolean resolveAllPending(String adminNotes) {
        String sql = "UPDATE complaints SET status = 'RESOLVED', admin_notes = ? WHERE status = 'PENDING'";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, adminNotes != null ? adminNotes : "Resolved in bulk by Administrator.");
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.resolveAllPending: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    public boolean clearClosedComplaints() {
        String sql = "DELETE FROM complaints WHERE status IN ('RESOLVED', 'DISMISSED')";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.clearClosedComplaints: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    public boolean resolveComplaintsForTarget(int targetId, String targetRole, String adminNotes) {
        String sql = "UPDATE complaints SET status = 'RESOLVED', admin_notes = ? WHERE target_id = ? AND target_role = ? AND status = 'PENDING'";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, adminNotes != null ? adminNotes : "Resolved: Worker/User dismissed from platform by Admin.");
            ps.setInt(2, targetId);
            ps.setString(3, targetRole);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.resolveComplaintsForTarget: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    public boolean deleteComplaintsForTarget(int targetId, String targetRole) {
        String sql = "DELETE FROM complaints WHERE target_id = ? AND target_role = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, targetId);
            ps.setString(2, targetRole);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("Error in ComplaintDAO.deleteComplaintsForTarget: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }


    private Complaint mapComplaint(ResultSet rs) throws SQLException {
        return new Complaint(
            rs.getInt("complaint_id"),
            rs.getInt("booking_id"),
            rs.getInt("complainant_id"),
            rs.getString("complainant_name"),
            rs.getString("complainant_role"),
            rs.getInt("target_id"),
            rs.getString("target_name"),
            rs.getString("target_role"),
            rs.getString("complaint_type"),
            rs.getString("description"),
            rs.getString("status"),
            rs.getString("admin_notes"),
            rs.getString("created_at")
        );
    }
}
