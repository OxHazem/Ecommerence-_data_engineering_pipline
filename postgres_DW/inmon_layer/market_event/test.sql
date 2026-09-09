SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'marketing_event'
ORDER BY ordinal_position;




SELECT *
FROM silver.marketing_event
LIMIT 10;


SELECT
    campaign_id,
    COUNT(DISTINCT TRIM(campaign_name)) AS name_count,
    STRING_AGG(DISTINCT TRIM(campaign_name), ' | ') AS campaign_names
FROM silver.marketing_event
WHERE campaign_id IS NOT NULL
GROUP BY campaign_id
HAVING COUNT(DISTINCT TRIM(campaign_name)) > 1
ORDER BY campaign_id;


SELECT
    COUNT(*) AS null_campaign_id_count
FROM silver.marketing_event
WHERE campaign_id IS NULL;


SELECT
    COUNT(*) AS campaign_id_without_name
FROM silver.marketing_event
WHERE campaign_id IS NOT NULL
  AND campaign_name IS NULL;



SELECT
    (SELECT COUNT(*) FROM silver.marketing_event) AS silver_count,
    (SELECT COUNT(*) FROM inmon_layer.marketing_event) AS inmon_count;



SELECT COUNT(*)
FROM silver.marketing_event me
LEFT JOIN inmon_layer.customer c
    ON me.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'inmon_layer'
  AND table_name = 'marketing_event'
ORDER BY ordinal_position;
