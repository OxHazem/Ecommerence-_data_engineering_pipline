INSERT INTO inmon_layer.shipping (
    shipment_id,
    order_id,
    shipping_city_id,
    shipping_date,
    estimated_delivery_date,
    delivery_date,
    shipping_method,
    shipping_status,
    shipping_cost
)

SELECT
    s.shipment_id,
    s.order_id,
    c.city_id,
    s.shipping_date,
    s.estimated_delivery_date,
    s.delivery_date,
    s.shipping_method,
    s.shipping_status,
    s.shipping_cost

FROM silver.shipping AS s

JOIN inmon_layer.orders AS o
    ON o.order_id = s.order_id

JOIN inmon_layer.city AS c
    ON c.city_name = TRIM(s.shipping_city)

JOIN inmon_layer.country AS co
    ON co.country_id = c.country_id
    AND co.country_name = TRIM(s.shipping_country)

WHERE s.shipment_id IS NOT NULL

ON CONFLICT (shipment_id) DO NOTHING;