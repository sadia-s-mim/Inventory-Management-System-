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
