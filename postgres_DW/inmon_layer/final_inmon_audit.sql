SELECT
    table_name,
    (
        SELECT COUNT(*)
        FROM information_schema.columns c
        WHERE c.table_schema = 'inmon_layer'
          AND c.table_name = t.table_name
    ) AS column_count
FROM information_schema.tables t
WHERE t.table_schema = 'inmon_layer'
  AND t.table_type = 'BASE TABLE'
ORDER BY table_name;



SELECT
    (SELECT COUNT(*) FROM inmon_layer.order_item) AS order_item_count,
    (SELECT COUNT(*) FROM inmon_layer.order_items) AS order_items_count;




SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'inmon_layer'
  AND tc.table_name IN ('order_item', 'order_items')
ORDER BY tc.table_name, tc.constraint_type;



SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'inmon_layer'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;









SELECT
    'customer' AS entity,
    (SELECT COUNT(*) FROM silver.customer) AS silver_count,
    (SELECT COUNT(*) FROM inmon_layer.customer) AS inmon_count

UNION ALL

SELECT
    'product',
    (SELECT COUNT(*) FROM silver.product),
    (SELECT COUNT(*) FROM inmon_layer.product)

UNION ALL

SELECT
    'orders',
    (SELECT COUNT(*) FROM silver.orders),
    (SELECT COUNT(*) FROM inmon_layer.orders)

UNION ALL

SELECT
    'order_item',
    (SELECT COUNT(*) FROM silver.order_item),
    (SELECT COUNT(*) FROM inmon_layer.order_item)

UNION ALL

SELECT
    'payment',
    (SELECT COUNT(*) FROM silver.payment),
    (SELECT COUNT(*) FROM inmon_layer.payment)

UNION ALL

SELECT
    'shipping',
    (SELECT COUNT(*) FROM silver.shipping),
    (SELECT COUNT(*) FROM inmon_layer.shipping)

UNION ALL

SELECT
    'review',
    (SELECT COUNT(*) FROM silver.review),
    (SELECT COUNT(*) FROM inmon_layer.review)

UNION ALL

SELECT
    'marketing_event',
    (SELECT COUNT(*) FROM silver.marketing_event),
    (SELECT COUNT(*) FROM inmon_layer.marketing_event)

UNION ALL

SELECT
    'exchange_rate',
    (SELECT COUNT(*) FROM silver.exchange_rate),
    (SELECT COUNT(*) FROM inmon_layer.exchange_rate);











SELECT 'customer → city' AS relationship,
       COUNT(*) AS invalid_rows
FROM inmon_layer.customer c
LEFT JOIN inmon_layer.city ci
    ON c.city_id = ci.city_id
WHERE ci.city_id IS NULL

UNION ALL

SELECT 'product → subcategory',
       COUNT(*)
FROM inmon_layer.product p
LEFT JOIN inmon_layer.subcategory sc
    ON p.subcategory_id = sc.subcategory_id
WHERE sc.subcategory_id IS NULL

UNION ALL

SELECT 'orders → customer',
       COUNT(*)
FROM inmon_layer.orders o
LEFT JOIN inmon_layer.customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'orders → shipping city',
       COUNT(*)
FROM inmon_layer.orders o
LEFT JOIN inmon_layer.city ci
    ON o.shipping_city_id = ci.city_id
WHERE ci.city_id IS NULL

UNION ALL

SELECT 'order_item → order',
       COUNT(*)
FROM inmon_layer.order_item oi
LEFT JOIN inmon_layer.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order_item → product',
       COUNT(*)
FROM inmon_layer.order_item oi
LEFT JOIN inmon_layer.product p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'payment → order',
       COUNT(*)
FROM inmon_layer.payment p
LEFT JOIN inmon_layer.orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'shipping → order',
       COUNT(*)
FROM inmon_layer.shipping s
LEFT JOIN inmon_layer.orders o
    ON s.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'shipping → city',
       COUNT(*)
FROM inmon_layer.shipping s
LEFT JOIN inmon_layer.city ci
    ON s.shipping_city_id = ci.city_id
WHERE ci.city_id IS NULL

UNION ALL

SELECT 'review → customer',
       COUNT(*)
FROM inmon_layer.review r
LEFT JOIN inmon_layer.customer c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'review → product',
       COUNT(*)
FROM inmon_layer.review r
LEFT JOIN inmon_layer.product p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'marketing_event → customer',
       COUNT(*)
FROM inmon_layer.marketing_event me
LEFT JOIN inmon_layer.customer c
    ON me.customer_id = c.customer_id
WHERE c.customer_id IS NULL;










SELECT
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'inmon_layer'
ORDER BY table_name, constraint_type, constraint_name;