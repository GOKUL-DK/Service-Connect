package com.serviceconnect.dao;

import com.serviceconnect.model.User;
import com.serviceconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for User entities using plain JDBC.
 */
public class UserDAO {

    /**
     * Authenticates a user with username and password.
     * @return User object if credentials are valid, null otherwise.
     */
    public User authenticate(String username, String password) {
        String sql = "SELECT id, name, username, password, role FROM users WHERE username = ? AND password = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new User(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getString("role")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.authenticate: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Finds a user by ID.
     */
    public User getUserById(int id) {
        String sql = "SELECT id, name, username, password, role FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new User(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getString("role")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.getUserById: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Retrieves all users (for administrative reporting).
     */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, name, username, password, role FROM users ORDER BY id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new User(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getString("role")
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.getAllUsers: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Updates user's personal profile information.
     */
    public boolean updateProfile(int id, String name) {
        String sql = "UPDATE users SET name = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.updateProfile: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    /**
     * Verifies if the provided current password matches the user's stored password.
     */
    public boolean verifyPassword(int id, String currentPassword) {
        String sql = "SELECT id FROM users WHERE id = ? AND password = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setString(2, currentPassword);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.verifyPassword: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, rs);
        }
    }

    /**
     * Updates user's password.
     */
    public boolean updatePassword(int id, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newPassword);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.updatePassword: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }

    /**
     * Checks if a username already exists in the system.
     */
    public boolean isUsernameTaken(String username) {
        String sql = "SELECT id FROM users WHERE LOWER(username) = LOWER(?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username.trim());
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.isUsernameTaken: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, rs);
        }
    }

    /**
     * Registers a new user (CUSTOMER or PROVIDER).
     * @return newly created User object with generated ID, or null on failure.
     */
    public User registerUser(String name, String username, String password, String role) {
        String sql = "INSERT INTO users (name, username, password, role) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, name.trim());
            ps.setString(2, username.trim());
            ps.setString(3, password.trim());
            ps.setString(4, role != null ? role.trim().toUpperCase() : "CUSTOMER");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int newId = rs.getInt(1);
                    return new User(newId, name.trim(), username.trim(), password.trim(), role);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.registerUser: " + e.getMessage());
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Deletes a user from the system by ID (cascades to related records).
     */
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in UserDAO.deleteUser: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(conn, ps, null);
        }
    }
}



