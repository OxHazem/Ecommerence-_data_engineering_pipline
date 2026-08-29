-- ============================================
-- Product → product_id
-- Missing values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
           OR TRIM(product_id) = ''
           OR UPPER(TRIM(product_id)) IN ('NULL', 'NAN')
    ) AS missing_product_id
FROM bronze.product;


-- ============================================
-- Product → product_id
-- Duplicates
-- ============================================

SELECT
    TRIM(product_id) AS product_id,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> ''
  AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(product_id)
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, product_id;


SELECT *
FROM bronze.product
WHERE TRIM(product_id) IN (
    SELECT TRIM(product_id)
    FROM bronze.product
    WHERE product_id IS NOT NULL
      AND TRIM(product_id) <> ''
      AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN')
    GROUP BY TRIM(product_id)
    HAVING COUNT(*) > 1
)
ORDER BY TRIM(product_id);



-- ============================================
-- Product → product_id
-- Invalid values / invalid type
-- ============================================

SELECT
    product_id,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> ''
  AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(product_id) !~ '^[1-9][0-9]*$'
GROUP BY product_id
ORDER BY occurrences DESC;



-- ============================================
-- Product → product_id
-- Business Rules
-- ============================================

SELECT *
FROM bronze.product
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> ''
  AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN')
  AND (
      TRIM(product_id)::numeric <= 0
  );


SELECT *
FROM bronze.product
WHERE TRIM(product_id) ~ '^[0-9]+$'
  AND TRIM(product_id)::bigint <= 0;



-- ============================================
-- Product → product_id
-- Inconsistent Format
-- ============================================

SELECT
    product_id,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> ''
  AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN')
  AND TRIM(product_id) ~ '^0+[0-9]+$'
GROUP BY product_id
ORDER BY occurrences DESC;


-- ============================================
-- Product → product_name
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE product_name IS NULL
           OR TRIM(product_name) = ''
           OR UPPER(TRIM(product_name)) IN ('NULL', 'NAN')
    ) AS missing_product_name
FROM bronze.product;

SELECT *
FROM bronze.product
WHERE product_name IS NULL
   OR TRIM(product_name) = ''
   OR UPPER(TRIM(product_name)) IN ('NULL', 'NAN');


-- ============================================
-- Product → product_name
-- Repeated values (profiling, NOT automatically an error)
-- ============================================

SELECT
    TRIM(product_name) AS product_name,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_name IS NOT NULL
  AND TRIM(product_name) <> ''
  AND UPPER(TRIM(product_name)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(product_name)
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- ============================================
-- Product → product_name
-- Invalid / placeholder values
-- ============================================

SELECT
    product_name,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_name IS NOT NULL
  AND TRIM(product_name) <> ''
  AND UPPER(TRIM(product_name)) IN (
      'UNKNOWN',
      'N/A',
      'NA',
      'NONE',
      'NULL',
      'NAN',
      'UNDEFINED'
  )
GROUP BY product_name
ORDER BY occurrences DESC;



-- ============================================
-- Product → product_name
-- Inconsistent Format: leading/trailing spaces
-- ============================================

SELECT
    product_name,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_name IS NOT NULL
  AND product_name <> TRIM(product_name)
GROUP BY product_name
ORDER BY occurrences DESC;



SELECT
    product_name,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_name IS NOT NULL
  AND product_name ~ '\s{2,}'
GROUP BY product_name
ORDER BY occurrences DESC;


-- ============================================
-- Product → category
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE category IS NULL
           OR TRIM(category) = ''
           OR UPPER(TRIM(category)) IN ('NULL', 'NAN')
    ) AS missing_category
FROM bronze.product;

SELECT *
FROM bronze.product
WHERE category IS NULL
   OR TRIM(category) = ''
   OR UPPER(TRIM(category)) IN ('NULL', 'NAN');


-- ============================================
-- Product → category
-- Value distribution
-- ============================================

SELECT
    category,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
GROUP BY category
ORDER BY occurrences DESC;



