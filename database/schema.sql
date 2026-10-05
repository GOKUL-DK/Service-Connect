-- ========================================================
-- ServiceConnect Database Schema & Predefined Dataset
-- Compatible with MySQL 8.0+
-- ========================================================

CREATE DATABASE IF NOT EXISTS serviceconnect;
USE serviceconnect;

-- Drop tables in reverse foreign key order if re-executing
DROP TABLE IF EXISTS provider_availability;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS providers;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS users;

-- 1. USERS TABLE
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL
);

-- 2. SERVICES TABLE
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- 3. LOCATIONS TABLE (Predefined landmarks with GPS coordinates)
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL
);

-- 4. PROVIDERS TABLE
CREATE TABLE providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    service_id INT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    available_from TIME NOT NULL,
    available_until TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    CONSTRAINT fk_provider_service FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE
);

-- 5. BOOKINGS TABLE
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    service_id INT NOT NULL,
    location_name VARCHAR(100) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    requested_time TIME NOT NULL,
    distance DOUBLE NOT NULL,
    status VARCHAR(20) DEFAULT 'REQUESTED',
    otp VARCHAR(10) DEFAULT '1234',
    is_emergency BOOLEAN DEFAULT FALSE,
    total_amount DOUBLE DEFAULT 0.0,
    rating INT DEFAULT 0,
    review_comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_service FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE
);

-- 6. BOOKING MESSAGES TABLE (Live In-App Chat)
CREATE TABLE booking_messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    sender_id INT NOT NULL,
    sender_name VARCHAR(100) NOT NULL,
    sender_role VARCHAR(20) NOT NULL,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_msg_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- 7. PROVIDER AVAILABILITY TABLE
CREATE TABLE provider_availability (
    availability_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    available_from TIME NOT NULL,
    available_until TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    CONSTRAINT fk_availability_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE CASCADE
);

-- 8. COMPLAINTS & GRIEVANCES TABLE
CREATE TABLE complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT DEFAULT NULL,
    complainant_id INT NOT NULL,
    complainant_name VARCHAR(100) NOT NULL,
    complainant_role VARCHAR(20) NOT NULL,
    target_id INT NOT NULL,
    target_name VARCHAR(100) NOT NULL,
    target_role VARCHAR(20) NOT NULL,
    complaint_type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    admin_notes TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- PREDEFINED DATA INSERTIONS
-- ========================================================

-- Insert Predefined Users (Customers, Providers, and Admin)
INSERT INTO users (id, name, username, password, role) VALUES
(1, 'Gokul', 'user1', 'user123', 'CUSTOMER'),
(2, 'Priya', 'user2', 'user123', 'CUSTOMER'),
(3, 'Arun Kumar', 'arun', 'arun123', 'PROVIDER'),
(4, 'Bala Kumar', 'bala', 'bala123', 'PROVIDER'),
(5, 'Administrator', 'admin', 'admin123', 'ADMIN'),
(6, 'Ananya Sharma', 'user3', 'user123', 'CUSTOMER'),
(7, 'Kavitha Nair', 'user4', 'user123', 'CUSTOMER'),
(8, 'Rohan Verma', 'user5', 'user123', 'CUSTOMER'),
(9, 'Deepak Raj', 'user6', 'user123', 'CUSTOMER'),
(10, 'Ravi', 'ravi', 'ravi123', 'PROVIDER'),
(11, 'Karthik', 'karthik', 'karthik123', 'PROVIDER'),
(12, 'Suresh', 'suresh', 'suresh123', 'PROVIDER'),
(13, 'Manoj', 'manoj', 'manoj123', 'PROVIDER'),
(14, 'Vijay', 'vijay', 'vijay123', 'PROVIDER'),
(15, 'Prakash', 'prakash', 'prakash123', 'PROVIDER'),
(16, 'Ramesh', 'ramesh', 'ramesh123', 'PROVIDER'),
(17, 'Ajay', 'ajay', 'ajay123', 'PROVIDER'),
(18, 'Dinesh', 'dinesh', 'dinesh123', 'PROVIDER'),
(19, 'Vikram', 'vikram', 'vikram123', 'PROVIDER'),
(20, 'Anand', 'anand', 'anand123', 'PROVIDER'),
(21, 'Murugan', 'murugan', 'murugan123', 'PROVIDER'),
(22, 'Saravanan', 'saravanan', 'saravanan123', 'PROVIDER'),
(23, 'Alex Carter', 'customer', 'customer123', 'CUSTOMER'),
(24, 'Arun Kumar', 'provider', 'provider123', 'PROVIDER'),
(25, 'Arun Kumar', 'plumber', 'plumber123', 'PROVIDER');

