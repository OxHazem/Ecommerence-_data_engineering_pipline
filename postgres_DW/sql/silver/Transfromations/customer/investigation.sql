SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE first_name IS NULL) AS null_first_name,
    COUNT(*) FILTER (WHERE last_name IS NULL) AS null_last_name,
    COUNT(*) FILTER (WHERE email IS NULL) AS null_email,
    COUNT(*) FILTER (WHERE phone IS NULL) AS null_phone,
    COUNT(*) FILTER (WHERE gender IS NULL) AS null_gender,
    COUNT(*) FILTER (WHERE date_of_birth IS NULL) AS null_date_of_birth,
    COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
    COUNT(*) FILTER (WHERE city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE registration_date IS NULL) AS null_registration_date,
    COUNT(*) FILTER (WHERE customer_status IS NULL) AS null_customer_status

FROM bronze.customer;

-- ============================================
-- CUSTOMER_ID INVESTIGATION
-- ============================================

-- 1. Missing / special missing values
SELECT *
FROM bronze.customer
WHERE customer_id IS NULL
   OR TRIM(customer_id) = ''
   OR UPPER(TRIM(customer_id)) IN ('NULL', 'NAN'); --no missing values or special missing values like 'NULL' or 'NaN' in customer_id column


-- 2. Whitespace inconsistencies
SELECT *
FROM bronze.customer
WHERE customer_id IS NOT NULL
  AND customer_id <> TRIM(customer_id); -- customer_id doesnot have leading or trailing whitespace


-- 3. Invalid data type / non-integer values
SELECT *
FROM bronze.customer
WHERE customer_id IS NOT NULL
  AND TRIM(customer_id) <> ''
  AND UPPER(TRIM(customer_id)) NOT IN ('NULL', 'NAN') -- exclude special missing values
  AND TRIM(customer_id) !~ '^-?[0-9]+$';


-- 4. Invalid values: zero or negative
SELECT *
FROM bronze.customer
WHERE customer_id IS NOT NULL
  AND TRIM(customer_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(customer_id) AS BIGINT) <= 0; -- no zero or negative customer IDs


-- 5. Duplicate customer IDs
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM bronze.customer
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY customer_id; 


-- 6. Show the actual duplicate records
SELECT *
FROM bronze.customer
WHERE customer_id IN (
    SELECT customer_id
    FROM bronze.customer
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)     -- there are duplicates
ORDER BY customer_id, registration_date DESC;

-- checking for inconsistencies in customer_id column

SELECT
    customer_id,
    '[' || customer_id || ']' AS visible_value,
    LENGTH(customer_id) AS original_length,
    LENGTH(TRIM(customer_id)) AS trimmed_length
FROM bronze.customer
WHERE customer_id IS NOT NULL
  AND customer_id <> TRIM(customer_id)
ORDER BY customer_id;


-- ============================================
-- Customer_id
-- Business Rule Validation
-- ============================================

SELECT *
FROM bronze.customer
WHERE customer_id IS NOT NULL
  AND TRIM(customer_id) ~ '^-?[0-9]+$'
  AND CAST(TRIM(customer_id) AS BIGINT) <= 0;


-- ============================================
-- First_name
-- Missing values
-- ============================================

SELECT *
FROM bronze.customer
WHERE first_name IS NULL
   OR TRIM(first_name) = ''
   OR UPPER(TRIM(first_name)) IN ('NULL', 'NAN');

-- ============================================
-- First_name
-- Invalid values / format
-- ============================================

SELECT *
FROM bronze.customer
WHERE first_name IS NOT NULL
  AND TRIM(first_name) <> ''
  AND TRIM(first_name) !~ '^[A-Za-z]+$';



-- ============================================
-- Last_name
-- Missing values
-- ============================================

SELECT *
FROM bronze.customer
WHERE last_name IS NULL
   OR TRIM(last_name) = ''
   OR UPPER(TRIM(last_name)) IN ('NULL', 'NAN');


-- ============================================
-- Last_name
-- Invalid / non-alphabetic values
-- ============================================

SELECT *
FROM bronze.customer
WHERE last_name IS NOT NULL
  AND TRIM(last_name) <> ''
  AND TRIM(last_name) !~ '^[A-Za-z]+$';


-- ============================================
-- Email
-- ============================================

