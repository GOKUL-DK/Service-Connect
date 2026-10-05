package com.serviceconnect.model;

import java.io.Serializable;

/**
 * Model representing service configuration parsed from XML rules.
 */
public class ServiceRule implements Serializable {
    private static final long serialVersionUID = 1L;

    private String serviceName;
    private int averageDuration; // in minutes
    private double baseFee;

    public ServiceRule() {
    }

    public ServiceRule(String serviceName, int averageDuration, double baseFee) {
        this.serviceName = serviceName;
        this.averageDuration = averageDuration;
        this.baseFee = baseFee;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public int getAverageDuration() {
        return averageDuration;
    }

    public void setAverageDuration(int averageDuration) {
        this.averageDuration = averageDuration;
    }

    public double getBaseFee() {
        return baseFee;
    }

    public void setBaseFee(double baseFee) {
        this.baseFee = baseFee;
    }

    @Override
    public String toString() {
        return "ServiceRule [serviceName=" + serviceName + ", duration=" + averageDuration + " mins, baseFee=" + baseFee + "]";
    }
}
