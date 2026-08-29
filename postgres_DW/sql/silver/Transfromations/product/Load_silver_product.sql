-- ============================================================
-- LOAD PRODUCT INTO SILVER
-- ============================================================
-- Uses the existing Product cleaning logic and loads the
-- cleaned result into silver.product.
-- ============================================================

INSERT INTO silver.product (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    supplier,
    cost,
    price,
    stock_quantity,
    product_status,
    launch_date,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system
)

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
        product_id::INTEGER AS product_id,
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
        launch_date::DATE AS launch_date,

        -- ====================================================
        -- METADATA
        -- ====================================================
        source_file,
        ingestion_timestamp,
        batch_id,
        source_system

    FROM deduplicated

    WHERE rn = 1
)

SELECT
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    supplier,
    cost,
    price,
    stock_quantity,
    product_status,
    launch_date,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system

FROM cleaned;
