-- ============================================================
-- SHIPPING CLEANING
-- ============================================================
-- Purpose:
-- Clean Bronze shipping data before loading it into Silver.
--
-- Cleaning rules:
--   shipment_id  -> duplicate
--   order_id     -> duplicate + invalid FK
--   shipping_date
--                -> invalid type
--                -> before order_date
--   estimated_delivery_date
--                -> before shipping_date
--   delivery_date
--                -> missing
--                -> before shipping_date
--   shipping_status
--                -> invalid value
-- ============================================================


WITH deduplicated_shipment_id AS (

    -- ========================================================
    -- SHIPMENT ID
    -- Keep the most recent record for each shipment_id.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY shipment_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_shipment_id

    FROM bronze.shipping
),


deduplicated AS (

    -- ========================================================
    -- ORDER ID
    -- Keep the most recent shipment for each order_id.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_order_id

    FROM deduplicated_shipment_id

    WHERE rn_shipment_id = 1
),


cleaned AS (

    SELECT

        s.shipment_id,
        s.order_id::INTEGER AS order_id,


        -- ====================================================
        -- SHIPPING DATE
        -- Invalid type -> NULL
        -- Before order date -> NULL
        -- ====================================================
        CASE
            WHEN s.shipping_date IS NULL
              OR TRIM(s.shipping_date) = ''
              OR UPPER(TRIM(s.shipping_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN TRIM(s.shipping_date) = 'not-a-date'
            THEN NULL

            WHEN LEFT(TRIM(s.shipping_date), 10)::DATE < o.order_date
            THEN NULL

            ELSE LEFT(TRIM(s.shipping_date), 10)::DATE
        END AS shipping_date,


        -- ====================================================
        -- ESTIMATED DELIVERY DATE
        -- Before shipping date -> NULL
        -- ====================================================
        CASE
            WHEN s.estimated_delivery_date IS NULL
              OR TRIM(s.estimated_delivery_date) = ''
              OR UPPER(TRIM(s.estimated_delivery_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LEFT(TRIM(s.estimated_delivery_date), 10)::DATE <
                 LEFT(TRIM(s.shipping_date), 10)::DATE
            THEN NULL

            ELSE LEFT(TRIM(s.estimated_delivery_date), 10)::DATE
        END AS estimated_delivery_date,


        -- ====================================================
        -- DELIVERY DATE
        -- Missing -> NULL
        -- Before shipping date -> NULL
        -- ====================================================
        CASE
            WHEN s.delivery_date IS NULL
              OR TRIM(s.delivery_date) = ''
              OR UPPER(TRIM(s.delivery_date)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LEFT(TRIM(s.delivery_date), 10)::DATE <
                 LEFT(TRIM(s.shipping_date), 10)::DATE
            THEN NULL

            ELSE LEFT(TRIM(s.delivery_date), 10)::DATE
        END AS delivery_date,


        s.shipping_country,
        s.shipping_city,
        s.shipping_method,


        -- ====================================================
        -- SHIPPING STATUS
        -- Invalid value -> NULL
        -- Standardize capitalization
        -- ====================================================
        CASE
            WHEN s.shipping_status IS NULL
              OR TRIM(s.shipping_status) = ''
              OR UPPER(TRIM(s.shipping_status)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(s.shipping_status)) = 'pending'
            THEN 'Pending'

            WHEN LOWER(TRIM(s.shipping_status)) = 'shipped'
            THEN 'Shipped'

            WHEN LOWER(TRIM(s.shipping_status)) = 'in transit'
            THEN 'In Transit'

            WHEN LOWER(TRIM(s.shipping_status)) = 'delivered'
            THEN 'Delivered'

            WHEN LOWER(TRIM(s.shipping_status)) = 'returned'
            THEN 'Returned'

            ELSE NULL
        END AS shipping_status,


        s.shipping_cost,


        -- ====================================================
        -- METADATA
        -- ====================================================
        s.source_file,
        s.ingestion_timestamp,
        s.batch_id,
        s.source_system


    FROM deduplicated s


    -- ========================================================
    -- ORDER RELATIONSHIP
    --
    -- Used to:
    --   1. Validate order_id
    --   2. Compare shipping_date with order_date
    -- ========================================================
    INNER JOIN silver.orders o
        ON s.order_id::INTEGER = o.order_id


    WHERE s.rn_order_id = 1
)


SELECT *
FROM cleaned;









































