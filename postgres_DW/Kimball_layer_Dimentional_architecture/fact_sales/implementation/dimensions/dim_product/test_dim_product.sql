SELECT
    COUNT(*) AS products,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(DISTINCT product_key) AS unique_product_keys
FROM kimball.dim_product;


SELECT *
FROM kimball.dim_product
ORDER BY product_key
LIMIT 10;