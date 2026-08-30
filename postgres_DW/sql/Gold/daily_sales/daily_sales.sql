CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.daily_sales (
    date DATE PRIMARY KEY,
    orders INTEGER NOT NULL,
    customers INTEGER NOT NULL,
    units_sold BIGINT NOT NULL,
    revenue NUMERIC(18,2),
    cost NUMERIC(18,2),
    profit NUMERIC(18,2),
    average_order_value NUMERIC(18,2),
    incomplete_items INTEGER NOT NULL
);



-- Drop TABLE IF EXISTS gold.daily_sales CASCADE;