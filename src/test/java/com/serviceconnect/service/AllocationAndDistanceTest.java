package com.serviceconnect.service;

import com.serviceconnect.model.ServiceRule;
import com.serviceconnect.util.DistanceUtil;
import com.serviceconnect.util.XMLRuleParser;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests validating distance calculation, XML DOM parsing, and XPath queries.
 */
public class AllocationAndDistanceTest {

    @Test
    public void testHaversineDistanceCalculation() {
        // Location A (Gandhipuram): 11.0168, 76.9558
        // Arun Kumar (Plumber): 11.0180, 76.9590
        double distance = DistanceUtil.calculateDistance(11.0168, 76.9558, 11.0180, 76.9590);
        assertTrue(distance > 0.3 && distance < 0.5, "Distance should be ~0.37 km, actual: " + distance);

        // Same location distance should be 0.0
        double zeroDist = DistanceUtil.calculateDistance(11.0168, 76.9558, 11.0168, 76.9558);
        assertEquals(0.0, zeroDist, 0.001);
    }

    @Test
    public void testXMLDOMParser() {
        XMLRuleParser parser = XMLRuleParser.getInstance();

        // Validate search rules from XML
        assertEquals(5, parser.getDefaultRadius(), "Default radius should be 5 from XML");
        assertEquals(15, parser.getMaximumRadius(), "Max radius should be 15 from XML");

        // Validate service rules parsed via DOM
        ServiceRule plumbing = parser.getServiceRule("Plumbing");
        assertNotNull(plumbing, "Plumbing rule must exist");
        assertEquals(60, plumbing.getAverageDuration());
        assertEquals(350.0, plumbing.getBaseFee(), 0.01);

        ServiceRule carpentry = parser.getServiceRule("Carpentry");
        assertNotNull(carpentry);
        assertEquals(90, carpentry.getAverageDuration());
    }

    @Test
    public void testXPathEvaluation() {
        XMLRuleParser parser = XMLRuleParser.getInstance();

        String defaultRadiusStr = parser.evaluateXPath("//search/defaultRadius");
        assertEquals("5", defaultRadiusStr.trim());

        String plumbingDuration = parser.evaluateXPath("//service[@name='Plumbing']/averageDuration");
        assertEquals("60", plumbingDuration.trim());
    }
}
