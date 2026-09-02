SELECT COUNT(*) AS fact_rows
FROM kimball.fact_sales;



SELECT
    COUNT(*) AS fact_rows,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_key) AS customers,
    COUNT(DISTINCT product_key) AS products,
    COUNT(payment_key) AS rows_with_payment,
    COUNT(*) - COUNT(payment_key) AS rows_without_payment
FROM kimball.fact_sales;





SELECT *
FROM kimball.fact_sales
ORDER BY sales_key
LIMIT 10;





SELECT
    o.currency,
    COUNT(*) AS fact_rows,
    ROUND(SUM(
        oi.quantity
        * oi.unit_price
        * (1 - COALESCE(oi.discount, 0) / 100.0)
    ), 2) AS original_currency_amount,
    ROUND(SUM(fs.revenue), 2) AS revenue_egp
FROM kimball.fact_sales fs
JOIN silver.order_item oi
    ON fs.order_id = oi.order_id
JOIN silver.orders o
    ON oi.order_id = o.order_id
GROUP BY o.currency
ORDER BY o.currency;









SELECT
    fs.sales_key,
    fs.order_id,
    o.currency,
    o.order_date,
    fs.quantity,
    fs.unit_price,
    fs.revenue,
    fs.cost,
    fs.profit
FROM kimball.fact_sales fs
JOIN silver.orders o
    ON fs.order_id = o.order_id
WHERE o.currency <> 'EGP'
ORDER BY fs.sales_key
LIMIT 20;








SELECT
    o.currency,
    COUNT(*) AS rows,
    SUM(oi.quantity * oi.unit_price) AS original_revenue,
    SUM(oi.quantity * oi.cost_at_sale) AS original_cost,
    SUM(fs.revenue) AS fact_revenue_egp,
    SUM(fs.cost) AS fact_cost_egp
FROM kimball.fact_sales fs
JOIN silver.orders o
    ON fs.order_id = o.order_id
JOIN silver.order_item oi
    ON fs.order_id = oi.order_id
   AND fs.product_key IS NOT NULL
GROUP BY o.currency
ORDER BY o.currency;






SELECT
    o.currency,
    COUNT(*) AS rows,
    MIN(er.rate) AS min_rate,
    MAX(er.rate) AS max_rate,
    AVG(er.rate) AS avg_rate
FROM silver.orders o
LEFT JOIN LATERAL (
    SELECT rate
    FROM silver.exchange_rate er
    WHERE er.base = o.currency
      AND er.quote = 'EGP'
      AND er.date <= o.order_date
    ORDER BY er.date DESC
    LIMIT 1
) er ON TRUE
WHERE o.currency IN ('AED', 'SAR', 'EGP')
GROUP BY o.currency
ORDER BY o.currency;





SELECT
    o.currency,
    COUNT(*) AS fact_rows,
    SUM(fs.revenue) AS revenue_egp,
    SUM(fs.cost) AS cost_egp,
    SUM(fs.profit) AS profit_egp
FROM kimball.fact_sales fs
JOIN silver.orders o
    ON fs.order_id = o.order_id
GROUP BY o.currency
ORDER BY o.currency;




SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE revenue - cost <> profit) AS incorrect_profit,
    COUNT(*) FILTER (WHERE revenue < 0) AS negative_revenue,
    COUNT(*) FILTER (WHERE cost < 0) AS negative_cost
FROM kimball.fact_sales;



SELECT
    COUNT(*) AS incorrect_profit
FROM kimball.fact_sales
WHERE ROUND(revenue - cost, 2) <> ROUND(profit, 2);



SELECT
    sales_key,
    order_id,
    quantity,
    unit_price,
    discount,
    revenue,
    cost,
    profit,
    ROUND(revenue - cost, 2) AS calculated_profit,
    ROUND(profit - (revenue - cost), 2) AS difference
FROM kimball.fact_sales
WHERE ROUND(revenue - cost, 2) <> ROUND(profit, 2)
LIMIT 20;