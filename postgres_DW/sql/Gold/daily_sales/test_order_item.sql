SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS null_quantity,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS null_unit_price,
    COUNT(*) FILTER (WHERE discount IS NULL) AS null_discount,
    COUNT(*) FILTER (WHERE cost_at_sale IS NULL) AS null_cost_at_sale
FROM silver.order_item;






SELECT
    COUNT(*) AS total_valid_rows,
    COUNT(*) FILTER (
        WHERE unit_price IS NOT NULL
          AND cost_at_sale IS NOT NULL
          AND discount IS NOT NULL
    ) AS rows_with_all_values,

    COUNT(*) FILTER (
        WHERE unit_price IS NOT NULL
          AND cost_at_sale IS NOT NULL
          AND discount IS NOT NULL
          AND ABS(
              cost_at_sale
              - unit_price * (1 - discount / 100.0)
          ) < 0.01
    ) AS matching_formula

FROM silver.order_item;



SELECT
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.cost_at_sale,

    ROUND(
        oi.quantity
        * oi.unit_price
        * (1 - COALESCE(oi.discount, 0) / 100.0),
        2
    ) AS line_revenue,

    ROUND(
        oi.quantity * oi.cost_at_sale,
        2
    ) AS line_cost,

    ROUND(
        (
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount, 0) / 100.0)
        )
        -
        (
            oi.quantity * oi.cost_at_sale
        ),
        2
    ) AS line_profit

FROM silver.order_item oi

JOIN silver.orders o
    ON oi.order_id = o.order_id

WHERE o.order_date = '2015-07-02'

ORDER BY line_profit;







SELECT
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.cost_at_sale,

    ROUND(
        oi.quantity
        * oi.unit_price
        * (1 - COALESCE(oi.discount, 0) / 100.0),
        2
    ) AS line_revenue,

    ROUND(
        oi.quantity * oi.cost_at_sale,
        2
    ) AS line_cost,

    ROUND(
        (
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount, 0) / 100.0)
        )
        -
        (
            oi.quantity * oi.cost_at_sale
        ),
        2
    ) AS line_profit

FROM silver.order_item oi

WHERE oi.order_id = 146993;


SELECT *
FROM silver.order_item
WHERE order_id = 146993;



SELECT
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.cost_at_sale
FROM silver.orders o
JOIN silver.order_item oi
    ON o.order_id = oi.order_id
WHERE o.order_date = '2015-07-02'
ORDER BY o.order_id, oi.product_id;