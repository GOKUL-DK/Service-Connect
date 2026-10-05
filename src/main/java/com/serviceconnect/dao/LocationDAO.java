package com.serviceconnect.dao;

import com.serviceconnect.model.Location;
import com.serviceconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for predefined Locations.
 */
public class LocationDAO {

    /**
     * Retrieves all predefined location points.
     */
    public List<Location> getAllLocations() {
        List<Location> list = new ArrayList<>();
        String sql = "SELECT location_id, location_name, latitude, longitude FROM locations ORDER BY location_name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new Location(
                    rs.getInt("location_id"),
                    rs.getString("location_name"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude")
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error in LocationDAO.getAllLocations: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Retrieves a location by its ID.
     */
    public Location getLocationById(int locationId) {
        String sql = "SELECT location_id, location_name, latitude, longitude FROM locations WHERE location_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, locationId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Location(
                    rs.getInt("location_id"),
                    rs.getString("location_name"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error in LocationDAO.getLocationById: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Retrieves a location by name (e.g., 'Location A').
     */
    public Location getLocationByName(String locationName) {
        String sql = "SELECT location_id, location_name, latitude, longitude FROM locations WHERE LOWER(location_name) = LOWER(?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, locationName);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Location(
                    rs.getInt("location_id"),
                    rs.getString("location_name"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error in LocationDAO.getLocationByName: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }
}
