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