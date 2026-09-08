SELECT COUNT(*)
FROM inmon_layer.shipping;




SELECT
    shipment_id,
    COUNT(*) AS cnt
FROM inmon_layer.shipping
GROUP BY shipment_id
HAVING COUNT(*) > 1;





SELECT COUNT(*)
FROM inmon_layer.shipping s
LEFT JOIN inmon_layer.orders o
    ON s.order_id = o.order_id
WHERE o.order_id IS NULL;





SELECT COUNT(*)
FROM inmon_layer.shipping s
LEFT JOIN inmon_layer.city c
    ON s.shipping_city_id = c.city_id
WHERE c.city_id IS NULL;




SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'shipping'
ORDER BY ordinal_position;



SELECT COUNT(*) AS silver_count
FROM silver.shipping;