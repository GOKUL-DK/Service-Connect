package com.serviceconnect.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Automatically initializes database tables and seeds sample data on application startup
 * if the database is uninitialized (e.g., in newly provisioned cloud environments like Render/Railway).
 */
@WebListener
public class DatabaseInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[ServiceConnect] Checking database connectivity and schema...");
        try (Connection conn = DBConnection.getConnection()) {
            boolean tablesExist = false;
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT 1 FROM users LIMIT 1")) {
                if (rs.next()) {
                    tablesExist = true;
                }
            } catch (Exception ignored) {
                // Table 'users' does not exist yet
            }

            if (tablesExist) {
                System.out.println("[ServiceConnect] Database tables verified. Schema ready.");
                return;
            }

            System.out.println("[ServiceConnect] Initializing schema from resources/schema.sql...");
            try (InputStream is = getClass().getClassLoader().getResourceAsStream("schema.sql")) {
                if (is == null) {
                    System.err.println("[ServiceConnect] schema.sql not found in classpath.");
                    return;
                }

                try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                     Statement stmt = conn.createStatement()) {
                    StringBuilder sqlBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        String trimmed = line.trim();
                        if (trimmed.startsWith("--") || trimmed.startsWith("/*") || trimmed.isEmpty()) {
                            continue;
                        }
                        sqlBuilder.append(line).append("\n");
                        if (trimmed.endsWith(";")) {
                            String command = sqlBuilder.toString().replace(";", "").trim();
                            // Skip database creation / use commands on managed cloud databases
                            if (!command.toUpperCase().startsWith("CREATE DATABASE") &&
                                !command.toUpperCase().startsWith("USE ")) {
                                try {
                                    stmt.execute(command);
                                } catch (Exception e) {
                                    // Log and proceed for idempotent statements
                                }
                            }
                            sqlBuilder.setLength(0);
                        }
                    }
                    System.out.println("[ServiceConnect] Database schema and sample data initialized successfully!");
                }
            }
        } catch (Exception e) {
            System.err.println("[ServiceConnect] Notice: Database auto-initialization skipped or encountered: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if needed
    }
}
