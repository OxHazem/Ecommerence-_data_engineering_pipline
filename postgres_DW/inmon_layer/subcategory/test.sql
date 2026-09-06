SELECT
    subcategory_id,
    subcategory_name,
    category_id
FROM inmon_layer.subcategory
ORDER BY category_id, subcategory_name;