INSERT INTO kimball.fact_sales (
    order_id,
    customer_key,
    product_key,
    date_key,
    payment_key,
    quantity,
    unit_price,
    discount,
    revenue,
    cost,
    profit
)

WITH item_financials AS (

    SELECT
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.discount,
        oi.cost_at_sale,

        o.customer_id,
        o.order_date,
        o.currency,

        dc.customer_key,
        dp.product_key,
        dd.date_key,

        dpay.payment_key,

        CASE
            WHEN oi.quantity IS NOT NULL
             AND oi.unit_price IS NOT NULL
             AND oi.cost_at_sale IS NOT NULL
            THEN TRUE
            ELSE FALSE
        END AS is_financially_complete,

        CASE
            WHEN o.currency = 'EGP' THEN 1
            ELSE er.rate
        END AS egp_rate

    FROM silver.order_item oi

    INNER JOIN silver.orders o
        ON oi.order_id = o.order_id

    INNER JOIN kimball.dim_customer dc
        ON o.customer_id = dc.customer_id
       AND o.order_date >= dc.effective_date
       AND o.order_date < dc.expiration_date

    INNER JOIN kimball.dim_product dp
        ON oi.product_id = dp.product_id

    INNER JOIN kimball.dim_date dd
        ON o.order_date = dd.full_date

    LEFT JOIN silver.payment p
        ON o.order_id = p.order_id

    LEFT JOIN kimball.dim_payment dpay
        ON p.payment_id = dpay.payment_id

    LEFT JOIN LATERAL (
        SELECT rate
        FROM silver.exchange_rate er
        WHERE er.base = o.currency
          AND er.quote = 'EGP'
          AND er.date <= o.order_date
        ORDER BY er.date DESC
        LIMIT 1
    ) er
        ON TRUE

    WHERE o.order_status <> 'Cancelled'
      AND o.order_date IS NOT NULL
),

calculated AS (

    SELECT
        *,
        
        CASE
            WHEN is_financially_complete
             AND egp_rate IS NOT NULL
            THEN ROUND(
                quantity
                * unit_price
                * (1 - COALESCE(discount, 0) / 100.0)
                * egp_rate,
                2
            )
            ELSE 0
        END AS revenue_egp,

        CASE
            WHEN is_financially_complete
             AND egp_rate IS NOT NULL
            THEN ROUND(
                quantity
                * cost_at_sale
                * egp_rate,
                2
            )
            ELSE 0
        END AS cost_egp

    FROM item_financials
)

SELECT
    order_id,
    customer_key,
    product_key,
    date_key,
    payment_key,
    quantity,
    unit_price,
    discount,

    revenue_egp AS revenue,
    cost_egp AS cost,

    revenue_egp - cost_egp AS profit

FROM calculated;