-- 1. Missing values
SELECT *
FROM bronze.customer
WHERE email IS NULL
   OR TRIM(email) = ''
   OR UPPER(TRIM(email)) IN ('NULL', 'NAN');


-- 2. Invalid email values
SELECT *
FROM bronze.customer
WHERE email IS NOT NULL
  AND TRIM(email) <> ''
  AND UPPER(TRIM(email)) NOT IN ('NULL', 'NAN')
  AND TRIM(email) !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

SELECT
    COUNT(*) AS invalid_email_count
FROM bronze.customer
WHERE email IS NOT NULL
  AND TRIM(email) <> ''
  AND UPPER(TRIM(email)) NOT IN ('NULL', 'NAN')
  AND TRIM(email) !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

SELECT
    TRIM(email) AS invalid_email,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE email IS NOT NULL
  AND TRIM(email) <> ''
  AND UPPER(TRIM(email)) NOT IN ('NULL', 'NAN')
  AND TRIM(email) !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
GROUP BY TRIM(email)
ORDER BY occurrences DESC;
-- 3. Inconsistent whitespace
SELECT *
FROM bronze.customer
WHERE email IS NOT NULL
  AND email <> TRIM(email);


-- ============================================
-- Phone
-- Missing values
-- ============================================

SELECT *
FROM bronze.customer
WHERE phone IS NULL
   OR TRIM(phone) = ''
   OR UPPER(TRIM(phone)) IN ('NULL', 'NAN');


-- ============================================
-- Phone
-- Inspect distinct formats
-- ============================================

SELECT
    phone,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE phone IS NOT NULL
  AND TRIM(phone) <> ''
  AND UPPER(TRIM(phone)) NOT IN ('NULL', 'NAN')
GROUP BY phone
ORDER BY occurrences DESC;



SELECT
    CASE
        WHEN TRIM(phone) ~ '^\+\d+ \d+$'
            THEN 'international_with_space'

        WHEN TRIM(phone) ~ '^\d+$'
            THEN 'digits_only'

        WHEN TRIM(phone) ~ '^\d{3}-\d{3}-\d{4}$'
            THEN 'hyphenated'

        ELSE 'other'
    END AS phone_format,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE phone IS NOT NULL
  AND TRIM(phone) <> ''
  AND UPPER(TRIM(phone)) NOT IN ('NULL', 'NAN')
GROUP BY phone_format
ORDER BY occurrences DESC;


SELECT *
FROM bronze.customer
WHERE phone IS NOT NULL
  AND TRIM(phone) <> ''
  AND UPPER(TRIM(phone)) NOT IN ('NULL', 'NAN')
  AND TRIM(phone) !~ '^\+\d+ \d+$'
  AND TRIM(phone) !~ '^\d+$'
  AND TRIM(phone) !~ '^\d{3}-\d{3}-\d{4}$';


SELECT
    COUNT(*) AS missing_phone_count
FROM bronze.customer
WHERE phone IS NULL
   OR TRIM(phone) = ''
   OR UPPER(TRIM(phone)) IN ('NULL', 'NAN');



-- ============================================
-- Gender
-- Missing values
-- ============================================

SELECT
    COUNT(*) AS missing_gender_count
FROM bronze.customer
WHERE gender IS NULL
   OR TRIM(gender) = ''
   OR UPPER(TRIM(gender)) IN ('NULL', 'NAN');




-- ============================================
-- Gender
-- Distinct values
-- ============================================

