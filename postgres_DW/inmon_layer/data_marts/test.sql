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




-- customer marts 


SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE o.customer_id IS NOT NULL) AS customers_with_orders,
    COUNT(*) FILTER (WHERE o.customer_id IS NULL) AS customers_without_orders
FROM inmon_layer.customer c
LEFT JOIN (
    SELECT DISTINCT customer_id
    FROM inmon_layer.orders
) o
    ON c.customer_id = o.customer_id;




SELECT COUNT(*) AS invalid_customer_references
FROM inmon_layer.orders o
LEFT JOIN inmon_layer.customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT customer_id) AS customers_with_orders
FROM inmon_layer.orders;



SELECT
    customer_id,
    COUNT(*) AS order_count
FROM inmon_layer.orders
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 10;




SELECT
    COUNT(*) AS customers,
    COUNT(DISTINCT c.customer_id) AS distinct_customers,
    COUNT(*) FILTER (WHERE ci.city_id IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE co.country_id IS NULL) AS missing_country
FROM inmon_layer.customer c
LEFT JOIN inmon_layer.city ci
    ON c.city_id = ci.city_id
LEFT JOIN inmon_layer.country co
    ON ci.country_id = co.country_id;



SELECT
    COUNT(DISTINCT o.customer_id) FILTER (
        WHERE oi.unit_price IS NULL
    ) AS customers_with_missing_price,

    COUNT(DISTINCT o.customer_id) FILTER (
        WHERE o.order_date IS NULL
    ) AS customers_with_missing_order_date
FROM inmon_layer.orders o
JOIN inmon_layer.order_item oi
    ON o.order_id = oi.order_id;