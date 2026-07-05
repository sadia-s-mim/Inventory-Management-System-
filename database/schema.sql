-- =====================================================================
-- PERFECT CHOICE — Clothing Retail Inventory Management System
-- =====================================================================

CREATE DATABASE IF NOT EXISTS perfect_choice CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE perfect_choice;

-- ---------------------------------------------------------------------
--  ROLES — Admin / Branch Manager / Sales User
-- ---------------------------------------------------------------------
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);
-- ---------------------------------------------------------------------
-- BRANCHES
-- ---------------------------------------------------------------------
CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    phone VARCHAR(30),
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- USERS
-- ---------------------------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    branch_id INT,
    phone VARCHAR(30),
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE SET NULL
);
-- ---------------------------------------------------------------------
-- STOCK_IN_DETAILS 
-- ---------------------------------------------------------------------
CREATE TABLE stock_in_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_in_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
    FOREIGN KEY (stock_in_id) REFERENCES stock_in(stock_in_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- =====================================================================
-- SAMPLE DATA
-- =====================================================================
INSERT INTO branches (branch_name, location, phone) VALUES
('Perfect Choice - Gulshan', 'Gulshan Avenue, Dhaka', '01700000001'),
('Perfect Choice - Uttara', 'Sector 7, Uttara, Dhaka', '01700000002');

-- password 
INSERT INTO users (full_name, email, password, role_id, branch_id, phone) VALUES
('Admin', 'admin@perfectchoice.com', '$2y$10$fP71sE8f.KnPU4UBwtGXIO4xP0ckofw.BJ9zyDOAUSC0mpr16e1Ma', 1, 1, '01710000001'),
('Branch Manager Gulshan', 'manager.gulshan@perfectchoice.com', '$2y$10$hZHYu.AO0Sfsos1CuaEbBuklhTyiL3Fwor2a0ohrp1GlTt3IYjxsm', 2, 1, '01710000002'),
('Sales User Uttara', 'sales.uttara@perfectchoice.com', '$2y$10$hX1KFgIm6kdlOoB1iWQXD.YGL8QCHzLQIVldw2RriiYFjlS6043P6', 3, 2, '01710000003');
INSERT INTO stock_in_details (stock_in_id, product_id, quantity, unit_cost) VALUES
(1, 1, 30, 1200.00),
(1, 2, 18, 1500.00),
(1, 3, 70, 250.00),
(1, 4, 55, 200.00),
(1, 5, 20, 1400.00),
(1, 6, 25, 700.00),
(1, 7, 28, 600.00),
(1, 8, 40, 400.00),
(1, 9, 20, 800.00),
(1, 10, 24, 650.00),
(1, 11, 35, 600.00),
(1, 12, 30, 550.00),
(1, 13, 18, 900.00),
(1, 14, 16, 1100.00),
(1, 15, 22, 500.00),
(2, 1, 15, 1200.00),
(2, 2, 10, 1500.00),
(2, 3, 45, 250.00),
(2, 4, 35, 200.00),
(2, 5, 12, 1400.00),
(2, 6, 14, 700.00),
(2, 7, 16, 600.00),
(2, 8, 22, 400.00),
(2, 9, 10, 800.00),
(2, 10, 14, 650.00),
(2, 11, 20, 600.00),
(2, 12, 18, 550.00),
(2, 13, 9, 900.00),
(2, 14, 8, 1100.00),
(2, 15, 12, 500.00),
(3, 3, 20, 250.00),
(4, 4, 15, 200.00),
(5, 6, 10, 700.00),
(6, 1, 8, 1200.00),
(7, 8, 15, 400.00),
(8, 11, 12, 600.00),
(9, 10, 10, 650.00),
(10, 3, 10, 250.00),
(11, 15, 10, 500.00);

