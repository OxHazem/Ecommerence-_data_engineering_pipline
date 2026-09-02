-- ============================================================
-- LOAD PAYMENT DIMENSION
-- ============================================================

INSERT INTO kimball.dim_payment (
    payment_id,
    payment_method,
    currency,
    payment_status,
    transaction_reference
)

SELECT
    p.payment_id,
    p.payment_method,
    p.currency,
    p.payment_status,
    p.transaction_reference

FROM silver.payment p;