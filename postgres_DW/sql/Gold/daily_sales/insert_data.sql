-- -- ============================================================
-- -- GOLD - DAILY SALES
-- -- ============================================================
-- -- Purpose:
-- -- Aggregate Silver orders and order items into daily
-- -- business metrics.
-- --
-- -- BUSINESS RULE:
-- --
-- -- A financially complete order item requires:
-- --     quantity IS NOT NULL
-- --     unit_price IS NOT NULL
-- --     cost_at_sale IS NOT NULL
-- --
-- -- Complete items:
-- --     -> contribute to revenue
-- --     -> contribute to cost
-- --     -> contribute to profit
-- --
-- -- Incomplete items:
-- --     -> do NOT contribute to financial metrics
-- --     -> are counted in incomplete_items
-- --
-- -- Negative profit is allowed when the item is complete
-- -- and the actual cost is greater than the selling price.
-- -- ============================================================


-- -- ============================================================
-- -- REBUILD GOLD TABLE
-- -- ============================================================

-- TRUNCATE TABLE gold.daily_sales;


-- INSERT INTO gold.daily_sales (
--     date,
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
--     -- DATE
--     -- ========================================================

--     o.order_date AS date,


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
--     --
--     -- Quantity is independent of price.
--     -- Therefore, if quantity exists, it is counted even when
--     -- price information is missing.
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
--     --
--     -- Only financially complete items contribute.
--     -- ========================================================

--     COALESCE(
--         ROUND(
--             SUM(
--                 CASE
--                     WHEN oi.quantity IS NOT NULL
--                      AND oi.unit_price IS NOT NULL
--                      AND oi.cost_at_sale IS NOT NULL
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
--     --
--     -- Only financially complete items contribute.
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
--     -- Profit = Revenue - Cost
--     --
--     -- Only financially complete items contribute.
--     --
--     -- Negative profit is NOT replaced with zero.
--     -- A negative value can represent a genuine business loss.
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
--     --
--     -- Total valid revenue / number of orders
--     -- ========================================================

--     COALESCE(
--         ROUND(
--             SUM(
--                 CASE
--                     WHEN oi.quantity IS NOT NULL
--                      AND oi.unit_price IS NOT NULL
--                      AND oi.cost_at_sale IS NOT NULL
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
--     --
--     -- An item is incomplete when any required financial
--     -- information is missing.
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
-- -- ORDER ITEM
-- -- ============================================================

-- LEFT JOIN silver.order_item oi
--     ON o.order_id = oi.order_id


-- -- ============================================================
-- -- BUSINESS RULES
-- -- ============================================================

-- WHERE o.order_status <> 'Cancelled'
--   AND o.order_date IS NOT NULL


-- -- ============================================================
-- -- DAILY AGGREGATION
-- -- ============================================================

-- GROUP BY o.order_date

-- ORDER BY o.order_date;

TRUNCATE TABLE gold.daily_sales;


INSERT INTO gold.daily_sales (
    date,
    orders,
    customers,
    units_sold,

    revenue,
    cost,
    profit,

    revenue_sar,
    cost_sar,
    profit_sar,

    revenue_aed,
    cost_aed,
    profit_aed,

    average_order_value,
    incomplete_items
)

WITH item_financials AS (

    SELECT

        o.order_id,
        o.customer_id,
        o.order_date,
        o.currency,

        oi.quantity,
        oi.unit_price,
        oi.discount,
        oi.cost_at_sale,

        -- ====================================================
        -- HISTORICAL EXCHANGE RATE
        --
        -- Find the latest available rate on or before
        -- the order date.
        -- ====================================================

        COALESCE(
            er.rate,
            1
        ) AS egp_rate,

        -- ====================================================
        -- VALID FINANCIAL ITEM
        -- ====================================================

        CASE
            WHEN oi.quantity IS NOT NULL
             AND oi.unit_price IS NOT NULL
             AND oi.cost_at_sale IS NOT NULL
            THEN TRUE
            ELSE FALSE
        END AS is_financially_complete

    FROM silver.orders o

    LEFT JOIN silver.order_item oi
        ON o.order_id = oi.order_id

    LEFT JOIN LATERAL (

        SELECT
            rate

        FROM silver.exchange_rate

        WHERE base = o.currency
          AND quote = 'EGP'
          AND date <= o.order_date

        ORDER BY date DESC

        LIMIT 1

    ) er
        ON TRUE

    WHERE o.order_status <> 'Cancelled'
      AND o.order_date IS NOT NULL
)


SELECT

    -- ========================================================
    -- DATE
    -- ========================================================

    order_date AS date,


    -- ========================================================
    -- ORDERS
    -- ========================================================

    COUNT(DISTINCT order_id) AS orders,


    -- ========================================================
    -- CUSTOMERS
    -- ========================================================

    COUNT(DISTINCT customer_id) AS customers,


    -- ========================================================
    -- UNITS SOLD
    -- ========================================================

    COALESCE(
        SUM(
            CASE
                WHEN quantity IS NOT NULL
                THEN quantity
                ELSE 0
            END
        ),
        0
    ) AS units_sold,


    -- ========================================================
    -- REVENUE — EGP
    --
    -- Native amount × historical currency → EGP rate
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        quantity
                        * unit_price
                        * (
                            1
                            - COALESCE(discount, 0) / 100.0
                        )
                        * egp_rate
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS revenue,


    -- ========================================================
    -- COST — EGP
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        quantity
                        * cost_at_sale
                        * egp_rate
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS cost,


    -- ========================================================
    -- PROFIT — EGP
    --
    -- Revenue EGP - Cost EGP
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        (
                            quantity
                            * unit_price
                            * (
                                1
                                - COALESCE(discount, 0) / 100.0
                            )
                            * egp_rate
                        )
                        -
                        (
                            quantity
                            * cost_at_sale
                            * egp_rate
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS profit,


    -- ========================================================
    -- REVENUE — SAR
    --
    -- EGP → SAR
    --
    -- Since SAR → EGP is stored:
    --
    -- SAR amount = EGP amount / SAR→EGP rate
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        (
                            quantity
                            * unit_price
                            * (
                                1
                                - COALESCE(discount, 0) / 100.0
                            )
                            * egp_rate
                        )
                        /
                        NULLIF(
                            (
                                SELECT rate
                                FROM silver.exchange_rate er_sar
                                WHERE er_sar.base = 'SAR'
                                  AND er_sar.quote = 'EGP'
                                  AND er_sar.date <= item_financials.order_date
                                ORDER BY er_sar.date DESC
                                LIMIT 1
                            ),
                            0
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS revenue_sar,


    -- ========================================================
    -- COST — SAR
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        (
                            quantity
                            * cost_at_sale
                            * egp_rate
                        )
                        /
                        NULLIF(
                            (
                                SELECT rate
                                FROM silver.exchange_rate er_sar
                                WHERE er_sar.base = 'SAR'
                                  AND er_sar.quote = 'EGP'
                                  AND er_sar.date <= item_financials.order_date
                                ORDER BY er_sar.date DESC
                                LIMIT 1
                            ),
                            0
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS cost_sar,


    -- ========================================================
    -- PROFIT — SAR
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        (
                            (
                                quantity
                                * unit_price
                                * (
                                    1
                                    - COALESCE(discount, 0) / 100.0
                                )
                                * egp_rate
                            )
                            -
                            (
                                quantity
                                * cost_at_sale
                                * egp_rate
                            )
                        )
                        /
                        NULLIF(
                            (
                                SELECT rate
                                FROM silver.exchange_rate er_sar
                                WHERE er_sar.base = 'SAR'
                                  AND er_sar.quote = 'EGP'
                                  AND er_sar.date <= item_financials.order_date
                                ORDER BY er_sar.date DESC
                                LIMIT 1
                            ),
                            0
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS profit_sar,


    -- ========================================================
    -- REVENUE — AED
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        (
                            quantity
                            * unit_price
                            * (
                                1
                                - COALESCE(discount, 0) / 100.0
                            )
                            * egp_rate
                        )
                        /
                        NULLIF(
                            (
                                SELECT rate
                                FROM silver.exchange_rate er_aed
                                WHERE er_aed.base = 'AED'
                                  AND er_aed.quote = 'EGP'
                                  AND er_aed.date <= item_financials.order_date
                                ORDER BY er_aed.date DESC
                                LIMIT 1
                            ),
                            0
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS revenue_aed,


    -- ========================================================
    -- COST — AED
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        (
                            quantity
                            * cost_at_sale
                            * egp_rate
                        )
                        /
                        NULLIF(
                            (
                                SELECT rate
                                FROM silver.exchange_rate er_aed
                                WHERE er_aed.base = 'AED'
                                  AND er_aed.quote = 'EGP'
                                  AND er_aed.date <= item_financials.order_date
                                ORDER BY er_aed.date DESC
                                LIMIT 1
                            ),
                            0
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS cost_aed,


    -- ========================================================
    -- PROFIT — AED
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        (
                            (
                                quantity
                                * unit_price
                                * (
                                    1
                                    - COALESCE(discount, 0) / 100.0
                                )
                                * egp_rate
                            )
                            -
                            (
                                quantity
                                * cost_at_sale
                                * egp_rate
                            )
                        )
                        /
                        NULLIF(
                            (
                                SELECT rate
                                FROM silver.exchange_rate er_aed
                                WHERE er_aed.base = 'AED'
                                  AND er_aed.quote = 'EGP'
                                  AND er_aed.date <= item_financials.order_date
                                ORDER BY er_aed.date DESC
                                LIMIT 1
                            ),
                            0
                        )
                    ELSE 0
                END
            ),
            2
        ),
        0
    ) AS profit_aed,


    -- ========================================================
    -- AVERAGE ORDER VALUE — EGP
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN is_financially_complete
                    THEN
                        quantity
                        * unit_price
                        * (
                            1
                            - COALESCE(discount, 0) / 100.0
                        )
                        * egp_rate
                    ELSE 0
                END
            )
            /
            NULLIF(
                COUNT(DISTINCT order_id),
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
        WHERE order_id IS NOT NULL
          AND NOT is_financially_complete
    ) AS incomplete_items


FROM item_financials

GROUP BY order_date

ORDER BY order_date;