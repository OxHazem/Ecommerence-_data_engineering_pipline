SELECT COUNT(*)
FROM inmon_layer.review;





SELECT
    review_id,
    COUNT(*) AS cnt
FROM inmon_layer.review
GROUP BY review_id
HAVING COUNT(*) > 1;





SELECT COUNT(*)
FROM inmon_layer.review r
LEFT JOIN inmon_layer.customer c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;





SELECT COUNT(*)
FROM inmon_layer.review r
LEFT JOIN inmon_layer.product p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL;





SELECT COUNT(*)
FROM inmon_layer.review
WHERE rating IS NOT NULL
  AND (rating < 1 OR rating > 5);