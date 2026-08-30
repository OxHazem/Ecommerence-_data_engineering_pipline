SELECT *
FROM gold.customer_sales
ORDER BY customer_id
LIMIT 20;




SELECT
    COUNT(*) AS customers,
    COUNT(*) FILTER (WHERE orders = 0) AS customers_without_orders,
    COUNT(*) FILTER (WHERE incomplete_items > 0) AS customers_with_incomplete_items,
    SUM(incomplete_items) AS total_incomplete_items,
    SUM(revenue) AS total_revenue,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit
FROM gold.customer_sales;



SELECT
    (SELECT COUNT(*)
     FROM silver.customer) AS silver_customers,

    (SELECT COUNT(*)
     FROM gold.customer_sales) AS gold_customers;



SELECT COUNT(*) AS missing_customers
FROM silver.customer c
LEFT JOIN gold.customer_sales g
    ON c.customer_id = g.customer_id
WHERE g.customer_id IS NULL;



SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM gold.customer_sales
GROUP BY customer_id
HAVING COUNT(*) > 1;




SELECT
    customer_id,
    revenue,
    cost,
    profit,
    revenue - cost AS calculated_profit
FROM gold.customer_sales
WHERE profit <> ROUND(revenue - cost, 2)
LIMIT 20;


SELECT
    COUNT(*) AS customers_with_negative_profit
FROM gold.customer_sales
WHERE profit < 0;



SELECT
    COUNT(*) AS customers_with_incomplete_items,
    SUM(incomplete_items) AS total_incomplete_items
FROM gold.customer_sales
WHERE incomplete_items > 0;



SELECT
    COUNT(*) AS customers_without_orders
FROM gold.customer_sales
WHERE orders = 0;





SELECT
    COUNT(*) AS customers,
    SUM(orders) AS total_orders,
    SUM(units_sold) AS total_units,
    SUM(revenue) AS total_revenue,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit,
    SUM(incomplete_items) AS total_incomplete_items
FROM gold.customer_sales;




SELECT
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.cost_at_sale,

    oi.quantity
        * oi.unit_price
        * (1 - COALESCE(oi.discount, 0) / 100.0)
        AS item_revenue,

    oi.quantity * oi.cost_at_sale
        AS item_cost,

    (
        oi.quantity
        * oi.unit_price
        * (1 - COALESCE(oi.discount, 0) / 100.0)
    )
    -
    (oi.quantity * oi.cost_at_sale)
        AS item_profit

FROM silver.order_item oi

JOIN silver.orders o
    ON oi.order_id = o.order_id

WHERE o.customer_id = 9436
  AND o.order_status <> 'Cancelled'
  AND oi.quantity IS NOT NULL
  AND oi.unit_price IS NOT NULL
  AND oi.cost_at_sale IS NOT NULL;