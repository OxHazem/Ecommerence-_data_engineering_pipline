-- -- ============================================================
-- -- GOLD - CUSTOMER SALES
-- -- ============================================================
-- -- Business rules:
-- --
-- -- 1. Cancelled orders are excluded.
-- --
-- -- 2. Valid quantity contributes to units_sold.
-- --
-- -- 3. Financially complete items require:
-- --       quantity
-- --       unit_price
-- --       cost_at_sale
-- --
-- -- 4. Incomplete items do not contribute to revenue,
-- --    cost, or profit.
-- --
-- -- 5. Incomplete items are counted separately.
-- --
-- -- 6. Negative profit is allowed when valid cost exceeds
-- --    valid revenue.
-- -- ============================================================


-- -- ============================================================
-- -- REBUILD GOLD TABLE
-- -- ============================================================

-- TRUNCATE TABLE gold.customer_sales;


-- INSERT INTO gold.customer_sales (
--     customer_id,
--     first_name,
--     last_name,
--     country,
--     city,
--     customer_status,
--     orders,
--     units_sold,
--     revenue,
--     cost,
--     profit,
--     average_order_value,
--     incomplete_items
-- )

-- SELECT

--     -- ========================================================
--     -- CUSTOMER INFORMATION
--     -- ========================================================

--     c.customer_id,

--     c.first_name,

--     c.last_name,

--     c.country,

--     c.city,

--     c.customer_status,


--     -- ========================================================
--     -- ORDERS
--     -- ========================================================

--     COUNT(DISTINCT o.order_id) AS orders,


--     -- ========================================================
--     -- UNITS SOLD
--     -- Only valid quantities contribute.
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
--     -- Requires quantity, unit_price and cost_at_sale
--     -- so that financial metrics use only complete items.
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
--     -- Negative profit is preserved when valid.
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
--     -- Valid customer revenue / customer's valid orders
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
--     -- An order item is incomplete if any required financial
--     -- field is missing.
--     -- ========================================================

--     COUNT(*) FILTER (
--         WHERE oi.order_id IS NOT NULL
--           AND (
--               oi.quantity IS NULL
--               OR oi.unit_price IS NULL
--               OR oi.cost_at_sale IS NULL
--           )
--     ) AS incomplete_items


-- FROM silver.customer c


-- -- ============================================================
-- -- CUSTOMER → ORDERS
-- --
-- -- Keep this as a LEFT JOIN so customers with no orders
-- -- remain in the Gold table.
-- -- ============================================================

-- LEFT JOIN silver.orders o
--     ON c.customer_id = o.customer_id
--    AND o.order_status <> 'Cancelled'


-- -- ============================================================
-- -- ORDERS → ORDER ITEMS
-- -- ============================================================

-- LEFT JOIN silver.order_item oi
--     ON o.order_id = oi.order_id


-- -- ============================================================
-- -- CUSTOMER GRAIN
-- -- ============================================================

-- GROUP BY
--     c.customer_id,
--     c.first_name,
--     c.last_name,
--     c.country,
--     c.city,
--     c.customer_status


-- ORDER BY c.customer_id;

-- ============================================================
-- GOLD - CUSTOMER SALES
-- ============================================================

TRUNCATE TABLE gold.customer_sales;


INSERT INTO gold.customer_sales (
    customer_id,
    first_name,
    last_name,
    country,
    city,
    customer_status,

    orders,
    units_sold,

    revenue,
    cost,
    profit,
    average_order_value,

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

        -- ====================================================
        -- CUSTOMER
        -- ====================================================

        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        c.city,
        c.customer_status,

        -- ====================================================
        -- ORDER
        -- ====================================================

        o.order_id,
        o.order_date,
        o.currency,

        -- ====================================================
        -- ORDER ITEM
        -- ====================================================

        oi.quantity,
        oi.unit_price,
        oi.cost_at_sale,

        COALESCE(
            oi.discount,
            0
        ) AS discount,

        -- ====================================================
        -- ORIGINAL CURRENCY REVENUE
        -- ====================================================

        (
            oi.quantity
            * oi.unit_price
            * (
                1
                - COALESCE(oi.discount, 0) / 100.0
            )
        ) AS revenue_original,

        -- ====================================================
        -- ORIGINAL CURRENCY COST
        -- ====================================================

        (
            oi.quantity
            * oi.cost_at_sale
        ) AS cost_original

    FROM silver.customer c

    LEFT JOIN silver.orders o
        ON c.customer_id = o.customer_id
       AND o.order_status <> 'Cancelled'

    LEFT JOIN silver.order_item oi
        ON o.order_id = oi.order_id
),

