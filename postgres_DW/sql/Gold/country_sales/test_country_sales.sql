SELECT
    COUNT(*) AS gold_countries
FROM gold.country_sales;




SELECT *
FROM gold.country_sales
ORDER BY country;



SELECT *
FROM gold.country_sales
WHERE country = 'Unknown';




SELECT
    country,
    COUNT(*) AS occurrences
FROM gold.country_sales
GROUP BY country
HAVING COUNT(*) > 1;