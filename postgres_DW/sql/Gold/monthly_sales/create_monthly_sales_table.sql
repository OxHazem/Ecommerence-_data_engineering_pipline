-- CREATE TABLE IF NOT EXISTS gold.monthly_sales (
--     month DATE PRIMARY KEY,
--     orders INTEGER NOT NULL,
--     customers INTEGER NOT NULL,
--     units_sold BIGINT NOT NULL,
--     revenue NUMERIC(18,2) NOT NULL,
--     cost NUMERIC(18,2) NOT NULL,
--     profit NUMERIC(18,2) NOT NULL,
--     average_order_value NUMERIC(18,2) NOT NULL,
--     incomplete_items INTEGER NOT NULL
-- );



-- ============================================================
-- GOLD - MONTHLY SALES
-- DROP OLD TABLE
-- ============================================================

DROP TABLE IF EXISTS gold.monthly_sales;


-- ============================================================
-- GOLD - MONTHLY SALES
-- CREATE NEW TABLE
-- ============================================================
-- Grain:
-- One row per calendar month.
--
-- Primary reporting currency:
-- EGP
--
-- Additional reporting currencies:
-- AED
-- SAR
-- ============================================================

CREATE TABLE gold.monthly_sales (

    month DATE PRIMARY KEY,

    orders INTEGER NOT NULL,

    customers INTEGER NOT NULL,

    units_sold BIGINT NOT NULL,

    -- ========================================================
    -- EGP
    -- ========================================================

    revenue NUMERIC(18,2) NOT NULL,

    cost NUMERIC(18,2) NOT NULL,

    profit NUMERIC(18,2) NOT NULL,

    average_order_value NUMERIC(18,2) NOT NULL,


    -- ========================================================
    -- AED
    -- ========================================================

    revenue_aed NUMERIC(18,2) NOT NULL,

    cost_aed NUMERIC(18,2) NOT NULL,

    profit_aed NUMERIC(18,2) NOT NULL,

    average_order_value_aed NUMERIC(18,2) NOT NULL,


    -- ========================================================
    -- SAR
    -- ========================================================

    revenue_sar NUMERIC(18,2) NOT NULL,

    cost_sar NUMERIC(18,2) NOT NULL,

    profit_sar NUMERIC(18,2) NOT NULL,

    average_order_value_sar NUMERIC(18,2) NOT NULL,


    -- ========================================================
    -- DATA QUALITY
    -- ========================================================

    incomplete_items INTEGER NOT NULL

);