INSERT INTO inmon_mart.sales_mart (
    order_id,
    order_date,
    order_status,
    currency,
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
    cost_at_sale,
    exchange_rate,
    revenue_egp,
    cost_egp,
    profit_egp
)
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.currency,

    c.customer_id,
    co.country_name AS customer_country,

    oi.product_id,
    p.product_name,
    p.brand,
    cat.category_name AS category,
    sc.subcategory_name AS subcategory,

    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.cost_at_sale,

    -- Exchange rate used for this transaction
    CASE
        WHEN o.order_date IS NULL THEN NULL
        WHEN o.currency = 'EGP' THEN 1.00000000
        ELSE er.rate
    END AS exchange_rate,

    -- Revenue standardized to EGP
    CASE
        WHEN o.order_status = 'Cancelled' THEN 0.00
        WHEN o.order_date IS NULL THEN NULL
        WHEN oi.quantity IS NULL OR oi.unit_price IS NULL THEN NULL
        WHEN o.currency = 'EGP' THEN
            ROUND(
                oi.quantity
                * oi.unit_price
                * (1 - COALESCE(oi.discount, 0) / 100.0),
                2
            )
        WHEN er.rate IS NOT NULL THEN
            ROUND(
                oi.quantity
                * oi.unit_price
                * (1 - COALESCE(oi.discount, 0) / 100.0)
                * er.rate,
                2
            )
        ELSE NULL
    END AS revenue_egp,

    -- Cost standardized to EGP
    CASE
        WHEN o.order_status = 'Cancelled' THEN 0.00
        WHEN o.order_date IS NULL THEN NULL
        WHEN oi.quantity IS NULL OR oi.cost_at_sale IS NULL THEN NULL
        WHEN o.currency = 'EGP' THEN
            ROUND(
                oi.quantity * oi.cost_at_sale,
                2
            )
        WHEN er.rate IS NOT NULL THEN
            ROUND(
                oi.quantity * oi.cost_at_sale * er.rate,
                2
            )
        ELSE NULL
    END AS cost_egp,

    -- Profit standardized to EGP
    CASE
        WHEN o.order_status = 'Cancelled' THEN 0.00
        WHEN o.order_date IS NULL THEN NULL
        WHEN oi.quantity IS NULL
          OR oi.unit_price IS NULL
          OR oi.cost_at_sale IS NULL THEN NULL
        WHEN o.currency = 'EGP' THEN
            ROUND(
                oi.quantity
                * oi.unit_price
                * (1 - COALESCE(oi.discount, 0) / 100.0),
                2
            )
            -
            ROUND(
                oi.quantity * oi.cost_at_sale,
                2
            )
        WHEN er.rate IS NOT NULL THEN
            ROUND(
                oi.quantity
                * oi.unit_price
                * (1 - COALESCE(oi.discount, 0) / 100.0)
                * er.rate,
                2
            )
            -
            ROUND(
                oi.quantity * oi.cost_at_sale * er.rate,
                2
            )
        ELSE NULL
    END AS profit_egp

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

LEFT JOIN LATERAL (
    SELECT er.rate
    FROM inmon_layer.exchange_rate er
    WHERE er.date <= o.order_date
      AND er.base = o.currency
      AND er.quote = 'EGP'
    ORDER BY er.date DESC
    LIMIT 1
) er ON TRUE;