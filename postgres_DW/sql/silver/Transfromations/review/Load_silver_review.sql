-- ============================================================
-- REVIEW CLEANING + LOAD INTO SILVER
-- ============================================================
-- Purpose:
-- Clean Bronze review data before loading it into Silver.
--
-- Cleaning rules:
--   review_id                 -> duplicate
--   customer_id              -> invalid foreign key
--   product_id               -> invalid foreign key
--   customer_product         -> duplicate
--   rating                   -> invalid value + invalid type
--   review_date              -> invalid type + business rule
-- ============================================================


INSERT INTO silver.review (
    review_id,
    customer_id,
    product_id,
    rating,
    review_date,
    verified_purchase,
    review_status
)

WITH deduplicated_review_id AS (

    -- Remove duplicate review_id.
    -- Keep the most recent record.
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY review_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_review_id

    FROM bronze.review
),

deduplicated AS (

    -- Remove duplicate customer + product combinations.
    -- Keep the most recent record.
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

        -- ====================================================
        -- IDs
        -- Bronze TEXT -> Silver INTEGER
        -- ====================================================
        r.review_id::INTEGER AS review_id,
        r.customer_id::INTEGER AS customer_id,
        r.product_id::INTEGER AS product_id,

        -- ====================================================
        -- RATING
        -- Invalid type -> NULL
        -- Invalid value outside 1-5 -> NULL
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
        -- Missing -> NULL
        -- Invalid type -> NULL
        -- Before customer registration -> NULL
        -- ====================================================
        CASE
            WHEN r.review_date IS NULL
              OR TRIM(r.review_date) = ''
              OR UPPER(TRIM(r.review_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(r.review_date)) = 'not-a-date'
            THEN NULL

            WHEN LEFT(TRIM(r.review_date), 10)::DATE <
                 c.registration_date
            THEN NULL

            ELSE LEFT(TRIM(r.review_date), 10)::DATE
        END AS review_date,

        -- ====================================================
        -- VERIFIED PURCHASE
        -- No dirty-data rule configured
        -- ====================================================
        CASE
            WHEN verified_purchase IS NULL
            OR TRIM(verified_purchase) = ''
            OR UPPER(TRIM(verified_purchase)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(verified_purchase)) IN ('true', 't', 'yes', '1')
            THEN TRUE

            WHEN LOWER(TRIM(verified_purchase)) IN ('false', 'f', 'no', '0')
            THEN FALSE

            ELSE NULL
        END AS verified_purchase,

        -- ====================================================
        -- REVIEW STATUS
        -- No dirty-data rule configured
        -- ====================================================
        r.review_status

    FROM deduplicated r

    -- ========================================================
    -- CUSTOMER FK VALIDATION
    -- ========================================================
    INNER JOIN silver.customer c
        ON r.customer_id::INTEGER = c.customer_id

    -- ========================================================
    -- PRODUCT FK VALIDATION
    -- ========================================================
    INNER JOIN silver.product p
        ON r.product_id::INTEGER = p.product_id

    WHERE r.rn_customer_product = 1
)

SELECT
    review_id,
    customer_id,
    product_id,
    rating,
    review_date,
    verified_purchase,
    review_status

FROM cleaned;