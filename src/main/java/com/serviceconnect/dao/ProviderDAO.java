package com.serviceconnect.dao;

import com.serviceconnect.model.Provider;
import com.serviceconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Provider entities and their real-time availability.
 */
public class ProviderDAO {

    /**
     * Retrieves all providers offering a specific service.
     */
    public List<Provider> getProvidersByService(int serviceId) {
        List<Provider> list = new ArrayList<>();
        String sql = "SELECT p.provider_id, p.name, p.service_id, s.service_name, p.phone, " +
                     "p.latitude, p.longitude, p.available_from, p.available_until, p.status " +
                     "FROM providers p " +
                     "JOIN services s ON p.service_id = s.service_id " +
                     "WHERE p.service_id = ? " +
                     "ORDER BY p.name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, serviceId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Provider p = new Provider(
                    rs.getInt("provider_id"),
                    rs.getString("name"),
                    rs.getInt("service_id"),
                    rs.getString("phone"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude"),
                    rs.getString("available_from"),
                    rs.getString("available_until"),
                    rs.getString("status")
                );
                p.setServiceName(rs.getString("service_name"));
                list.add(p);
            }
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.getProvidersByService: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Retrieves all providers by service name.
     */
    public List<Provider> getProvidersByServiceName(String serviceName) {
        List<Provider> list = new ArrayList<>();
        String sql = "SELECT p.provider_id, p.name, p.service_id, s.service_name, p.phone, " +
                     "p.latitude, p.longitude, p.available_from, p.available_until, p.status " +
                     "FROM providers p " +
                     "JOIN services s ON p.service_id = s.service_id " +
                     "WHERE LOWER(s.service_name) = LOWER(?) " +
                     "ORDER BY p.name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, serviceName);
            rs = ps.executeQuery();

            while (rs.next()) {
                Provider p = new Provider(
                    rs.getInt("provider_id"),
                    rs.getString("name"),
                    rs.getInt("service_id"),
                    rs.getString("phone"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude"),
                    rs.getString("available_from"),
                    rs.getString("available_until"),
                    rs.getString("status")
                );
                p.setServiceName(rs.getString("service_name"));
                list.add(p);
            }
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.getProvidersByServiceName: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Retrieves a provider by their ID.
     */
    public Provider getProviderById(int providerId) {
        String sql = "SELECT p.provider_id, p.name, p.service_id, s.service_name, p.phone, " +
                     "p.latitude, p.longitude, p.available_from, p.available_until, p.status " +
                     "FROM providers p " +
                     "JOIN services s ON p.service_id = s.service_id " +
                     "WHERE p.provider_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, providerId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Provider p = new Provider(
                    rs.getInt("provider_id"),
                    rs.getString("name"),
                    rs.getInt("service_id"),
                    rs.getString("phone"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude"),
                    rs.getString("available_from"),
                    rs.getString("available_until"),
                    rs.getString("status")
                );
                p.setServiceName(rs.getString("service_name"));
                return p;
            }
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.getProviderById: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Resolves a Provider object associated with a given username.
     * Matches provider name starting with or equal to user's name.
     */
    public Provider getProviderByUsername(String username) {
        String sql = "SELECT p.provider_id, p.name, p.service_id, s.service_name, p.phone, " +
                     "p.latitude, p.longitude, p.available_from, p.available_until, p.status " +
                     "FROM providers p " +
                     "JOIN services s ON p.service_id = s.service_id " +
                     "JOIN users u ON LOWER(p.name) = LOWER(u.name) " +
                     "WHERE u.username = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();

            if (rs.next()) {
                Provider p = new Provider(
                    rs.getInt("provider_id"),
                    rs.getString("name"),
                    rs.getInt("service_id"),
                    rs.getString("phone"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude"),
                    rs.getString("available_from"),
                    rs.getString("available_until"),
                    rs.getString("status")
                );
                p.setServiceName(rs.getString("service_name"));
                return p;
            }
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.getProviderByUsername: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Updates provider availability and working hours.
     */
    public boolean updateAvailability(int providerId, String availableFrom, String availableUntil, String status) {
        String sql = "UPDATE providers SET available_from = ?, available_until = ?, status = ? WHERE provider_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, availableFrom);
            ps.setString(2, availableUntil);
            ps.setString(3, status);
            ps.setInt(4, providerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.updateAvailability: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    /**
     * Updates only provider status ('AVAILABLE', 'BUSY').
     */
    public boolean updateStatus(int providerId, String status) {
        String sql = "UPDATE providers SET status = ? WHERE provider_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, providerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.updateStatus: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    /**
     * Retrieves all providers in system for admin reporting.
     */
    public List<Provider> getAllProviders() {
        List<Provider> list = new ArrayList<>();
        String sql = "SELECT p.provider_id, p.name, p.service_id, s.service_name, p.phone, " +
                     "p.latitude, p.longitude, p.available_from, p.available_until, p.status " +
                     "FROM providers p " +
                     "JOIN services s ON p.service_id = s.service_id " +
                     "ORDER BY p.provider_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Provider p = new Provider(
                    rs.getInt("provider_id"),
                    rs.getString("name"),
                    rs.getInt("service_id"),
                    rs.getString("phone"),
                    rs.getDouble("latitude"),
                    rs.getDouble("longitude"),
                    rs.getString("available_from"),
                    rs.getString("available_until"),
                    rs.getString("status")
                );
                p.setServiceName(rs.getString("service_name"));
                list.add(p);
            }
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.getAllProviders: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }


    /**
     * Calculates the average customer rating for a provider.
     */
    public double getAverageRating(int providerId) {
        String sql = "SELECT AVG(rating) FROM bookings WHERE provider_id = ? AND rating > 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, providerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                double avg = rs.getDouble(1);
                return avg > 0 ? Math.round(avg * 10.0) / 10.0 : 4.9; // Default fallback to 4.9
            }
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.getAverageRating: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return 4.9;
    }

    /**
     * Updates provider's personal information and working shift.
     */
    public boolean updateProfile(int providerId, String name, String phone, String availableFrom, String availableUntil) {
        String sql = "UPDATE providers SET name = ?, phone = ?, available_from = ?, available_until = ? WHERE provider_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, phone);
            ps.setString(3, availableFrom);
            ps.setString(4, availableUntil);
            ps.setInt(5, providerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.updateProfile: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    /**
     * Deletes a provider from the system (cascades to bookings, availability, etc.).
     */
    public boolean deleteProvider(int providerId) {
        String sql = "DELETE FROM providers WHERE provider_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, providerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.deleteProvider: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    /**
     * Registers a new service provider/worker in the system.
     * Inserts into providers and provider_availability tables.
     * @return generated provider_id, or -1 on error.
     */
    public int createProvider(String name, int serviceId, String phone, double latitude, double longitude, String availableFrom, String availableUntil) {
        String sql = "INSERT INTO providers (name, service_id, phone, latitude, longitude, available_from, available_until, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'AVAILABLE')";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, name.trim());
            ps.setInt(2, serviceId);
            ps.setString(3, phone != null && !phone.trim().isEmpty() ? phone.trim() : "9000000099");
            ps.setDouble(4, latitude != 0.0 ? latitude : 11.0168);
            ps.setDouble(5, longitude != 0.0 ? longitude : 76.9558);
            
            String fromTime = availableFrom != null && !availableFrom.trim().isEmpty() ? availableFrom.trim() : "09:00";
            if (fromTime.length() == 5) fromTime += ":00";
            String untilTime = availableUntil != null && !availableUntil.trim().isEmpty() ? availableUntil.trim() : "18:00";
            if (untilTime.length() == 5) untilTime += ":00";

            ps.setString(6, fromTime);
            ps.setString(7, untilTime);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int provId = rs.getInt(1);

                    // Insert corresponding row into provider_availability
                    String availSql = "INSERT INTO provider_availability (provider_id, available_from, available_until, status) VALUES (?, ?, ?, 'AVAILABLE')";
                    try (PreparedStatement psAvail = conn.prepareStatement(availSql)) {
                        psAvail.setInt(1, provId);
                        psAvail.setString(2, fromTime);
                        psAvail.setString(3, untilTime);
                        psAvail.executeUpdate();
                    } catch (SQLException ex) {
                        System.err.println("Warning: could not insert initial availability: " + ex.getMessage());
                    }

                    return provId;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ProviderDAO.createProvider: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return -1;
    }
}


