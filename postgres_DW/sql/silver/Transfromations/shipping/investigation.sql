SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE shipment_id IS NULL OR TRIM(shipment_id) = '') AS null_shipment_id,
    COUNT(*) FILTER (WHERE order_id IS NULL OR TRIM(order_id) = '') AS null_order_id,
    COUNT(*) FILTER (WHERE shipping_date IS NULL OR TRIM(shipping_date) = '') AS null_shipping_date,
    COUNT(*) FILTER (WHERE estimated_delivery_date IS NULL OR TRIM(estimated_delivery_date) = '') AS null_estimated_delivery_date,
    COUNT(*) FILTER (WHERE delivery_date IS NULL OR TRIM(delivery_date) = '') AS null_delivery_date,
    COUNT(*) FILTER (WHERE shipping_country IS NULL OR TRIM(shipping_country) = '') AS null_shipping_country,
    COUNT(*) FILTER (WHERE shipping_city IS NULL OR TRIM(shipping_city) = '') AS null_shipping_city,
    COUNT(*) FILTER (WHERE shipping_method IS NULL OR TRIM(shipping_method) = '') AS null_shipping_method,
    COUNT(*) FILTER (WHERE shipping_status IS NULL OR TRIM(shipping_status) = '') AS null_shipping_status,
    COUNT(*) FILTER (WHERE shipping_cost IS NULL OR TRIM(shipping_cost) = '') AS null_shipping_cost

FROM bronze.shipping;

