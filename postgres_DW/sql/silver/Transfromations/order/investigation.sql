SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE order_id IS NULL OR TRIM(order_id) = '') AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS null_customer_id,
    COUNT(*) FILTER (WHERE order_date IS NULL OR TRIM(order_date) = '') AS null_order_date,
    COUNT(*) FILTER (WHERE order_status IS NULL OR TRIM(order_status) = '') AS null_order_status,
    COUNT(*) FILTER (WHERE currency IS NULL OR TRIM(currency) = '') AS null_currency,
    COUNT(*) FILTER (WHERE shipping_country IS NULL OR TRIM(shipping_country) = '') AS null_shipping_country,
    COUNT(*) FILTER (WHERE shipping_city IS NULL OR TRIM(shipping_city) = '') AS null_shipping_city

FROM bronze.orders;

-- ============================================
-- ORDER_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.orders
WHERE order_id IS NULL OR TRIM(order_id) = '' OR UPPER(TRIM(order_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Primary Key Uniqueness)
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM bronze.orders
WHERE order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN')
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id; 

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.orders
WHERE order_id IS NOT NULL AND TRIM(order_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(order_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'order_id' is the Primary Key for this table)

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.orders
WHERE order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(order_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.orders
WHERE order_id IS NOT NULL AND order_id <> TRIM(order_id);


-- ============================================
-- CUSTOMER_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.orders
WHERE customer_id IS NULL OR TRIM(customer_id) = '' OR UPPER(TRIM(customer_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: One customer can legitimately place multiple orders)

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.orders
WHERE customer_id IS NOT NULL AND TRIM(customer_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(customer_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys (customer_id does not exist in bronze.customer)
SELECT o.*
FROM bronze.orders o
LEFT JOIN bronze.customer c ON TRIM(o.customer_id) = TRIM(c.customer_id)
WHERE o.customer_id IS NOT NULL AND TRIM(o.customer_id) ~ '^-?[0-9]+$'
  AND c.customer_id IS NULL;

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.orders
WHERE customer_id IS NOT NULL AND TRIM(customer_id) <> '' AND UPPER(TRIM(customer_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(customer_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.orders
WHERE customer_id IS NOT NULL AND customer_id <> TRIM(customer_id);


-- ============================================
-- ORDER_DATE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.orders
WHERE order_date IS NULL OR TRIM(order_date) = '' OR UPPER(TRIM(order_date)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Many orders can happen on the exact same date)

-- 3. Invalid Values / Business Rules (Future dates or before registration)
-- Future orders check:
SELECT *
FROM bronze.orders
WHERE order_date IS NOT NULL AND TRIM(order_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(order_date), 10)::date > CURRENT_DATE;
-- Chronological check against customer registration:
SELECT o.order_id, o.customer_id, o.order_date, c.registration_date
FROM bronze.orders o
JOIN bronze.customer c ON TRIM(o.customer_id) = TRIM(c.customer_id)
WHERE o.order_date IS NOT NULL AND TRIM(o.order_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND c.registration_date IS NOT NULL AND TRIM(c.registration_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(o.order_date), 10)::date < LEFT(TRIM(c.registration_date), 10)::date;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'order_date' is a date, not a relational key)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.orders
WHERE order_date IS NOT NULL AND TRIM(order_date) <> '' AND UPPER(TRIM(order_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(order_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.orders
WHERE order_date IS NOT NULL AND order_date <> TRIM(order_date);


-- ============================================
-- ORDER_STATUS INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.orders
WHERE order_status IS NULL OR TRIM(order_status) = '' OR UPPER(TRIM(order_status)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Status is a categorical classification)

-- 3. Invalid Values (Not in allowed domain)
SELECT
    TRIM(order_status) AS status_value,
    COUNT(*) AS occurrences
FROM bronze.orders
WHERE order_status IS NOT NULL AND TRIM(order_status) <> '' AND UPPER(TRIM(order_status)) NOT IN ('NULL', 'NAN')
  AND LOWER(TRIM(order_status)) NOT IN (
      'pending', 'processing', 'shipped', 'delivered', 'cancelled', 'returned'
  )
GROUP BY TRIM(order_status)
ORDER BY occurrences DESC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Column is inherently a flexible string)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(order_status)) AS normalized_status,
    STRING_AGG(DISTINCT order_status, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.orders
WHERE order_status IS NOT NULL AND TRIM(order_status) <> '' AND UPPER(TRIM(order_status)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(order_status))
HAVING COUNT(DISTINCT order_status) > 1
ORDER BY occurrences DESC;


-- ============================================
-- CURRENCY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.orders
WHERE currency IS NULL OR TRIM(currency) = '' OR UPPER(TRIM(currency)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values 
-- (Not Applicable: Captured completely by the format Regex below)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Column is a string)

-- 6. Inconsistent Formats (Not 3 uppercase letters or has whitespace)
SELECT *
FROM bronze.orders
WHERE currency IS NOT NULL AND TRIM(currency) <> '' AND UPPER(TRIM(currency)) NOT IN ('NULL', 'NAN')
  AND TRIM(currency) !~ '^[A-Z]{3}$';


-- ============================================
-- SHIPPING_COUNTRY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.orders
WHERE shipping_country IS NULL OR TRIM(shipping_country) = '' OR UPPER(TRIM(shipping_country)) IN ('NULL', 'NAN');

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
    LOWER(TRIM(shipping_country)) AS normalized_country,
    COUNT(DISTINCT shipping_country) AS different_representations,
    STRING_AGG(DISTINCT shipping_country, ', ' ORDER BY shipping_country) AS representations
FROM bronze.orders
WHERE shipping_country IS NOT NULL AND TRIM(shipping_country) <> '' AND UPPER(TRIM(shipping_country)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(shipping_country))
HAVING COUNT(DISTINCT shipping_country) > 1
ORDER BY different_representations DESC;


-- ============================================
-- SHIPPING_CITY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.orders
WHERE shipping_city IS NULL OR TRIM(shipping_city) = '' OR UPPER(TRIM(shipping_city)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values 
-- (Not Applicable)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Different textual representations)
SELECT
    LOWER(TRIM(shipping_city)) AS normalized_city,
    COUNT(DISTINCT shipping_city) AS different_representations,
    STRING_AGG(DISTINCT shipping_city, ', ' ORDER BY shipping_city) AS representations
FROM bronze.orders
WHERE shipping_city IS NOT NULL AND TRIM(shipping_city) <> '' AND UPPER(TRIM(shipping_city)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(shipping_city))
HAVING COUNT(DISTINCT shipping_city) > 1
ORDER BY different_representations DESC;



