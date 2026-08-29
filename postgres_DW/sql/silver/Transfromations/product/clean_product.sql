-- ============================================================
-- PRODUCT CLEANING
-- ============================================================
-- Cleaning rules from dirty_config:
--   product_id       -> duplicate
--   price            -> invalid value + invalid type
--   cost             -> invalid value
--   stock_quantity   -> invalid value
--   category         -> inconsistent format
--   brand            -> inconsistent format
-- ============================================================

WITH deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn

    FROM bronze.product
),

cleaned AS (

    SELECT
        product_id,
        product_name,

        -- ====================================================
        -- CATEGORY
        -- Standardize inconsistent capitalization
        -- ====================================================
        CASE
            WHEN LOWER(TRIM(category)) = 'electronics'
            THEN 'Electronics'

            ELSE TRIM(category)
        END AS category,

        subcategory,

        -- ====================================================
        -- BRAND
        -- Standardize inconsistent capitalization
        -- ====================================================
        CASE
            WHEN LOWER(TRIM(brand)) = 'samsung'
            THEN 'Samsung'

            ELSE TRIM(brand)
        END AS brand,

        supplier,

        -- ====================================================
        -- COST
        -- Negative cost -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(cost) ~ '^-?[0-9]+(\.[0-9]+)?$'
                 AND CAST(TRIM(cost) AS DECIMAL(10,2)) < 0
            THEN NULL

            ELSE CAST(TRIM(cost) AS DECIMAL(10,2))
        END AS cost,

        -- ====================================================
        -- PRICE
        -- Negative values / invalid types -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(price) ~ '^-?[0-9]+(\.[0-9]+)?$'
                 AND CAST(TRIM(price) AS DECIMAL(10,2)) < 0
            THEN NULL

            WHEN TRIM(price) !~ '^[0-9]+(\.[0-9]+)?$'
            THEN NULL

            ELSE CAST(TRIM(price) AS DECIMAL(10,2))
        END AS price,

        -- ====================================================
        -- STOCK QUANTITY
        -- Negative stock quantity -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(stock_quantity) ~ '^-?[0-9]+$'
                 AND CAST(TRIM(stock_quantity) AS INTEGER) < 0
            THEN NULL

            ELSE CAST(TRIM(stock_quantity) AS INTEGER)
        END AS stock_quantity,

        product_status,
        launch_date,

        -- ====================================================
        -- Metadata
        -- ====================================================
        source_file,
        ingestion_timestamp,
        batch_id,
        source_system

    FROM deduplicated
    WHERE rn = 1
)

SELECT *
FROM cleaned;





ALTER TABLE silver.product
ALTER COLUMN cost DROP NOT NULL;




ALTER TABLE silver.product
ALTER COLUMN price DROP NOT NULL;

ALTER TABLE silver.product
ALTER COLUMN stock_quantity DROP NOT NULL;



SELECT COUNT(*)
FROM silver.product;


SELECT
    product_id,
    COUNT(*) AS occurrences
FROM silver.product
GROUP BY product_id
HAVING COUNT(*) > 1;


SELECT
    COUNT(*) FILTER (WHERE cost < 0) AS negative_cost,
    COUNT(*) FILTER (WHERE price < 0) AS negative_price,
    COUNT(*) FILTER (WHERE stock_quantity < 0) AS negative_stock
FROM silver.product;


SELECT DISTINCT category
FROM silver.product
ORDER BY category;


SELECT DISTINCT brand
FROM silver.product
ORDER BY brand;