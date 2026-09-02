SELECT
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'kimball.fact_sales'::regclass
  AND contype = 'f';



SELECT COUNT(*) AS orphan_customer_keys
FROM kimball.fact_sales f
LEFT JOIN kimball.dim_customer d
    ON f.customer_key = d.customer_key
WHERE d.customer_key IS NULL;



SELECT COUNT(*) AS orphan_product_keys
FROM kimball.fact_sales f
LEFT JOIN kimball.dim_product d
    ON f.product_key = d.product_key
WHERE d.product_key IS NULL;


SELECT COUNT(*) AS orphan_date_keys
FROM kimball.fact_sales f
LEFT JOIN kimball.dim_date d
    ON f.date_key = d.date_key
WHERE d.date_key IS NULL;





SELECT COUNT(*) AS orphan_payment_keys
FROM kimball.fact_sales f
LEFT JOIN kimball.dim_payment d
    ON f.payment_key = d.payment_key
WHERE f.payment_key IS NOT NULL
  AND d.payment_key IS NULL;



SELECT COUNT(*) AS fact_rows
FROM kimball.fact_sales;



SELECT
    order_id,
    product_key,
    COUNT(*) AS row_count
FROM kimball.fact_sales
GROUP BY order_id, product_key
HAVING COUNT(*) > 1
ORDER BY row_count DESC
LIMIT 20;




SELECT COUNT(*) AS expected_fact_rows
FROM silver.order_item oi
INNER JOIN silver.orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL;



SELECT COUNT(*) AS unmatched_fact_rows
FROM kimball.fact_sales f
LEFT JOIN silver.order_item oi
    ON f.order_id = oi.order_id
WHERE oi.order_id IS NULL;





SELECT
    order_id,
    product_key,
    COUNT(*) AS row_count
FROM kimball.fact_sales
GROUP BY order_id, product_key
HAVING COUNT(*) > 1
ORDER BY row_count DESC
LIMIT 20;




SELECT COUNT(*) AS unmatched_fact_rows
FROM kimball.fact_sales f
LEFT JOIN silver.order_item oi
    ON f.order_id = oi.order_id
WHERE oi.order_id IS NULL;





SELECT
    COUNT(*) FILTER (WHERE dc.customer_key IS NULL) AS missing_customer,
    COUNT(*) FILTER (WHERE dp.product_key IS NULL) AS missing_product,
    COUNT(*) FILTER (WHERE dd.date_key IS NULL) AS missing_date
FROM silver.order_item oi
INNER JOIN silver.orders o
    ON oi.order_id = o.order_id
LEFT JOIN kimball.dim_customer dc
    ON o.customer_id = dc.customer_id
   AND o.order_date >= dc.effective_date
   AND o.order_date < dc.expiration_date
LEFT JOIN kimball.dim_product dp
    ON oi.product_id = dp.product_id
LEFT JOIN kimball.dim_date dd
    ON o.order_date = dd.full_date
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL;



SELECT
    COUNT(*) AS orders_before_customer_effective_date
FROM silver.order_item oi
INNER JOIN silver.orders o
    ON oi.order_id = o.order_id
INNER JOIN kimball.dim_customer dc
    ON o.customer_id = dc.customer_id
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL
  AND o.order_date < dc.effective_date;


  SELECT
    MIN(o.order_date) AS earliest_order,
    MIN(dc.effective_date) AS earliest_customer_effective_date
FROM silver.order_item oi
INNER JOIN silver.orders o
    ON oi.order_id = o.order_id
INNER JOIN kimball.dim_customer dc
    ON o.customer_id = dc.customer_id
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL
  AND o.order_date < dc.effective_date;



SELECT COUNT(DISTINCT o.customer_id) AS affected_customers
FROM silver.order_item oi
JOIN silver.orders o
    ON oi.order_id = o.order_id
JOIN kimball.dim_customer dc
    ON o.customer_id = dc.customer_id
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL
  AND o.order_date < dc.effective_date;





SELECT
    o.customer_id,
    dc.effective_date,
    MIN(o.order_date) AS earliest_order_date
FROM silver.order_item oi
JOIN silver.orders o
    ON oi.order_id = o.order_id
JOIN kimball.dim_customer dc
    ON o.customer_id = dc.customer_id
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL
  AND o.order_date < dc.effective_date
GROUP BY
    o.customer_id,
    dc.effective_date
ORDER BY earliest_order_date
LIMIT 20;




SELECT
    COUNT(*) AS customers_with_2026_effective_date
FROM kimball.dim_customer
WHERE effective_date = DATE '2026-09-01';




SELECT
    customer_id,
    first_name,
    last_name,
    registration_date,
    effective_date,
    expiration_date,
    is_current
FROM kimball.dim_customer
WHERE effective_date = DATE '2026-09-01'
ORDER BY customer_id
LIMIT 20;




SELECT
    dc.customer_id,
    dc.effective_date,
    MIN(o.order_date) AS earliest_order_date,
    COUNT(DISTINCT o.order_id) AS order_count
FROM kimball.dim_customer dc
JOIN silver.orders o
    ON dc.customer_id = o.customer_id
WHERE dc.effective_date = DATE '2026-09-01'
  AND o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL
GROUP BY
    dc.customer_id,
    dc.effective_date
ORDER BY earliest_order_date;



UPDATE kimball.dim_customer dc
SET effective_date = x.earliest_order_date
FROM (
    SELECT
        o.customer_id,
        MIN(o.order_date) AS earliest_order_date
    FROM silver.orders o
    WHERE o.order_status <> 'Cancelled'
      AND o.order_date IS NOT NULL
    GROUP BY o.customer_id
) x
WHERE dc.customer_id = x.customer_id
  AND dc.effective_date = DATE '2026-09-01'
  AND dc.is_current = TRUE;



SELECT COUNT(*) AS invalid_future_effective_dates
FROM kimball.dim_customer
WHERE effective_date > CURRENT_DATE;



SELECT COUNT(*) AS affected_customers_remaining
FROM kimball.dim_customer
WHERE effective_date = DATE '2026-09-01'
  AND registration_date IS NULL;



SELECT COUNT(*) AS orders_before_customer_effective_date
FROM silver.order_item oi
JOIN silver.orders o
    ON oi.order_id = o.order_id
JOIN kimball.dim_customer dc
    ON o.customer_id = dc.customer_id
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL
  AND o.order_date < dc.effective_date;