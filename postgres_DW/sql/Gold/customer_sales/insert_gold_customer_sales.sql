-- ============================================================
-- GOLD - CUSTOMER SALES
-- ============================================================
-- Business rules:
--
-- 1. Cancelled orders are excluded.
--
-- 2. Valid quantity contributes to units_sold.
--
-- 3. Financially complete items require:
--       quantity
--       unit_price
--       cost_at_sale
--
-- 4. Incomplete items do not contribute to revenue,
--    cost, or profit.
--
-- 5. Incomplete items are counted separately.
--
-- 6. Negative profit is allowed when valid cost exceeds
--    valid revenue.
-- ============================================================


-- ============================================================
-- REBUILD GOLD TABLE
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
    incomplete_items
)

SELECT

    -- ========================================================
    -- CUSTOMER INFORMATION
    -- ========================================================

    c.customer_id,

    c.first_name,

    c.last_name,

    c.country,

    c.city,

    c.customer_status,


    -- ========================================================
    -- ORDERS
    -- ========================================================

    COUNT(DISTINCT o.order_id) AS orders,


    -- ========================================================
    -- UNITS SOLD
    -- Only valid quantities contribute.
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
    --
    -- Requires quantity, unit_price and cost_at_sale
    -- so that financial metrics use only complete items.
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN oi.quantity IS NOT NULL
                     AND oi.unit_price IS NOT NULL
                     AND oi.cost_at_sale IS NOT NULL
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
    -- Profit = Revenue - Cost
    --
    -- Negative profit is preserved when valid.
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
    --
    -- Valid customer revenue / customer's valid orders
    -- ========================================================

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN oi.quantity IS NOT NULL
                     AND oi.unit_price IS NOT NULL
                     AND oi.cost_at_sale IS NOT NULL
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
    --
    -- An order item is incomplete if any required financial
    -- field is missing.
    -- ========================================================

    COUNT(*) FILTER (
        WHERE oi.order_id IS NOT NULL
          AND (
              oi.quantity IS NULL
              OR oi.unit_price IS NULL
              OR oi.cost_at_sale IS NULL
          )
    ) AS incomplete_items


FROM silver.customer c


-- ============================================================
-- CUSTOMER → ORDERS
--
-- Keep this as a LEFT JOIN so customers with no orders
-- remain in the Gold table.
-- ============================================================

LEFT JOIN silver.orders o
    ON c.customer_id = o.customer_id
   AND o.order_status <> 'Cancelled'


-- ============================================================
-- ORDERS → ORDER ITEMS
-- ============================================================

LEFT JOIN silver.order_item oi
    ON o.order_id = oi.order_id


-- ============================================================
-- CUSTOMER GRAIN
-- ============================================================

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country,
    c.city,
    c.customer_status


ORDER BY c.customer_id;