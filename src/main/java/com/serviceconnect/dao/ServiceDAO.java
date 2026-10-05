package com.serviceconnect.dao;

import com.serviceconnect.model.Service;
import com.serviceconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Service catalog operations using plain JDBC.
 */
public class ServiceDAO {

    /**
     * Retrieves all available services from database.
     */
    public List<Service> getAllServices() {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT service_id, service_name, description FROM services ORDER BY service_name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                services.add(new Service(
                    rs.getInt("service_id"),
                    rs.getString("service_name"),
                    rs.getString("description")
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error in ServiceDAO.getAllServices: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return services;
    }

    /**
     * Retrieves service details by service ID.
     */
    public Service getServiceById(int serviceId) {
        String sql = "SELECT service_id, service_name, description FROM services WHERE service_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, serviceId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Service(
                    rs.getInt("service_id"),
                    rs.getString("service_name"),
                    rs.getString("description")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error in ServiceDAO.getServiceById: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Retrieves service details by service name (case-insensitive search).
     */
    public Service getServiceByName(String serviceName) {
        String sql = "SELECT service_id, service_name, description FROM services WHERE LOWER(service_name) = LOWER(?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, serviceName);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Service(
                    rs.getInt("service_id"),
                    rs.getString("service_name"),
                    rs.getString("description")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error in ServiceDAO.getServiceByName: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }
}
