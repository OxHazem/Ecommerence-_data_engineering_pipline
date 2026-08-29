SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE order_id IS NULL OR TRIM(order_id) = '') AS null_order_id,
    COUNT(*) FILTER (WHERE product_id IS NULL OR TRIM(product_id) = '') AS null_product_id,
    COUNT(*) FILTER (WHERE quantity IS NULL OR TRIM(quantity) = '') AS null_quantity,
    COUNT(*) FILTER (WHERE unit_price IS NULL OR TRIM(unit_price) = '') AS null_unit_price,
    COUNT(*) FILTER (WHERE discount IS NULL OR TRIM(discount) = '') AS null_discount,
    COUNT(*) FILTER (WHERE cost_at_sale IS NULL OR TRIM(cost_at_sale) = '') AS null_cost_at_sale

FROM bronze.order_item;

-- ============================================
-- ORDER_ID & PRODUCT_ID (COMPOSITE KEY) INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.order_item
WHERE order_id IS NULL OR TRIM(order_id) = '' OR UPPER(TRIM(order_id)) IN ('NULL', 'NAN')
   OR product_id IS NULL OR TRIM(product_id) = '' OR UPPER(TRIM(product_id)) IN ('NULL', 'NAN');

-- 2. Duplicate Records (Composite Key Uniqueness)
SELECT
    order_id,
    product_id,
    COUNT(*) AS duplicate_count
FROM bronze.order_item
WHERE order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN')
  AND product_id IS NOT NULL AND TRIM(product_id) <> '' AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN')
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY order_id, product_id;

-- 3. Invalid Values (IDs cannot be negative or zero)
SELECT *
FROM bronze.order_item
WHERE (order_id IS NOT NULL AND TRIM(order_id) ~ '^-?[0-9]+$' AND CAST(TRIM(order_id) AS BIGINT) <= 0)
   OR (product_id IS NOT NULL AND TRIM(product_id) ~ '^-?[0-9]+$' AND CAST(TRIM(product_id) AS BIGINT) <= 0);

-- 4. Invalid Foreign Keys
-- order_id does not exist in bronze.orders
SELECT oi.*
FROM bronze.order_item oi
LEFT JOIN bronze.orders o ON TRIM(oi.order_id) = TRIM(o.order_id)
WHERE oi.order_id IS NOT NULL AND TRIM(oi.order_id) ~ '^-?[0-9]+$'
  AND o.order_id IS NULL;
-- product_id does not exist in bronze.product
SELECT oi.*
FROM bronze.order_item oi
LEFT JOIN bronze.product p ON TRIM(oi.product_id) = TRIM(p.product_id)
WHERE oi.product_id IS NOT NULL AND TRIM(oi.product_id) ~ '^-?[0-9]+$'
  AND p.product_id IS NULL;

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.order_item
WHERE (order_id IS NOT NULL AND TRIM(order_id) <> '' AND UPPER(TRIM(order_id)) NOT IN ('NULL', 'NAN') AND TRIM(order_id) !~ '^-?[0-9]+$')
   OR (product_id IS NOT NULL AND TRIM(product_id) <> '' AND UPPER(TRIM(product_id)) NOT IN ('NULL', 'NAN') AND TRIM(product_id) !~ '^-?[0-9]+$');

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.order_item
WHERE (order_id IS NOT NULL AND order_id <> TRIM(order_id))
   OR (product_id IS NOT NULL AND product_id <> TRIM(product_id));


-- ============================================
-- QUANTITY INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.order_item
WHERE quantity IS NULL OR TRIM(quantity) = '' OR UPPER(TRIM(quantity)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: 'quantity' is a measure, many orders can legitimately have the same quantity)

-- 3. Invalid Values (Quantity <= 0 is biologically invalid for an order)
SELECT *
FROM bronze.order_item
WHERE quantity IS NOT NULL AND TRIM(quantity) ~ '^-?[0-9]+$'
  AND CAST(TRIM(quantity) AS BIGINT) <= 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'quantity' is a numerical measure, not a relational key)

-- 5. Invalid Data Types (Non-integer strings)
SELECT *
FROM bronze.order_item
WHERE quantity IS NOT NULL AND TRIM(quantity) <> '' AND UPPER(TRIM(quantity)) NOT IN ('NULL', 'NAN')
  AND TRIM(quantity) !~ '^-?[0-9]+$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.order_item
