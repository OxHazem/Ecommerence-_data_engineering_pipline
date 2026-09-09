SELECT
    (SELECT COUNT(*) FROM silver.payment) AS silver_count,
    (SELECT COUNT(*) FROM inmon_layer.payment) AS inmon_count;


SELECT
    payment_id,
    COUNT(*) AS cnt
FROM inmon_layer.payment
GROUP BY payment_id
HAVING COUNT(*) > 1;



SELECT
    transaction_reference,
    COUNT(*) AS occurrence_count
FROM inmon_layer.payment
WHERE transaction_reference IS NOT NULL
GROUP BY transaction_reference
HAVING COUNT(*) > 1;



SELECT COUNT(*)
FROM inmon_layer.payment p
LEFT JOIN inmon_layer.orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;







SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'payment'
ORDER BY ordinal_position;