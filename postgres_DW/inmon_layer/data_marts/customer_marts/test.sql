SELECT
    COUNT(*) AS customers_without_orders
FROM inmon_mart.customer_mart
WHERE total_orders = 0;




SELECT
    COUNT(*) FILTER (WHERE total_items <> 0) AS bad_items,
    COUNT(*) FILTER (WHERE total_quantity <> 0) AS bad_quantity,
    COUNT(*) FILTER (WHERE total_revenue_egp IS NOT NULL) AS bad_revenue,
    COUNT(*) FILTER (WHERE total_cost_egp IS NOT NULL) AS bad_cost,
    COUNT(*) FILTER (WHERE total_profit_egp IS NOT NULL) AS bad_profit,
    COUNT(*) FILTER (WHERE first_order_date IS NOT NULL) AS bad_first_date,
    COUNT(*) FILTER (WHERE last_order_date IS NOT NULL) AS bad_last_date
FROM inmon_mart.customer_mart
WHERE total_orders = 0;





SELECT
    SUM(total_orders) AS mart_total_orders,
    SUM(total_items) AS mart_total_items,
    SUM(total_quantity) AS mart_total_quantity
FROM inmon_mart.customer_mart;





SELECT COUNT(*) AS profit_mismatches
FROM inmon_mart.customer_mart
WHERE total_profit_egp IS NOT NULL
  AND total_revenue_egp IS NOT NULL
  AND total_cost_egp IS NOT NULL
  AND total_profit_egp <> total_revenue_egp - total_cost_egp;






SELECT
    COUNT(*) AS customers,
    COUNT(*) FILTER (WHERE total_orders > 0) AS active_customers,
    COUNT(*) FILTER (WHERE total_orders = 0) AS customers_without_orders,
    SUM(total_orders) AS total_orders,
    SUM(total_items) AS total_items,
    SUM(total_quantity) AS total_quantity,
    SUM(total_revenue_egp) AS total_revenue_egp,
    SUM(total_cost_egp) AS total_cost_egp,
    SUM(total_profit_egp) AS total_profit_egp
FROM inmon_mart.customer_mart;








SELECT
    cm.total_revenue_egp,
    sm.total_revenue_egp,
    cm.total_cost_egp,
    sm.total_cost_egp,
    cm.total_profit_egp,
    sm.total_profit_egp
FROM
(
    SELECT
        SUM(total_revenue_egp) AS total_revenue_egp,
        SUM(total_cost_egp) AS total_cost_egp,
        SUM(total_profit_egp) AS total_profit_egp
    FROM inmon_mart.customer_mart
) cm
CROSS JOIN
(
    SELECT
        SUM(revenue_egp) AS total_revenue_egp,
        SUM(cost_egp) AS total_cost_egp,
        SUM(profit_egp) AS total_profit_egp
    FROM inmon_mart.sales_mart
) sm;