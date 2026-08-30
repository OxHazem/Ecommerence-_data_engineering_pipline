-- ============================================================
-- GOLD - COUNTRY SALES
-- ============================================================
-- Grain:
-- One row per shipping country.
--
-- Purpose:
-- Aggregate sales performance by shipping country.
-- ============================================================

CREATE TABLE IF NOT EXISTS gold.country_sales (

    country VARCHAR(100) PRIMARY KEY,

    orders INTEGER NOT NULL,

    customers INTEGER NOT NULL,

    units_sold BIGINT NOT NULL,

    revenue NUMERIC(18,2) NOT NULL,

    cost NUMERIC(18,2) NOT NULL,

    profit NUMERIC(18,2) NOT NULL,

    average_order_value NUMERIC(18,2) NOT NULL,

    incomplete_items INTEGER NOT NULL

);