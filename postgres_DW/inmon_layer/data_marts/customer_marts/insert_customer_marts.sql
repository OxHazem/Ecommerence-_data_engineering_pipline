INSERT INTO inmon_mart.customer_mart (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    gender,
    date_of_birth,
    country,
    city,
    registration_date,
    customer_status,
    total_orders,
    total_items,
    total_quantity,
    total_revenue_egp,
    total_cost_egp,
    total_profit_egp,
    first_order_date,
    last_order_date
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.gender,
    c.date_of_birth,
    co.country_name AS country,
    ci.city_name AS city,
    c.registration_date,
    c.customer_status,

    -- Number of orders
    COALESCE(oa.total_orders, 0) AS total_orders,

    -- Number of order-item rows
    COALESCE(oa.total_items, 0) AS total_items,

    -- Total quantity purchased
    COALESCE(oa.total_quantity, 0) AS total_quantity,

    -- Financial metrics in EGP
    oa.total_revenue_egp,
    oa.total_cost_egp,
    oa.total_profit_egp,

    -- Order behavior
    oa.first_order_date,
    oa.last_order_date

FROM inmon_layer.customer c

JOIN inmon_layer.city ci
    ON c.city_id = ci.city_id

JOIN inmon_layer.country co
    ON ci.country_id = co.country_id

LEFT JOIN (
    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        COUNT(oi.order_id) AS total_items,

        SUM(COALESCE(oi.quantity, 0)) AS total_quantity,

        MIN(o.order_date) AS first_order_date,

        MAX(o.order_date) AS last_order_date,

        /*
         * Revenue in EGP.
         *
         * Cancelled orders contribute zero.
         * Rows with missing unit_price cannot contribute
         * a known revenue value.
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
         * Cost in EGP.
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
         * Profit in EGP.
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

    FROM inmon_layer.orders o

    LEFT JOIN inmon_layer.order_item oi
        ON o.order_id = oi.order_id

    LEFT JOIN LATERAL (
        SELECT er.rate
        FROM inmon_layer.exchange_rate er
        WHERE er.date <= o.order_date
          AND er.base = o.currency
          AND er.quote = 'EGP'
        ORDER BY er.date DESC
        LIMIT 1
    ) er ON TRUE

    GROUP BY o.customer_id
) oa
    ON c.customer_id = oa.customer_id;