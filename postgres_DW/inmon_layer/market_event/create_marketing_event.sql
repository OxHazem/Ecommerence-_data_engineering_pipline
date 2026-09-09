CREATE TABLE IF NOT EXISTS inmon_layer.marketing_event (
    event_id INTEGER PRIMARY KEY,

    customer_id INTEGER NOT NULL,

    campaign_id INTEGER,

    campaign_name VARCHAR(255),

    event_type VARCHAR(50) NOT NULL,

    channel VARCHAR(50) NOT NULL,

    event_timestamp TIMESTAMPTZ,

    device_type VARCHAR(50),

    CONSTRAINT fk_marketing_event_customer
        FOREIGN KEY (customer_id)
        REFERENCES inmon_layer.customer(customer_id)
);