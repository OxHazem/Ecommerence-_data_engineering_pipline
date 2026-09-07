SELECT COUNT(*)
FROM inmon_layer.payment;




SELECT
    payment_id,
    COUNT(*) AS cnt
FROM inmon_layer.payment
GROUP BY payment_id
HAVING COUNT(*) > 1;







SELECT COUNT(*)
FROM inmon_layer.payment p
LEFT JOIN inmon_layer.orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;







SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'payment'
ORDER BY ordinal_position;