-- ============================================
-- Product → category
-- Distinct values for domain investigation
-- ============================================

SELECT
    TRIM(category) AS category,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(category)
ORDER BY occurrences DESC;



-- ============================================
-- Product → category
-- Inconsistent Format
-- ============================================

SELECT
    LOWER(TRIM(category)) AS normalized_category,
    STRING_AGG(DISTINCT category, ', ' ORDER BY category) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(category))
HAVING COUNT(DISTINCT TRIM(category)) > 1
ORDER BY occurrences DESC;




-- ============================================
-- Product → category
-- Business Rule: category/subcategory relationship
-- ============================================

SELECT
    category,
    subcategory,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND subcategory IS NOT NULL
  AND TRIM(subcategory) <> ''
GROUP BY category, subcategory
ORDER BY category, occurrences DESC;


-- ============================================
-- Product → subcategory
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE subcategory IS NULL
           OR TRIM(subcategory) = ''
           OR UPPER(TRIM(subcategory)) IN ('NULL', 'NAN')
    ) AS missing_subcategory
FROM bronze.product;


-- ============================================
-- Product → subcategory
-- Value distribution
-- ============================================

SELECT
    TRIM(subcategory) AS subcategory,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE subcategory IS NOT NULL
  AND TRIM(subcategory) <> ''
  AND UPPER(TRIM(subcategory)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(subcategory)
ORDER BY occurrences DESC;



-- ============================================
-- Product → subcategory
-- Distinct values
-- ============================================

SELECT
    TRIM(subcategory) AS subcategory,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE subcategory IS NOT NULL
  AND TRIM(subcategory) <> ''
  AND UPPER(TRIM(subcategory)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(subcategory)
ORDER BY occurrences DESC;




-- ============================================
-- Product → subcategory
-- Inconsistent Format
-- ============================================

SELECT
    LOWER(TRIM(subcategory)) AS normalized_subcategory,
    STRING_AGG(
        DISTINCT subcategory,
        ', ' ORDER BY subcategory
    ) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE subcategory IS NOT NULL
  AND TRIM(subcategory) <> ''
  AND UPPER(TRIM(subcategory)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(subcategory))
HAVING COUNT(DISTINCT TRIM(subcategory)) > 1
ORDER BY occurrences DESC;



-- ============================================
-- Product → subcategory
-- Business Rule: category/subcategory consistency
-- ============================================

SELECT
    TRIM(category) AS category,
    TRIM(subcategory) AS subcategory,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND subcategory IS NOT NULL
  AND TRIM(subcategory) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
  AND UPPER(TRIM(subcategory)) NOT IN ('NULL', 'NAN')
GROUP BY
    TRIM(category),
    TRIM(subcategory)
ORDER BY
    TRIM(category),
    occurrences DESC;


-- ============================================
-- Product → brand
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE brand IS NULL
           OR TRIM(brand) = ''
           OR UPPER(TRIM(brand)) IN ('NULL', 'NAN')
    ) AS missing_brand
FROM bronze.product;


SELECT *
FROM bronze.product
WHERE brand IS NULL
   OR TRIM(brand) = ''
   OR UPPER(TRIM(brand)) IN ('NULL', 'NAN');



-- ============================================
-- Product → brand
-- Value distribution
-- ============================================

SELECT
    TRIM(brand) AS brand,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE brand IS NOT NULL
  AND TRIM(brand) <> ''
  AND UPPER(TRIM(brand)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(brand)
ORDER BY occurrences DESC;



-- ============================================
-- Product → brand
-- Distinct values
-- ============================================

SELECT
    TRIM(brand) AS brand,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE brand IS NOT NULL
  AND TRIM(brand) <> ''
  AND UPPER(TRIM(brand)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(brand)
ORDER BY occurrences DESC;




-- ============================================
-- Product → brand
-- Inconsistent Format
-- ============================================

SELECT
    LOWER(TRIM(brand)) AS normalized_brand,
    STRING_AGG(
        DISTINCT brand,
        ', ' ORDER BY brand
    ) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE brand IS NOT NULL
  AND TRIM(brand) <> ''
  AND UPPER(TRIM(brand)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(brand))
HAVING COUNT(DISTINCT TRIM(brand)) > 1
ORDER BY occurrences DESC;




-- ============================================
-- Product → cost
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE cost IS NULL
           OR TRIM(cost) = ''
           OR UPPER(TRIM(cost)) IN ('NULL', 'NAN')
    ) AS missing_cost
FROM bronze.product;

SELECT *
FROM bronze.product
WHERE cost IS NULL
   OR TRIM(cost) = ''
   OR UPPER(TRIM(cost)) IN ('NULL', 'NAN');



-- ============================================
-- Product → cost
-- Value distribution
-- ============================================

SELECT
    cost,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE cost IS NOT NULL
  AND TRIM(cost) <> ''
  AND UPPER(TRIM(cost)) NOT IN ('NULL', 'NAN')
GROUP BY cost
ORDER BY occurrences DESC;



-- ============================================
-- Product → cost
-- Invalid Values / Numeric Representation
-- ============================================

SELECT
    cost,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE cost IS NOT NULL
  AND TRIM(cost) <> ''
  AND UPPER(TRIM(cost)) NOT IN ('NULL', 'NAN')
  AND TRIM(cost) !~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
GROUP BY cost
ORDER BY occurrences DESC;



-- ============================================
-- Product → cost
-- Inconsistent Format
-- ============================================

SELECT
    cost,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE cost IS NOT NULL
  AND TRIM(cost) <> ''
  AND UPPER(TRIM(cost)) NOT IN ('NULL', 'NAN')
  AND TRIM(cost) ~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
GROUP BY cost
ORDER BY cost;

SELECT
    cost,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE cost IS NOT NULL
  AND cost <> TRIM(cost)
GROUP BY cost
ORDER BY occurrences DESC;

-- ============================================
-- Product → cost
-- Business Rule: cost >= 0
-- ============================================

SELECT *
FROM bronze.product
WHERE TRIM(cost) ~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
  AND TRIM(cost)::numeric < 0;



-- ============================================
-- Product → cost
-- Business Rule: cost < price
-- ============================================

SELECT *
FROM bronze.product
WHERE TRIM(cost) ~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
  AND TRIM(price) ~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
  AND TRIM(cost)::numeric >= TRIM(price)::numeric;


-- ============================================
-- Product → price
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE price IS NULL
           OR TRIM(price) = ''
           OR UPPER(TRIM(price)) IN ('NULL', 'NAN')
    ) AS missing_price
FROM bronze.product;


SELECT *
FROM bronze.product
WHERE price IS NULL
   OR TRIM(price) = ''
   OR UPPER(TRIM(price)) IN ('NULL', 'NAN');


-- ============================================
-- Product → price
-- Value distribution
-- ============================================

SELECT
    TRIM(price) AS price,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE price IS NOT NULL
  AND TRIM(price) <> ''
  AND UPPER(TRIM(price)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(price)
ORDER BY occurrences DESC;


-- ============================================
-- Product → price
-- Invalid Values
-- ============================================

SELECT
    price,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE price IS NOT NULL
  AND TRIM(price) <> ''
  AND UPPER(TRIM(price)) NOT IN ('NULL', 'NAN')
  AND TRIM(price) !~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
GROUP BY price
ORDER BY occurrences DESC;



-- ============================================
-- Product → price
-- Inconsistent Format
-- ============================================

SELECT
    price,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE price IS NOT NULL
  AND price <> TRIM(price)
GROUP BY price
ORDER BY occurrences DESC;


SELECT
    TRIM(price)::numeric AS numeric_price,
    STRING_AGG(
        DISTINCT price,
        ', ' ORDER BY price
    ) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE price IS NOT NULL
  AND TRIM(price) <> ''
  AND UPPER(TRIM(price)) NOT IN ('NULL', 'NAN')
  AND TRIM(price) ~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
GROUP BY TRIM(price)::numeric
HAVING COUNT(DISTINCT TRIM(price)) > 1
ORDER BY occurrences DESC;



-- ============================================
-- Product → price
-- Business Rule: price >= 0
-- ============================================

SELECT *
FROM bronze.product
WHERE TRIM(price) ~ '^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
  AND TRIM(price)::numeric < 0;


-- ============================================
-- Product → stock_quantity
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE stock_quantity IS NULL
           OR TRIM(stock_quantity) = ''
           OR UPPER(TRIM(stock_quantity)) IN ('NULL', 'NAN')
    ) AS missing_stock_quantity
FROM bronze.product;

SELECT *
FROM bronze.product
WHERE stock_quantity IS NULL
   OR TRIM(stock_quantity) = ''
   OR UPPER(TRIM(stock_quantity)) IN ('NULL', 'NAN');


-- ============================================
-- Product → stock_quantity
-- Value distribution
-- ============================================

SELECT
    TRIM(stock_quantity) AS stock_quantity,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE stock_quantity IS NOT NULL
  AND TRIM(stock_quantity) <> ''
  AND UPPER(TRIM(stock_quantity)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(stock_quantity)
ORDER BY occurrences DESC;


-- ============================================
-- Product → stock_quantity
-- Invalid Values
-- ============================================

SELECT
    stock_quantity,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE stock_quantity IS NOT NULL
  AND TRIM(stock_quantity) <> ''
  AND UPPER(TRIM(stock_quantity)) NOT IN ('NULL', 'NAN')
  AND TRIM(stock_quantity) !~ '^[+-]?\d+$'
GROUP BY stock_quantity
ORDER BY occurrences DESC;


-- ============================================
-- Product → stock_quantity
-- Inconsistent Format
-- ============================================

SELECT
    stock_quantity,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE stock_quantity IS NOT NULL
  AND stock_quantity <> TRIM(stock_quantity)
GROUP BY stock_quantity
ORDER BY occurrences DESC;



SELECT
    TRIM(stock_quantity)::integer AS numeric_quantity,
    STRING_AGG(
        DISTINCT stock_quantity,
        ', ' ORDER BY stock_quantity
    ) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE stock_quantity IS NOT NULL
  AND TRIM(stock_quantity) <> ''
  AND UPPER(TRIM(stock_quantity)) NOT IN ('NULL', 'NAN')
  AND TRIM(stock_quantity) ~ '^[+-]?\d+$'
GROUP BY TRIM(stock_quantity)::integer
HAVING COUNT(DISTINCT TRIM(stock_quantity)) > 1
ORDER BY occurrences DESC;



-- ============================================
-- Product → stock_quantity
-- Business Rule: stock_quantity >= 0
-- ============================================

SELECT *
FROM bronze.product
WHERE TRIM(stock_quantity) ~ '^[+-]?\d+$'
  AND TRIM(stock_quantity)::integer < 0;


-- ============================================
-- Product → category
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE category IS NULL
           OR TRIM(category) = ''
           OR UPPER(TRIM(category)) IN ('NULL', 'NAN')
    ) AS missing_category
FROM bronze.product;


SELECT *
FROM bronze.product
WHERE category IS NULL
   OR TRIM(category) = ''
   OR UPPER(TRIM(category)) IN ('NULL', 'NAN');


-- ============================================
-- Product → category
-- Value distribution
-- ============================================

SELECT
    TRIM(category) AS category,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(category)
ORDER BY occurrences DESC;


-- ============================================
-- Product → category
-- Distinct Values
-- ============================================

SELECT
    TRIM(category) AS category,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(category)
ORDER BY occurrences DESC;



-- ============================================
-- Product → category
-- Inconsistent Format
-- ============================================

SELECT
    LOWER(TRIM(category)) AS normalized_category,
    STRING_AGG(
        DISTINCT category,
        ', ' ORDER BY category
    ) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(category))
