SELECT
    COUNT(*) AS customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(DISTINCT customer_key) AS unique_customer_keys
FROM kimball.dim_customer;




SELECT *
FROM kimball.dim_customer
ORDER BY customer_key
LIMIT 20;



SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(*) FILTER (WHERE is_current = TRUE) AS current_rows,
    COUNT(DISTINCT customer_id) FILTER (WHERE is_current = TRUE) AS unique_current_customers
FROM kimball.dim_customer;



SELECT
    customer_id,
    COUNT(*) AS versions
FROM kimball.dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;





SELECT
    customer_id,
    first_name,
    last_name,
    country,
    city,
    customer_status
FROM kimball.dim_customer
WHERE is_current = TRUE
ORDER BY customer_id
LIMIT 5;



SELECT
    customer_key,
    customer_id,
    first_name,
    last_name,
    country,
    city,
    customer_status,
    effective_date,
    expiration_date,
    is_current
FROM kimball.dim_customer
WHERE customer_id = 1;



CREATE TEMP TABLE scd_test_source AS
SELECT *
FROM silver.customer;


UPDATE scd_test_source
SET city = 'Abu Dhabi'
WHERE customer_id = 1;


SELECT
    customer_id,
    first_name,
    last_name,
    country,
    city,
    customer_status
FROM scd_test_source
WHERE customer_id = 1;


SELECT
    s.customer_id,
    d.customer_key AS old_customer_key,
    d.city AS old_city,
    s.city AS new_city
FROM scd_test_source s
JOIN kimball.dim_customer d
    ON s.customer_id = d.customer_id
   AND d.is_current = TRUE
WHERE s.city IS DISTINCT FROM d.city;


UPDATE kimball.dim_customer
SET
    expiration_date = CURRENT_DATE - INTERVAL '1 day',
    is_current = FALSE
WHERE customer_id = 1
  AND is_current = TRUE;



SELECT
    customer_key,
    customer_id,
    city,
    effective_date,
    expiration_date,
    is_current
FROM kimball.dim_customer
WHERE customer_id = 1;


DELETE FROM kimball.dim_customer
WHERE customer_id = 1
  AND customer_key = 10001;

UPDATE kimball.dim_customer
SET expiration_date = DATE '9999-12-31',
    is_current = TRUE
WHERE customer_id = 1
  AND customer_key = 1;


SELECT
    customer_key,
    customer_id,
    city,
    effective_date,
    expiration_date,
    is_current
FROM kimball.dim_customer
WHERE customer_id = 1;



UPDATE kimball.dim_customer d
SET
    expiration_date = CURRENT_DATE - 1,
    is_current = FALSE
FROM scd_test_source s
WHERE d.customer_id = s.customer_id
  AND d.is_current = TRUE
  AND (
       d.first_name IS DISTINCT FROM s.first_name
    OR d.last_name IS DISTINCT FROM s.last_name
    OR d.gender IS DISTINCT FROM s.gender
    OR d.email IS DISTINCT FROM s.email
    OR d.phone IS DISTINCT FROM s.phone
    OR d.country IS DISTINCT FROM s.country
    OR d.city IS DISTINCT FROM s.city
    OR d.customer_status IS DISTINCT FROM s.customer_status
    OR d.registration_date IS DISTINCT FROM s.registration_date
  );



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
FROM scd_test_source s
LEFT JOIN kimball.dim_customer d
    ON s.customer_id = d.customer_id
   AND d.is_current = TRUE
WHERE d.customer_id IS NULL;




SELECT
    customer_key,
    customer_id,
    first_name,
    last_name,
    city,
    effective_date,
    expiration_date,
    is_current
FROM kimball.dim_customer
WHERE customer_id = 1
ORDER BY customer_key;



DELETE FROM kimball.dim_customer
WHERE customer_id = 1
  AND customer_key = 10002;



UPDATE kimball.dim_customer
SET
    expiration_date = DATE '9999-12-31',
    is_current = TRUE
WHERE customer_id = 1
  AND customer_key = 1;


SELECT
    customer_key,
    customer_id,
    first_name,
    last_name,
    city,
    effective_date,
    expiration_date,
    is_current
FROM kimball.dim_customer
WHERE customer_id = 1
ORDER BY customer_key;