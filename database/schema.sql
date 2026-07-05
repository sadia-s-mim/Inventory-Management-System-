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
-- CATEGORIES — self-referencing tree (Gender > Clothing/Shoes > Type)
-- ---------------------------------------------------------------------
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id INT DEFAULT NULL,
    cat_level TINYINT NOT NULL DEFAULT 1,  -- 1=Gender, 2=Group, 3=Type
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- SUPPLIERS
-- ---------------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(150),
    address VARCHAR(255),
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- STOCK_IN 
-- ---------------------------------------------------------------------
CREATE TABLE stock_in (
    stock_in_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    branch_id INT NOT NULL,
    user_id INT NOT NULL,
    reference_no VARCHAR(50),
    stock_in_date DATE NOT NULL,
    total_cost DECIMAL(12,2) DEFAULT 0,
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
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

-- ---------------------------------------------------------------------
--STOCK_OUT 
-- ---------------------------------------------------------------------
CREATE TABLE stock_out (
    stock_out_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    user_id INT NOT NULL,
    reference_no VARCHAR(50),
    stock_out_date DATE NOT NULL,
    total_amount DECIMAL(12,2) DEFAULT 0,
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------
--STOCK_OUT_DETAILS 
-- ---------------------------------------------------------------------
CREATE TABLE stock_out_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_out_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (stock_out_id) REFERENCES stock_out(stock_out_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ---------------------------------------------------------------------
-- SETTINGS 
-- ---------------------------------------------------------------------
CREATE TABLE settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value VARCHAR(255)
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


-- Categories: Level 1 Gender, Level 2 Group, Level 3 Type
INSERT INTO categories (category_name, parent_id, cat_level) VALUES
('Female', NULL, 1),
('Male', NULL, 1);

INSERT INTO categories (category_name, parent_id, cat_level) VALUES
('Clothing', 1, 2),
('Shoes', 1, 2),
('Clothing', 2, 2),
('Shoes', 2, 2);

INSERT INTO categories (category_name, parent_id, cat_level) VALUES
('Abaya', 3, 3),
('Hijab', 3, 3),
('Burqa', 3, 3),
('Kurti', 3, 3),
('Tops', 3, 3),
('Heels', 4, 3),
('Flats', 4, 3),
('Shirt', 5, 3),
('Panjabi', 5, 3),
('Loafers', 6, 3),
('Sandals', 6, 3);

-- Stock In:
INSERT INTO stock_in (supplier_id, branch_id, user_id, reference_no, stock_in_date, total_cost, notes) VALUES
(1, 1, 1, 'SI-OPEN-B1', DATE_SUB(CURDATE(), INTERVAL 20 DAY), 283700.00, 'Opening balance stock'),
(1, 2, 1, 'SI-OPEN-B2', DATE_SUB(CURDATE(), INTERVAL 20 DAY), 158150.00, 'Opening balance stock');

-- Stock In:
INSERT INTO stock_in (supplier_id, branch_id, user_id, reference_no, stock_in_date, total_cost, notes) VALUES
(1, 1, 1, 'SI-20260625-B1', DATE_SUB(CURDATE(), INTERVAL 9 DAY), 5000.00, 'Restock delivery'),
(1, 2, 2, 'SI-20260625-B2', DATE_SUB(CURDATE(), INTERVAL 9 DAY), 3000.00, 'Restock delivery'),
(1, 1, 1, 'SI-20260628-B1', DATE_SUB(CURDATE(), INTERVAL 6 DAY), 7000.00, 'Restock delivery'),
(1, 2, 2, 'SI-20260630-B2', DATE_SUB(CURDATE(), INTERVAL 4 DAY), 9600.00, 'Restock delivery'),
(1, 1, 1, 'SI-20260701-B1', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 6000.00, 'Restock delivery'),
(1, 2, 2, 'SI-20260702-B2', DATE_SUB(CURDATE(), INTERVAL 2 DAY), 7200.00, 'Restock delivery'),
(2, 1, 1, 'SI-20260703-B1', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 6500.00, 'Restock delivery'),
(1, 2, 2, 'SI-20260703-B2', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 2500.00, 'Restock delivery'),
(2, 1, 1, 'SI-20260704-B1', CURDATE(), 5000.00, 'Restock delivery');

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



-- Stock Out: 
INSERT INTO stock_out (branch_id, user_id, reference_no, stock_out_date, total_amount, notes) VALUES
(1, 2, 'SO-20260621-B1', DATE_SUB(CURDATE(), INTERVAL 13 DAY), 4400.00, 'Daily sales'),
(2, 3, 'SO-20260621-B2', DATE_SUB(CURDATE(), INTERVAL 13 DAY), 2700.00, 'Daily sales'),
(1, 2, 'SO-20260622-B1', DATE_SUB(CURDATE(), INTERVAL 12 DAY), 6600.00, 'Daily sales'),
(2, 3, 'SO-20260622-B2', DATE_SUB(CURDATE(), INTERVAL 12 DAY), 5800.00, 'Daily sales'),
(1, 2, 'SO-20260623-B1', DATE_SUB(CURDATE(), INTERVAL 11 DAY), 4500.00, 'Daily sales'),
(2, 3, 'SO-20260623-B2', DATE_SUB(CURDATE(), INTERVAL 11 DAY), 5200.00, 'Daily sales'),
(1, 2, 'SO-20260624-B1', DATE_SUB(CURDATE(), INTERVAL 10 DAY), 5500.00, 'Daily sales'),
(2, 3, 'SO-20260624-B2', DATE_SUB(CURDATE(), INTERVAL 10 DAY), 4200.00, 'Daily sales'),
(1, 2, 'SO-20260625-B1', DATE_SUB(CURDATE(), INTERVAL 9 DAY), 10650.00, 'Daily sales'),
(1, 2, 'SO-20260626-B1', DATE_SUB(CURDATE(), INTERVAL 8 DAY), 11400.00, 'Daily sales'),
(2, 3, 'SO-20260626-B2', DATE_SUB(CURDATE(), INTERVAL 8 DAY), 6600.00, 'Daily sales'),
(1, 2, 'SO-20260627-B1', DATE_SUB(CURDATE(), INTERVAL 7 DAY), 11200.00, 'Daily sales'),
(2, 3, 'SO-20260627-B2', DATE_SUB(CURDATE(), INTERVAL 7 DAY), 5250.00, 'Daily sales'),
(1, 2, 'SO-20260628-B1', DATE_SUB(CURDATE(), INTERVAL 6 DAY), 6900.00, 'Daily sales'),
(2, 3, 'SO-20260628-B2', DATE_SUB(CURDATE(), INTERVAL 6 DAY), 4050.00, 'Daily sales'),
(1, 2, 'SO-20260629-B1', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 14750.00, 'Daily sales'),
(2, 3, 'SO-20260630-B2', DATE_SUB(CURDATE(), INTERVAL 4 DAY), 3600.00, 'Daily sales'),
(1, 2, 'SO-20260630-B1', DATE_SUB(CURDATE(), INTERVAL 4 DAY), 4950.00, 'Daily sales'),
(1, 2, 'SO-20260701-B1', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 13300.00, 'Daily sales'),
(2, 3, 'SO-20260701-B2', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 3300.00, 'Daily sales'),
(1, 2, 'SO-20260702-B1', DATE_SUB(CURDATE(), INTERVAL 2 DAY), 17500.00, 'Daily sales'),
(1, 2, 'SO-20260703-B1', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 16500.00, 'Daily sales'),
(2, 3, 'SO-20260703-B2', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 3750.00, 'Daily sales'),
(2, 3, 'SO-20260704-B2', CURDATE(), 12100.00, 'Daily sales'),
(1, 2, 'SO-20260704-B1', CURDATE(), 4400.00, 'Daily sales');


INSERT INTO settings (setting_key, setting_value) VALUES
('company_name', 'Perfect Choice'),
('currency', 'BDT'),
('low_stock_threshold_default', '10');


