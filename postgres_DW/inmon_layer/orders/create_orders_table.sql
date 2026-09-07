CREATE TABLE IF NOT EXISTS inmon_layer.orders (
    order_id INTEGER PRIMARY KEY,

    customer_id INTEGER NOT NULL,

    order_date DATE,

    order_status VARCHAR(50) ,

    currency VARCHAR(3) NOT NULL,

    shipping_city_id INTEGER NOT NULL,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES inmon_layer.customer(customer_id),

    CONSTRAINT fk_orders_shipping_city
        FOREIGN KEY (shipping_city_id)
        REFERENCES inmon_layer.city(city_id)
);