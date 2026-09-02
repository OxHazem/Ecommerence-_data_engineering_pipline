-- ============================================================
-- POPULATE DATE DIMENSION
-- ============================================================

INSERT INTO kimball.dim_date (
    date_key,
    full_date,
    day,
    day_name,
    week,
    month,
    month_name,
    quarter,
    year,
    is_weekend
)

SELECT

    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,

    d::DATE AS full_date,

    EXTRACT(DAY FROM d)::INTEGER AS day,

    TRIM(TO_CHAR(d, 'Day')) AS day_name,

    EXTRACT(WEEK FROM d)::INTEGER AS week,

    EXTRACT(MONTH FROM d)::INTEGER AS month,

    TRIM(TO_CHAR(d, 'Month')) AS month_name,

    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,

    EXTRACT(YEAR FROM d)::INTEGER AS year,

    EXTRACT(ISODOW FROM d) IN (6, 7) AS is_weekend

FROM generate_series(
    DATE '2015-02-15',
    DATE '2026-08-29',
    INTERVAL '1 day'
) AS d;


