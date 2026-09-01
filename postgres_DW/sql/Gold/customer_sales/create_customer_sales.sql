-- 
-- ============================================================
-- GOLD - CUSTOMER SALES
-- ============================================================
-- Grain:
-- One row per customer.
--
-- Financial values:
--   revenue / cost / profit        → EGP
--   revenue_sar / cost_sar / profit_sar → SAR
--   revenue_aed / cost_aed / profit_aed → AED
-- ============================================================

DROP TABLE IF EXISTS gold.customer_sales;

CREATE TABLE gold.customer_sales (

    customer_id INTEGER PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,

    last_name VARCHAR(50) NOT NULL,

    country VARCHAR(100),

    city VARCHAR(100),

    customer_status VARCHAR(20),

    orders INTEGER NOT NULL,

    units_sold BIGINT NOT NULL,

    -- ========================================================
    -- EGP
    -- ========================================================

    revenue NUMERIC(18,2) NOT NULL,

    cost NUMERIC(18,2) NOT NULL,

    profit NUMERIC(18,2) NOT NULL,

    average_order_value NUMERIC(18,2) NOT NULL,

    -- ========================================================
    -- SAR
    -- ========================================================

    revenue_sar NUMERIC(18,2) NOT NULL,

    cost_sar NUMERIC(18,2) NOT NULL,

    profit_sar NUMERIC(18,2) NOT NULL,

    -- ========================================================
    -- AED
    -- ========================================================

    revenue_aed NUMERIC(18,2) NOT NULL,

    cost_aed NUMERIC(18,2) NOT NULL,

    profit_aed NUMERIC(18,2) NOT NULL,

    -- ========================================================
    -- DATA QUALITY
    -- ========================================================

    incomplete_items INTEGER NOT NULL
);