CREATE TABLE IF NOT EXISTS inmon_layer.payment (
    payment_id INTEGER PRIMARY KEY,

    order_id INTEGER NOT NULL,

    payment_date DATE,

    payment_method VARCHAR(50),

    amount NUMERIC(12,2),

    payment_status VARCHAR(50),

    transaction_reference VARCHAR(255),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES inmon_layer.orders(order_id),

    CONSTRAINT uq_payment_transaction_reference
        UNIQUE (transaction_reference),

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0)
);