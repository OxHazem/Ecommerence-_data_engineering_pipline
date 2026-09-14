SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'order_item'
ORDER BY ordinal_position;


SELECT
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount,
    AVG(discount) AS avg_discount
FROM inmon_layer.order_item;