package com.serviceconnect.util;

import com.serviceconnect.model.ServiceRule;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * Utility parser using Java XML DOM and XPath APIs to parse service_rules.xml.
 * Demonstrates:
 * - DocumentBuilderFactory
 * - DocumentBuilder
 * - Document
 * - NodeList
 * - Element
 * - XPathFactory & XPath expressions
 */
public class XMLRuleParser {

    private static final String XML_FILE_PATH = "service_rules.xml";

    private int defaultRadius = 5;
    private int maximumRadius = 10;
    private final Map<String, ServiceRule> serviceRules = new HashMap<>();

    private static XMLRuleParser instance;
    private Document document;

    private XMLRuleParser() {
        loadAndParseXML();
    }

    public static synchronized XMLRuleParser getInstance() {
        if (instance == null) {
            instance = new XMLRuleParser();
        }
        return instance;
    }

    /**
     * Loads the XML file from the classpath and parses it using Java DOM Parser.
     */
    private void loadAndParseXML() {
        try {
            InputStream is = getClass().getClassLoader().getResourceAsStream(XML_FILE_PATH);
            if (is == null) {
                System.err.println("Warning: " + XML_FILE_PATH + " not found on classpath, using defaults.");
                return;
            }

            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            // Secure XML parsing configuration
            factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            this.document = builder.parse(is);
            this.document.getDocumentElement().normalize();

            // 1. Read <search> parameters using DOM APIs
            NodeList searchNodes = document.getElementsByTagName("search");
            if (searchNodes.getLength() > 0) {
                Element searchElement = (Element) searchNodes.item(0);
                String defRadStr = getTagValue("defaultRadius", searchElement);
                String maxRadStr = getTagValue("maximumRadius", searchElement);

                if (defRadStr != null && !defRadStr.trim().isEmpty()) {
                    this.defaultRadius = Integer.parseInt(defRadStr.trim());
                }
                if (maxRadStr != null && !maxRadStr.trim().isEmpty()) {
                    this.maximumRadius = Integer.parseInt(maxRadStr.trim());
                }
            }

            // 2. Read <service> elements using DOM APIs
            NodeList serviceNodes = document.getElementsByTagName("service");
            for (int i = 0; i < serviceNodes.getLength(); i++) {
                Node node = serviceNodes.item(i);
                if (node.getNodeType() == Node.ELEMENT_NODE) {
                    Element element = (Element) node;
                    String serviceName = element.getAttribute("name");
                    String durationStr = getTagValue("averageDuration", element);
                    String feeStr = getTagValue("baseFee", element);

                    int duration = 60;
                    double fee = 300.0;

                    if (durationStr != null && !durationStr.trim().isEmpty()) {
                        duration = Integer.parseInt(durationStr.trim());
                    }
                    if (feeStr != null && !feeStr.trim().isEmpty()) {
                        fee = Double.parseDouble(feeStr.trim());
                    }

                    ServiceRule rule = new ServiceRule(serviceName, duration, fee);
                    serviceRules.put(serviceName.toLowerCase(), rule);
                }
            }

        } catch (Exception e) {
            System.err.println("Error parsing XML rules: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Demonstrates XPath expression evaluation on XML configuration.
     * @param expression XPath query string (e.g. "//search/defaultRadius")
     * @return String value resulting from XPath query
     */
    public String evaluateXPath(String expression) {
        if (this.document == null) {
            return "";
        }
        try {
            XPath xPath = XPathFactory.newInstance().newXPath();
            return (String) xPath.compile(expression).evaluate(this.document, XPathConstants.STRING);
        } catch (Exception e) {
            System.err.println("XPath evaluation error: " + e.getMessage());
            return "";
        }
    }

    private String getTagValue(String tag, Element element) {
        NodeList nodeList = element.getElementsByTagName(tag);
        if (nodeList.getLength() > 0 && nodeList.item(0) != null) {
            return nodeList.item(0).getTextContent();
        }
        return null;
    }

    public int getDefaultRadius() {
        return defaultRadius;
    }

    public int getMaximumRadius() {
        return maximumRadius;
    }

    public ServiceRule getServiceRule(String serviceName) {
        if (serviceName == null) return null;
        return serviceRules.get(serviceName.toLowerCase());
    }

    public Map<String, ServiceRule> getAllServiceRules() {
        return serviceRules;
    }
}
