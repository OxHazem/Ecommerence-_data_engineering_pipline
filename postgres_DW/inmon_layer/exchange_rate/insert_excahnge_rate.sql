INSERT INTO inmon_layer.exchange_rate (
    date,
    base,
    quote,
    rate
)
SELECT
    s.date,
    TRIM(s.base),
    TRIM(s.quote),
    s.rate
FROM silver.exchange_rate AS s
ON CONFLICT (date, base, quote) DO NOTHING;