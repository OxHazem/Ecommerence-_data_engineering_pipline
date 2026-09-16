INSERT INTO inmon_mart.product_mart (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    supplier,
    cost,
    price,
    stock_quantity,
    product_status,
    launch_date,
    total_orders,
    total_items,
    total_quantity,
    total_revenue_egp,
    total_cost_egp,
    total_profit_egp,
    first_sale_date,
    last_sale_date
)
SELECT
    p.product_id,
    p.product_name,
    cat.category_name AS category,
    sc.subcategory_name AS subcategory,
    p.brand,
    p.supplier,
    p.cost,
    p.price,
    p.stock_quantity,
    p.product_status,
    p.launch_date,

    -- Sales activity
    COALESCE(pa.total_orders, 0) AS total_orders,
    COALESCE(pa.total_items, 0) AS total_items,
    COALESCE(pa.total_quantity, 0) AS total_quantity,

    -- Financial metrics
    pa.total_revenue_egp,
    pa.total_cost_egp,
    pa.total_profit_egp,

    -- Sale dates
    pa.first_sale_date,
    pa.last_sale_date

FROM inmon_layer.product p

JOIN inmon_layer.subcategory sc
    ON p.subcategory_id = sc.subcategory_id

JOIN inmon_layer.category cat
    ON sc.category_id = cat.category_id

LEFT JOIN (
    SELECT
        oi.product_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        COUNT(oi.order_id) AS total_items,

        SUM(COALESCE(oi.quantity, 0)) AS total_quantity,

        MIN(o.order_date) AS first_sale_date,

        MAX(o.order_date) AS last_sale_date,

        /*
         * Revenue in EGP
         */
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled' THEN 0.00

                WHEN o.order_date IS NULL
                  OR oi.quantity IS NULL
                  OR oi.unit_price IS NULL THEN NULL

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
            END
        ) AS total_revenue_egp,

        /*
         * Cost in EGP
         */
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled' THEN 0.00

                WHEN o.order_date IS NULL
                  OR oi.quantity IS NULL
                  OR oi.cost_at_sale IS NULL THEN NULL

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
            END
        ) AS total_cost_egp,

        /*
         * Profit in EGP
         */
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled' THEN 0.00

                WHEN o.order_date IS NULL
                  OR oi.quantity IS NULL
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
            END
        ) AS total_profit_egp

    FROM inmon_layer.order_item oi

    JOIN inmon_layer.orders o
        ON oi.order_id = o.order_id

    LEFT JOIN LATERAL (
        SELECT er.rate
        FROM inmon_layer.exchange_rate er
        WHERE er.date <= o.order_date
          AND er.base = o.currency
          AND er.quote = 'EGP'
        ORDER BY er.date DESC
        LIMIT 1
    ) er ON TRUE

    GROUP BY oi.product_id
) pa
    ON p.product_id = pa.product_id;