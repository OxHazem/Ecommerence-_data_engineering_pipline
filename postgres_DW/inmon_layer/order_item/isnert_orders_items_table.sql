INSERT INTO inmon_layer.order_item (
    order_id,
    product_id,
    quantity,
    unit_price,
    discount,
    cost_at_sale
)

SELECT
    s.order_id,
    s.product_id,
    s.quantity,
    s.unit_price,
    s.discount,
    s.cost_at_sale

FROM silver.order_item AS s

JOIN inmon_layer.orders AS o
    ON o.order_id = s.order_id

JOIN inmon_layer.product AS p
    ON p.product_id = s.product_id

WHERE s.order_id IS NOT NULL
  AND s.product_id IS NOT NULL

ON CONFLICT (order_id, product_id) DO NOTHING;