HAVING COUNT(DISTINCT TRIM(category)) > 1
ORDER BY occurrences DESC;


SELECT
    category,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND category <> TRIM(category)
GROUP BY category
ORDER BY occurrences DESC;


-- ============================================
-- Product → category
-- Business Rule: category/subcategory consistency
-- ============================================

SELECT
    TRIM(category) AS category,
    TRIM(subcategory) AS subcategory,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
  AND UPPER(TRIM(category)) NOT IN ('NULL', 'NAN')
  AND subcategory IS NOT NULL
  AND TRIM(subcategory) <> ''
  AND UPPER(TRIM(subcategory)) NOT IN ('NULL', 'NAN')
GROUP BY
    TRIM(category),
    TRIM(subcategory)
ORDER BY
    TRIM(category),
    occurrences DESC;


-- ============================================
-- Product → supplier
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE supplier IS NULL
           OR TRIM(supplier) = ''
           OR UPPER(TRIM(supplier)) IN ('NULL', 'NAN')
    ) AS missing_supplier
FROM bronze.product;


SELECT *
FROM bronze.product
WHERE supplier IS NULL
   OR TRIM(supplier) = ''
   OR UPPER(TRIM(supplier)) IN ('NULL', 'NAN');


-- ============================================
-- Product → supplier
-- Value distribution
-- ============================================