-- ============================================
-- SHIPMENT_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE shipment_id IS NULL OR TRIM(shipment_id) = '' OR UPPER(TRIM(shipment_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Primary Key Uniqueness)
SELECT
    shipment_id,
    COUNT(*) AS duplicate_count
FROM bronze.shipping
WHERE shipment_id IS NOT NULL AND TRIM(shipment_id) <> '' AND UPPER(TRIM(shipment_id)) NOT IN ('NULL', 'NAN')
GROUP BY shipment_id
HAVING COUNT(*) > 1
ORDER BY shipment_id; 

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.shipping
WHERE shipment_id IS NOT NULL AND TRIM(shipment_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(shipment_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'shipment_id' is the Primary Key for this table)

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.shipping
WHERE shipment_id IS NOT NULL AND TRIM(shipment_id) <> '' AND UPPER(TRIM(shipment_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(shipment_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.shipping
WHERE shipment_id IS NOT NULL AND shipment_id <> TRIM(shipment_id);


-- ============================================
-- ORDER_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE order_id IS NULL OR TRIM(order_id) = '' OR UPPER(TRIM(order_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Multiple shipments for one order - explicitly injected error)
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM bronze.shipping
WHERE order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN')
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id;

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.shipping
WHERE order_id IS NOT NULL AND TRIM(order_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(order_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys (order_id does not exist in bronze.orders)
SELECT s.*
FROM bronze.shipping s
LEFT JOIN bronze.orders o ON TRIM(s.order_id) = TRIM(o.order_id)
WHERE s.order_id IS NOT NULL AND TRIM(s.order_id) ~ '^-?[0-9]+$'
  AND o.order_id IS NULL;

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.shipping
WHERE order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(order_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.shipping
WHERE order_id IS NOT NULL AND order_id <> TRIM(order_id);


-- ============================================
-- SHIPPING_DATE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE shipping_date IS NULL OR TRIM(shipping_date) = '' OR UPPER(TRIM(shipping_date)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Many shipments happen on the exact same date)

-- 3. Invalid Values / Business Rules (Chronological check against order date)
SELECT s.shipment_id, s.order_id, s.shipping_date, o.order_date
FROM bronze.shipping s
JOIN bronze.orders o ON TRIM(s.order_id) = TRIM(o.order_id)
WHERE s.shipping_date IS NOT NULL AND TRIM(s.shipping_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND o.order_date IS NOT NULL AND TRIM(o.order_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(s.shipping_date), 10)::date < LEFT(TRIM(o.order_date), 10)::date;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.shipping
WHERE shipping_date IS NOT NULL AND TRIM(shipping_date) <> '' AND UPPER(TRIM(shipping_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(shipping_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.shipping
WHERE shipping_date IS NOT NULL AND shipping_date <> TRIM(shipping_date);


-- ============================================
-- ESTIMATED_DELIVERY_DATE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE estimated_delivery_date IS NULL OR TRIM(estimated_delivery_date) = '' OR UPPER(TRIM(estimated_delivery_date)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values / Business Rules (Estimated delivery before shipping date)
SELECT *
FROM bronze.shipping
WHERE estimated_delivery_date IS NOT NULL AND TRIM(estimated_delivery_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND shipping_date IS NOT NULL AND TRIM(shipping_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(estimated_delivery_date), 10)::date < LEFT(TRIM(shipping_date), 10)::date;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.shipping
WHERE estimated_delivery_date IS NOT NULL AND TRIM(estimated_delivery_date) <> '' AND UPPER(TRIM(estimated_delivery_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(estimated_delivery_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.shipping
WHERE estimated_delivery_date IS NOT NULL AND estimated_delivery_date <> TRIM(estimated_delivery_date);


-- ============================================
-- DELIVERY_DATE INVESTIGATION
-- ============================================

-- 1. Missing Values (A NULL delivery_date CAN be valid for undelivered packages, surfacing for context)
SELECT *
FROM bronze.shipping
WHERE delivery_date IS NULL OR TRIM(delivery_date) = '' OR UPPER(TRIM(delivery_date)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values / Business Rules (Actual delivery before shipping date)
SELECT *
FROM bronze.shipping
WHERE delivery_date IS NOT NULL AND TRIM(delivery_date) <> '' AND UPPER(TRIM(delivery_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(delivery_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND shipping_date IS NOT NULL AND TRIM(shipping_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(delivery_date), 10)::date < LEFT(TRIM(shipping_date), 10)::date;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.shipping
WHERE delivery_date IS NOT NULL AND TRIM(delivery_date) <> '' AND UPPER(TRIM(delivery_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(delivery_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.shipping
WHERE delivery_date IS NOT NULL AND delivery_date <> TRIM(delivery_date);


-- ============================================
-- SHIPPING_COUNTRY & SHIPPING_CITY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE shipping_country IS NULL OR TRIM(shipping_country) = '' OR UPPER(TRIM(shipping_country)) IN ('NULL', 'NAN')
   OR shipping_city IS NULL OR TRIM(shipping_city) = '' OR UPPER(TRIM(shipping_city)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values 
-- (Not Applicable)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Strings)

-- 6. Inconsistent Formats (Different textual representations e.g., EG vs Egypt or capitalization)
SELECT
    LOWER(TRIM(shipping_country)) AS normalized_country,
    COUNT(DISTINCT shipping_country) AS different_representations,
    STRING_AGG(DISTINCT shipping_country, ', ' ORDER BY shipping_country) AS representations
FROM bronze.shipping
WHERE shipping_country IS NOT NULL AND TRIM(shipping_country) <> '' AND UPPER(TRIM(shipping_country)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(shipping_country))
HAVING COUNT(DISTINCT shipping_country) > 1
ORDER BY different_representations DESC;

SELECT
    LOWER(TRIM(shipping_city)) AS normalized_city,
    COUNT(DISTINCT shipping_city) AS different_representations,
    STRING_AGG(DISTINCT shipping_city, ', ' ORDER BY shipping_city) AS representations
FROM bronze.shipping
WHERE shipping_city IS NOT NULL AND TRIM(shipping_city) <> '' AND UPPER(TRIM(shipping_city)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(shipping_city))
HAVING COUNT(DISTINCT shipping_city) > 1
ORDER BY different_representations DESC;


-- ============================================
-- SHIPPING_METHOD INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE shipping_method IS NULL OR TRIM(shipping_method) = '' OR UPPER(TRIM(shipping_method)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values (Anomalies in shipping methods)
SELECT
    TRIM(shipping_method) AS method_value,
    COUNT(*) AS occurrences
FROM bronze.shipping
WHERE shipping_method IS NOT NULL AND TRIM(shipping_method) <> '' AND UPPER(TRIM(shipping_method)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(shipping_method)
ORDER BY occurrences ASC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(shipping_method)) AS normalized_method,
    STRING_AGG(DISTINCT shipping_method, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.shipping
WHERE shipping_method IS NOT NULL AND TRIM(shipping_method) <> '' AND UPPER(TRIM(shipping_method)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(shipping_method))
HAVING COUNT(DISTINCT shipping_method) > 1
ORDER BY occurrences DESC;


-- ============================================
-- SHIPPING_STATUS INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE shipping_status IS NULL OR TRIM(shipping_status) = '' OR UPPER(TRIM(shipping_status)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values (Not in allowed domain)
SELECT
    TRIM(shipping_status) AS status_value,
    COUNT(*) AS occurrences
FROM bronze.shipping
WHERE shipping_status IS NOT NULL AND TRIM(shipping_status) <> '' AND UPPER(TRIM(shipping_status)) NOT IN ('NULL', 'NAN')
  AND LOWER(TRIM(shipping_status)) NOT IN (
      'pending', 'shipped', 'in transit', 'delivered', 'returned', 'failed'
  )
GROUP BY TRIM(shipping_status)
ORDER BY occurrences DESC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(shipping_status)) AS normalized_status,
    STRING_AGG(DISTINCT shipping_status, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.shipping
WHERE shipping_status IS NOT NULL AND TRIM(shipping_status) <> '' AND UPPER(TRIM(shipping_status)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(shipping_status))
HAVING COUNT(DISTINCT shipping_status) > 1
ORDER BY occurrences DESC;


-- ============================================
-- SHIPPING_COST INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.shipping
WHERE shipping_cost IS NULL OR TRIM(shipping_cost) = '' OR UPPER(TRIM(shipping_cost)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: measure)

-- 3. Invalid Values (Negative costs)
SELECT *
FROM bronze.shipping
WHERE shipping_cost IS NOT NULL AND TRIM(shipping_cost) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND CAST(TRIM(shipping_cost) AS DECIMAL(10,2)) < 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types (Non-numeric strings)
SELECT *
FROM bronze.shipping
WHERE shipping_cost IS NOT NULL AND TRIM(shipping_cost) <> '' AND UPPER(TRIM(shipping_cost)) NOT IN ('NULL', 'NAN')
  AND TRIM(shipping_cost) !~ '^-?[0-9]+(\.[0-9]+)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.shipping
WHERE shipping_cost IS NOT NULL AND shipping_cost <> TRIM(shipping_cost);



SELECT
    shipping_status,
    COUNT(*) AS occurrences
FROM bronze.shipping
GROUP BY shipping_status
ORDER BY occurrences DESC;


SELECT
    TRIM(shipping_date) AS date_value,
    COUNT(*) AS occurrences
FROM bronze.shipping
WHERE shipping_date IS NOT NULL
  AND TRIM(shipping_date) <> ''
  AND UPPER(TRIM(shipping_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(shipping_date) !~ '^\d{4}-\d{2}-\d{2}'
GROUP BY TRIM(shipping_date)
ORDER BY occurrences DESC;