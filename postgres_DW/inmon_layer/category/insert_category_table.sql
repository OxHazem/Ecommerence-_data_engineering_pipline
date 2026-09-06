INSERT INTO inmon_layer.category (category_name)
SELECT DISTINCT
    TRIM(category) AS category_name
FROM silver.product
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
ON CONFLICT (category_name) DO NOTHING;