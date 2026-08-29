-- ============================================================
-- ORDER CLEANING
-- ============================================================
-- Purpose:
-- Clean Bronze order data before loading it into Silver.
--
-- Cleaning rules from dirty_config:
--   order_id       -> duplicate
--   customer_id    -> invalid foreign key
--   order_date     -> invalid type
--   order_status   -> invalid value + inconsistent format
--   order_date     -> business rules
--                      - before customer registration
--                      - future date
-- ============================================================


WITH deduplicated AS (

    -- ========================================================
    -- ORDER ID
    -- Remove duplicate order records.
    -- Keep the most recent record for each order_id.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn

    FROM bronze.orders
),


cleaned AS (

    SELECT
        o.order_id,

        -- Bronze customer_id is TEXT.
        -- Convert it to INTEGER for Silver.
        o.customer_id::INTEGER AS customer_id,

        -- ====================================================
        -- ORDER DATE
        -- Convert to DATE
        -- Future date -> NULL
        -- Before customer registration -> NULL
        -- ====================================================
        CASE
            WHEN LEFT(TRIM(o.order_date), 10)::DATE > CURRENT_DATE
            THEN NULL

            WHEN LEFT(TRIM(o.order_date), 10)::DATE < c.registration_date
            THEN NULL

            ELSE LEFT(TRIM(o.order_date), 10)::DATE
        END AS order_date,

        -- ====================================================
        -- ORDER STATUS
        -- Invalid values -> NULL
        -- Inconsistent capitalization -> standardized format
        -- ====================================================
        CASE
            WHEN o.order_status IS NULL
              OR TRIM(o.order_status) = ''
              OR UPPER(TRIM(o.order_status)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(o.order_status)) = 'pending'
            THEN 'Pending'

            WHEN LOWER(TRIM(o.order_status)) = 'shipped'
            THEN 'Shipped'

            WHEN LOWER(TRIM(o.order_status)) = 'delivered'
            THEN 'Delivered'

            WHEN LOWER(TRIM(o.order_status)) = 'cancelled'
            THEN 'Cancelled'

            ELSE NULL
        END AS order_status,

        o.currency,
        o.shipping_country,
        o.shipping_city,

        -- ====================================================
        -- Metadata
        -- ====================================================
        o.source_file,
        o.ingestion_timestamp,
        o.batch_id,
        o.source_system

    FROM deduplicated o

    -- ========================================================
    -- CUSTOMER RELATIONSHIP
    -- Used to:
    --   1. Validate customer_id
    --   2. Compare order_date with registration_date
    -- ========================================================
    INNER JOIN silver.customer c
        ON o.customer_id::INTEGER = c.customer_id

    WHERE o.rn = 1
)


SELECT *
FROM cleaned;


-- ============================================================
-- LOAD ORDERS INTO SILVER
-- ============================================================

INSERT INTO silver.orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    currency,
    shipping_country,
    shipping_city,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system
)

WITH deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn

    FROM bronze.orders
),

cleaned AS (

    SELECT
        o.order_id::INTEGER AS order_id,

        o.customer_id::INTEGER AS customer_id,

        CASE
            WHEN LEFT(TRIM(o.order_date), 10)::DATE > CURRENT_DATE
            THEN NULL

            WHEN LEFT(TRIM(o.order_date), 10)::DATE < c.registration_date
            THEN NULL

            ELSE LEFT(TRIM(o.order_date), 10)::DATE
        END AS order_date,

        CASE
            WHEN o.order_status IS NULL
              OR TRIM(o.order_status) = ''
              OR UPPER(TRIM(o.order_status)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(o.order_status)) = 'pending'
            THEN 'Pending'

            WHEN LOWER(TRIM(o.order_status)) = 'shipped'
            THEN 'Shipped'

            WHEN LOWER(TRIM(o.order_status)) = 'delivered'
            THEN 'Delivered'

            WHEN LOWER(TRIM(o.order_status)) = 'cancelled'
            THEN 'Cancelled'

            ELSE NULL
        END AS order_status,

        o.currency,
        o.shipping_country,
        o.shipping_city,

        o.source_file,
        o.ingestion_timestamp,
        o.batch_id,
        o.source_system

    FROM deduplicated o

    INNER JOIN silver.customer c
        ON o.customer_id::INTEGER = c.customer_id

    WHERE o.rn = 1
)

SELECT
    order_id,
    customer_id,
    order_date,
    order_status,
    currency,
    shipping_country,
    shipping_city,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system

FROM cleaned;






ALTER TABLE silver.orders
ALTER COLUMN order_status DROP NOT NULL;

ALTER TABLE silver.orders
ALTER COLUMN order_date DROP NOT NULL;


SELECT COUNT(*)
FROM silver.orders;


SELECT
    order_id,
    COUNT(*) AS occurrences
FROM silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1;


SELECT o.order_id
FROM silver.orders o
LEFT JOIN silver.customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



SELECT
    o.order_id,
    o.order_date,
    c.registration_date
FROM silver.orders o
JOIN silver.customer c
    ON o.customer_id = c.customer_id
WHERE o.order_date IS NOT NULL
  AND c.registration_date IS NOT NULL
  AND o.order_date < c.registration_date;



SELECT *
FROM silver.orders
WHERE order_date > CURRENT_DATE;