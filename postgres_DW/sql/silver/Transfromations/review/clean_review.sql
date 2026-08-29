-- ============================================================
-- REVIEW CLEANING
-- ============================================================
-- Purpose:
-- Clean Bronze review data before loading it into Silver.
--
-- Cleaning rules from dirty_config:
--   review_id                 -> duplicate
--   customer_id              -> invalid foreign key
--   product_id               -> invalid foreign key
--   customer_product         -> duplicate
--   rating                   -> invalid value + invalid type
--   review_date              -> invalid type + business rule
-- ============================================================


WITH deduplicated_review_id AS (

    -- ========================================================
    -- REVIEW ID
    -- Remove duplicate review records.
    -- Keep the most recent record for each review_id.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY review_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_review_id

    FROM bronze.review
),


deduplicated AS (

    -- ========================================================
    -- CUSTOMER + PRODUCT
    -- Remove duplicate customer-product combinations.
    -- Keep the most recent record.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, product_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_customer_product

    FROM deduplicated_review_id

    WHERE rn_review_id = 1
),


cleaned AS (

    SELECT

        r.review_id,

        r.customer_id,

        r.product_id,

        -- ====================================================
        -- RATING
        -- Will be cleaned next:
        --   - invalid value
        --   - invalid type
        -- ====================================================
        -- ====================================================
        -- RATING
        -- Invalid type -> NULL
        -- Invalid value (outside 1-5) -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(r.rating) !~ '^[0-9]+$'
            THEN NULL

            WHEN TRIM(r.rating)::INTEGER NOT BETWEEN 1 AND 5
            THEN NULL

            ELSE TRIM(r.rating)::INTEGER
        END AS rating,

        -- ====================================================
        -- REVIEW DATE
        -- Will be cleaned next:
        --   - invalid type
        --   - business rule
        -- ====================================================
        -- ====================================================
        -- REVIEW DATE
        -- Invalid type -> NULL
        -- Before customer registration -> NULL
        -- ====================================================
        CASE
            WHEN r.review_date IS NULL
            OR TRIM(r.review_date) = ''
            OR UPPER(TRIM(r.review_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN TRIM(r.review_date) = 'not-a-date'
            THEN NULL

            WHEN LEFT(TRIM(r.review_date), 10)::DATE < c.registration_date
            THEN NULL

            ELSE LEFT(TRIM(r.review_date), 10)::DATE
        END AS review_date,

        r.verified_purchase,

        r.review_status,

        -- ====================================================
        -- METADATA
        -- ====================================================
        r.source_file,
        r.ingestion_timestamp,
        r.batch_id,
        r.source_system

    FROM deduplicated r

    -- ========================================================
    -- CUSTOMER RELATIONSHIP
    --
    -- Validates customer_id against Silver Customer.
    -- ========================================================
    INNER JOIN silver.customer c
        ON r.customer_id::INTEGER = c.customer_id

    -- ========================================================
    -- PRODUCT RELATIONSHIP
    --
    -- Validates product_id against Silver Product.
    -- ========================================================
    INNER JOIN silver.product p
        ON r.product_id::INTEGER = p.product_id

    WHERE r.rn_customer_product = 1
)


SELECT *
FROM cleaned;



































SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'review'
ORDER BY ordinal_position;



SELECT
    TRIM(verified_purchase) AS verified_purchase,
    COUNT(*) AS occurrences
FROM bronze.review
GROUP BY TRIM(verified_purchase)
ORDER BY occurrences DESC;