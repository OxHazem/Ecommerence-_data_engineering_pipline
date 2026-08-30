-- ============================================================
-- GOLD - COUNTRY SALES
-- ============================================================

TRUNCATE TABLE gold.country_sales;


INSERT INTO gold.country_sales (
    country,
    orders,
    customers,
    units_sold,
    revenue,
    cost,
    profit,
    average_order_value,
    incomplete_items
)

SELECT

    -- ========================================================
    -- COUNTRY
    --
    -- NULL countries are grouped as 'Unknown'.
    -- ========================================================

    COALESCE(
        NULLIF(TRIM(o.shipping_country), ''),
        'Unknown'
    ) AS country,


    -- ========================================================
    -- ORDERS
    -- ========================================================

    COUNT(DISTINCT o.order_id) AS orders,


    -- ========================================================
    -- CUSTOMERS
    -- ========================================================

    COUNT(DISTINCT o.customer_id) AS customers,


    -- ========================================================
    -- UNITS SOLD
    -- ========================================================

    COALESCE(
        SUM(
            CASE
                WHEN oi.quantity IS NOT NULL
                THEN oi.quantity
                ELSE 0
            END
        ),
        0
    ) AS units_sold,


    -- ========================================================
    -- REVENUE
    -- Requires quantity and unit_price.
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN oi.quantity IS NOT NULL
                     AND oi.unit_price IS NOT NULL
                    THEN
                        oi.quantity
                        * oi.unit_price
                        * (
                            1
                            - COALESCE(oi.discount, 0) / 100.0
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS revenue,


    -- ========================================================
    -- COST
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN oi.quantity IS NOT NULL
                     AND oi.unit_price IS NOT NULL
                     AND oi.cost_at_sale IS NOT NULL
                    THEN
                        oi.quantity * oi.cost_at_sale
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS cost,


    -- ========================================================
    -- PROFIT
    --
    -- Calculated from underlying item-level values.
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN oi.quantity IS NOT NULL
                     AND oi.unit_price IS NOT NULL
                     AND oi.cost_at_sale IS NOT NULL
                    THEN
                        (
                            oi.quantity
                            * oi.unit_price
                            * (
                                1
                                - COALESCE(oi.discount, 0) / 100.0
                            )
                        )
                        -
                        (
                            oi.quantity * oi.cost_at_sale
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS profit,


    -- ========================================================
    -- AVERAGE ORDER VALUE
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN oi.quantity IS NOT NULL
                     AND oi.unit_price IS NOT NULL
                    THEN
                        oi.quantity
                        * oi.unit_price
                        * (
                            1
                            - COALESCE(oi.discount, 0) / 100.0
                        )
                    ELSE 0
                END
            )
            /
            NULLIF(
                COUNT(DISTINCT o.order_id),
                0
            ),
            2
        ),
        0
    ) AS average_order_value,


    -- ========================================================
    -- INCOMPLETE ITEMS
    -- ========================================================

    COUNT(*) FILTER (
        WHERE oi.order_id IS NOT NULL
          AND (
              oi.quantity IS NULL
              OR oi.unit_price IS NULL
              OR oi.cost_at_sale IS NULL
          )
    ) AS incomplete_items


FROM silver.orders o


-- ============================================================
-- ORDER ITEMS
-- ============================================================

LEFT JOIN silver.order_item oi
    ON o.order_id = oi.order_id


-- ============================================================
-- CANCELLED ORDERS
-- ============================================================

WHERE o.order_status <> 'Cancelled'


GROUP BY
    COALESCE(
        NULLIF(TRIM(o.shipping_country), ''),
        'Unknown'
    )


ORDER BY country;