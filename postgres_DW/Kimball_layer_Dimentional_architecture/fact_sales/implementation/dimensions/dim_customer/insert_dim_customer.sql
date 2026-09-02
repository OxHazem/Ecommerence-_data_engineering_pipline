-- -- ============================================================
-- -- LOAD CUSTOMER DIMENSION
-- -- ============================================================

-- INSERT INTO kimball.dim_customer (
--     customer_id,
--     first_name,
--     last_name,
--     gender,
--     email,
--     phone,
--     country,
--     city,
--     customer_status,
--     registration_date,
--     effective_date,
--     expiration_date,
--     is_current
-- )

-- SELECT

--     c.customer_id,

--     c.first_name,

--     c.last_name,

--     c.gender,

--     c.email,

--     c.phone,

--     c.country,

--     c.city,

--     c.customer_status,

--     c.registration_date,

--     COALESCE(
--         c.registration_date,
--         CURRENT_DATE
--     ) AS effective_date,

--     DATE '9999-12-31' AS expiration_date,

--     TRUE AS is_current

-- FROM silver.customer c;





INSERT INTO kimball.dim_customer (
    customer_id,
    first_name,
    last_name,
    gender,
    email,
    phone,
    country,
    city,
    customer_status,
    registration_date,
    effective_date,
    expiration_date,
    is_current
)
SELECT
    s.customer_id,
    s.first_name,
    s.last_name,
    s.gender,
    s.email,
    s.phone,
    s.country,
    s.city,
    s.customer_status,
    s.registration_date,
    CURRENT_DATE,
    DATE '9999-12-31',
    TRUE
FROM silver.customer s
LEFT JOIN kimball.dim_customer d
    ON s.customer_id = d.customer_id
   AND d.is_current = TRUE
WHERE d.customer_id IS NULL;


