SELECT *
FROM inmon_layer.customer
ORDER BY customer_id
LIMIT 20;




SELECT
    COUNT(*) AS invalid_customers
FROM inmon_layer.customer c
LEFT JOIN inmon_layer.city ci
    ON c.city_id = ci.city_id
LEFT JOIN inmon_layer.country co
    ON ci.country_id = co.country_id
WHERE ci.city_id IS NULL
   OR co.country_id IS NULL;




SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'customer'
ORDER BY ordinal_position;




SELECT
    (SELECT COUNT(*) FROM silver.customer) AS silver_count,
    (SELECT COUNT(*) FROM inmon_layer.customer) AS inmon_count;





SELECT COUNT(*)
FROM inmon_layer.customer c
LEFT JOIN inmon_layer.city ci
    ON c.city_id = ci.city_id
WHERE ci.city_id IS NULL;




SELECT
    ci.city_name,
    COUNT(DISTINCT co.country_name) AS country_count
FROM inmon_layer.city ci
JOIN inmon_layer.country co
    ON ci.country_id = co.country_id
GROUP BY ci.city_name
HAVING COUNT(DISTINCT co.country_name) > 1;