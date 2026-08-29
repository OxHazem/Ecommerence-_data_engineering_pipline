SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE event_id IS NULL OR TRIM(event_id) = '') AS null_event_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS null_customer_id,
    COUNT(*) FILTER (WHERE campaign_id IS NULL OR TRIM(campaign_id) = '') AS null_campaign_id,
    COUNT(*) FILTER (WHERE campaign_name IS NULL OR TRIM(campaign_name) = '') AS null_campaign_name,
    COUNT(*) FILTER (WHERE event_type IS NULL OR TRIM(event_type) = '') AS null_event_type,
    COUNT(*) FILTER (WHERE channel IS NULL OR TRIM(channel) = '') AS null_channel,
    COUNT(*) FILTER (WHERE event_timestamp IS NULL OR TRIM(event_timestamp) = '') AS null_event_timestamp,
    COUNT(*) FILTER (WHERE device_type IS NULL OR TRIM(device_type) = '') AS null_device_type,
    COUNT(*) FILTER (WHERE country IS NULL OR TRIM(country) = '') AS null_country

FROM bronze.marketing_event;

-- ============================================
-- EVENT_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE event_id IS NULL OR TRIM(event_id) = '' OR UPPER(TRIM(event_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Primary Key Uniqueness)
SELECT
    event_id,
    COUNT(*) AS duplicate_count
FROM bronze.marketing_event
WHERE event_id IS NOT NULL AND TRIM(event_id) <> '' AND UPPER(TRIM(event_id)) NOT IN ('NULL', 'NAN')
GROUP BY event_id
HAVING COUNT(*) > 1
ORDER BY event_id; 

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.marketing_event
WHERE event_id IS NOT NULL AND TRIM(event_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(event_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'event_id' is the Primary Key for this table)

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.marketing_event
WHERE event_id IS NOT NULL AND TRIM(event_id) <> '' AND UPPER(TRIM(event_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(event_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.marketing_event
WHERE event_id IS NOT NULL AND event_id <> TRIM(event_id);


-- ============================================
-- CUSTOMER_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE customer_id IS NULL OR TRIM(customer_id) = '' OR UPPER(TRIM(customer_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: A customer can trigger many marketing events)

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.marketing_event
WHERE customer_id IS NOT NULL AND TRIM(customer_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(customer_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys (customer_id does not exist in bronze.customer)
SELECT m.*
FROM bronze.marketing_event m
LEFT JOIN bronze.customer c ON TRIM(m.customer_id) = TRIM(c.customer_id)
WHERE m.customer_id IS NOT NULL AND TRIM(m.customer_id) ~ '^-?[0-9]+$'
  AND c.customer_id IS NULL;

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.marketing_event
WHERE customer_id IS NOT NULL AND TRIM(customer_id) <> '' AND UPPER(TRIM(customer_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(customer_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.marketing_event
WHERE customer_id IS NOT NULL AND customer_id <> TRIM(customer_id);


-- ============================================
-- CAMPAIGN_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE campaign_id IS NULL OR TRIM(campaign_id) = '' OR UPPER(TRIM(campaign_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Many events can map to the same campaign)

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.marketing_event
WHERE campaign_id IS NOT NULL AND TRIM(campaign_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(campaign_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: We do not have a separate campaign dimensional table yet)

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.marketing_event
WHERE campaign_id IS NOT NULL AND TRIM(campaign_id) <> '' AND UPPER(TRIM(campaign_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(campaign_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.marketing_event
WHERE campaign_id IS NOT NULL AND campaign_id <> TRIM(campaign_id);


-- ============================================
-- CAMPAIGN_NAME INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE campaign_name IS NULL OR TRIM(campaign_name) = '' OR UPPER(TRIM(campaign_name)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values
-- (Not Applicable)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(campaign_name)) AS normalized_campaign,
    STRING_AGG(DISTINCT campaign_name, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.marketing_event
WHERE campaign_name IS NOT NULL AND TRIM(campaign_name) <> '' AND UPPER(TRIM(campaign_name)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(campaign_name))
HAVING COUNT(DISTINCT campaign_name) > 1
ORDER BY occurrences DESC;


-- ============================================
-- EVENT_TYPE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE event_type IS NULL OR TRIM(event_type) = '' OR UPPER(TRIM(event_type)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values (Anomalies in event types e.g. "InvalidEvent")
SELECT
    TRIM(event_type) AS type_value,
    COUNT(*) AS occurrences
FROM bronze.marketing_event
WHERE event_type IS NOT NULL AND TRIM(event_type) <> '' AND UPPER(TRIM(event_type)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(event_type)
ORDER BY occurrences ASC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(event_type)) AS normalized_type,
    STRING_AGG(DISTINCT event_type, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.marketing_event
WHERE event_type IS NOT NULL AND TRIM(event_type) <> '' AND UPPER(TRIM(event_type)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(event_type))
HAVING COUNT(DISTINCT event_type) > 1
ORDER BY occurrences DESC;


-- ============================================
-- CHANNEL INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE channel IS NULL OR TRIM(channel) = '' OR UPPER(TRIM(channel)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values (Anomalies in channels)
SELECT
    TRIM(channel) AS channel_value,
    COUNT(*) AS occurrences
FROM bronze.marketing_event
WHERE channel IS NOT NULL AND TRIM(channel) <> '' AND UPPER(TRIM(channel)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(channel)
ORDER BY occurrences ASC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(channel)) AS normalized_channel,
    STRING_AGG(DISTINCT channel, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.marketing_event
WHERE channel IS NOT NULL AND TRIM(channel) <> '' AND UPPER(TRIM(channel)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(channel))
HAVING COUNT(DISTINCT channel) > 1
ORDER BY occurrences DESC;


-- ============================================
-- EVENT_TIMESTAMP INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE event_timestamp IS NULL OR TRIM(event_timestamp) = '' OR UPPER(TRIM(event_timestamp)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values / Business Rules (Future timestamps or before customer registration)
-- Future timestamp check:
SELECT *
FROM bronze.marketing_event
WHERE event_timestamp IS NOT NULL AND TRIM(event_timestamp) ~ '^\d{4}-\d{2}-\d{2}'
  AND LEFT(TRIM(event_timestamp), 10)::date > CURRENT_DATE;
-- Chronological check against customer registration:
SELECT m.event_id, m.customer_id, m.event_timestamp, c.registration_date
FROM bronze.marketing_event m
JOIN bronze.customer c ON TRIM(m.customer_id) = TRIM(c.customer_id)
WHERE m.event_timestamp IS NOT NULL AND TRIM(m.event_timestamp) ~ '^\d{4}-\d{2}-\d{2}'
  AND c.registration_date IS NOT NULL AND TRIM(c.registration_date) ~ '^\d{4}-\d{2}-\d{2}'
  AND LEFT(TRIM(m.event_timestamp), 10)::date < LEFT(TRIM(c.registration_date), 10)::date;

-- 4. Invalid Foreign Keys
-- (Not Applicable: Not a relational key)

-- 5. Invalid Data Types (Not YYYY-MM-DD HH:MM:SS or ISO datetime)
SELECT *
FROM bronze.marketing_event
WHERE event_timestamp IS NOT NULL AND TRIM(event_timestamp) <> '' AND UPPER(TRIM(event_timestamp)) NOT IN ('NULL', 'NAN')
  AND TRIM(event_timestamp) !~ '^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.marketing_event
WHERE event_timestamp IS NOT NULL AND event_timestamp <> TRIM(event_timestamp);


-- ============================================
-- DEVICE_TYPE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE device_type IS NULL OR TRIM(device_type) = '' OR UPPER(TRIM(device_type)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values (Not in allowed domain)
SELECT
    TRIM(device_type) AS device_value,
    COUNT(*) AS occurrences
FROM bronze.marketing_event
WHERE device_type IS NOT NULL AND TRIM(device_type) <> '' AND UPPER(TRIM(device_type)) NOT IN ('NULL', 'NAN')
  AND LOWER(TRIM(device_type)) NOT IN (
      'mobile', 'desktop', 'tablet'
  )
GROUP BY TRIM(device_type)
ORDER BY occurrences DESC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(device_type)) AS normalized_device,
    STRING_AGG(DISTINCT device_type, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.marketing_event
WHERE device_type IS NOT NULL AND TRIM(device_type) <> '' AND UPPER(TRIM(device_type)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(device_type))
HAVING COUNT(DISTINCT device_type) > 1
ORDER BY occurrences DESC;


-- ============================================
-- COUNTRY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.marketing_event
WHERE country IS NULL OR TRIM(country) = '' OR UPPER(TRIM(country)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values 
-- (Not Applicable)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Different textual representations e.g., EG vs Egypt)
SELECT
    LOWER(TRIM(country)) AS normalized_country,
    COUNT(DISTINCT country) AS different_representations,
    STRING_AGG(DISTINCT country, ', ' ORDER BY country) AS representations
FROM bronze.marketing_event
WHERE country IS NOT NULL AND TRIM(country) <> '' AND UPPER(TRIM(country)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(country))
HAVING COUNT(DISTINCT country) > 1
ORDER BY different_representations DESC;
