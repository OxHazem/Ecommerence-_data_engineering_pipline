-- ALTER TABLE inmon_layer.orders
-- ALTER COLUMN order_date DROP NOT NULL;


INSERT INTO inmon_layer.orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    currency,
    shipping_city_id
)
SELECT
    s.order_id,
    s.customer_id,
    s.order_date,
    s.order_status,
    s.currency,
    ci.city_id
FROM silver.orders AS s
JOIN inmon_layer.city AS ci
    ON ci.city_name = TRIM(s.shipping_city)
JOIN inmon_layer.country AS co
    ON co.country_id = ci.country_id
    AND co.country_name = TRIM(s.shipping_country)
WHERE s.order_id IS NOT NULL
ON CONFLICT (order_id) DO NOTHING;





