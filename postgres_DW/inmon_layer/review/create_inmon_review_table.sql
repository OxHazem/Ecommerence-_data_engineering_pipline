CREATE TABLE IF NOT EXISTS inmon_layer.review (
    review_id INTEGER PRIMARY KEY,

    customer_id INTEGER NOT NULL,

    product_id INTEGER NOT NULL,

    rating INTEGER,

    review_date DATE,

    verified_purchase BOOLEAN NOT NULL,

    review_status VARCHAR(50) NOT NULL,

    CONSTRAINT fk_review_customer
        FOREIGN KEY (customer_id)
        REFERENCES inmon_layer.customer(customer_id),

    CONSTRAINT fk_review_product
        FOREIGN KEY (product_id)
        REFERENCES inmon_layer.product(product_id),

    CONSTRAINT chk_review_rating
        CHECK (rating IS NULL OR rating BETWEEN 1 AND 5)
);