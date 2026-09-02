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


SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE revenue - cost <> profit
    ) AS profit_mismatches,
    COUNT(*) FILTER (
        WHERE revenue < 0
    ) AS negative_revenue,
    COUNT(*) FILTER (
        WHERE cost < 0
    ) AS negative_cost
FROM kimball.fact_sales;



SELECT
    o.currency,
    COUNT(*) AS fact_rows,
    COUNT(*) FILTER (
        WHERE f.revenue = 0 AND f.cost = 0
    ) AS zero_financial_rows
FROM kimball.fact_sales f
JOIN silver.orders o
    ON f.order_id = o.order_id
GROUP BY o.currency
ORDER BY o.currency;




SELECT
    o.currency,
    COUNT(*) AS rows_without_rate
FROM silver.order_item oi
JOIN silver.orders o
    ON oi.order_id = o.order_id
LEFT JOIN LATERAL (
    SELECT er.rate
    FROM silver.exchange_rate er
    WHERE er.base = o.currency
      AND er.quote = 'EGP'
      AND er.date <= o.order_date
    ORDER BY er.date DESC
    LIMIT 1
) er ON TRUE
WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL
  AND o.currency <> 'EGP'
  AND er.rate IS NULL
GROUP BY o.currency
ORDER BY o.currency;






SELECT
    d.full_date,
    SUM(f.revenue) AS fact_revenue,
    SUM(f.cost) AS fact_cost,
    SUM(f.profit) AS fact_profit
FROM kimball.fact_sales f
JOIN kimball.dim_date d
    ON f.date_key = d.date_key
GROUP BY d.full_date
ORDER BY d.full_date
LIMIT 20;




SELECT
    d.full_date,
    SUM(f.revenue) AS fact_revenue,
    SUM(f.cost) AS fact_cost,
    SUM(f.profit) AS fact_profit
FROM kimball.fact_sales f
JOIN kimball.dim_date d
    ON f.date_key = d.date_key
GROUP BY d.full_date
ORDER BY d.full_date;




SELECT *
FROM gold.daily_sales
ORDER BY date
LIMIT 20;


SELECT *
FROM gold.daily_sales
LIMIT 5;



SELECT
    ROUND(SUM(f.revenue), 2) AS kimball_revenue,
    ROUND(SUM(f.cost), 2) AS kimball_cost,
    ROUND(SUM(f.profit), 2) AS kimball_profit
FROM kimball.fact_sales f;




SELECT
    ROUND(SUM(revenue), 2) AS gold_revenue,
    ROUND(SUM(cost), 2) AS gold_cost,
    ROUND(SUM(profit), 2) AS gold_profit
FROM gold.daily_sales;




SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(*) FILTER (
        WHERE ABS(revenue - ROUND(revenue, 2)) > 0
    ) AS revenue_unrounded_rows,
    COUNT(*) FILTER (
        WHERE ABS(cost - ROUND(cost, 2)) > 0
    ) AS cost_unrounded_rows
FROM kimball.fact_sales;




SELECT
    ROUND(SUM(f.revenue), 2) AS kimball_revenue,
    ROUND(SUM(f.cost), 2) AS kimball_cost,
    ROUND(SUM(f.profit), 2) AS kimball_profit,
    ROUND(SUM(f.revenue) - SUM(f.cost), 2) AS revenue_minus_cost
FROM kimball.fact_sales f;





WITH kimball AS (
    SELECT
        d.full_date AS sale_date,
        ROUND(SUM(f.revenue), 2) AS revenue,
        ROUND(SUM(f.cost), 2) AS cost,
        ROUND(SUM(f.profit), 2) AS profit
    FROM kimball.fact_sales f
    JOIN kimball.dim_date d
        ON f.date_key = d.date_key
    GROUP BY d.full_date
),
gold AS (
    SELECT
        date AS sale_date,
        ROUND(SUM(revenue), 2) AS revenue,
        ROUND(SUM(cost), 2) AS cost,
        ROUND(SUM(profit), 2) AS profit
    FROM gold.daily_sales
    GROUP BY date
)
SELECT
    COALESCE(k.sale_date, g.sale_date) AS sale_date,
    COALESCE(k.revenue, 0) AS kimball_revenue,
    COALESCE(g.revenue, 0) AS gold_revenue,
    ROUND(COALESCE(k.revenue, 0) - COALESCE(g.revenue, 0), 2) AS revenue_diff,
    ROUND(COALESCE(k.cost, 0) - COALESCE(g.cost, 0), 2) AS cost_diff,
    ROUND(COALESCE(k.profit, 0) - COALESCE(g.profit, 0), 2) AS profit_diff
FROM kimball k
FULL OUTER JOIN gold g
    ON k.sale_date = g.sale_date
WHERE
    ABS(COALESCE(k.revenue, 0) - COALESCE(g.revenue, 0)) > 0
    OR ABS(COALESCE(k.cost, 0) - COALESCE(g.cost, 0)) > 0
    OR ABS(COALESCE(k.profit, 0) - COALESCE(g.profit, 0)) > 0
ORDER BY sale_date;




SELECT
    (SELECT COUNT(*) FROM kimball.dim_date) AS dim_date_rows,
    (SELECT COUNT(*) FROM kimball.dim_customer) AS dim_customer_rows,
    (SELECT COUNT(*) FROM kimball.dim_product) AS dim_product_rows,
    (SELECT COUNT(*) FROM kimball.dim_payment) AS dim_payment_rows,
    (SELECT COUNT(*) FROM kimball.fact_sales) AS fact_sales_rows;




    SELECT
    COUNT(*) FILTER (WHERE customer_key IS NULL) AS null_customer_keys,
    COUNT(*) FILTER (WHERE product_key IS NULL) AS null_product_keys,
    COUNT(*) FILTER (WHERE date_key IS NULL) AS null_date_keys,
    COUNT(*) FILTER (WHERE payment_key IS NULL) AS null_payment_keys
FROM kimball.fact_sales;