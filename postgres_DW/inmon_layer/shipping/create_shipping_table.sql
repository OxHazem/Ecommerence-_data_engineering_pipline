DROP TABLE IF EXISTS inmon_layer.shipping;



CREATE TABLE IF NOT EXISTS inmon_layer.shipping (
    shipment_id INTEGER PRIMARY KEY,

    order_id INTEGER NOT NULL,

    shipping_city_id INTEGER NOT NULL,

    shipping_date DATE,

    estimated_delivery_date DATE,

    delivery_date DATE,

    shipping_method VARCHAR(50) NOT NULL,

    shipping_status VARCHAR(50) NOT NULL,

    shipping_cost NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_shipping_order
        FOREIGN KEY (order_id)
        REFERENCES inmon_layer.orders(order_id),

    CONSTRAINT fk_shipping_city
        FOREIGN KEY (shipping_city_id)
        REFERENCES inmon_layer.city(city_id),

    CONSTRAINT chk_shipping_cost
        CHECK (shipping_cost >= 0)
);