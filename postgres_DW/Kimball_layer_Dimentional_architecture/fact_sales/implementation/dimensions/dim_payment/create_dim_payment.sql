-- ============================================================
-- KIMBALL - PAYMENT DIMENSION
-- ============================================================
-- Grain:
-- One row represents one payment.
--
-- payment_key = surrogate key
-- payment_id  = business/natural key
-- ============================================================

DROP TABLE IF EXISTS kimball.dim_payment;

CREATE TABLE kimball.dim_payment (

    payment_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    payment_id INTEGER NOT NULL UNIQUE,

    payment_method VARCHAR(50),

    currency VARCHAR(10),

    payment_status VARCHAR(30),

    transaction_reference VARCHAR(255)

);