-- Insert Predefined Services (14 Services)
INSERT INTO services (service_id, service_name, description) VALUES
(1, 'Plumbing', 'Pipe repairs, leakage fix, taps and sanitary installations'),
(2, 'Electrical Repair', 'Wiring, switches, fuse repair, and electrical fixtures'),
(3, 'Carpentry', 'Furniture repair, wood fittings, doors, and cabinet woodwork'),
(4, 'AC Service', 'Air conditioner maintenance, gas refill, and servicing'),
(5, 'Appliance Repair', 'Washing machine, refrigerator, and microwave repairs'),
(6, 'Computer Repair', 'Desktop/Laptop OS issues, hardware repair, and upgrades'),
(7, 'Painting', 'Interior/exterior wall painting, waterproofing, and touch-ups'),
(8, 'Cleaning', 'Deep home cleaning, kitchen scrubbing, and sanitization'),
(9, 'Vehicle Repair', 'Two-wheeler and four-wheeler breakdown and regular service'),
(10, 'Home Maintenance', 'General handyman, masonry, drilling, and fixture fixes'),
(11, 'Pest Control', 'Termite control, bed bug eradication, and residential pest management'),
(12, 'Solar Panel Service', 'Solar panel cleaning, inverter diagnostics, and rooftop maintenance'),
(13, 'Gardening & Lawn Care', 'Lawn mowing, tree trimming, hedge cutting, and garden landscaping'),
(14, 'CCTV & Smart Security', 'CCTV installation, security camera wiring, and DVR smart setup');

-- Insert Predefined Locations
INSERT INTO locations (location_id, location_name, latitude, longitude) VALUES
(1, 'Location A', 11.0168, 76.9558),
(2, 'Location B', 11.0085, 76.9450),
(3, 'Location C', 11.0250, 77.0100),
(4, 'Location D', 11.0280, 76.9420),
(5, 'Location E', 11.0797, 76.9997);

-- Insert Predefined Service Providers
INSERT INTO providers (provider_id, name, service_id, phone, latitude, longitude, available_from, available_until, status) VALUES
(101, 'Arun Kumar', 1, '9000000001', 11.0180, 76.9590, '09:00:00', '17:00:00', 'AVAILABLE'),
(102, 'Bala Kumar', 1, '9000000002', 11.0250, 76.9500, '10:00:00', '18:00:00', 'AVAILABLE'),
(103, 'Kumar', 1, '9000000003', 11.0790, 76.9990, '08:00:00', '16:00:00', 'AVAILABLE'),
(104, 'Suresh Plumber', 1, '9000000004', 11.0190, 76.9570, '09:00:00', '17:00:00', 'BUSY'),
(105, 'Ravi', 2, '9000000005', 11.0175, 76.9565, '08:30:00', '17:30:00', 'AVAILABLE'),
(106, 'Karthik', 3, '9000000006', 11.0160, 76.9540, '09:00:00', '18:00:00', 'AVAILABLE'),
(107, 'Suresh', 4, '9000000007', 11.0200, 76.9580, '09:00:00', '19:00:00', 'AVAILABLE'),
(108, 'Manoj', 5, '9000000008', 11.0150, 76.9520, '10:00:00', '17:00:00', 'AVAILABLE'),
(109, 'Vijay', 6, '9000000009', 11.0195, 76.9575, '09:00:00', '18:00:00', 'AVAILABLE'),
(110, 'Prakash', 7, '9000000010', 11.0220, 76.9610, '08:00:00', '17:00:00', 'AVAILABLE'),
(111, 'Ramesh', 8, '900000011', 11.0140, 76.9530, '07:00:00', '16:00:00', 'AVAILABLE'),
(112, 'Ajay', 9, '9000000012', 11.0210, 76.9560, '09:00:00', '19:00:00', 'AVAILABLE'),
(113, 'Dinesh', 10, '9000000013', 11.0170, 76.9550, '08:00:00', '18:00:00', 'AVAILABLE'),
(114, 'Vikram', 11, '9000000014', 11.0185, 76.9560, '08:00:00', '18:00:00', 'AVAILABLE'),
(115, 'Anand', 12, '9000000015', 11.0190, 76.9585, '09:00:00', '17:00:00', 'AVAILABLE'),
(116, 'Murugan', 13, '9000000016', 11.0165, 76.9545, '07:00:00', '17:00:00', 'AVAILABLE'),
(117, 'Saravanan', 14, '9000000017', 11.0215, 76.9570, '09:00:00', '19:00:00', 'AVAILABLE');

