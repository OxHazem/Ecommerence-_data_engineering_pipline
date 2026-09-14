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