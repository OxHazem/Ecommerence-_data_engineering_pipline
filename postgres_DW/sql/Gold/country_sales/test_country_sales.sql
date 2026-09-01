SELECT
    COUNT(*) AS gold_countries
FROM gold.country_sales;




SELECT *
FROM gold.country_sales
ORDER BY country;




SELECT
    country,

    revenue_egp,
    cost_egp,
    profit_egp,

    ROUND(
        revenue_egp - cost_egp,
        2
    ) AS calculated_profit,

    ROUND(
        profit_egp - (revenue_egp - cost_egp),
        2
    ) AS profit_difference

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