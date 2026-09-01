-- -- ============================================================
-- -- GOLD - COUNTRY SALES
-- -- ============================================================

-- TRUNCATE TABLE gold.country_sales;


-- INSERT INTO gold.country_sales (
--     country,
--     orders,
--     customers,
--     units_sold,
--     revenue,
--     cost,
--     profit,
--     average_order_value,
--     incomplete_items
-- )

-- SELECT

--     -- ========================================================
--     -- COUNTRY
--     --
--     -- NULL countries are grouped as 'Unknown'.
--     -- ========================================================

--     COALESCE(
--         NULLIF(TRIM(o.shipping_country), ''),
--         'Unknown'
--     ) AS country,


--     -- ========================================================
--     -- ORDERS
--     -- ========================================================

--     COUNT(DISTINCT o.order_id) AS orders,


--     -- ========================================================
--     -- CUSTOMERS
--     -- ========================================================

--     COUNT(DISTINCT o.customer_id) AS customers,


--     -- ========================================================
--     -- UNITS SOLD
--     -- ========================================================

--     COALESCE(
--         SUM(
--             CASE
--                 WHEN oi.quantity IS NOT NULL
--                 THEN oi.quantity
--                 ELSE 0
--             END
--         ),
--         0
--     ) AS units_sold,


--     -- ========================================================
--     -- REVENUE
--     -- Requires quantity and unit_price.
--     -- ========================================================

--     COALESCE(
--         ROUND(
--             SUM(
--                 CASE
--                     WHEN oi.quantity IS NOT NULL
--                      AND oi.unit_price IS NOT NULL
--                     THEN
--                         oi.quantity
--                         * oi.unit_price
--                         * (
--                             1
--                             - COALESCE(oi.discount, 0) / 100.0
--                         )
--                     ELSE 0
--                 END
--             ),
--             2
--         ),
--         0
--     ) AS revenue,


--     -- ========================================================
--     -- COST
--     -- ========================================================

--     COALESCE(
--         ROUND(
--             SUM(
--                 CASE
--                     WHEN oi.quantity IS NOT NULL
--                      AND oi.unit_price IS NOT NULL
--                      AND oi.cost_at_sale IS NOT NULL
--                     THEN
--                         oi.quantity * oi.cost_at_sale
--                     ELSE 0
--                 END
--             ),
--             2
--         ),
--         0
--     ) AS cost,


--     -- ========================================================
--     -- PROFIT
--     --
--     -- Calculated from underlying item-level values.
--     -- ========================================================

--     COALESCE(
--         ROUND(
--             SUM(
--                 CASE
--                     WHEN oi.quantity IS NOT NULL
--                      AND oi.unit_price IS NOT NULL
--                      AND oi.cost_at_sale IS NOT NULL
--                     THEN
--                         (
--                             oi.quantity
--                             * oi.unit_price
--                             * (
--                                 1
--                                 - COALESCE(oi.discount, 0) / 100.0
--                             )
--                         )
--                         -
--                         (
--                             oi.quantity * oi.cost_at_sale
--                         )
--                     ELSE 0
--                 END
--             ),
--             2
--         ),
--         0
--     ) AS profit,


--     -- ========================================================
--     -- AVERAGE ORDER VALUE
--     -- ========================================================

--     COALESCE(
--         ROUND(
--             SUM(
--                 CASE
--                     WHEN oi.quantity IS NOT NULL
--                      AND oi.unit_price IS NOT NULL
--                     THEN
--                         oi.quantity
--                         * oi.unit_price
--                         * (
--                             1
--                             - COALESCE(oi.discount, 0) / 100.0
--                         )
--                     ELSE 0
--                 END
--             )
--             /
--             NULLIF(
--                 COUNT(DISTINCT o.order_id),
--                 0
--             ),
--             2
--         ),
--         0
--     ) AS average_order_value,


--     -- ========================================================
--     -- INCOMPLETE ITEMS
--     -- ========================================================

