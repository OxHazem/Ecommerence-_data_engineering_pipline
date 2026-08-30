CREATE TABLE IF NOT EXISTS gold.monthly_sales (
    month DATE PRIMARY KEY,
    orders INTEGER NOT NULL,
    customers INTEGER NOT NULL,
    units_sold BIGINT NOT NULL,
    revenue NUMERIC(18,2) NOT NULL,
    cost NUMERIC(18,2) NOT NULL,
    profit NUMERIC(18,2) NOT NULL,
    average_order_value NUMERIC(18,2) NOT NULL,
    incomplete_items INTEGER NOT NULL
);