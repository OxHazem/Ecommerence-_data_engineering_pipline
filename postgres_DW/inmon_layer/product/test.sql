SELECT COUNT(*) AS product_count
FROM inmon_layer.product;



SELECT COUNT(*) AS silver_product_count
FROM silver.product;






SELECT
    p.product_id,
    p.product_name,
    sc.subcategory_name,
    c.category_name,
    p.brand,
    p.supplier,
    p.cost,
    p.price
FROM inmon_layer.product p
JOIN inmon_layer.subcategory sc
    ON p.subcategory_id = sc.subcategory_id
JOIN inmon_layer.category c
    ON sc.category_id = c.category_id
ORDER BY p.product_id
LIMIT 20;





SELECT
    (SELECT COUNT(*) FROM silver.product) AS silver_count,
    (SELECT COUNT(*) FROM inmon_layer.product) AS inmon_count;







SELECT COUNT(*) AS invalid_products
FROM inmon_layer.product p
LEFT JOIN inmon_layer.subcategory sc
    ON p.subcategory_id = sc.subcategory_id
WHERE sc.subcategory_id IS NULL;