SELECT *
FROM gold.product_sales
ORDER BY product_id
LIMIT 20;



SELECT
    COUNT(*) AS negative_profit_products
FROM gold.product_sales
WHERE profit < 0;