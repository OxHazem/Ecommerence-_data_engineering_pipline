SELECT
    COUNT(*) AS inmon_orders,
    COUNT(order_date) AS orders_with_date,
    COUNT(*) - COUNT(order_date) AS orders_without_date,
    COUNT(order_status) AS orders_with_status,
    COUNT(*) - COUNT(order_status) AS orders_without_status
FROM inmon_layer.orders;