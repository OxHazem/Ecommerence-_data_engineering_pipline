INSERT INTO silver.shipping (
    shipment_id,
    order_id,
    shipping_date,
    estimated_delivery_date,
    delivery_date,
    shipping_country,
    shipping_city,
    shipping_method,
    shipping_status,
    shipping_cost,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system
)

WITH deduplicated_shipment_id AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY shipment_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_shipment_id

    FROM bronze.shipping
),

deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_order_id

    FROM deduplicated_shipment_id

    WHERE rn_shipment_id = 1
),

cleaned_shipping_date AS (

    SELECT

        s.*,
        o.order_date,

        CASE
            WHEN s.shipping_date IS NULL
              OR TRIM(s.shipping_date) = ''
              OR UPPER(TRIM(s.shipping_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(s.shipping_date)) = 'not-a-date'
            THEN NULL

            WHEN LEFT(TRIM(s.shipping_date), 10)::DATE < o.order_date
            THEN NULL

            ELSE LEFT(TRIM(s.shipping_date), 10)::DATE
        END AS cleaned_shipping_date

    FROM deduplicated s

    INNER JOIN silver.orders o
        ON s.order_id::INTEGER = o.order_id

    WHERE s.rn_order_id = 1
),

cleaned AS (

    SELECT

        shipment_id::INTEGER AS shipment_id,
        order_id::INTEGER AS order_id,

        cleaned_shipping_date AS shipping_date,

        -- ====================================================
        -- ESTIMATED DELIVERY DATE
        -- Before shipping date -> NULL
        -- ====================================================
        CASE
            WHEN estimated_delivery_date IS NULL
              OR TRIM(estimated_delivery_date) = ''
              OR UPPER(TRIM(estimated_delivery_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(estimated_delivery_date)) = 'not-a-date'
            THEN NULL

            WHEN cleaned_shipping_date IS NULL
            THEN NULL

            WHEN LEFT(TRIM(estimated_delivery_date), 10)::DATE <
                 cleaned_shipping_date
            THEN NULL

            ELSE LEFT(TRIM(estimated_delivery_date), 10)::DATE
        END AS estimated_delivery_date,

        -- ====================================================
        -- DELIVERY DATE
        -- Missing -> NULL
        -- Before shipping date -> NULL
        -- ====================================================
        CASE
            WHEN delivery_date IS NULL
              OR TRIM(delivery_date) = ''
              OR UPPER(TRIM(delivery_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(delivery_date)) = 'not-a-date'
            THEN NULL

            WHEN cleaned_shipping_date IS NULL
            THEN NULL

            WHEN LEFT(TRIM(delivery_date), 10)::DATE <
                 cleaned_shipping_date
            THEN NULL

            ELSE LEFT(TRIM(delivery_date), 10)::DATE
        END AS delivery_date,

        shipping_country,
        shipping_city,
        shipping_method,

        -- ====================================================
        -- SHIPPING STATUS
        -- Invalid value -> NULL
        -- ====================================================
        CASE
            WHEN shipping_status IS NULL
              OR TRIM(shipping_status) = ''
              OR UPPER(TRIM(shipping_status)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(shipping_status)) = 'pending'
            THEN 'Pending'

            WHEN LOWER(TRIM(shipping_status)) = 'shipped'
            THEN 'Shipped'

            WHEN LOWER(TRIM(shipping_status)) = 'in transit'
            THEN 'In Transit'

            WHEN LOWER(TRIM(shipping_status)) = 'delivered'
            THEN 'Delivered'

            WHEN LOWER(TRIM(shipping_status)) = 'returned'
            THEN 'Returned'

            ELSE NULL
        END AS shipping_status,

        shipping_cost::DECIMAL(10,2) AS shipping_cost,

        source_file,
        ingestion_timestamp,
        batch_id,
        source_system

    FROM cleaned_shipping_date
)

SELECT
    shipment_id,
    order_id,
    shipping_date,
    estimated_delivery_date,
    delivery_date,
    shipping_country,
    shipping_city,
    shipping_method,
    shipping_status,
    shipping_cost,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system

FROM cleaned;