SELECT
    COUNT(*) AS payments,
    COUNT(DISTINCT payment_id) AS unique_payment_ids,
    COUNT(DISTINCT payment_key) AS unique_payment_keys
FROM kimball.dim_payment;





SELECT *
FROM kimball.dim_payment
ORDER BY payment_key
LIMIT 10;



SELECT *
FROM silver.order_item
LIMIT 5;





SELECT *
FROM silver.orders
LIMIT 5;


SELECT
    order_id,
    COUNT(*) AS payment_count
FROM silver.payment
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_count DESC;


SELECT
    COUNT(*) AS order_items,
    COUNT(DISTINCT order_id) AS orders
FROM silver.order_item;



SELECT
    COUNT(DISTINCT oi.order_id) AS orders_with_items,
    COUNT(DISTINCT p.order_id) AS orders_with_payment,
    COUNT(DISTINCT CASE
        WHEN p.order_id IS NULL THEN oi.order_id
    END) AS orders_without_payment
FROM silver.order_item oi
LEFT JOIN silver.payment p
    ON oi.order_id = p.order_id;