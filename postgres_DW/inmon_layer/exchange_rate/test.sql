SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'exchange_rate'
ORDER BY ordinal_position;



SELECT COUNT(*) AS exchange_rate_count
FROM silver.exchange_rate;





SELECT
    date,
    base,
    quote,
    COUNT(*) AS occurrences
FROM silver.exchange_rate
GROUP BY
    date,
    base,
    quote
HAVING COUNT(*) > 1
ORDER BY date, base, quote;





SELECT
    COUNT(*) FILTER (WHERE date IS NULL) AS null_dates,
    COUNT(*) FILTER (WHERE base IS NULL) AS null_base,
    COUNT(*) FILTER (WHERE quote IS NULL) AS null_quote,
    COUNT(*) FILTER (WHERE rate IS NULL) AS null_rates
FROM silver.exchange_rate;



