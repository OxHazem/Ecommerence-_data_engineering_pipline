SELECT
    COUNT(*) AS inmon_orders,
    COUNT(order_date) AS orders_with_date,
    COUNT(*) - COUNT(order_date) AS orders_without_date,
    COUNT(order_status) AS orders_with_status,
    COUNT(*) - COUNT(order_status) AS orders_without_status
FROM inmon_layer.orders;



SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'orders'
ORDER BY ordinal_position;




SELECT
    (SELECT COUNT(*) FROM silver.orders) AS silver_count,
    (SELECT COUNT(*) FROM inmon_layer.orders) AS inmon_count;




SELECT COUNT(*)
FROM inmon_layer.orders o
LEFT JOIN inmon_layer.customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;




SELECT COUNT(*)
FROM inmon_layer.orders o
LEFT JOIN inmon_layer.city c
    ON o.shipping_city_id = c.city_id
WHERE c.city_id IS NULL;




SELECT
    c.city_name,
    COUNT(DISTINCT co.country_name) AS country_count
FROM inmon_layer.city c
JOIN inmon_layer.country co
    ON c.country_id = co.country_id
GROUP BY c.city_name
HAVING COUNT(DISTINCT co.country_name) > 1;




SELECT COUNT(*)
FROM inmon_layer.orders o
LEFT JOIN inmon_layer.customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



SELECT COUNT(*)
FROM inmon_layer.orders o
LEFT JOIN inmon_layer.city c
    ON o.shipping_city_id = c.city_id
WHERE c.city_id IS NULL;


SELECT
    c.city_name,
    COUNT(DISTINCT co.country_name) AS country_count
FROM inmon_layer.city c
JOIN inmon_layer.country co
    ON c.country_id = co.country_id
GROUP BY c.city_name
HAVING COUNT(DISTINCT co.country_name) > 1;



SELECT
    c.customer_id,
    COUNT(DISTINCT o.currency) AS currency_count
FROM inmon_layer.orders o
JOIN inmon_layer.customer c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT o.currency) > 1;




SELECT
    c.customer_id,
    c.city_id,
    ci.country_id,
    co.country_name,
    o.currency,
    COUNT(*) AS order_count
FROM inmon_layer.orders o
JOIN inmon_layer.customer c
    ON o.customer_id = c.customer_id
JOIN inmon_layer.city ci
    ON c.city_id = ci.city_id
JOIN inmon_layer.country co
    ON ci.country_id = co.country_id
GROUP BY
    c.customer_id,
    c.city_id,
    ci.country_id,
    co.country_name,
    o.currency
ORDER BY c.customer_id
LIMIT 50;







SELECT
    table_schema,
    table_name,
    column_name
FROM information_schema.columns
WHERE column_name = 'currency'
ORDER BY table_schema, table_name;




SELECT
    co.country_id,
    co.country_name,
    COUNT(DISTINCT o.currency) AS currency_count,
    STRING_AGG(DISTINCT o.currency, ', ') AS currencies
FROM inmon_layer.orders o
JOIN inmon_layer.customer cu
    ON o.customer_id = cu.customer_id
JOIN inmon_layer.city ci
    ON cu.city_id = ci.city_id
JOIN inmon_layer.country co
    ON ci.country_id = co.country_id
GROUP BY
    co.country_id,
    co.country_name
ORDER BY co.country_id;



SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'country'
ORDER BY ordinal_position;