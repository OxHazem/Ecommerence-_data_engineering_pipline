-- ============================================================
-- 1. GOLD
-- ============================================================

TRUNCATE TABLE gold.daily_sales;
TRUNCATE TABLE gold.monthly_sales;
TRUNCATE TABLE gold.product_sales;
TRUNCATE TABLE gold.customer_sales;
TRUNCATE TABLE gold.country_sales;
TRUNCATE TABLE gold.shipping_performance;
TRUNCATE TABLE gold.marketing_performance;

-- Add any other Gold tables you created.


-- ============================================================
-- 2. SILVER
-- ============================================================

TRUNCATE TABLE silver.order_item CASCADE;
TRUNCATE TABLE silver.orders CASCADE;
TRUNCATE TABLE silver.product CASCADE;
TRUNCATE TABLE silver.customer CASCADE;
TRUNCATE TABLE silver.shipping CASCADE;
TRUNCATE TABLE silver.payment CASCADE;
TRUNCATE TABLE silver.review CASCADE;
TRUNCATE TABLE silver.marketing_event CASCADE;
TRUNCATE TABLE silver.exchange_rate CASCADE;


-- ============================================================
-- 3. BRONZE
-- ============================================================

TRUNCATE TABLE bronze.order_item CASCADE;
TRUNCATE TABLE bronze.orders CASCADE;
TRUNCATE TABLE bronze.product CASCADE;
TRUNCATE TABLE bronze.customer CASCADE;
TRUNCATE TABLE bronze.shipping CASCADE;
TRUNCATE TABLE bronze.payment CASCADE;
TRUNCATE TABLE bronze.review CASCADE;
TRUNCATE TABLE bronze.marketing_event CASCADE;
TRUNCATE TABLE bronze.exchange_rate CASCADE;

