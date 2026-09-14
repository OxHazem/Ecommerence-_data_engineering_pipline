CREATE SCHEMA IF NOT EXISTS inmon_mart;

CREATE TABLE inmon_mart.customer_mart (
    -- Customer information
    customer_id INTEGER NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    gender VARCHAR(20),
    date_of_birth DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    registration_date DATE,
    customer_status VARCHAR(50),

    -- Purchasing metrics
    total_orders INTEGER NOT NULL,
    total_items INTEGER NOT NULL,
    total_quantity BIGINT NOT NULL,

    -- Financial metrics in EGP
    total_revenue_egp NUMERIC(18,2),
    total_cost_egp NUMERIC(18,2),
    total_profit_egp NUMERIC(18,2),

    -- Order behavior
    first_order_date DATE,
    last_order_date DATE,

    PRIMARY KEY (customer_id)
);