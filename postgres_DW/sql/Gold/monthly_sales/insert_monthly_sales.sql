-- ============================================================
-- GOLD - MONTHLY SALES
-- ============================================================
-- Purpose:
-- Aggregate Gold daily sales into monthly business metrics.
--
-- Grain:
-- One row = one calendar month.
--
-- Customers are calculated as DISTINCT customers per month
-- because daily customer counts cannot simply be summed.
-- ============================================================


-- ============================================================
-- Rebuild the Gold table
-- ============================================================

TRUNCATE TABLE gold.monthly_sales;


WITH monthly_metrics AS (

    SELECT
        DATE_TRUNC('month', date)::DATE AS month,

        SUM(orders) AS orders,

        SUM(units_sold) AS units_sold,

        SUM(revenue) AS revenue,

        SUM(cost) AS cost,

        SUM(profit) AS profit,

        SUM(incomplete_items) AS incomplete_items

    FROM gold.daily_sales

    GROUP BY DATE_TRUNC('month', date)
),

monthly_customers AS (

    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,

        COUNT(DISTINCT o.customer_id) AS customers

    FROM silver.orders o

    WHERE o.order_status <> 'Cancelled'
      AND o.order_date IS NOT NULL

    GROUP BY DATE_TRUNC('month', o.order_date)

)


INSERT INTO gold.monthly_sales (
    month,
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

    m.month,

    m.orders,

    COALESCE(c.customers, 0) AS customers,

    m.units_sold,

    m.revenue,

    m.cost,

    m.profit,

    COALESCE(
        ROUND(
            m.revenue / NULLIF(m.orders, 0),
            2
        ),
        0
    ) AS average_order_value,

    m.incomplete_items

FROM monthly_metrics m

LEFT JOIN monthly_customers c
    ON m.month = c.month

ORDER BY m.month;





