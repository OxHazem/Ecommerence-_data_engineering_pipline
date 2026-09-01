SELECT *
FROM gold.product_sales
ORDER BY product_id
LIMIT 20;



SELECT
    COUNT(*) AS negative_profit_products
FROM gold.product_sales
WHERE profit < 0;



SELECT
    product_id,
    product_name,
    orders,
    units_sold,
    revenue,
    cost,
    profit,
    revenue_sar,
    cost_sar,
    profit_sar,
    revenue_aed,
    cost_aed,
    profit_aed
FROM gold.product_sales
ORDER BY product_id
LIMIT 20;