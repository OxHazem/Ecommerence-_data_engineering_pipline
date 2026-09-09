INSERT INTO inmon_layer.marketing_event (
    event_id,
    customer_id,
    campaign_id,
    campaign_name,
    event_type,
    channel,
    event_timestamp,
    device_type
)

SELECT
    s.event_id,
    s.customer_id,
    s.campaign_id,
    s.campaign_name,
    s.event_type,
    s.channel,
    s.event_timestamp,
    s.device_type

FROM silver.marketing_event AS s

JOIN inmon_layer.customer AS c
    ON c.customer_id = s.customer_id

WHERE s.event_id IS NOT NULL

ON CONFLICT (event_id) DO NOTHING;