SELECT
    TRIM(gender) AS gender_value,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE gender IS NOT NULL
  AND TRIM(gender) <> ''
  AND UPPER(TRIM(gender)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(gender)
ORDER BY occurrences DESC;




-- ============================================
-- Gender
-- Invalid values
-- ============================================

SELECT
    TRIM(gender) AS gender_value,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE gender IS NOT NULL
  AND TRIM(gender) <> ''
  AND UPPER(TRIM(gender)) NOT IN ('NULL', 'NAN')
  AND TRIM(gender) NOT IN ('Male', 'Female', 'Other', 'Unknown')
GROUP BY TRIM(gender)
ORDER BY occurrences DESC;



-- ============================================
-- Gender
-- Potential capitalization inconsistency
-- ============================================

SELECT
    TRIM(gender) AS gender_value,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE gender IS NOT NULL
  AND TRIM(gender) <> ''
  AND UPPER(TRIM(gender)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(gender)
ORDER BY gender_value;


-- ============================================
-- Date_of_birth
-- Missing values
-- ============================================

SELECT
    COUNT(*) AS missing_date_of_birth
FROM bronze.customer
WHERE date_of_birth IS NULL
   OR TRIM(date_of_birth::text) = ''
   OR UPPER(TRIM(date_of_birth::text)) IN ('NULL', 'NAN');

-- ============================================
-- Date_of_birth
-- Inspect date range
-- ============================================

SELECT
    MIN(date_of_birth) AS earliest_date_of_birth,
    MAX(date_of_birth) AS latest_date_of_birth
FROM bronze.customer
WHERE date_of_birth IS NOT NULL;

SELECT *
FROM bronze.customer
WHERE date_of_birth IS NOT NULL
  AND TRIM(date_of_birth) <> ''
  AND UPPER(TRIM(date_of_birth)) NOT IN ('NULL', 'NAN')
  AND TRIM(date_of_birth) !~ '^\d{4}-\d{2}-\d{2}$';



-- ============================================
-- Date_of_birth
-- Business rule violation
-- DOB must be before registration date
-- ============================================

SELECT *
FROM bronze.customer
WHERE date_of_birth IS NOT NULL
  AND registration_date IS NOT NULL
  AND date_of_birth >= registration_date;


-- ============================================
-- Customer → date_of_birth
-- Business Rule:
-- DOB must be earlier than registration_date
-- ============================================

SELECT *
FROM bronze.customer
WHERE date_of_birth IS NOT NULL
  AND registration_date IS NOT NULL
  AND TRIM(date_of_birth) ~ '^\d{4}-\d{2}-\d{2}$'
  AND TRIM(registration_date) ~ '^\d{4}-\d{2}-\d{2}$'
  AND TRIM(date_of_birth)::date >= TRIM(registration_date)::date;


-- ============================================
-- Customer → country
-- Missing values
-- ============================================

SELECT
    COUNT(*) AS missing_country
FROM bronze.customer
WHERE country IS NULL
   OR TRIM(country) = ''
   OR UPPER(TRIM(country)) IN ('NULL', 'NAN');



-- ============================================
-- Customer → country
-- Distinct values
-- ============================================

SELECT
    country,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE country IS NOT NULL
  AND TRIM(country) <> ''
  AND UPPER(TRIM(country)) NOT IN ('NULL', 'NAN')
GROUP BY country
ORDER BY occurrences DESC;




-- ============================================
-- Customer → country
-- Potential country-code formats
-- ============================================

SELECT
    country,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE country IS NOT NULL
  AND TRIM(country) <> ''
  AND UPPER(TRIM(country)) NOT IN ('NULL', 'NAN')
  AND TRIM(country) ~ '^[A-Za-z]{2,3}$'
GROUP BY country
ORDER BY occurrences DESC;




SELECT
    LOWER(TRIM(country)) AS normalized_country,
    COUNT(DISTINCT country) AS different_representations,
    STRING_AGG(DISTINCT country, ', ' ORDER BY country) AS representations
FROM bronze.customer
WHERE country IS NOT NULL
  AND TRIM(country) <> ''
  AND UPPER(TRIM(country)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(country))
HAVING COUNT(DISTINCT country) > 1
ORDER BY different_representations DESC;


-- ============================================
-- Customer → city
-- Missing values
-- ============================================

SELECT
    COUNT(*) AS missing_city
FROM bronze.customer
WHERE city IS NULL
   OR TRIM(city) = ''
   OR UPPER(TRIM(city)) IN ('NULL', 'NAN');


-- ============================================
-- Customer → city
-- Distinct values
-- ============================================

SELECT
    city,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE city IS NOT NULL
  AND TRIM(city) <> ''
  AND UPPER(TRIM(city)) NOT IN ('NULL', 'NAN')
GROUP BY city
ORDER BY occurrences DESC;

-- ============================================
-- Customer → city
-- Inconsistent representations
-- ============================================

SELECT
    LOWER(TRIM(city)) AS normalized_city,
    COUNT(DISTINCT city) AS different_representations,
    STRING_AGG(DISTINCT city, ', ' ORDER BY city) AS representations
FROM bronze.customer
WHERE city IS NOT NULL
  AND TRIM(city) <> ''
  AND UPPER(TRIM(city)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(city))
HAVING COUNT(DISTINCT city) > 1
ORDER BY different_representations DESC;

SELECT *
FROM bronze.customer
WHERE
    (country IN ('Egypt', 'EG')
        AND city NOT IN ('Cairo', 'cairo', 'Alexandria', 'Giza', 'Luxor'))

 OR (country = 'Saudi Arabia'
        AND city NOT IN ('Riyadh', 'Jeddah', 'Mecca'))

 OR (country = 'United Arab Emirates'
        AND city NOT IN ('Dubai', 'Abu Dhabi', 'Sharjah'));


-- ============================================
-- Customer → registration_date
-- Missing values
-- ============================================


SELECT
    COUNT(*) AS missing_registration_date
FROM bronze.customer
WHERE registration_date IS NULL
   OR TRIM(registration_date) = ''
   OR UPPER(TRIM(registration_date)) IN ('NULL', 'NAN');

-- ===========================================
-- Customer → registration_date
-- Distinct formats
-- ============================================

SELECT
    CASE
        WHEN TRIM(registration_date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN 'YYYY-MM-DD'

        WHEN TRIM(registration_date) ~ '^\d{4}-\d{2}-\d{2}T'
            THEN 'ISO_datetime'

        ELSE 'other'
    END AS date_format,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE registration_date IS NOT NULL
  AND TRIM(registration_date) <> ''
  AND UPPER(TRIM(registration_date)) NOT IN ('NULL', 'NAN')
GROUP BY date_format
ORDER BY occurrences DESC;


-- ===========================================
-- Customer → registration_date
-- Invalid formats
-- ============================================

SELECT
    registration_date,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE registration_date IS NOT NULL
  AND TRIM(registration_date) <> ''
  AND UPPER(TRIM(registration_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(registration_date) !~ '^\d{4}-\d{2}-\d{2}(T.*)?$'
GROUP BY registration_date
ORDER BY occurrences DESC;

-- ============================================
-- Customer → registration_date
-- Business Rule:
-- date_of_birth must be before registration_date
-- ============================================

SELECT *
FROM bronze.customer
WHERE date_of_birth IS NOT NULL
  AND registration_date IS NOT NULL
  AND TRIM(date_of_birth) ~ '^\d{4}-\d{2}-\d{2}$'
  AND TRIM(registration_date) ~ '^\d{4}-\d{2}-\d{2}T'
  AND TRIM(date_of_birth)::date >=
      LEFT(TRIM(registration_date), 10)::date;



SELECT *
FROM bronze.customer
WHERE registration_date IS NOT NULL
  AND TRIM(registration_date) <> ''
  AND UPPER(TRIM(registration_date)) NOT IN ('NULL', 'NAN')
  AND LEFT(TRIM(registration_date), 10)::date > CURRENT_DATE;



--- ============================================
-- Customer → customer_status
-- Missing values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE customer_status IS NULL
           OR TRIM(customer_status) = ''
           OR UPPER(TRIM(customer_status)) IN ('NULL', 'NAN')
    ) AS missing_customer_status
FROM bronze.customer;


--- ============================================
-- Customer → customer_status
-- Check the actual values
-- ============================================
SELECT
    customer_status,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE customer_status IS NOT NULL
  AND TRIM(customer_status) <> ''
  AND UPPER(TRIM(customer_status)) NOT IN ('NULL', 'NAN')
GROUP BY customer_status
ORDER BY occurrences DESC;



--- ============================================
-- Customer → customer_status
-- Check for invalid values
-- ============================================

SELECT

    customer_status,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE customer_status IS NOT NULL
  AND TRIM(customer_status) <> ''
  AND UPPER(TRIM(customer_status)) NOT IN ('NULL', 'NAN')
  AND TRIM(customer_status) NOT IN (
      'Active',
      'Inactive',
      'Suspended'
  )
GROUP BY customer_status
ORDER BY occurrences DESC;




SELECT
    LOWER(TRIM(customer_status)) AS normalized_status,
    STRING_AGG(DISTINCT customer_status, ', ') AS representations,
    COUNT(*) AS occurrences
FROM bronze.customer
WHERE customer_status IS NOT NULL
  AND TRIM(customer_status) <> ''
  AND UPPER(TRIM(customer_status)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(customer_status))
ORDER BY occurrences DESC;