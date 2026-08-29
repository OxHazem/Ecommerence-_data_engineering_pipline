INSERT INTO silver.payment (
    payment_id,
    order_id,
    payment_date,
    payment_method,
    amount,
    currency,
    payment_status,
    transaction_reference,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system
)

WITH deduplicated_payment_id AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY payment_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_payment_id

    FROM bronze.payment
),

deduplicated AS (

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

        p.payment_id::INTEGER AS payment_id,

        p.order_id::INTEGER AS order_id,

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

        p.payment_method,

        CASE
            WHEN TRIM(p.amount) !~ '^[0-9]+(\.[0-9]+)?$'
            THEN NULL

            ELSE TRIM(p.amount)::DECIMAL(12,2)
        END AS amount,

        p.currency,

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

        p.transaction_reference,

        p.source_file,
        p.ingestion_timestamp,
        p.batch_id,
        p.source_system

    FROM deduplicated p

    INNER JOIN silver.orders o
        ON p.order_id::INTEGER = o.order_id

    WHERE p.rn_order_id = 1
)

SELECT
    payment_id,
    order_id,
    payment_date,
    payment_method,
    amount,
    currency,
    payment_status,
    transaction_reference,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system

FROM cleaned;
