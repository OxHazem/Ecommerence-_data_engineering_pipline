-- Active: 1787559651180@@127.0.0.1@5432@ecommerce_dw
-- ============================================================
-- E-Commerce Data Warehouse
-- Schema Creation
-- ============================================================

-- Bronze:
-- Raw/ingested data loaded from MinIO.
CREATE SCHEMA IF NOT EXISTS bronze;

-- Silver:
-- Cleaned, standardized and validated data.
CREATE SCHEMA IF NOT EXISTS silver;

-- Gold:
-- Business-ready analytical data.
CREATE SCHEMA IF NOT EXISTS gold;