converted AS (

    SELECT

        i.*,

        -- ====================================================
        -- ORDER CURRENCY → EGP
        -- ====================================================

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                i.revenue_original * er.rate
            ELSE 0
        END AS revenue_egp,

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                i.cost_original * er.rate
            ELSE 0
        END AS cost_egp,

        -- ====================================================
        -- ORDER CURRENCY → EGP → SAR
        --
        -- SAR → EGP rate is used as the denominator.
        -- ====================================================

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.revenue_original * er.rate
                )
                / NULLIF(sar_er.rate, 0)
            ELSE 0
        END AS revenue_sar_calc,

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.cost_original * er.rate
                )
                / NULLIF(sar_er.rate, 0)
            ELSE 0
        END AS cost_sar_calc,

        -- ====================================================
        -- ORDER CURRENCY → EGP → AED
        -- ====================================================

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.revenue_original * er.rate
                )
                / NULLIF(aed_er.rate, 0)
            ELSE 0
        END AS revenue_aed_calc,

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.cost_original * er.rate
                )
                / NULLIF(aed_er.rate, 0)
            ELSE 0
        END AS cost_aed_calc

    FROM item_financials i

    -- ========================================================
    -- ORDER CURRENCY → EGP
    -- ========================================================

    LEFT JOIN silver.exchange_rate er
        ON er.base = i.currency
       AND er.quote = 'EGP'
       AND er.date = i.order_date

    -- ========================================================
    -- SAR → EGP
    -- ========================================================

    LEFT JOIN silver.exchange_rate sar_er
        ON sar_er.base = 'SAR'
       AND sar_er.quote = 'EGP'
       AND sar_er.date = i.order_date

    -- ========================================================
    -- AED → EGP
    -- ========================================================

    LEFT JOIN silver.exchange_rate aed_er
        ON aed_er.base = 'AED'
       AND aed_er.quote = 'EGP'
       AND aed_er.date = i.order_date
)

SELECT

    -- ========================================================
    -- CUSTOMER INFORMATION
    -- ========================================================

    customer_id,

    MAX(first_name),
    MAX(last_name),
    MAX(country),
    MAX(city),
    MAX(customer_status),

    -- ========================================================
    -- ORDERS
    -- ========================================================

    COUNT(DISTINCT order_id) AS orders,

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
    -- EGP REVENUE
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(revenue_egp),
            0
        ),
        2
    ) AS revenue,

    -- ========================================================
    -- EGP COST
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(cost_egp),
            0
        ),
        2
    ) AS cost,

    -- ========================================================
    -- EGP PROFIT
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(
                revenue_egp - cost_egp
            ),
            0
        ),
        2
    ) AS profit,

    -- ========================================================
    -- AVERAGE ORDER VALUE
    --
    -- EGP revenue / customer's orders
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(revenue_egp)
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
    -- SAR REVENUE
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(revenue_sar_calc),
            0
        ),
        2
    ) AS revenue_sar,

    -- ========================================================
    -- SAR COST
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(cost_sar_calc),
            0
        ),
        2
    ) AS cost_sar,

    -- ========================================================
    -- SAR PROFIT
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(
                revenue_sar_calc
                - cost_sar_calc
            ),
            0
        ),
        2
    ) AS profit_sar,

    -- ========================================================
    -- AED REVENUE
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(revenue_aed_calc),
            0
        ),
        2
    ) AS revenue_aed,

    -- ========================================================
    -- AED COST
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(cost_aed_calc),
            0
        ),
        2
    ) AS cost_aed,

    -- ========================================================
    -- AED PROFIT
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(
                revenue_aed_calc
                - cost_aed_calc
            ),
            0
        ),
        2
    ) AS profit_aed,

    -- ========================================================
    -- INCOMPLETE ITEMS
    -- ========================================================

    COUNT(*) FILTER (
        WHERE order_id IS NOT NULL
          AND (
              quantity IS NULL
              OR unit_price IS NULL
              OR cost_at_sale IS NULL
          )
    ) AS incomplete_items

FROM converted

GROUP BY customer_id

ORDER BY customer_id;