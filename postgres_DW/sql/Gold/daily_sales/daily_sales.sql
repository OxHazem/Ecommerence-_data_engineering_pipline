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

ALTER TABLE gold.daily_sales
ADD COLUMN revenue_sar NUMERIC(18,2),
ADD COLUMN cost_sar NUMERIC(18,2),
ADD COLUMN profit_sar NUMERIC(18,2),
ADD COLUMN revenue_aed NUMERIC(18,2),
ADD COLUMN cost_aed NUMERIC(18,2),
ADD COLUMN profit_aed NUMERIC(18,2);

-- Drop TABLE IF EXISTS gold.daily_sales CASCADE;