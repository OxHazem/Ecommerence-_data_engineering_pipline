SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE review_id IS NULL OR TRIM(review_id) = '') AS null_review_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS null_customer_id,
    COUNT(*) FILTER (WHERE product_id IS NULL OR TRIM(product_id) = '') AS null_product_id,
    COUNT(*) FILTER (WHERE rating IS NULL OR TRIM(rating) = '') AS null_rating,
    COUNT(*) FILTER (WHERE review_text IS NULL OR TRIM(review_text) = '') AS null_review_text,
    COUNT(*) FILTER (WHERE review_date IS NULL OR TRIM(review_date) = '') AS null_review_date,
    COUNT(*) FILTER (WHERE verified_purchase IS NULL OR TRIM(verified_purchase) = '') AS null_verified_purchase,
    COUNT(*) FILTER (WHERE review_status IS NULL OR TRIM(review_status) = '') AS null_review_status

FROM bronze.review;

-- ============================================
-- REVIEW_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.review
WHERE review_id IS NULL OR TRIM(review_id) = '' OR UPPER(TRIM(review_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Primary Key Uniqueness)
SELECT
    review_id,
    COUNT(*) AS duplicate_count
FROM bronze.review
WHERE review_id IS NOT NULL AND TRIM(review_id) <> '' AND UPPER(TRIM(review_id)) NOT IN ('NULL', 'NAN')
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY review_id; 

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.review
WHERE review_id IS NOT NULL AND TRIM(review_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(review_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'review_id' is the Primary Key for this table)

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.review
WHERE review_id IS NOT NULL AND TRIM(review_id) <> '' AND UPPER(TRIM(review_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(review_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.review
WHERE review_id IS NOT NULL AND review_id <> TRIM(review_id);


-- ============================================
-- CUSTOMER_ID & PRODUCT_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.review
WHERE customer_id IS NULL OR TRIM(customer_id) = '' OR UPPER(TRIM(customer_id)) IN ('NULL', 'NAN')
   OR product_id IS NULL OR TRIM(product_id) = '' OR UPPER(TRIM(product_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Business Rule: A customer should only review a specific product once)
SELECT
    customer_id,
    product_id,
    COUNT(*) AS duplicate_count
FROM bronze.review
WHERE customer_id IS NOT NULL AND TRIM(customer_id) <> '' AND UPPER(TRIM(customer_id)) NOT IN ('NULL', 'NAN')
  AND product_id IS NOT NULL AND TRIM(product_id) <> '' AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN')
GROUP BY customer_id, product_id
HAVING COUNT(*) > 1
ORDER BY customer_id, product_id;

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.review
WHERE (customer_id IS NOT NULL AND TRIM(customer_id) ~ '^-?[0-9]+$' AND CAST(TRIM(customer_id) AS BIGINT) <= 0)
   OR (product_id IS NOT NULL AND TRIM(product_id) ~ '^-?[0-9]+$' AND CAST(TRIM(product_id) AS BIGINT) <= 0);

-- 4. Invalid Foreign Keys
-- customer_id does not exist in bronze.customer
SELECT r.*
FROM bronze.review r
LEFT JOIN bronze.customer c ON TRIM(r.customer_id) = TRIM(c.customer_id)
WHERE r.customer_id IS NOT NULL AND TRIM(r.customer_id) ~ '^-?[0-9]+$'
  AND c.customer_id IS NULL;
-- product_id does not exist in bronze.product
SELECT r.*
FROM bronze.review r
LEFT JOIN bronze.product p ON TRIM(r.product_id) = TRIM(p.product_id)
WHERE r.product_id IS NOT NULL AND TRIM(r.product_id) ~ '^-?[0-9]+$'
  AND p.product_id IS NULL;

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.review
WHERE (customer_id IS NOT NULL AND TRIM(customer_id) <> '' AND UPPER(TRIM(customer_id)) NOT IN ('NULL', 'NAN') AND TRIM(customer_id) !~ '^-?[0-9]+$')
   OR (product_id IS NOT NULL AND TRIM(product_id) <> '' AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN') AND TRIM(product_id) !~ '^-?[0-9]+$');

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.review
WHERE (customer_id IS NOT NULL AND customer_id <> TRIM(customer_id))
   OR (product_id IS NOT NULL AND product_id <> TRIM(product_id));


-- ============================================
-- RATING INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.review
WHERE rating IS NULL OR TRIM(rating) = '' OR UPPER(TRIM(rating)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Rating is a categorical/numerical score)

-- 3. Invalid Values (Rating must be strictly between 1 and 5)
SELECT *
FROM bronze.review
WHERE rating IS NOT NULL AND TRIM(rating) ~ '^-?[0-9]+$'
  AND (CAST(TRIM(rating) AS BIGINT) < 1 OR CAST(TRIM(rating) AS BIGINT) > 5);

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'rating' is not a key)

-- 5. Invalid Data Types (Non-integer strings like "excellent")
SELECT *
FROM bronze.review
WHERE rating IS NOT NULL AND TRIM(rating) <> '' AND UPPER(TRIM(rating)) NOT IN ('NULL', 'NAN')
  AND TRIM(rating) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.review
WHERE rating IS NOT NULL AND rating <> TRIM(rating);


-- ============================================
-- REVIEW_TEXT INVESTIGATION
-- ============================================

-- 1. Missing Values (Completely empty reviews)
SELECT *
FROM bronze.review
WHERE review_text IS NULL OR TRIM(review_text) = '' OR UPPER(TRIM(review_text)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values
-- (Not Applicable: Free text field)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Field is inherently text)

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.review
WHERE review_text IS NOT NULL AND review_text <> TRIM(review_text);


-- ============================================
-- REVIEW_DATE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.review
WHERE review_date IS NULL OR TRIM(review_date) = '' OR UPPER(TRIM(review_date)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Many reviews can happen on the exact same date)

-- 3. Invalid Values / Business Rules (Future dates or before customer registration)
-- Future review check:
SELECT *
FROM bronze.review
WHERE review_date IS NOT NULL AND TRIM(review_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(review_date), 10)::date > CURRENT_DATE;
-- Chronological check against customer registration:
SELECT r.review_id, r.customer_id, r.review_date, c.registration_date
FROM bronze.review r
JOIN bronze.customer c ON TRIM(r.customer_id) = TRIM(c.customer_id)
WHERE r.review_date IS NOT NULL AND TRIM(r.review_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND c.registration_date IS NOT NULL AND TRIM(c.registration_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(r.review_date), 10)::date < LEFT(TRIM(c.registration_date), 10)::date;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'review_date' is a date, not a key)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.review
WHERE review_date IS NOT NULL AND TRIM(review_date) <> '' AND UPPER(TRIM(review_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(review_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.review
WHERE review_date IS NOT NULL AND review_date <> TRIM(review_date);


-- ============================================
-- VERIFIED_PURCHASE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.review
WHERE verified_purchase IS NULL OR TRIM(verified_purchase) = '' OR UPPER(TRIM(verified_purchase)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Boolean column)

-- 3. Invalid Values / Data Types (Not recognized as boolean)
SELECT *
FROM bronze.review
WHERE verified_purchase IS NOT NULL AND TRIM(verified_purchase) <> '' AND UPPER(TRIM(verified_purchase)) NOT IN ('NULL', 'NAN')
  AND LOWER(TRIM(verified_purchase)) NOT IN ('true', 'false', 't', 'f', '1', '0');

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Checked by invalid values block)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(verified_purchase)) AS normalized_boolean,
    STRING_AGG(DISTINCT verified_purchase, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.review
WHERE verified_purchase IS NOT NULL AND TRIM(verified_purchase) <> '' AND UPPER(TRIM(verified_purchase)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(verified_purchase))
HAVING COUNT(DISTINCT verified_purchase) > 1
ORDER BY occurrences DESC;


-- ============================================
-- REVIEW_STATUS INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.review
WHERE review_status IS NULL OR TRIM(review_status) = '' OR UPPER(TRIM(review_status)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Categorical column)

-- 3. Invalid Values (Not in allowed domain e.g. Published, Pending, Rejected)
SELECT
    TRIM(review_status) AS status_value,
    COUNT(*) AS occurrences
FROM bronze.review
WHERE review_status IS NOT NULL AND TRIM(review_status) <> '' AND UPPER(TRIM(review_status)) NOT IN ('NULL', 'NAN')
  AND LOWER(TRIM(review_status)) NOT IN (
      'published', 'pending', 'rejected'
  )
GROUP BY TRIM(review_status)
ORDER BY occurrences DESC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Column is inherently a flexible string)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(review_status)) AS normalized_status,
    STRING_AGG(DISTINCT review_status, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.review
WHERE review_status IS NOT NULL AND TRIM(review_status) <> '' AND UPPER(TRIM(review_status)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(review_status))
HAVING COUNT(DISTINCT review_status) > 1
ORDER BY occurrences DESC;
