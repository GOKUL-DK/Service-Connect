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
     * Supports cloud environments (Render, Railway, Docker) via environment variables,
     * System properties, or local fallback.
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        String dbUrl = System.getenv("DB_URL");
        String dbUser = System.getenv("DB_USER");
        String dbPass = System.getenv("DB_PASSWORD");

        // Auto-detect common cloud connection URLs (Railway, Render, Heroku)
        if (dbUrl == null || dbUrl.trim().isEmpty()) {
            String connUrl = System.getenv("DATABASE_URL");
            if (connUrl == null || connUrl.trim().isEmpty()) {
                connUrl = System.getenv("MYSQL_URL");
            }
            if (connUrl == null || connUrl.trim().isEmpty()) {
                connUrl = System.getenv("MYSQL_PUBLIC_URL");
            }

            if (connUrl != null && !connUrl.trim().isEmpty()) {
                connUrl = connUrl.trim();
                if (connUrl.startsWith("mysql://") || connUrl.startsWith("mysql2://")) {
                    try {
                        java.net.URI uri = new java.net.URI(connUrl);
                        String userInfo = uri.getUserInfo();
                        if (userInfo != null && userInfo.contains(":")) {
                            String[] parts = userInfo.split(":", 2);
                            dbUser = parts[0];
                            dbPass = parts[1];
                        }
                        String host = uri.getHost();
                        int port = uri.getPort() == -1 ? 3306 : uri.getPort();
                        String path = uri.getPath(); // /dbname
                        dbUrl = "jdbc:mysql://" + host + ":" + port + path + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                    } catch (Exception e) {
                        System.err.println("Failed to parse cloud database URI: " + e.getMessage());
                    }
                } else if (connUrl.startsWith("jdbc:")) {
                    dbUrl = connUrl;
                }
            }
        }

        // Fallback to System properties, then local defaults
        if (dbUrl == null || dbUrl.trim().isEmpty()) {
            dbUrl = System.getProperty("db.url", URL);
        }
        if (dbUser == null || dbUser.trim().isEmpty()) {
            dbUser = System.getProperty("db.user", USER);
        }
        if (dbPass == null) {
            dbPass = System.getProperty("db.password", PASSWORD);
        }

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
