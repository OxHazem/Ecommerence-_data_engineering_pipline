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