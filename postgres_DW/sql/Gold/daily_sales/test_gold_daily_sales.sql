SELECT *
FROM gold.daily_sales
ORDER BY date
LIMIT 20;



SELECT
    date,
    orders,
    customers,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    ROUND(cost, 2) AS cost,
    ROUND(profit, 2) AS profit,
    ROUND(average_order_value, 2) AS average_order_value,
    incomplete_items
FROM gold.daily_sales
ORDER BY date
LIMIT 50;




SELECT
    date,
    orders,
    customers,
    units_sold,
    revenue,
    cost,
    profit,
    average_order_value,
    incomplete_items
FROM gold.daily_sales
WHERE profit < 0 




SELECT *
FROM gold.daily_sales
WHERE date = '2015-07-02';