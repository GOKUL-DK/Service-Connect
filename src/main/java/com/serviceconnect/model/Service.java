package com.serviceconnect.model;

import java.io.Serializable;

/**
 * Model representing a service category (e.g. Plumbing, Electrical Repair, etc.).
 */
public class Service implements Serializable {
    private static final long serialVersionUID = 1L;

    private int serviceId;
    private String serviceName;
    private String description;

    public Service() {
    }

    public Service(int serviceId, String serviceName, String description) {
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.description = description;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "Service [serviceId=" + serviceId + ", serviceName=" + serviceName + "]";
    }
}
