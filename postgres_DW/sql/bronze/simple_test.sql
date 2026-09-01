SELECT customer_id, date_of_birth
FROM bronze.customer
WHERE date_of_birth = 'not-a-date'
LIMIT 10;



SELECT COUNT(*) AS total_rows
FROM bronze.exchange_rate;



SELECT
    base,
    quote,
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM bronze.exchange_rate
GROUP BY base, quote
ORDER BY base;



select * from bronze.exchange_rate limit 10;