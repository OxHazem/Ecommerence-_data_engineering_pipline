-- ============================================================
-- PAYMENT CLEANING
-- ============================================================
-- Purpose:
-- Clean Bronze payment data before loading it into Silver.
--
-- Cleaning rules:
--   payment_id  -> duplicate
--   order_id    -> duplicate + invalid FK
--   amount      -> invalid value + invalid type
--   payment_date -> invalid type + business rule
--   payment_status -> invalid value
-- ============================================================


WITH deduplicated_payment_id AS (

    -- ========================================================
    -- PAYMENT ID
    -- Remove duplicate payment records.
    -- Keep the most recent record.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY payment_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_payment_id

    FROM bronze.payment
),


deduplicated AS (

    -- ========================================================
    -- ORDER ID
    -- Remove duplicate payments for the same order.
    -- Keep the most recent record.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_order_id

    FROM deduplicated_payment_id

    WHERE rn_payment_id = 1
),


cleaned AS (

    SELECT

        p.payment_id,

        -- Bronze order_id is TEXT
        -- Convert it to INTEGER for Silver
        p.order_id::INTEGER AS order_id,


        -- ====================================================
        -- PAYMENT DATE
        -- Missing / invalid type -> NULL
        -- Future date -> NULL
        -- Before order date -> NULL
        -- ====================================================
        CASE
            WHEN p.payment_date IS NULL
              OR TRIM(p.payment_date) = ''
              OR UPPER(TRIM(p.payment_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN TRIM(p.payment_date) = 'not-a-date'
            THEN NULL

            WHEN LEFT(TRIM(p.payment_date), 10)::DATE > CURRENT_DATE
            THEN NULL

            WHEN LEFT(TRIM(p.payment_date), 10)::DATE < o.order_date
            THEN NULL

            ELSE LEFT(TRIM(p.payment_date), 10)::DATE
        END AS payment_date,


        -- ====================================================
        -- PAYMENT METHOD
        -- No dirty-data rule configured
        -- ====================================================
        p.payment_method,


        -- ====================================================
        -- AMOUNT
        -- Invalid type -> NULL
        -- Negative amount -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(p.amount) !~ '^[0-9]+(\.[0-9]+)?$'
            THEN NULL

            ELSE TRIM(p.amount)::DECIMAL(12,2)
        END AS amount,


        -- ====================================================
        -- CURRENCY
        -- No dirty-data rule configured
        -- ====================================================
        p.currency,


        -- ====================================================
        -- PAYMENT STATUS
        -- Invalid value -> NULL
        -- ====================================================
        CASE
            WHEN p.payment_status IS NULL
              OR TRIM(p.payment_status) = ''
              OR UPPER(TRIM(p.payment_status)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(p.payment_status)) = 'pending'
            THEN 'Pending'

            WHEN LOWER(TRIM(p.payment_status)) = 'completed'
            THEN 'Completed'

            WHEN LOWER(TRIM(p.payment_status)) = 'failed'
            THEN 'Failed'

            WHEN LOWER(TRIM(p.payment_status)) = 'refunded'
            THEN 'Refunded'

            ELSE NULL
        END AS payment_status,


        -- ====================================================
        -- TRANSACTION REFERENCE
        -- No dirty-data rule configured
        -- ====================================================
        p.transaction_reference,


        -- ====================================================
        -- METADATA
        -- ====================================================
        p.source_file,
        p.ingestion_timestamp,
        p.batch_id,
        p.source_system


    FROM deduplicated p


    -- ========================================================
    -- ORDER RELATIONSHIP
    --
    -- 1. Validates order_id
    -- 2. Gives us order_date for the business rule
    -- ========================================================
    INNER JOIN silver.orders o
        ON p.order_id::INTEGER = o.order_id


    WHERE p.rn_order_id = 1
)


SELECT *
FROM cleaned;




















SELECT COUNT(*)
FROM silver.payment;






SELECT
    payment_id,
    COUNT(*) AS occurrences
FROM silver.payment
GROUP BY payment_id
HAVING COUNT(*) > 1;





SELECT
    order_id,
    COUNT(*) AS occurrences
FROM silver.payment
GROUP BY order_id
HAVING COUNT(*) > 1;





SELECT p.order_id
FROM silver.payment p
LEFT JOIN silver.orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;




SELECT
    COUNT(*) FILTER (WHERE amount < 0) AS negative_amounts
FROM silver.payment;