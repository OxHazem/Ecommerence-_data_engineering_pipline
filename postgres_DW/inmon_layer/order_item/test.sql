SELECT COUNT(*)
FROM inmon_layer.order_item;



SELECT
    order_id,
    product_id,
    COUNT(*) AS cnt
FROM inmon_layer.order_item
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;





SELECT COUNT(*)
FROM inmon_layer.order_item oi
LEFT JOIN inmon_layer.orders o
    ON oi.order_id = o.order_id
LEFT JOIN inmon_layer.product p
    ON oi.product_id = p.product_id
WHERE o.order_id IS NULL
   OR p.product_id IS NULL;