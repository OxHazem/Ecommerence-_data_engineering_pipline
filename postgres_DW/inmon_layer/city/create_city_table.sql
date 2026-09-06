CREATE TABLE IF NOT EXISTS inmon_layer.city (
    city_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INTEGER NOT NULL,

    CONSTRAINT fk_city_country
        FOREIGN KEY (country_id)
        REFERENCES inmon_layer.country(country_id),

    CONSTRAINT uq_city_country
        UNIQUE (country_id, city_name)
);

