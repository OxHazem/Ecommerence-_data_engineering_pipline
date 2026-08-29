SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE requested_date IS NULL OR TRIM(requested_date) = '') AS null_requested_date,
    COUNT(*) FILTER (WHERE date IS NULL OR TRIM(date) = '') AS null_date,
    COUNT(*) FILTER (WHERE base IS NULL OR TRIM(base) = '') AS null_base,
    COUNT(*) FILTER (WHERE quote IS NULL OR TRIM(quote) = '') AS null_quote,
    COUNT(*) FILTER (WHERE rate IS NULL OR TRIM(rate) = '') AS null_rate

FROM bronze.exchange_rate;

-- ============================================
-- COMPOSITE KEY INVESTIGATION (requested_date, base, quote)
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.exchange_rate
WHERE requested_date IS NULL OR TRIM(requested_date) = '' OR UPPER(TRIM(requested_date)) IN ('NULL', 'NAN')
   OR base IS NULL OR TRIM(base) = '' OR UPPER(TRIM(base)) IN ('NULL', 'NAN')
   OR quote IS NULL OR TRIM(quote) = '' OR UPPER(TRIM(quote)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (A specific currency pair should only have one rate per requested date)
SELECT
    requested_date,
    base,
    quote,
    COUNT(*) AS duplicate_count
FROM bronze.exchange_rate
WHERE requested_date IS NOT NULL AND TRIM(requested_date) <> '' AND UPPER(TRIM(requested_date)) NOT IN ('NULL', 'NAN')
  AND base IS NOT NULL AND TRIM(base) <> '' AND UPPER(TRIM(base)) NOT IN ('NULL', 'NAN')
  AND quote IS NOT NULL AND TRIM(quote) <> '' AND UPPER(TRIM(quote)) NOT IN ('NULL', 'NAN')
GROUP BY requested_date, base, quote
HAVING COUNT(*) > 1
ORDER BY requested_date, base, quote;

-- ============================================
-- REQUESTED_DATE INVESTIGATION
-- ============================================

-- 1. Missing Values (Covered in composite key check above)

-- 2. Duplicate Records (Covered in composite key check above)

-- 3. Invalid Values / Business Rules (Future dates)
SELECT *
FROM bronze.exchange_rate
WHERE requested_date IS NOT NULL AND TRIM(requested_date) ~ '^\d{4}-\d{2}-\d{2}'
  AND LEFT(TRIM(requested_date), 10)::date > CURRENT_DATE;

-- 4. Invalid Foreign Keys
-- (Not Applicable: Date is not a relational key)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.exchange_rate
WHERE requested_date IS NOT NULL AND TRIM(requested_date) <> '' AND UPPER(TRIM(requested_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(requested_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.exchange_rate
WHERE requested_date IS NOT NULL AND requested_date <> TRIM(requested_date);


-- ============================================
-- DATE (Actual API Date) INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.exchange_rate
WHERE date IS NULL OR TRIM(date) = '' OR UPPER(TRIM(date)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Dates repeat for many currency pairs)

-- 3. Invalid Values / Business Rules (Future dates or extreme mismatch with requested_date)
SELECT *
FROM bronze.exchange_rate
WHERE date IS NOT NULL AND TRIM(date) ~ '^\d{4}-\d{2}-\d{2}'
  AND LEFT(TRIM(date), 10)::date > CURRENT_DATE;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types (Not YYYY-MM-DD or ISO datetime)
SELECT *
FROM bronze.exchange_rate
WHERE date IS NOT NULL AND TRIM(date) <> '' AND UPPER(TRIM(date)) NOT IN ('NULL', 'NAN')
  AND TRIM(date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.exchange_rate
WHERE date IS NOT NULL AND date <> TRIM(date);


-- ============================================
-- BASE CURRENCY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.exchange_rate
WHERE base IS NULL OR TRIM(base) = '' OR UPPER(TRIM(base)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values
-- (Not Applicable: Covered by format Regex below)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Not exactly 3 uppercase letters or has whitespace)
SELECT *
FROM bronze.exchange_rate
WHERE base IS NOT NULL AND TRIM(base) <> '' AND UPPER(TRIM(base)) NOT IN ('NULL', 'NAN')
  AND TRIM(base) !~ '^[A-Z]{3}$';


-- ============================================
-- QUOTE CURRENCY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.exchange_rate
WHERE quote IS NULL OR TRIM(quote) = '' OR UPPER(TRIM(quote)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable)

-- 3. Invalid Values
-- (Not Applicable: Covered by format Regex below)

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types
-- (Not Applicable: String)

-- 6. Inconsistent Formats (Not exactly 3 uppercase letters or has whitespace)
SELECT *
FROM bronze.exchange_rate
WHERE quote IS NOT NULL AND TRIM(quote) <> '' AND UPPER(TRIM(quote)) NOT IN ('NULL', 'NAN')
  AND TRIM(quote) !~ '^[A-Z]{3}$';


-- ============================================
-- RATE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.exchange_rate
WHERE rate IS NULL OR TRIM(rate) = '' OR UPPER(TRIM(rate)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: Numerical measure)

-- 3. Invalid Values (Zero or negative exchange rates)
SELECT *
FROM bronze.exchange_rate
WHERE rate IS NOT NULL AND TRIM(rate) ~ '^-?[0-9]+(\.[0-9]+)?(e-?[0-9]+)?$'
  AND CAST(TRIM(rate) AS DECIMAL(18,8)) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable)

-- 5. Invalid Data Types (Non-numeric strings like "invalid-rate")
SELECT *
FROM bronze.exchange_rate
WHERE rate IS NOT NULL AND TRIM(rate) <> '' AND UPPER(TRIM(rate)) NOT IN ('NULL', 'NAN')
  AND TRIM(rate) !~ '^-?[0-9]+(\.[0-9]+)?(e-?[0-9]+)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.exchange_rate
WHERE rate IS NOT NULL AND rate <> TRIM(rate);
