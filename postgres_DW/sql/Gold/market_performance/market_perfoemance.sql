SELECT
    event_type,
    COUNT(*) AS event_count
FROM silver.marketing_event
GROUP BY event_type
ORDER BY event_count DESC;



SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT campaign_id) AS campaigns,
    COUNT(DISTINCT channel) AS channels
FROM silver.marketing_event;


SELECT
    campaign_id,
    channel,
    COUNT(*) AS rows_count
FROM silver.marketing_event
GROUP BY
    campaign_id,
    channel
HAVING COUNT(*) > 1
ORDER BY rows_count DESC
LIMIT 20;



SELECT
    campaign_id,
    campaign_name,
    channel,
    event_type,
    COUNT(*) AS event_count
FROM silver.marketing_event
WHERE campaign_id = 1
GROUP BY
    campaign_id,
    campaign_name,
    channel,
    event_type
ORDER BY
    channel,
    event_type;



SELECT
    campaign_id,
    channel,
    COUNT(DISTINCT campaign_name) AS campaign_names,
    STRING_AGG(DISTINCT campaign_name, ' | ') AS names
FROM silver.marketing_event
WHERE campaign_id IS NOT NULL
GROUP BY
    campaign_id,
    channel
HAVING COUNT(DISTINCT campaign_name) > 1
ORDER BY campaign_id, channel;



SELECT DISTINCT
    campaign_name
FROM silver.marketing_event
WHERE campaign_name IS NOT NULL
ORDER BY campaign_name;



SELECT DISTINCT
    channel
FROM silver.marketing_event
WHERE channel IS NOT NULL
ORDER BY channel;


SELECT COUNT(*) AS gold_rows
FROM gold.marketing_performance;




SELECT *
FROM gold.marketing_performance
ORDER BY campaign_name, channel;



SELECT
    SUM(events) AS total_events,
    SUM(impressions) AS impressions,
    SUM(views) AS views,
    SUM(clicks) AS clicks,
    SUM(add_to_carts) AS add_to_carts,
    SUM(purchases) AS purchases
FROM gold.marketing_performance;