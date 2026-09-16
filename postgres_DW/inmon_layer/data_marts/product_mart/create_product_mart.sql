CREATE SCHEMA IF NOT EXISTS inmon_mart;

CREATE TABLE inmon_mart.product_mart (
    -- Product information
    product_id INTEGER NOT NULL,
    product_name VARCHAR(255),
    category VARCHAR(255),
    subcategory VARCHAR(255),
    brand VARCHAR(100),
    supplier VARCHAR(150),
    cost NUMERIC(12,2),
    price NUMERIC(12,2),
    stock_quantity INTEGER,
    product_status VARCHAR(50),
    launch_date DATE,

    -- Sales metrics
    total_orders INTEGER NOT NULL,
    total_items INTEGER NOT NULL,
    total_quantity BIGINT NOT NULL,

    -- Financial metrics in EGP
    total_revenue_egp NUMERIC(18,2),
    total_cost_egp NUMERIC(18,2),
    total_profit_egp NUMERIC(18,2),

    -- Sales activity
    first_sale_date DATE,
    last_sale_date DATE,

    PRIMARY KEY (product_id)
);