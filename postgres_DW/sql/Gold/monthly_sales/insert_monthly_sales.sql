-- -- ============================================================
-- -- GOLD - MONTHLY SALES
-- -- ============================================================
-- -- Purpose:
-- -- Aggregate Gold daily sales into monthly business metrics.
-- --
-- -- Grain:
-- -- One row = one calendar month.
-- --
-- -- Customers are calculated as DISTINCT customers per month
-- -- because daily customer counts cannot simply be summed.
-- -- ============================================================


-- -- ============================================================
-- -- Rebuild the Gold table
-- -- ============================================================

-- TRUNCATE TABLE gold.monthly_sales;


-- WITH monthly_metrics AS (

--     SELECT
--         DATE_TRUNC('month', date)::DATE AS month,

--         SUM(orders) AS orders,

--         SUM(units_sold) AS units_sold,

--         SUM(revenue) AS revenue,

--         SUM(cost) AS cost,

--         SUM(profit) AS profit,

--         SUM(incomplete_items) AS incomplete_items

--     FROM gold.daily_sales

--     GROUP BY DATE_TRUNC('month', date)
-- ),

-- monthly_customers AS (

--     SELECT
--         DATE_TRUNC('month', o.order_date)::DATE AS month,

--         COUNT(DISTINCT o.customer_id) AS customers

--     FROM silver.orders o

--     WHERE o.order_status <> 'Cancelled'
--       AND o.order_date IS NOT NULL

--     GROUP BY DATE_TRUNC('month', o.order_date)

-- )


-- INSERT INTO gold.monthly_sales (
--     month,
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

--     m.month,

--     m.orders,

--     COALESCE(c.customers, 0) AS customers,

--     m.units_sold,

--     m.revenue,

--     m.cost,

--     m.profit,

--     COALESCE(
--         ROUND(
--             m.revenue / NULLIF(m.orders, 0),
--             2
--         ),
--         0
--     ) AS average_order_value,

--     m.incomplete_items

-- FROM monthly_metrics m

-- LEFT JOIN monthly_customers c
--     ON m.month = c.month

-- ORDER BY m.month;



-- ============================================================
-- GOLD - MONTHLY SALES
-- ============================================================
-- Grain:
-- One row per calendar month.
--
-- Source:
-- gold.daily_sales
--
-- Currency strategy:
-- Daily sales already contains historically converted
-- EGP, AED, and SAR metrics.
--
-- Therefore monthly_sales simply aggregates those values.
-- ============================================================

TRUNCATE TABLE gold.monthly_sales;


-- ============================================================
-- MONTHLY SALES METRICS
-- ============================================================

WITH monthly_metrics AS (

    SELECT

        DATE_TRUNC('month', date)::DATE AS month,

        SUM(orders) AS orders,

        SUM(units_sold) AS units_sold,

        SUM(revenue) AS revenue,

        SUM(cost) AS cost,

        SUM(profit) AS profit,

        SUM(revenue_aed) AS revenue_aed,

        SUM(cost_aed) AS cost_aed,

        SUM(profit_aed) AS profit_aed,

        SUM(revenue_sar) AS revenue_sar,

        SUM(cost_sar) AS cost_sar,

        SUM(profit_sar) AS profit_sar,

        SUM(incomplete_items) AS incomplete_items

    FROM gold.daily_sales

    GROUP BY DATE_TRUNC('month', date)
),


-- ============================================================
-- DISTINCT CUSTOMERS PER MONTH
-- ============================================================
-- We cannot SUM daily customer counts because the same
-- customer can appear on multiple days.
-- ============================================================

monthly_customers AS (

    SELECT

        DATE_TRUNC(
            'month',
            o.order_date
        )::DATE AS month,

        COUNT(DISTINCT o.customer_id) AS customers

    FROM silver.orders o

    WHERE o.order_status <> 'Cancelled'

      AND o.order_date IS NOT NULL

    GROUP BY
        DATE_TRUNC(
            'month',
            o.order_date
        )

)


-- ============================================================
-- INSERT MONTHLY GOLD DATA
-- ============================================================

INSERT INTO gold.monthly_sales (

    month,

    orders,

    customers,

    units_sold,

    -- EGP
    revenue,
    cost,
    profit,
    average_order_value,

    -- AED
    revenue_aed,
    cost_aed,
    profit_aed,
    average_order_value_aed,

    -- SAR
    revenue_sar,
    cost_sar,
    profit_sar,
    average_order_value_sar,

    incomplete_items
)

SELECT

    m.month,

    m.orders,

    COALESCE(
        c.customers,
        0
    ) AS customers,

    m.units_sold,


    -- ========================================================
    -- EGP
    -- ========================================================

    COALESCE(
        ROUND(m.revenue, 2),
        0
    ) AS revenue,

    COALESCE(
        ROUND(m.cost, 2),
        0
    ) AS cost,

    COALESCE(
        ROUND(m.profit, 2),
        0
    ) AS profit,

    COALESCE(
        ROUND(
            m.revenue
            / NULLIF(m.orders, 0),
            2
        ),
        0
    ) AS average_order_value,


    -- ========================================================
    -- AED
    -- ========================================================

    COALESCE(
        ROUND(m.revenue_aed, 2),
        0
    ) AS revenue_aed,

    COALESCE(
        ROUND(m.cost_aed, 2),
        0
    ) AS cost_aed,

    COALESCE(
        ROUND(m.profit_aed, 2),
        0
    ) AS profit_aed,

    COALESCE(
        ROUND(
            m.revenue_aed
            / NULLIF(m.orders, 0),
            2
        ),
        0
    ) AS average_order_value_aed,


    -- ========================================================
    -- SAR
    -- ========================================================

    COALESCE(
        ROUND(m.revenue_sar, 2),
        0
    ) AS revenue_sar,

    COALESCE(
        ROUND(m.cost_sar, 2),
        0
    ) AS cost_sar,

    COALESCE(
        ROUND(m.profit_sar, 2),
        0
    ) AS profit_sar,

    COALESCE(
        ROUND(
            m.revenue_sar
            / NULLIF(m.orders, 0),
            2
        ),
        0
    ) AS average_order_value_sar,


    -- ========================================================
    -- DATA QUALITY
    -- ========================================================

    m.incomplete_items


FROM monthly_metrics m

LEFT JOIN monthly_customers c

    ON m.month = c.month


ORDER BY m.month;

