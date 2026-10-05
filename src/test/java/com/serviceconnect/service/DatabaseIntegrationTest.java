package com.serviceconnect.service;

import com.serviceconnect.dao.ComplaintDAO;
import com.serviceconnect.dao.ProviderDAO;
import com.serviceconnect.dao.UserDAO;
import com.serviceconnect.model.Complaint;
import com.serviceconnect.model.Provider;
import com.serviceconnect.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class DatabaseIntegrationTest {

    @BeforeEach
    public void setUp() {
        try {
            ProviderDAO pDao = new ProviderDAO();
            pDao.updateStatus(101, "AVAILABLE");
            pDao.updateStatus(104, "BUSY");
        } catch (Exception ignored) {}
    }

    @Test
    public void testUserAuthentication() {
        UserDAO dao = new UserDAO();
        User customer = dao.authenticate("user1", "user123");
        assertNotNull(customer, "user1 should authenticate successfully");
        assertEquals("CUSTOMER", customer.getRole());
        assertEquals("Gokul", customer.getName());

        User provider = dao.authenticate("arun", "arun123");
        assertNotNull(provider, "arun should authenticate successfully");
        assertEquals("PROVIDER", provider.getRole());

        User invalid = dao.authenticate("invalid", "wrongpass");
        assertNull(invalid, "Invalid credentials should return null");
    }

    @Test
    public void testProviderAllocationAlgorithm() {
        ProviderAllocationService service = new ProviderAllocationService();
        // Search for Plumbing near Location A (11.0168, 76.9558), radius = 5.0 km, time = 11:00 AM
        List<Provider> matches = service.findSuitableProviders("Plumbing", 11.0168, 76.9558, 5.0, "11:00");

        assertNotNull(matches, "Matches list should not be null");
        assertFalse(matches.isEmpty(), "Should find qualifying plumbing providers within 5 km");

        // First provider must be Arun Kumar (~0.37 km, closest)
        Provider first = matches.get(0);
        assertEquals("Arun Kumar", first.getName());
        assertTrue(first.getDistance() < 1.0, "Arun Kumar should be < 1.0 km away");

        // Second provider must be Bala Kumar (~1.12 km)
        if (matches.size() > 1) {
            Provider second = matches.get(1);
            assertEquals("Bala Kumar", second.getName());
            assertTrue(second.getDistance() > first.getDistance(), "Results must be sorted by distance ascending");
        }

        // Verify that Kumar (~8.3 km) was filtered out by the 5 km radius
        boolean containsFarProvider = matches.stream().anyMatch(p -> "Kumar".equals(p.getName()));
        assertFalse(containsFarProvider, "Kumar (~8.3 km) must be excluded from a 5 km radius search");
    }

    @Test
    public void testTwoWayComplaintLifecycle() {
        ComplaintDAO complaintDAO = new ComplaintDAO();

        // 1. Customer lodges complaint about a worker
        Complaint c1 = new Complaint();
        c1.setBookingId(1);
        c1.setComplainantId(1);
        c1.setComplainantName("Gokul");
        c1.setComplainantRole("CUSTOMER");
        c1.setTargetId(101);
        c1.setTargetName("Arun Kumar");
        c1.setTargetRole("PROVIDER");
        c1.setComplaintType("Late Arrival");
        c1.setDescription("Technician arrived 45 minutes past the scheduled time slot.");
        c1.setStatus("PENDING");

        boolean created1 = complaintDAO.createComplaint(c1);
        assertTrue(created1, "Customer complaint should be logged in database");

        // 2. Worker lodges complaint about a customer
        Complaint c2 = new Complaint();
        c2.setBookingId(1);
        c2.setComplainantId(2);
        c2.setComplainantName("Arun Kumar");
        c2.setComplainantRole("PROVIDER");
        c2.setTargetId(1);
        c2.setTargetName("Gokul");
        c2.setTargetRole("CUSTOMER");
        c2.setComplaintType("Customer Abusive Behavior");
        c2.setDescription("Customer used foul language regarding service charges.");
        c2.setStatus("PENDING");

        boolean created2 = complaintDAO.createComplaint(c2);
        assertTrue(created2, "Worker complaint should be logged in database");

        // 3. Admin receives and views all complaints
        List<Complaint> allComplaints = complaintDAO.getAllComplaints();
        assertNotNull(allComplaints);
        assertFalse(allComplaints.isEmpty());

        Complaint latest = allComplaints.get(0);
        assertTrue(latest.getComplaintId() > 0);

        // 4. Admin updates status with resolution notes
        boolean updated = complaintDAO.updateComplaintStatus(latest.getComplaintId(), "RESOLVED", "Mediation completed by administrator.");
        assertTrue(updated, "Admin should be able to resolve grievance");

        // Cleanup all test complaints to prevent database pollution
        for (Complaint c : complaintDAO.getAllComplaints()) {
            if ("Late Arrival".equals(c.getComplaintType()) || "Customer Abusive Behavior".equals(c.getComplaintType())) {
                complaintDAO.deleteComplaint(c.getComplaintId());
            }
        }
    }

    @Test
    public void testUserProfileAndSecurityPassword() {
        UserDAO userDAO = new UserDAO();
        User testUser = userDAO.getUserById(1);
        assertNotNull(testUser);

        String originalName = testUser.getName();

        // 1. Edit personal profile information
        boolean nameUpdated = userDAO.updateProfile(1, "Gokul Test Name");
        assertTrue(nameUpdated, "User profile name should update successfully");

        User updatedUser = userDAO.getUserById(1);
        assertEquals("Gokul Test Name", updatedUser.getName());

        // 2. Password verification
        assertTrue(userDAO.verifyPassword(1, "user123"), "Current password check should succeed");
        assertFalse(userDAO.verifyPassword(1, "wrongpass"), "Incorrect current password check should fail");

        // 3. Change password
        boolean passChanged = userDAO.updatePassword(1, "newpass456");
        assertTrue(passChanged, "Password update should succeed");
        assertTrue(userDAO.verifyPassword(1, "newpass456"), "New password should be verified");

        // 4. Restore original credentials to keep tests idempotent
        userDAO.updateProfile(1, originalName);
        userDAO.updatePassword(1, "user123");
        assertTrue(userDAO.verifyPassword(1, "user123"), "Original password should be restored");
    }
}
