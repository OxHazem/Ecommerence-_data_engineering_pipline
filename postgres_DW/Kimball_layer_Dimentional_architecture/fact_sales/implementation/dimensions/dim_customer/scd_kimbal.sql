-- 1. Expire changed customers

UPDATE kimball.dim_customer d
SET
    expiration_date = CURRENT_DATE - 1,
    is_current = FALSE
FROM silver.customer s
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



-- 2. Insert new versions of changed customers --test 



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