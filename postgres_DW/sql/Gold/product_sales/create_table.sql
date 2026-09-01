-- -- ============================================================
-- -- GOLD - PRODUCT SALES
-- -- ============================================================
-- -- Grain:
-- -- One row per product.
-- --
-- -- Purpose:
-- -- Aggregate product information with sales performance
-- -- from Silver orders and order items.
-- -- ============================================================

-- CREATE TABLE IF NOT EXISTS gold.product_sales (

--     product_id INTEGER PRIMARY KEY,

--     product_name VARCHAR(255) NOT NULL,

--     category VARCHAR(100),

--     subcategory VARCHAR(100),

--     brand VARCHAR(100),

--     orders INTEGER NOT NULL,

--     units_sold BIGINT NOT NULL,

--     revenue NUMERIC(18,2) NOT NULL,

--     cost NUMERIC(18,2) NOT NULL,

--     profit NUMERIC(18,2) NOT NULL,

--     average_selling_price NUMERIC(18,2) NOT NULL,

--     incomplete_items INTEGER NOT NULL

-- );


-- ============================================================
-- GOLD - PRODUCT SALES
-- ============================================================
-- Grain:
-- One row per product.
--
-- Financial values:
-- EGP is the primary/base currency.
-- SAR and AED are alternative representations.
-- ============================================================

DROP TABLE IF EXISTS gold.product_sales;

CREATE TABLE gold.product_sales (

    product_id INTEGER PRIMARY KEY,

    product_name VARCHAR(255) NOT NULL,

    category VARCHAR(100),

    subcategory VARCHAR(100),

    brand VARCHAR(100),

    orders INTEGER NOT NULL,

    units_sold BIGINT NOT NULL,

    -- ========================================================
    -- EGP
    -- ========================================================

    revenue NUMERIC(18,2) NOT NULL,

    cost NUMERIC(18,2) NOT NULL,

    profit NUMERIC(18,2) NOT NULL,

    average_selling_price NUMERIC(18,2) NOT NULL,

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