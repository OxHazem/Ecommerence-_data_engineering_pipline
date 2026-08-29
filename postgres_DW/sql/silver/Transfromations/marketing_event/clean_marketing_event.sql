-- ============================================================
-- MARKETING EVENT CLEANING
-- ============================================================
-- Purpose:
-- Clean Bronze marketing event data before loading it
-- into Silver.
--
-- Cleaning rules from dirty_config:
--   customer_id       -> invalid foreign key
--   event_id          -> duplicate
--   campaign_id       -> missing
--   event_type        -> invalid value
--   device_type       -> inconsistent format
--   event_timestamp   -> invalid type + business rule
-- ============================================================


WITH deduplicated AS (

    -- ========================================================
    -- EVENT ID
    -- Remove duplicate event records.
    -- Keep the most recent record for each event_id.
    -- ========================================================
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn_event_id

    FROM bronze.marketing_event
),


cleaned AS (

    SELECT

        m.event_id,
        m.customer_id,

        -- ====================================================
        -- CAMPAIGN ID
        -- Missing values are allowed.
        -- Will be cleaned next.
        -- ====================================================
        CASE
            WHEN m.campaign_id IS NULL
            OR TRIM(m.campaign_id) = ''
            OR UPPER(TRIM(m.campaign_id)) IN ('NULL', 'NAN')
            THEN NULL

            ELSE TRIM(m.campaign_id)::INTEGER
        END AS campaign_id,

        m.campaign_name,

        -- ====================================================
        -- EVENT TYPE
        -- Will be cleaned next:
        --   - invalid value
        -- ====================================================
        -- ====================================================
        -- EVENT TYPE
        -- Invalid value -> NULL
        -- Standardize valid values
        -- ====================================================
        CASE
            WHEN m.event_type IS NULL
            OR TRIM(m.event_type) = ''
            OR UPPER(TRIM(m.event_type)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(m.event_type)) = 'view'
            THEN 'View'

            WHEN LOWER(TRIM(m.event_type)) = 'click'
            THEN 'Click'

            WHEN LOWER(TRIM(m.event_type)) = 'add to cart'
            THEN 'Add to Cart'

            WHEN LOWER(TRIM(m.event_type)) = 'purchase'
            THEN 'Purchase'

            WHEN LOWER(TRIM(m.event_type)) = 'impression'
            THEN 'Impression'

            ELSE NULL
        END AS event_type,

        m.channel,

        -- ====================================================
        -- EVENT TIMESTAMP
        -- Will be cleaned next:
        --   - invalid type
        --   - business rule
        -- ====================================================
        -- ====================================================
        -- EVENT TIMESTAMP
        -- Invalid type -> NULL
        -- Future timestamp -> NULL
        -- Before customer registration -> NULL
        -- ====================================================
        CASE
            WHEN m.event_timestamp IS NULL
            OR TRIM(m.event_timestamp) = ''
            OR UPPER(TRIM(m.event_timestamp)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN TRIM(m.event_timestamp) = 'not-a-date'
            THEN NULL

            WHEN TRIM(m.event_timestamp)::TIMESTAMP > CURRENT_TIMESTAMP
            THEN NULL

            WHEN c.registration_date IS NOT NULL
            AND TRIM(m.event_timestamp)::TIMESTAMP < c.registration_date::TIMESTAMP
            THEN NULL

            ELSE TRIM(m.event_timestamp)::TIMESTAMP
        END AS event_timestamp,

        -- ====================================================
        -- DEVICE TYPE
        -- Will be cleaned next:
        --   - inconsistent format
        -- ====================================================
        CASE
            WHEN m.device_type IS NULL
            OR TRIM(m.device_type) = ''
            OR UPPER(TRIM(m.device_type)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(m.device_type)) = 'mobile'
            THEN 'Mobile'

            WHEN LOWER(TRIM(m.device_type)) = 'tablet'
            THEN 'Tablet'

            WHEN LOWER(TRIM(m.device_type)) = 'desktop'
            THEN 'Desktop'

            ELSE TRIM(m.device_type)
        END AS device_type,

        m.country,

        -- ====================================================
        -- METADATA
        -- ====================================================
        m.source_file,
        m.ingestion_timestamp,
        m.batch_id,
        m.source_system

    FROM deduplicated m


    -- ========================================================
    -- CUSTOMER RELATIONSHIP
    --
    -- Validates customer_id against Silver Customer.
    -- Invalid customer_id values such as 10001 are excluded.
    -- ========================================================
    INNER JOIN silver.customer c
        ON m.customer_id::INTEGER = c.customer_id


    WHERE m.rn_event_id = 1
)


SELECT *
FROM cleaned;




SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'marketing_event'
ORDER BY ordinal_position;





























SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'exchange_rate'
ORDER BY ordinal_position;