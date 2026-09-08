INSERT INTO inmon_layer.review (
    review_id,
    customer_id,
    product_id,
    rating,
    review_date,
    verified_purchase,
    review_status
)

SELECT
    s.review_id,
    s.customer_id,
    s.product_id,
    s.rating,
    s.review_date,
    s.verified_purchase,
    s.review_status

FROM silver.review AS s

JOIN inmon_layer.customer AS c
    ON c.customer_id = s.customer_id

JOIN inmon_layer.product AS p
    ON p.product_id = s.product_id

WHERE s.review_id IS NOT NULL

ON CONFLICT (review_id) DO NOTHING;