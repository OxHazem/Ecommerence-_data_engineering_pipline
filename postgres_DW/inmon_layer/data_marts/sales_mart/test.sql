SELECT COUNT(*) AS sales_mart_count
FROM inmon_mart.sales_mart;




SELECT *
FROM inmon_mart.sales_mart
ORDER BY order_id, product_id
LIMIT 20;




SELECT
    COUNT(*) AS mart_count,
    COUNT(DISTINCT (order_id, product_id)) AS distinct_order_product
FROM inmon_mart.sales_mart;







SELECT
    SUM(quantity) AS mart_quantity,
    SUM(unit_price * quantity) AS gross_value,
    SUM(discount) AS total_discount,
    SUM(cost_at_sale * quantity) AS total_cost
FROM inmon_mart.sales_mart;









SELECT
    currency,
    COUNT(*) AS row_count,
    COUNT(*) FILTER (WHERE exchange_rate IS NULL) AS missing_rate,
    MIN(exchange_rate) AS min_rate,
    MAX(exchange_rate) AS max_rate
FROM inmon_mart.sales_mart
GROUP BY currency
ORDER BY currency;







SELECT
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS missing_unit_price,
    COUNT(*) FILTER (WHERE revenue_egp IS NULL) AS missing_revenue,
    COUNT(*) FILTER (WHERE cost_egp IS NULL) AS missing_cost,
    COUNT(*) FILTER (WHERE profit_egp IS NULL) AS missing_profit
FROM inmon_mart.sales_mart;





SELECT
    order_status,
    COUNT(*) AS row_count,
    SUM(COALESCE(revenue_egp, 0)) AS revenue_egp,
    SUM(COALESCE(cost_egp, 0)) AS cost_egp,
    SUM(COALESCE(profit_egp, 0)) AS profit_egp
FROM inmon_mart.sales_mart
GROUP BY order_status
ORDER BY order_status;






SELECT COUNT(*) AS profit_mismatches
FROM inmon_mart.sales_mart
WHERE profit_egp IS NOT NULL
  AND revenue_egp IS NOT NULL
  AND cost_egp IS NOT NULL
  AND profit_egp <> revenue_egp - cost_egp;