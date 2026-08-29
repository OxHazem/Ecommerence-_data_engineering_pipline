-- ============================================================
-- CUSTOMER CLEANING
-- ============================================================
-- Purpose:
-- Clean Bronze customer data before loading it into Silver.
--
-- Cleaning rules from dirty_config:
--   customer_id       -> duplicate
--   email             -> invalid value
--   phone             -> missing
-- ============================================================


WITH deduplicated AS (

    -- Remove duplicate customer records.
    -- Keep the most recent record for each customer_id.
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn
    FROM bronze.customer
),

cleaned AS (

    SELECT
        customer_id,
        first_name,
        last_name,

        -- ====================================================
        -- EMAIL
        -- Invalid email -> NULL
        -- ====================================================
        CASE
            WHEN email IS NULL
              OR TRIM(email) = ''
              OR UPPER(TRIM(email)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN TRIM(email) !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            THEN NULL

            ELSE TRIM(email)
        END AS email,

        -- ====================================================
        -- PHONE
        -- Missing phone -> NULL
        -- ====================================================
        CASE
            WHEN phone IS NULL
              OR TRIM(phone) = ''
              OR UPPER(TRIM(phone)) IN ('NULL', 'NAN')
            THEN NULL

            ELSE TRIM(phone)
        END AS phone,

         -- ====================================================
        -- GENDER
        -- Missing / invalid values -> 'Unknown'
        -- ====================================================
        CASE
            WHEN gender IS NULL
            OR TRIM(gender) = ''
            OR UPPER(TRIM(gender)) IN ('NULL', 'NAN')
            THEN 'Unknown'

            WHEN TRIM(gender) NOT IN ('Male', 'Female', 'Other', 'Unknown')
            THEN 'Unknown'

            ELSE TRIM(gender)
        END AS gender,


        -- ====================================================
        -- DATE OF BIRTH
        -- Missing / invalid type -> NULL
        -- ====================================================
        CASE
            WHEN date_of_birth IS NULL
            OR TRIM(date_of_birth) = ''
            OR UPPER(TRIM(date_of_birth)) IN ('NULL', 'NAN')
            THEN NULL

            WHEN TRIM(date_of_birth) = 'not-a-date'
            THEN NULL

            ELSE TRIM(date_of_birth)::DATE
        END AS date_of_birth,
        -- ====================================================
        -- COUNTRY
        -- Standardize country codes/names to full country names
        -- ====================================================
        CASE
            WHEN TRIM(country) = 'EG'
            THEN 'Egypt'

            WHEN TRIM(country) = 'SA'
            THEN 'Saudi Arabia'

            WHEN TRIM(country) = 'AE'
            THEN 'United Arab Emirates'

            ELSE TRIM(country)
        END AS country,
        -- ====================================================
        -- CITY
        -- Standardize inconsistent capitalization
        -- ====================================================
        CASE
            WHEN LOWER(TRIM(city)) = 'cairo'
            THEN 'Cairo'

            ELSE TRIM(city)
        END AS city,


        CASE
            WHEN LEFT(TRIM(registration_date), 10)::DATE > CURRENT_DATE
            THEN NULL
            ELSE LEFT(TRIM(registration_date), 10)::DATE
        END AS registration_date,

        customer_status,

        -- Keep metadata
        source_file,
        ingestion_timestamp,
        batch_id,
        source_system

    FROM deduplicated
    WHERE rn = 1
)

SELECT *
FROM cleaned;