CREATE SCHEMA IF NOT EXISTS inmon_mart;

CREATE TABLE IF NOT EXISTS inmon_mart.sales_mart (
    -- Order information
    order_id INTEGER NOT NULL,
    order_date DATE,
    order_status VARCHAR(50),
    currency VARCHAR(3) NOT NULL,

    -- Customer information
    customer_id INTEGER NOT NULL,
    customer_country VARCHAR(100),

    -- Product information
    product_id INTEGER NOT NULL,
    product_name VARCHAR(255),
    brand VARCHAR(100),
    category VARCHAR(255),
    subcategory VARCHAR(255),

    -- Original transaction values
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    discount NUMERIC(12,2),
    cost_at_sale NUMERIC(12,2),

    -- Exchange-rate information
    exchange_rate NUMERIC(18,8),

    -- Standardized financial measures
    revenue_egp NUMERIC(18,2),
    cost_egp NUMERIC(18,2),
    profit_egp NUMERIC(18,2),

    PRIMARY KEY (order_id, product_id)
);


