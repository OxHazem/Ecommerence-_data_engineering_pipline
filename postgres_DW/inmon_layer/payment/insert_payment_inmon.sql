INSERT INTO inmon_layer.payment (
    payment_id,
    order_id,
    payment_date,
    payment_method,
    amount,
    payment_status,
    transaction_reference
)

SELECT
    s.payment_id,
    s.order_id,
    s.payment_date,
    s.payment_method,
    s.amount,
    s.payment_status,
    s.transaction_reference

FROM silver.payment AS s

JOIN inmon_layer.orders AS o
    ON o.order_id = s.order_id

WHERE s.payment_id IS NOT NULL

ON CONFLICT (payment_id) DO NOTHING;