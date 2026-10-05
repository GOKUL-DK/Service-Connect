USE serviceconnect;

-- Insert Additional Users (Customers and all Provider login accounts)
INSERT IGNORE INTO users (id, name, username, password, role) VALUES
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
(22, 'Saravanan', 'saravanan', 'saravanan123', 'PROVIDER');

-- Insert Additional Services
INSERT IGNORE INTO services (service_id, service_name, description) VALUES
(11, 'Pest Control', 'Termite control, bed bug eradication, and residential pest management'),
(12, 'Solar Panel Service', 'Solar panel cleaning, inverter diagnostics, and rooftop maintenance'),
(13, 'Gardening & Lawn Care', 'Lawn mowing, tree trimming, hedge cutting, and garden landscaping'),
(14, 'CCTV & Smart Security', 'CCTV installation, security camera wiring, and DVR smart setup');

-- Insert Additional Providers
INSERT IGNORE INTO providers (provider_id, name, service_id, phone, latitude, longitude, available_from, available_until, status) VALUES
(114, 'Vikram', 11, '9000000014', 11.0185, 76.9560, '08:00:00', '18:00:00', 'AVAILABLE'),
(115, 'Anand', 12, '9000000015', 11.0190, 76.9585, '09:00:00', '17:00:00', 'AVAILABLE'),
(116, 'Murugan', 13, '9000000016', 11.0165, 76.9545, '07:00:00', '17:00:00', 'AVAILABLE'),
(117, 'Saravanan', 14, '9000000017', 11.0215, 76.9570, '09:00:00', '19:00:00', 'AVAILABLE');

-- Insert Additional Provider Availability
INSERT IGNORE INTO provider_availability (provider_id, available_from, available_until, status) VALUES
(114, '08:00:00', '18:00:00', 'AVAILABLE'),
(115, '09:00:00', '17:00:00', 'AVAILABLE'),
(116, '07:00:00', '17:00:00', 'AVAILABLE'),
(117, '09:00:00', '19:00:00', 'AVAILABLE');

-- Insert Rich Used Services (Bookings across multiple customers and providers)
INSERT INTO bookings (user_id, provider_id, service_id, location_name, latitude, longitude, requested_time, distance, status) VALUES
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
