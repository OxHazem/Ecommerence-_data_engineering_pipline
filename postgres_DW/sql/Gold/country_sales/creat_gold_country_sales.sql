-- -- -- ============================================================
-- -- -- GOLD - COUNTRY SALES
-- -- -- ============================================================
-- -- -- Grain:
-- -- -- One row per shipping country.
-- -- --
-- -- -- Purpose:
-- -- -- Aggregate sales performance by shipping country.
-- -- -- ============================================================

-- -- CREATE TABLE IF NOT EXISTS gold.country_sales (

-- --     country VARCHAR(100) PRIMARY KEY,

-- --     orders INTEGER NOT NULL,

-- --     customers INTEGER NOT NULL,

-- --     units_sold BIGINT NOT NULL,

-- --     revenue NUMERIC(18,2) NOT NULL,

-- --     cost NUMERIC(18,2) NOT NULL,

-- --     profit NUMERIC(18,2) NOT NULL,

-- --     average_order_value NUMERIC(18,2) NOT NULL,

-- --     incomplete_items INTEGER NOT NULL

-- -- );

-- -- ============================================================
-- -- GOLD - COUNTRY SALES
-- -- ============================================================
-- -- Grain:
-- -- One row per shipping country.
-- --
-- -- Currency policy:
-- -- All financial values are calculated in EGP first.
-- --
-- -- The Gold table also provides equivalent values in:
-- --   EGP
-- --   SAR
-- --   AED
-- --
-- -- Exchange rates are taken according to the order date.
-- -- ============================================================

-- DROP TABLE IF EXISTS gold.country_sales;

-- CREATE TABLE gold.country_sales (

--     country VARCHAR(100) PRIMARY KEY,

--     orders INTEGER NOT NULL,

--     customers INTEGER NOT NULL,

--     units_sold BIGINT NOT NULL,

--     -- ========================================================
--     -- EGP
--     -- ========================================================

--     revenue_egp NUMERIC(18,2) NOT NULL,

--     cost_egp NUMERIC(18,2) NOT NULL,

--     profit_egp NUMERIC(18,2) NOT NULL,

--     average_order_value_egp NUMERIC(18,2) NOT NULL,

--     -- ========================================================
--     -- SAR EQUIVALENT
--     -- ========================================================

--     revenue_sar NUMERIC(18,2) NOT NULL,

--     cost_sar NUMERIC(18,2) NOT NULL,

--     profit_sar NUMERIC(18,2) NOT NULL,

--     average_order_value_sar NUMERIC(18,2) NOT NULL,

--     -- ========================================================
--     -- AED EQUIVALENT
--     -- ========================================================

--     revenue_aed NUMERIC(18,2) NOT NULL,

--     cost_aed NUMERIC(18,2) NOT NULL,

--     profit_aed NUMERIC(18,2) NOT NULL,

--     average_order_value_aed NUMERIC(18,2) NOT NULL,

--     -- ========================================================
--     -- DATA QUALITY
--     -- ========================================================

--     incomplete_items INTEGER NOT NULL
-- );
-- ============================================================
-- GOLD - COUNTRY SALES
-- ============================================================
-- Grain:
-- One row per shipping country.
--
-- Currency policy:
--   EGP = canonical/base currency
--   SAR = equivalent value
--   AED = equivalent value
--
-- Revenue, cost and profit are calculated at item level
-- using the exchange rate applicable to the order date.
-- ============================================================

DROP TABLE IF EXISTS gold.country_sales;

CREATE TABLE gold.country_sales (

    country VARCHAR(100) PRIMARY KEY,

    orders INTEGER NOT NULL,

    customers INTEGER NOT NULL,

    units_sold BIGINT NOT NULL,

    -- ========================================================
    -- EGP
    -- ========================================================

    revenue_egp NUMERIC(18,2) NOT NULL,

    cost_egp NUMERIC(18,2) NOT NULL,

    profit_egp NUMERIC(18,2) NOT NULL,

    average_order_value_egp NUMERIC(18,2) NOT NULL,


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