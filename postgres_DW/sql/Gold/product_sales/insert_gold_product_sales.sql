-- -- ============================================================
-- -- GOLD - PRODUCT SALES
-- -- ============================================================

-- TRUNCATE TABLE gold.product_sales;


-- INSERT INTO gold.product_sales (
--     product_id,
--     product_name,
--     category,
--     subcategory,
--     brand,
--     orders,
--     units_sold,
--     revenue,
--     cost,
--     profit,
--     average_selling_price,
--     incomplete_items
-- )

-- SELECT

--     -- ========================================================
--     -- PRODUCT INFORMATION
--     -- ========================================================

--     p.product_id,

--     p.product_name,

--     p.category,

--     p.subcategory,

--     p.brand,


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
--                             1 - COALESCE(oi.discount, 0) / 100.0
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
--     -- Requires quantity, unit_price and cost_at_sale.
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
--     -- Revenue - Cost
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
--                                 1 - COALESCE(oi.discount, 0) / 100.0
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
--     -- AVERAGE SELLING PRICE
--     --
--     -- Revenue / valid units sold
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
--                             1 - COALESCE(oi.discount, 0) / 100.0
--                         )
--                     ELSE 0
--                 END
--             )
--             /
--             NULLIF(
--                 SUM(
--                     CASE
--                         WHEN oi.quantity IS NOT NULL
--                          AND oi.unit_price IS NOT NULL
--                         THEN oi.quantity
--                         ELSE 0
--                     END
--                 ),
--                 0
--             ),
--             2
--         ),
--         0
--     ) AS average_selling_price,


--     -- ========================================================
--     -- INCOMPLETE ITEMS
--     --
--     -- Quantity or unit_price is missing.
--     -- ========================================================

--     COUNT(*) FILTER (
--         WHERE oi.order_id IS NOT NULL
--           AND (
--               oi.quantity IS NULL
--               OR oi.unit_price IS NULL
--           )
--     ) AS incomplete_items


-- FROM silver.product p


-- -- ============================================================
-- -- PRODUCT → ORDER ITEM
-- -- ============================================================

-- LEFT JOIN silver.order_item oi
--     ON p.product_id = oi.product_id


-- -- ============================================================
-- -- ORDER ITEM → ORDERS
-- -- ============================================================

-- LEFT JOIN silver.orders o
--     ON oi.order_id = o.order_id
--    AND o.order_status <> 'Cancelled'


-- -- ============================================================
-- -- PRODUCT LEVEL
-- -- ============================================================

-- GROUP BY
--     p.product_id,
--     p.product_name,
--     p.category,
--     p.subcategory,
--     p.brand


-- ORDER BY p.product_id;



-- ============================================================
-- GOLD - PRODUCT SALES
-- ============================================================

TRUNCATE TABLE gold.product_sales;


INSERT INTO gold.product_sales (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    orders,
    units_sold,

    revenue,
    cost,
    profit,
    average_selling_price,

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

        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,
        p.brand,

        o.order_id,
        o.order_date,
        o.currency,

        oi.quantity,
        oi.unit_price,
        oi.cost_at_sale,
        COALESCE(oi.discount, 0) AS discount,

        -- ====================================================
        -- ORIGINAL CURRENCY VALUES
        -- ====================================================

        (
            oi.quantity
            * oi.unit_price
            * (
                1 - COALESCE(oi.discount, 0) / 100.0
            )
        ) AS revenue_original,

        (
            oi.quantity
            * oi.cost_at_sale
        ) AS cost_original

    FROM silver.product p

    LEFT JOIN silver.order_item oi
        ON p.product_id = oi.product_id

    LEFT JOIN silver.orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'

),

converted AS (

    SELECT

        i.*,

        -- ====================================================
        -- EGP
        --
        -- Exchange table contains:
        --
        -- SAR → EGP
        -- AED → EGP
        -- EGP → EGP = 1
        --
        -- Therefore:
        --
        -- original amount × rate = EGP
        -- ====================================================

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                i.revenue_original
                * er.rate
            ELSE 0
        END AS revenue_egp,

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                i.cost_original
                * er.rate
            ELSE 0
        END AS cost_egp,

        -- ====================================================
        -- SAR
        --
        -- EGP / (SAR → EGP)
        -- ====================================================

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.revenue_original
                    * er.rate
                )
                / NULLIF(
                    sar_er.rate,
                    0
                )
            ELSE 0
        END AS revenue_sar_calc,

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.cost_original
                    * er.rate
                )
                / NULLIF(
                    sar_er.rate,
                    0
                )
            ELSE 0
        END AS cost_sar_calc,

        -- ====================================================
        -- AED
        --
        -- EGP / (AED → EGP)
        -- ====================================================

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.revenue_original
                    * er.rate
                )
                / NULLIF(
                    aed_er.rate,
                    0
                )
            ELSE 0
        END AS revenue_aed_calc,

        CASE
            WHEN i.quantity IS NOT NULL
             AND i.unit_price IS NOT NULL
             AND i.cost_at_sale IS NOT NULL
            THEN
                (
                    i.cost_original
                    * er.rate
                )
                / NULLIF(
                    aed_er.rate,
                    0
                )
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

    product_id,

    MAX(product_name),
    MAX(category),
    MAX(subcategory),
    MAX(brand),

    -- ========================================================
    -- ORDERS
    -- ========================================================

    COUNT(DISTINCT order_id) AS orders,

    -- ========================================================
    -- UNITS
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
            SUM(revenue_egp - cost_egp),
            0
        ),
        2
    ) AS profit,

    -- ========================================================
    -- AVERAGE SELLING PRICE
    -- EGP revenue / valid units
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(revenue_egp)
            /
            NULLIF(
                SUM(
                    CASE
                        WHEN quantity IS NOT NULL
                         AND unit_price IS NOT NULL
                         AND cost_at_sale IS NOT NULL
                        THEN quantity
                        ELSE 0
                    END
                ),
                0
            ),
            2
        ),
        0
    ) AS average_selling_price,

    -- ========================================================
    -- SAR
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(revenue_sar_calc),
            0
        ),
        2
    ) AS revenue_sar,

    ROUND(
        COALESCE(
            SUM(cost_sar_calc),
            0
        ),
        2
    ) AS cost_sar,

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
    -- AED
    -- ========================================================

    ROUND(
        COALESCE(
            SUM(revenue_aed_calc),
            0
        ),
        2
    ) AS revenue_aed,

    ROUND(
        COALESCE(
            SUM(cost_aed_calc),
            0
        ),
        2
    ) AS cost_aed,

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

GROUP BY product_id

ORDER BY product_id;