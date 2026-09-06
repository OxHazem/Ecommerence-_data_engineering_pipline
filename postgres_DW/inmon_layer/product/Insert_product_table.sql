INSERT INTO inmon_layer.product (
    product_id,
    product_name,
    subcategory_id,
    brand,
    supplier,
    cost,
    price,
    stock_quantity,
    product_status,
    launch_date
)
SELECT
    s.product_id,
    s.product_name,
    sc.subcategory_id,
    s.brand,
    s.supplier,
    s.cost,
    s.price,
    s.stock_quantity,
    s.product_status,
    s.launch_date
FROM silver.product AS s
JOIN inmon_layer.subcategory AS sc
    ON sc.subcategory_name = TRIM(s.subcategory)
JOIN inmon_layer.category AS c
    ON c.category_id = sc.category_id
    AND c.category_name = TRIM(s.category)
WHERE s.product_id IS NOT NULL
ON CONFLICT (product_id) DO NOTHING;