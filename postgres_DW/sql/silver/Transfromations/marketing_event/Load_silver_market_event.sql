-- ============================================================
-- MARKETING EVENT CLEANING + LOAD INTO SILVER
-- ============================================================

INSERT INTO silver.marketing_event (
    event_id,
    customer_id,
    campaign_id,
    campaign_name,
    event_type,
    channel,
    event_timestamp,
    device_type,
    country
)

WITH deduplicated AS (

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

        -- ====================================================
        -- IDs
        -- Bronze TEXT -> Silver INTEGER
        -- ====================================================
        m.event_id::INTEGER AS event_id,

        m.customer_id::INTEGER AS customer_id,


        -- ====================================================
        -- CAMPAIGN ID
        -- Missing -> NULL
        -- Values such as '87.0' -> INTEGER
        -- ====================================================
        CASE
            WHEN m.campaign_id IS NULL
              OR TRIM(m.campaign_id) = ''
              OR UPPER(TRIM(m.campaign_id)) IN ('NULL', 'NAN')
            THEN NULL

            ELSE TRIM(m.campaign_id)::NUMERIC::INTEGER
        END AS campaign_id,


        m.campaign_name,


        -- ====================================================
        -- EVENT TYPE
        -- Standardize valid values
        -- Invalid values -> NULL
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
        -- Invalid / missing -> NULL
        -- Future -> NULL
        -- Before customer registration -> NULL
        -- ====================================================
        CASE
            WHEN m.event_timestamp IS NULL
              OR TRIM(m.event_timestamp) = ''
              OR UPPER(TRIM(m.event_timestamp)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN LOWER(TRIM(m.event_timestamp)) = 'not-a-date'
            THEN NULL

            WHEN TRIM(m.event_timestamp)::TIMESTAMP WITH TIME ZONE
                 > CURRENT_TIMESTAMP
            THEN NULL

            WHEN c.registration_date IS NOT NULL
             AND TRIM(m.event_timestamp)::TIMESTAMP WITH TIME ZONE
                 < c.registration_date::TIMESTAMP WITH TIME ZONE
            THEN NULL

            ELSE TRIM(m.event_timestamp)::TIMESTAMP WITH TIME ZONE
        END AS event_timestamp,


        -- ====================================================
        -- DEVICE TYPE
        -- Standardize capitalization
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


        m.country

    FROM deduplicated m

    -- ========================================================
    -- CUSTOMER FK VALIDATION
    -- Invalid customer_id values are excluded.
    -- ========================================================
    INNER JOIN silver.customer c
        ON m.customer_id::INTEGER = c.customer_id

    WHERE m.rn_event_id = 1
)

SELECT
    event_id,
    customer_id,
    campaign_id,
    campaign_name,
    event_type,
    channel,
    event_timestamp,
    device_type,
    country

FROM cleaned;