SELECT *
FROM gold.shipping_performance
ORDER BY shipping_method;



SELECT
    COUNT(*) AS total_shipments,

    COUNT(*) FILTER (
        WHERE delivery_date IS NOT NULL
    ) AS delivered,

    COUNT(*) FILTER (
        WHERE delivery_date IS NULL
    ) AS not_delivered,

    COUNT(*) FILTER (
        WHERE delivery_date IS NOT NULL
          AND estimated_delivery_date IS NOT NULL
          AND delivery_date > estimated_delivery_date
    ) AS delayed,

    COUNT(*) FILTER (
        WHERE estimated_delivery_date IS NULL
    ) AS missing_estimated_date

FROM silver.shipping;



SELECT
    shipment_id,
    order_id,
    shipping_date,
    estimated_delivery_date,
    delivery_date,
    shipping_method,
    shipping_status
FROM silver.shipping
WHERE delivery_date IS NOT NULL
  AND estimated_delivery_date IS NOT NULL
  AND delivery_date > estimated_delivery_date
LIMIT 20;



SELECT
    SUM(shipments) AS gold_shipments
FROM gold.shipping_performance;



SELECT
    SUM(delivered_shipments) AS gold_delivered,
    SUM(delayed_shipments) AS gold_delayed
FROM gold.shipping_performance;




SELECT
    shipment_id,
    shipping_date,
    delivery_date,
    delivery_date - shipping_date AS delivery_days
FROM silver.shipping
WHERE shipping_date IS NOT NULL
  AND delivery_date IS NOT NULL
ORDER BY delivery_days DESC
LIMIT 20;


SELECT
    COUNT(*) AS delivered_shipments,
    MIN(delivery_date - shipping_date) AS minimum_delivery_days,
    MAX(delivery_date - shipping_date) AS maximum_delivery_days,
    ROUND(
        AVG(delivery_date - shipping_date),
        2
    ) AS average_delivery_days
FROM silver.shipping
WHERE shipping_date IS NOT NULL
  AND delivery_date IS NOT NULL;




SELECT
    COUNT(*) AS shipments_over_30_days
FROM silver.shipping
WHERE shipping_date IS NOT NULL
  AND delivery_date IS NOT NULL
  AND delivery_date - shipping_date > 30;