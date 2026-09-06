INSERT INTO inmon_layer.city (
    city_name,
    country_id
)
SELECT DISTINCT
    TRIM(s.city) AS city_name,
    c.country_id
FROM silver.customer AS s
JOIN inmon_layer.country AS c
    ON c.country_name = TRIM(s.country)
WHERE s.city IS NOT NULL
  AND TRIM(s.city) <> ''
  AND s.country IS NOT NULL
  AND TRIM(s.country) <> ''
ON CONFLICT (country_id, city_name) DO NOTHING;