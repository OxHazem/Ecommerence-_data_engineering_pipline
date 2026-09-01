INSERT INTO gold.marketing_performance (
    campaign_name,
    channel,
    events,
    unique_customers,
    impressions,
    views,
    clicks,
    add_to_carts,
    purchases
)

SELECT

    COALESCE(
        NULLIF(TRIM(campaign_name), ''),
        'Unknown'
    ) AS campaign_name,

    COALESCE(
        NULLIF(TRIM(channel), ''),
        'Unknown'
    ) AS channel,

    COUNT(*) AS events,

    COUNT(DISTINCT customer_id) AS unique_customers,

    COUNT(*) FILTER (
        WHERE event_type = 'Impression'
    ) AS impressions,

    COUNT(*) FILTER (
        WHERE event_type = 'View'
    ) AS views,

    COUNT(*) FILTER (
        WHERE event_type = 'Click'
    ) AS clicks,

    COUNT(*) FILTER (
        WHERE event_type = 'Add to Cart'
    ) AS add_to_carts,

    COUNT(*) FILTER (
        WHERE event_type = 'Purchase'
    ) AS purchases

FROM silver.marketing_event

GROUP BY
    COALESCE(
        NULLIF(TRIM(campaign_name), ''),
        'Unknown'
    ),
    COALESCE(
        NULLIF(TRIM(channel), ''),
        'Unknown'
    )

ORDER BY
    campaign_name,
    channel;