--     COUNT(*) FILTER (
--         WHERE oi.order_id IS NOT NULL
--           AND (
--               oi.quantity IS NULL
--               OR oi.unit_price IS NULL
--               OR oi.cost_at_sale IS NULL
--           )
--     ) AS incomplete_items


-- FROM silver.orders o


-- -- ============================================================
-- -- ORDER ITEMS
-- -- ============================================================

-- LEFT JOIN silver.order_item oi
--     ON o.order_id = oi.order_id


-- -- ============================================================
-- -- CANCELLED ORDERS
-- -- ============================================================

-- WHERE o.order_status <> 'Cancelled'


-- GROUP BY
--     COALESCE(
--         NULLIF(TRIM(o.shipping_country), ''),
--         'Unknown'
--     )


-- ORDER BY country;

-- ============================================================
-- GOLD - COUNTRY SALES
-- ============================================================

TRUNCATE TABLE gold.country_sales;


INSERT INTO gold.country_sales (
    country,
    orders,
    customers,
    units_sold,

    revenue_egp,
    cost_egp,
    profit_egp,
    average_order_value_egp,

    revenue_sar,
    cost_sar,
    profit_sar,

    revenue_aed,
    cost_aed,
    profit_aed,

    incomplete_items
)

WITH item_financials AS (

    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.currency,

        COALESCE(
            NULLIF(TRIM(o.shipping_country), ''),
            'Unknown'
        ) AS country,

        oi.quantity,
        oi.unit_price,
        oi.discount,
        oi.cost_at_sale,

        -- ====================================================
        -- ORIGINAL CURRENCY → EGP
        -- ====================================================

        CASE
            WHEN o.currency = 'EGP'
                THEN 1::NUMERIC

            ELSE er.rate
        END AS rate_to_egp

    FROM silver.orders o

    LEFT JOIN silver.order_item oi
        ON o.order_id = oi.order_id

    -- ========================================================
    -- ORDER CURRENCY → EGP
    --
    -- Most recent available rate on or before order date.
    -- ========================================================

    LEFT JOIN LATERAL (

        SELECT e.rate

        FROM silver.exchange_rate e

        WHERE e.base = o.currency
          AND e.quote = 'EGP'
          AND e.date <= o.order_date

        ORDER BY e.date DESC

        LIMIT 1

    ) er
        ON o.currency <> 'EGP'

    WHERE o.order_status <> 'Cancelled'
      AND o.order_date IS NOT NULL
),


calculated_items AS (

    SELECT

        country,
        order_id,
        customer_id,
        order_date,
        quantity,
        unit_price,
        discount,
        cost_at_sale,
        currency,
        rate_to_egp,

        -- ====================================================
        -- FINANCIAL COMPLETENESS
        -- ====================================================

        CASE
            WHEN quantity IS NOT NULL
             AND unit_price IS NOT NULL
             AND cost_at_sale IS NOT NULL
             AND rate_to_egp IS NOT NULL
            THEN TRUE

            ELSE FALSE
        END AS is_financially_complete,

        -- ====================================================
        -- REVENUE IN ORIGINAL CURRENCY
        -- ====================================================

        CASE
            WHEN quantity IS NOT NULL
             AND unit_price IS NOT NULL
             AND rate_to_egp IS NOT NULL
            THEN
                quantity
                * unit_price
                * (
                    1
                    - COALESCE(discount, 0) / 100.0
                )

            ELSE 0
        END AS revenue_original,

        -- ====================================================
        -- COST IN ORIGINAL CURRENCY
        -- ====================================================

        CASE
            WHEN quantity IS NOT NULL
             AND cost_at_sale IS NOT NULL
             AND rate_to_egp IS NOT NULL
            THEN
                quantity * cost_at_sale

            ELSE 0
        END AS cost_original

    FROM item_financials
)


