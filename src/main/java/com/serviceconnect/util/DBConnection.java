package com.serviceconnect.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Utility class for managing plain JDBC connections to the MySQL database.
 * No ORM / Hibernate used, strictly adheres to pure JDBC for lab demonstration.
 */
public class DBConnection {

    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/serviceconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata";
    private static final String USER = "root";
    private static final String PASSWORD = "root"; // Update if your local MySQL root password differs

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found in classpath: " + e.getMessage());
        }
    }

    /**
     * Obtains a new JDBC Connection from DriverManager.
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        // Allows overriding via System property if needed in different lab environments
        String dbUrl = System.getProperty("db.url", URL);
        String dbUser = System.getProperty("db.user", USER);
        String dbPass = System.getProperty("db.password", PASSWORD);
        return DriverManager.getConnection(dbUrl, dbUser, dbPass);
    }

    /**
     * Safely closes JDBC resources to prevent memory or connection leaks.
     */
    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
        } catch (SQLException ignored) {}
        try {
            if (stmt != null) stmt.close();
        } catch (SQLException ignored) {}
        try {
            if (conn != null) conn.close();
        } catch (SQLException ignored) {}
    }
}
