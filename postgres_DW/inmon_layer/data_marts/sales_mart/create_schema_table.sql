CREATE SCHEMA IF NOT EXISTS inmon_mart;

CREATE TABLE IF NOT EXISTS inmon_mart.sales_mart (
    order_id INTEGER NOT NULL,
    order_date DATE,

    customer_id INTEGER NOT NULL,
    customer_country VARCHAR(100),

    product_id INTEGER NOT NULL,
    product_name VARCHAR(255),
    brand VARCHAR(100),
    category VARCHAR(255),
    subcategory VARCHAR(255),

    quantity INTEGER,
    unit_price NUMERIC(12,2),
    discount NUMERIC(12,2),
    cost_at_sale NUMERIC(12,2),

    PRIMARY KEY (order_id, product_id)
);