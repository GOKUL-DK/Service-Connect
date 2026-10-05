package com.serviceconnect.service;

import com.serviceconnect.model.ServiceRule;
import com.serviceconnect.util.XMLRuleParser;

/**
 * Service encapsulating XML-configured business rules for services and radius restrictions.
 */
public class XMLRuleService {

    private final XMLRuleParser parser;

    public XMLRuleService() {
        this.parser = XMLRuleParser.getInstance();
    }

    public int getDefaultRadius() {
        return parser.getDefaultRadius();
    }

    public int getMaximumRadius() {
        return parser.getMaximumRadius();
    }

    public int getAverageDuration(String serviceName) {
        ServiceRule rule = parser.getServiceRule(serviceName);
        return rule != null ? rule.getAverageDuration() : 60;
    }

    public double getBaseFee(String serviceName) {
        ServiceRule rule = parser.getServiceRule(serviceName);
        return rule != null ? rule.getBaseFee() : 300.0;
    }

    public String queryRuleByXPath(String xpath) {
        return parser.evaluateXPath(xpath);
    }
}