WHERE quantity IS NOT NULL AND quantity <> TRIM(quantity);


-- ============================================
-- UNIT_PRICE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.order_item
WHERE unit_price IS NULL OR TRIM(unit_price) = '' OR UPPER(TRIM(unit_price)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: 'unit_price' is a measure)

-- 3. Invalid Values (Negative price)
SELECT *
FROM bronze.order_item
WHERE unit_price IS NOT NULL AND TRIM(unit_price) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND CAST(TRIM(unit_price) AS DECIMAL(10,2)) < 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'unit_price' is not a key)

-- 5. Invalid Data Types (Non-numeric strings)
SELECT *
FROM bronze.order_item
WHERE unit_price IS NOT NULL AND TRIM(unit_price) <> '' AND UPPER(TRIM(unit_price)) NOT IN ('NULL', 'NAN')
  AND TRIM(unit_price) !~ '^-?[0-9]+(\.[0-9]+)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.order_item
WHERE unit_price IS NOT NULL AND unit_price <> TRIM(unit_price);


-- ============================================
-- DISCOUNT INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.order_item
WHERE discount IS NULL OR TRIM(discount) = '' OR UPPER(TRIM(discount)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: 'discount' is a measure)

-- 3. Invalid Values (Negative discount or greater than 100%)
SELECT *
FROM bronze.order_item
WHERE discount IS NOT NULL AND TRIM(discount) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND (CAST(TRIM(discount) AS DECIMAL(10,2)) < 0 OR CAST(TRIM(discount) AS DECIMAL(10,2)) > 100);

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'discount' is not a key)

-- 5. Invalid Data Types (Non-numeric strings)
SELECT *
FROM bronze.order_item
WHERE discount IS NOT NULL AND TRIM(discount) <> '' AND UPPER(TRIM(discount)) NOT IN ('NULL', 'NAN')
  AND TRIM(discount) !~ '^-?[0-9]+(\.[0-9]+)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.order_item
WHERE discount IS NOT NULL AND discount <> TRIM(discount);


-- ============================================
-- COST_AT_SALE INVESTIGATION
-- ============================================

-- 1. Missing Values
SELECT *
FROM bronze.order_item
WHERE cost_at_sale IS NULL OR TRIM(cost_at_sale) = '' OR UPPER(TRIM(cost_at_sale)) IN ('NULL', 'NAN');

-- 2. Duplicate Records
-- (Not Applicable: 'cost_at_sale' is a measure)

-- 3. Invalid Values (Negative cost)
SELECT *
FROM bronze.order_item
WHERE cost_at_sale IS NOT NULL AND TRIM(cost_at_sale) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND CAST(TRIM(cost_at_sale) AS DECIMAL(10,2)) < 0;

-- 4. Invalid Foreign Keys
-- (Not Applicable: 'cost_at_sale' is not a key)

-- 5. Invalid Data Types (Non-numeric strings)
SELECT *
FROM bronze.order_item
WHERE cost_at_sale IS NOT NULL AND TRIM(cost_at_sale) <> '' AND UPPER(TRIM(cost_at_sale)) NOT IN ('NULL', 'NAN')
  AND TRIM(cost_at_sale) !~ '^-?[0-9]+(\.[0-9]+)?$';

-- 6. Inconsistent Formats (Leading/trailing whitespace)
SELECT *
FROM bronze.order_item
WHERE cost_at_sale IS NOT NULL AND cost_at_sale <> TRIM(cost_at_sale);



-- ============================================
-- BUSINESS RULE INVESTIGATION
-- ============================================

-- 1. Discounted selling price should not be negative
SELECT *
FROM bronze.order_item
WHERE unit_price IS NOT NULL
  AND discount IS NOT NULL
  AND TRIM(unit_price) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND TRIM(discount) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND (
      CAST(TRIM(unit_price) AS DECIMAL(10,2))
      * (1 - CAST(TRIM(discount) AS DECIMAL(10,2)) / 100)
  ) < 0;


-- 2. Cost at sale should not exceed unit selling price
SELECT *
FROM bronze.order_item
WHERE cost_at_sale IS NOT NULL
  AND unit_price IS NOT NULL
  AND TRIM(cost_at_sale) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND TRIM(unit_price) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND CAST(TRIM(cost_at_sale) AS DECIMAL(10,2))
      > CAST(TRIM(unit_price) AS DECIMAL(10,2));