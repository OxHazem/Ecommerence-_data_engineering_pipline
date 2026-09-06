INSERT INTO inmon_layer.country (country_name)
SELECT DISTINCT
    TRIM(country) AS country_name
FROM silver.customer
WHERE country IS NOT NULL
  AND TRIM(country) <> ''
ON CONFLICT (country_name) DO NOTHING;