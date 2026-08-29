SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE payment_id IS NULL OR TRIM(payment_id) = '') AS null_payment_id,
    COUNT(*) FILTER (WHERE order_id IS NULL OR TRIM(order_id) = '') AS null_order_id,
    COUNT(*) FILTER (WHERE payment_date IS NULL OR TRIM(payment_date) = '') AS null_payment_date,
    COUNT(*) FILTER (WHERE payment_method IS NULL OR TRIM(payment_method) = '') AS null_payment_method,
    COUNT(*) FILTER (WHERE amount IS NULL OR TRIM(amount) = '') AS null_amount,
    COUNT(*) FILTER (WHERE currency IS NULL OR TRIM(currency) = '') AS null_currency,
    COUNT(*) FILTER (WHERE payment_status IS NULL OR TRIM(payment_status) = '') AS null_payment_status,
    COUNT(*) FILTER (WHERE transaction_reference IS NULL OR TRIM(transaction_reference) = '') AS null_transaction_reference

FROM bronze.payment;

-- ============================================
-- PAYMENT_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE payment_id IS NULL OR TRIM(payment_id) = '' OR UPPER(TRIM(payment_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Primary Key Uniqueness)
SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM bronze.payment
WHERE payment_id IS NOT NULL AND TRIM(payment_id) <> '' AND UPPER(TRIM(payment_id)) NOT IN ('NULL', 'NAN')
GROUP BY payment_id
HAVING COUNT(*) > 1
ORDER BY payment_id; 

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.payment
WHERE payment_id IS NOT NULL AND TRIM(payment_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(payment_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'payment_id' is the Primary Key for this table)

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.payment
WHERE payment_id IS NOT NULL AND TRIM(payment_id) <> '' AND UPPER(TRIM(payment_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(payment_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.payment
WHERE payment_id IS NOT NULL AND payment_id <> TRIM(payment_id);


-- ============================================
-- ORDER_ID INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE order_id IS NULL OR TRIM(order_id) = '' OR UPPER(TRIM(order_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Multiple payments for one order)
-- Dirty_Data.md defines this as a specific injected duplicate error
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM bronze.payment
WHERE order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN')
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id;

-- 3. Invalid Values (IDs cannot be zero or negative)
SELECT *
FROM bronze.payment
WHERE order_id IS NOT NULL AND TRIM(order_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(order_id) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys (order_id does not exist in bronze.orders)
SELECT p.*
FROM bronze.payment p
LEFT JOIN bronze.orders o ON TRIM(p.order_id) = TRIM(o.order_id)
WHERE p.order_id IS NOT NULL AND TRIM(p.order_id) ~ '^-?[0-9]+$'
  AND o.order_id IS NULL;

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.payment
WHERE order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(order_id) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.payment
WHERE order_id IS NOT NULL AND order_id <> TRIM(order_id);


-- ============================================
-- PAYMENT_DATE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE payment_date IS NULL OR TRIM(payment_date) = '' OR UPPER(TRIM(payment_date)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Many payments can happen on the exact same date)

-- 3. Invalid Values / Business Rules (Future dates or before order date)
-- Future payments check:
SELECT *
FROM bronze.payment
WHERE payment_date IS NOT NULL AND TRIM(payment_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(payment_date), 10)::date > CURRENT_DATE;
-- Chronological check against order date:
SELECT p.payment_id, p.order_id, p.payment_date, o.order_date
FROM bronze.payment p
JOIN bronze.orders o ON TRIM(p.order_id) = TRIM(o.order_id)
WHERE p.payment_date IS NOT NULL AND TRIM(p.payment_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND o.order_date IS NOT NULL AND TRIM(o.order_date) ~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
  AND LEFT(TRIM(p.payment_date), 10)::date < LEFT(TRIM(o.order_date), 10)::date;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'payment_date' is a date, not a key)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.payment
WHERE payment_date IS NOT NULL AND TRIM(payment_date) <> '' AND UPPER(TRIM(payment_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(payment_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.payment
WHERE payment_date IS NOT NULL AND payment_date <> TRIM(payment_date);


-- ============================================
-- PAYMENT_METHOD INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE payment_method IS NULL OR TRIM(payment_method) = '' OR UPPER(TRIM(payment_method)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Categorical column)

-- 3. Invalid Values (Anomalies in payment methods)
SELECT
    TRIM(payment_method) AS method_value,
    COUNT(*) AS occurrences
FROM bronze.payment
WHERE payment_method IS NOT NULL AND TRIM(payment_method) <> '' AND UPPER(TRIM(payment_method)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(payment_method)
ORDER BY occurrences ASC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Column is a string)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(payment_method)) AS normalized_method,
    STRING_AGG(DISTINCT payment_method, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.payment
WHERE payment_method IS NOT NULL AND TRIM(payment_method) <> '' AND UPPER(TRIM(payment_method)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(payment_method))
HAVING COUNT(DISTINCT payment_method) > 1
ORDER BY occurrences DESC;


SELECT
    TRIM(payment_method) AS method_value,
    COUNT(*) AS occurrences
FROM bronze.payment
WHERE payment_method IS NOT NULL
  AND TRIM(payment_method) <> ''
  AND UPPER(TRIM(payment_method)) NOT IN ('NULL', 'NAN')
  AND LOWER(TRIM(payment_method)) NOT IN (
      'credit_card',
      'debit_card',
      'paypal',
      'bank_transfer',
      'cash'
  )
GROUP BY TRIM(payment_method)
ORDER BY occurrences DESC;


-- ============================================
-- AMOUNT INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE amount IS NULL OR TRIM(amount) = '' OR UPPER(TRIM(amount)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: 'amount' is a numerical measure)

-- 3. Invalid Values (Negative amounts)
SELECT *
FROM bronze.payment
WHERE amount IS NOT NULL AND TRIM(amount) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND CAST(TRIM(amount) AS DECIMAL(12,2)) < 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'amount' is not a key)

-- 5. Invalid Data Types (Non-numeric strings like "one hundred")
SELECT *
FROM bronze.payment
WHERE amount IS NOT NULL AND TRIM(amount) <> '' AND UPPER(TRIM(amount)) NOT IN ('NULL', 'NAN')
  AND TRIM(amount) !~ '^-?[0-9]+(\.[0-9]+)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.payment
WHERE amount IS NOT NULL AND amount <> TRIM(amount);


-- ============================================
-- CURRENCY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE currency IS NULL OR TRIM(currency) = '' OR UPPER(TRIM(currency)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values 
-- (Not Applicable: Covered by format Regex below)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Column is a string)

-- 6. Inconsistent Formats (Not 3 uppercase letters or has whitespace)
SELECT *
FROM bronze.payment
WHERE currency IS NOT NULL AND TRIM(currency) <> '' AND UPPER(TRIM(currency)) NOT IN ('NULL', 'NAN')
  AND TRIM(currency) !~ '^[A-Z]{3}$';


-- ============================================
-- PAYMENT_STATUS INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE payment_status IS NULL OR TRIM(payment_status) = '' OR UPPER(TRIM(payment_status)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Categorical column)

-- 3. Invalid Values (Not in allowed domain, e.g. "InvalidStatus")
SELECT
    TRIM(payment_status) AS status_value,
    COUNT(*) AS occurrences
FROM bronze.payment
WHERE payment_status IS NOT NULL AND TRIM(payment_status) <> '' AND UPPER(TRIM(payment_status)) NOT IN ('NULL', 'NAN')
  AND LOWER(TRIM(payment_status)) NOT IN (
      'completed', 'pending', 'failed', 'refunded', 'cancelled'
  )
GROUP BY TRIM(payment_status)
ORDER BY occurrences DESC;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: Column is inherently a flexible string)

-- 6. Inconsistent Formats (Capitalization issues & Whitespace)
SELECT
    LOWER(TRIM(payment_status)) AS normalized_status,
    STRING_AGG(DISTINCT payment_status, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.payment
WHERE payment_status IS NOT NULL AND TRIM(payment_status) <> '' AND UPPER(TRIM(payment_status)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(payment_status))
HAVING COUNT(DISTINCT payment_status) > 1
ORDER BY occurrences DESC;


-- ============================================
-- TRANSACTION_REFERENCE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.payment
WHERE transaction_reference IS NULL OR TRIM(transaction_reference) = '' OR UPPER(TRIM(transaction_reference)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (A transaction reference should be completely unique)
SELECT
    transaction_reference,
    COUNT(*) AS duplicate_count
FROM bronze.payment
WHERE transaction_reference IS NOT NULL AND TRIM(transaction_reference) <> '' AND UPPER(TRIM(transaction_reference)) NOT IN ('NULL', 'NAN')
GROUP BY transaction_reference
HAVING COUNT(*) > 1
ORDER BY transaction_reference;

-- 3. Invalid Values 
-- (Not Applicable: Transaction refs are usually opaque strings)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.payment
WHERE transaction_reference IS NOT NULL AND transaction_reference <> TRIM(transaction_reference);





SELECT
    payment_status,
    COUNT(*) AS occurrences
FROM bronze.payment
GROUP BY payment_status
ORDER BY occurrences DESC;