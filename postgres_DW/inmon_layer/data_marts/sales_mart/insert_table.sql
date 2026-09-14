INSERT INTO inmon_mart.sales_mart (
    order_id,
    order_date,
    customer_id,
    customer_country,
    product_id,
    product_name,
    brand,
    category,
    subcategory,
    quantity,
    unit_price,
    discount,
    cost_at_sale
)
SELECT
    o.order_id,
    o.order_date,

    c.customer_id,
    co.country_name AS customer_country,

    oi.product_id,
    p.product_name,
    p.brand,
    cat.category_name,
    sc.subcategory_name,

    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.cost_at_sale

FROM inmon_layer.order_item oi

JOIN inmon_layer.orders o
    ON oi.order_id = o.order_id

JOIN inmon_layer.customer c
    ON o.customer_id = c.customer_id

JOIN inmon_layer.city ci
    ON c.city_id = ci.city_id

JOIN inmon_layer.country co
    ON ci.country_id = co.country_id

JOIN inmon_layer.product p
    ON oi.product_id = p.product_id

JOIN inmon_layer.subcategory sc
    ON p.subcategory_id = sc.subcategory_id

JOIN inmon_layer.category cat
    ON sc.category_id = cat.category_id

ON CONFLICT (order_id, product_id) DO NOTHING;