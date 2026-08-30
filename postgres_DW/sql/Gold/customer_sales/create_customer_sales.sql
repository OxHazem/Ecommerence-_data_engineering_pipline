-- ============================================================
-- GOLD - CUSTOMER SALES
-- ============================================================
-- Grain:
-- One row per customer.
--
-- Purpose:
-- Aggregate customer information with sales performance.
-- ============================================================

CREATE TABLE IF NOT EXISTS gold.customer_sales (

    customer_id INTEGER PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,

    last_name VARCHAR(50) NOT NULL,

    country VARCHAR(100),

    city VARCHAR(100),

    customer_status VARCHAR(20),

    orders INTEGER NOT NULL,

    units_sold BIGINT NOT NULL,

    revenue NUMERIC(18,2) NOT NULL,

    cost NUMERIC(18,2) NOT NULL,

    profit NUMERIC(18,2) NOT NULL,

    average_order_value NUMERIC(18,2) NOT NULL,

    incomplete_items INTEGER NOT NULL

);