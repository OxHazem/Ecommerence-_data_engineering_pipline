CREATE TABLE IF NOT EXISTS inmon_layer.customer (
    customer_id INTEGER PRIMARY KEY,

    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    gender VARCHAR(20),
    date_of_birth DATE,

    city_id INTEGER NOT NULL,

    registration_date DATE,
    customer_status VARCHAR(50),

    CONSTRAINT fk_customer_city
        FOREIGN KEY (city_id)
        REFERENCES inmon_layer.city(city_id)
);