SELECT

    ci.country,

    -- ========================================================
    -- ORDERS
    -- ========================================================

    COUNT(DISTINCT ci.order_id) AS orders,

    -- ========================================================
    -- CUSTOMERS
    -- ========================================================

    COUNT(DISTINCT ci.customer_id) AS customers,

    -- ========================================================
    -- UNITS SOLD
    -- ========================================================

    COALESCE(
        SUM(
            CASE
                WHEN ci.quantity IS NOT NULL
                THEN ci.quantity
                ELSE 0
            END
        ),
        0
    ) AS units_sold,


    -- ========================================================
    -- EGP REVENUE
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        ci.revenue_original
                        * ci.rate_to_egp
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS revenue_egp,


    -- ========================================================
    -- EGP COST
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        ci.cost_original
                        * ci.rate_to_egp
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS cost_egp,


    -- ========================================================
    -- EGP PROFIT
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        (
                            ci.revenue_original
                            - ci.cost_original
                        )
                        * ci.rate_to_egp
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS profit_egp,


    -- ========================================================
    -- AVERAGE ORDER VALUE - EGP
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        ci.revenue_original
                        * ci.rate_to_egp
                    ELSE 0
                END
            )
            /
            NULLIF(
                COUNT(DISTINCT ci.order_id),
                0
            ),
            2
        ),
        0
    ) AS average_order_value_egp,


    -- ========================================================
    -- REVENUE - SAR
    --
    -- First convert original currency → EGP.
    -- Then EGP → SAR using the historical SAR → EGP rate
    -- applicable to that order date.
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        (
                            ci.revenue_original
                            * ci.rate_to_egp
                        )
                        /
                        NULLIF(sr.rate, 0)
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS revenue_sar,


    -- ========================================================
    -- COST - SAR
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        (
                            ci.cost_original
                            * ci.rate_to_egp
                        )
                        /
                        NULLIF(sr.rate, 0)
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS cost_sar,


    -- ========================================================
    -- PROFIT - SAR
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        (
                            (
                                ci.revenue_original
                                - ci.cost_original
                            )
                            * ci.rate_to_egp
                        )
                        /
                        NULLIF(sr.rate, 0)
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS profit_sar,


    -- ========================================================
    -- REVENUE - AED
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        (
                            ci.revenue_original
                            * ci.rate_to_egp
                        )
                        /
                        NULLIF(ar.rate, 0)
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS revenue_aed,


    -- ========================================================
    -- COST - AED
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        (
                            ci.cost_original
                            * ci.rate_to_egp
                        )
                        /
                        NULLIF(ar.rate, 0)
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS cost_aed,


    -- ========================================================
    -- PROFIT - AED
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN ci.is_financially_complete
                    THEN
                        (
                            (
                                ci.revenue_original
                                - ci.cost_original
                            )
                            * ci.rate_to_egp
                        )
                        /
                        NULLIF(ar.rate, 0)
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS profit_aed,


    -- ========================================================
    -- INCOMPLETE ITEMS
    -- ========================================================

    COUNT(*) FILTER (
        WHERE ci.quantity IS NULL
           OR ci.unit_price IS NULL
           OR ci.cost_at_sale IS NULL
    ) AS incomplete_items


FROM calculated_items ci


-- ============================================================
-- SAR → EGP RATE FOR THE ORDER DATE
-- ============================================================

LEFT JOIN LATERAL (

    SELECT e.rate

    FROM silver.exchange_rate e

    WHERE e.base = 'SAR'
      AND e.quote = 'EGP'
      AND e.date <= ci.order_date

    ORDER BY e.date DESC

    LIMIT 1

) sr
    ON TRUE


-- ============================================================
-- AED → EGP RATE FOR THE ORDER DATE
-- ============================================================

LEFT JOIN LATERAL (

    SELECT e.rate

    FROM silver.exchange_rate e

    WHERE e.base = 'AED'
      AND e.quote = 'EGP'
      AND e.date <= ci.order_date

    ORDER BY e.date DESC

    LIMIT 1

) ar
    ON TRUE


-- ============================================================
-- COUNTRY GRAIN
-- ============================================================

GROUP BY ci.country

ORDER BY ci.country;

