INSERT INTO inmon_layer.customer (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    gender,
    date_of_birth,
    city_id,
    registration_date,
    customer_status
)
SELECT
    s.customer_id,
    s.first_name,
    s.last_name,
    s.email,
    s.phone,
    s.gender,
    s.date_of_birth,
    c.city_id,
    s.registration_date,
    s.customer_status
FROM silver.customer AS s
JOIN inmon_layer.city AS c
    ON c.city_name = TRIM(s.city)
JOIN inmon_layer.country AS co
    ON co.country_id = c.country_id
    AND co.country_name = TRIM(s.country)
WHERE s.customer_id IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;