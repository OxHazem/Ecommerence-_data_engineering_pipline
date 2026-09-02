SELECT
    COUNT(*) AS total_dates,
    MIN(full_date) AS first_date,
    MAX(full_date) AS last_date
FROM kimball.dim_date;




SELECT *
FROM kimball.dim_date
ORDER BY full_date
LIMIT 10;



SELECT *
FROM kimball.dim_date
ORDER BY full_date DESC
LIMIT 10;