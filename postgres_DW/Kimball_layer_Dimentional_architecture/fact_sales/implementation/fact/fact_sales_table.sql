DROP TABLE IF EXISTS kimball.fact_sales;

CREATE TABLE kimball.fact_sales (
    -- Primary Key
    sales_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Degenerate Dimension
    order_id INTEGER NOT NULL,

    -- Foreign Keys
    customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    payment_key INTEGER,

    -- Measures
    quantity INTEGER,
    unit_price NUMERIC(18,2),
    discount NUMERIC(5,2),
    revenue NUMERIC(18,2) NOT NULL,
    cost NUMERIC(18,2) NOT NULL,
    profit NUMERIC(18,2) NOT NULL,

    -- Foreign Key Constraints
    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key)
        REFERENCES kimball.dim_customer(customer_key),

    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_key)
        REFERENCES kimball.dim_product(product_key),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)
        REFERENCES kimball.dim_date(date_key),

    CONSTRAINT fk_fact_payment
        FOREIGN KEY (payment_key)
        REFERENCES kimball.dim_payment(payment_key)
);