SELECT
    TRIM(supplier) AS supplier,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE supplier IS NOT NULL
  AND TRIM(supplier) <> ''
  AND UPPER(TRIM(supplier)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(supplier)
ORDER BY occurrences DESC;



-- ============================================
-- Product → supplier
-- Distinct Values
-- ============================================

SELECT
    TRIM(supplier) AS supplier,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE supplier IS NOT NULL
  AND TRIM(supplier) <> ''
  AND UPPER(TRIM(supplier)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(supplier)
ORDER BY occurrences DESC;



-- ============================================
-- Product → supplier
-- Inconsistent Format: whitespace
-- ============================================

SELECT
    supplier,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE supplier IS NOT NULL
  AND supplier <> TRIM(supplier)
GROUP BY supplier
ORDER BY occurrences DESC;


-- ============================================
-- Product → supplier
-- Inconsistent Format: casing
-- ============================================

SELECT
    LOWER(TRIM(supplier)) AS normalized_supplier,
    STRING_AGG(
        DISTINCT supplier,
        ', ' ORDER BY supplier
    ) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE supplier IS NOT NULL
  AND TRIM(supplier) <> ''
  AND UPPER(TRIM(supplier)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(supplier))
HAVING COUNT(DISTINCT TRIM(supplier)) > 1
ORDER BY occurrences DESC;


-- ============================================
-- Product → product_status
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE product_status IS NULL
           OR TRIM(product_status) = ''
           OR UPPER(TRIM(product_status)) IN ('NULL', 'NAN')
    ) AS missing_product_status
FROM bronze.product;

SELECT *
FROM bronze.product
WHERE product_status IS NULL
   OR TRIM(product_status) = ''
   OR UPPER(TRIM(product_status)) IN ('NULL', 'NAN');


-- ============================================
-- Product → product_status
-- Value Distribution
-- ============================================

SELECT
    TRIM(product_status) AS product_status,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_status IS NOT NULL
  AND TRIM(product_status) <> ''
  AND UPPER(TRIM(product_status)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(product_status)
ORDER BY occurrences DESC;


-- ============================================
-- Product → product_status
-- Distinct Values
-- ============================================

SELECT
    TRIM(product_status) AS product_status,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_status IS NOT NULL
  AND TRIM(product_status) <> ''
  AND UPPER(TRIM(product_status)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(product_status)
ORDER BY occurrences DESC;


-- ============================================
-- Product → product_status
-- Inconsistent Format: Whitespace
-- ============================================

SELECT
    product_status,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_status IS NOT NULL
  AND product_status <> TRIM(product_status)
GROUP BY product_status
ORDER BY occurrences DESC;


-- ============================================
-- Product → product_status
-- Inconsistent Format: Casing
-- ============================================

SELECT
    LOWER(TRIM(product_status)) AS normalized_status,
    STRING_AGG(
        DISTINCT product_status,
        ', ' ORDER BY product_status
    ) AS representations,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE product_status IS NOT NULL
  AND TRIM(product_status) <> ''
  AND UPPER(TRIM(product_status)) NOT IN ('NULL', 'NAN')
GROUP BY LOWER(TRIM(product_status))
HAVING COUNT(DISTINCT TRIM(product_status)) > 1
ORDER BY occurrences DESC;



-- ============================================
-- Product → launch_date
-- Missing Values
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE launch_date IS NULL
           OR TRIM(launch_date) = ''
           OR UPPER(TRIM(launch_date)) IN ('NULL', 'NAN')
    ) AS missing_launch_date
FROM bronze.product;


SELECT *
FROM bronze.product
WHERE launch_date IS NULL
   OR TRIM(launch_date) = ''
   OR UPPER(TRIM(launch_date)) IN ('NULL', 'NAN');



   -- ============================================
-- Product → launch_date
-- Value Distribution
-- ============================================

SELECT
    TRIM(launch_date) AS launch_date,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE launch_date IS NOT NULL
  AND TRIM(launch_date) <> ''
  AND UPPER(TRIM(launch_date)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(launch_date)
ORDER BY occurrences DESC;



-- ============================================
-- Product → launch_date
-- Invalid Values / Date Representation
-- ============================================

SELECT
    launch_date,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE launch_date IS NOT NULL
  AND TRIM(launch_date) <> ''
  AND UPPER(TRIM(launch_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(launch_date) !~ '^\d{4}-\d{2}-\d{2}$'
GROUP BY launch_date
ORDER BY occurrences DESC;


-- ============================================
-- Product → launch_date
-- Invalid Date Values
-- ============================================

SELECT
    launch_date,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE launch_date IS NOT NULL
  AND TRIM(launch_date) <> ''
  AND UPPER(TRIM(launch_date)) NOT IN ('NULL', 'NAN')
  AND TRIM(launch_date) ~ '^\d{4}-\d{2}-\d{2}$'
  AND TO_DATE(TRIM(launch_date), 'YYYY-MM-DD') IS NULL;


-- ============================================
-- Product → launch_date
-- Inconsistent Format: Whitespace
-- ============================================

SELECT
    launch_date,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE launch_date IS NOT NULL
  AND launch_date <> TRIM(launch_date)
GROUP BY launch_date
ORDER BY occurrences DESC;



-- ============================================
-- Product → launch_date
-- Inconsistent Date Representation
-- ============================================

SELECT
    TRIM(launch_date) AS launch_date,
    COUNT(*) AS occurrences
FROM bronze.product
WHERE launch_date IS NOT NULL
  AND TRIM(launch_date) <> ''
  AND UPPER(TRIM(launch_date)) NOT IN ('NULL', 'NAN')
GROUP BY TRIM(launch_date)
ORDER BY occurrences DESC;


-- ============================================
-- Product → launch_date
-- Date Range Investigation
-- ============================================

SELECT
    MIN(TO_DATE(TRIM(launch_date), 'YYYY-MM-DD')) AS earliest_launch_date,
    MAX(TO_DATE(TRIM(launch_date), 'YYYY-MM-DD')) AS latest_launch_date
FROM bronze.product
WHERE TRIM(launch_date) ~ '^\d{4}-\d{2}-\d{2}$';



-- ============================================
-- Product → launch_date
-- Business Rule: launch_date must not be in the future
-- ============================================

SELECT *
FROM bronze.product
WHERE TRIM(launch_date) ~ '^\d{4}-\d{2}-\d{2}$'
  AND TO_DATE(TRIM(launch_date), 'YYYY-MM-DD') > CURRENT_DATE;