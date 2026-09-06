INSERT INTO inmon_layer.subcategory (
    subcategory_name,
    category_id
)
SELECT DISTINCT
    TRIM(s.subcategory) AS subcategory_name,
    c.category_id
FROM silver.product AS s
JOIN inmon_layer.category AS c
    ON c.category_name = TRIM(s.category)
WHERE s.subcategory IS NOT NULL
  AND TRIM(s.subcategory) <> ''
  AND s.category IS NOT NULL
  AND TRIM(s.category) <> ''
ON CONFLICT (category_id, subcategory_name) DO NOTHING;