-- ============================================================
-- GOLD - DAILY SALES
-- ============================================================
-- Purpose:
-- Aggregate Silver orders and order items into daily
-- business metrics.
--
-- BUSINESS RULE:
--
-- A financially complete order item requires:
--     quantity IS NOT NULL
--     unit_price IS NOT NULL
--     cost_at_sale IS NOT NULL
--
-- Complete items:
--     -> contribute to revenue
--     -> contribute to cost
--     -> contribute to profit
--
-- Incomplete items:
--     -> do NOT contribute to financial metrics
--     -> are counted in incomplete_items
--
-- Negative profit is allowed when the item is complete
-- and the actual cost is greater than the selling price.
-- ============================================================


-- ============================================================
-- REBUILD GOLD TABLE
-- ============================================================

TRUNCATE TABLE gold.daily_sales;


INSERT INTO gold.daily_sales (
    date,
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
    -- DATE
    -- ========================================================

    o.order_date AS date,


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
    --
    -- Quantity is independent of price.
    -- Therefore, if quantity exists, it is counted even when
    -- price information is missing.
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
    -- Only financially complete items contribute.
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
    --
    -- Only financially complete items contribute.
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
    -- Only financially complete items contribute.
    --
    -- Negative profit is NOT replaced with zero.
    -- A negative value can represent a genuine business loss.
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
    -- Total valid revenue / number of orders
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
    -- An item is incomplete when any required financial
    -- information is missing.
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
-- ORDER ITEM
-- ============================================================

LEFT JOIN silver.order_item oi
    ON o.order_id = oi.order_id


-- ============================================================
-- BUSINESS RULES
-- ============================================================

WHERE o.order_status <> 'Cancelled'
  AND o.order_date IS NOT NULL


-- ============================================================
-- DAILY AGGREGATION
-- ============================================================

GROUP BY o.order_date

ORDER BY o.order_date;