-- Insert Initial Provider Availability
INSERT INTO provider_availability (provider_id, available_from, available_until, status) VALUES
(101, '09:00:00', '17:00:00', 'AVAILABLE'),
(102, '10:00:00', '18:00:00', 'AVAILABLE'),
(103, '08:00:00', '16:00:00', 'AVAILABLE'),
(104, '09:00:00', '17:00:00', 'BUSY'),
(105, '08:30:00', '17:30:00', 'AVAILABLE'),
(106, '09:00:00', '18:00:00', 'AVAILABLE'),
(107, '09:00:00', '19:00:00', 'AVAILABLE'),
(108, '10:00:00', '17:00:00', 'AVAILABLE'),
(109, '09:00:00', '18:00:00', 'AVAILABLE'),
(110, '08:00:00', '17:00:00', 'AVAILABLE'),
(111, '07:00:00', '16:00:00', 'AVAILABLE'),
(112, '09:00:00', '19:00:00', 'AVAILABLE'),
(113, '08:00:00', '18:00:00', 'AVAILABLE'),
(114, '08:00:00', '18:00:00', 'AVAILABLE'),
(115, '09:00:00', '17:00:00', 'AVAILABLE'),
(116, '07:00:00', '17:00:00', 'AVAILABLE'),
(117, '09:00:00', '19:00:00', 'AVAILABLE');

-- Insert Predefined Bookings / Used Services (Past and Active across Customers and Providers)
INSERT INTO bookings (user_id, provider_id, service_id, location_name, latitude, longitude, requested_time, distance, status) VALUES
(1, 101, 1, 'Location A', 11.0168, 76.9558, '11:00:00', 0.37, 'COMPLETED'),
(1, 105, 2, 'Location A', 11.0168, 76.9558, '14:00:00', 0.45, 'IN_PROGRESS'),
(1, 107, 4, 'Location A', 11.0168, 76.9558, '16:30:00', 0.85, 'ACCEPTED'),
(2, 106, 3, 'Location B', 11.0085, 76.9450, '10:15:00', 0.62, 'COMPLETED'),
(2, 111, 8, 'Location B', 11.0085, 76.9450, '13:00:00', 0.51, 'ACCEPTED'),
(6, 108, 5, 'Location C', 11.0250, 77.0100, '09:30:00', 0.70, 'COMPLETED'),
(6, 110, 7, 'Location C', 11.0250, 77.0100, '15:00:00', 1.10, 'REQUESTED'),
(7, 109, 6, 'Location D', 11.0280, 76.9420, '11:30:00', 0.58, 'COMPLETED'),
(7, 114, 11, 'Location D', 11.0280, 76.9420, '12:00:00', 0.42, 'ACCEPTED'),
(8, 112, 9, 'Location E', 11.0797, 76.9997, '10:00:00', 0.82, 'COMPLETED'),
(8, 115, 12, 'Location E', 11.0797, 76.9997, '14:30:00', 0.95, 'IN_PROGRESS'),
(9, 113, 10, 'Location A', 11.0168, 76.9558, '11:00:00', 0.35, 'COMPLETED'),
(9, 117, 14, 'Location A', 11.0168, 76.9558, '16:00:00', 0.75, 'ACCEPTED');
