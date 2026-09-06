CREATE TABLE IF NOT EXISTS inmon_layer.product (
    product_id INTEGER PRIMARY KEY,

    product_name VARCHAR(255) NOT NULL,

    subcategory_id INTEGER NOT NULL,

    brand VARCHAR(100),
    supplier VARCHAR(150),

    cost NUMERIC(12,2),
    price NUMERIC(12,2),
    stock_quantity INTEGER,

    product_status VARCHAR(50),
    launch_date DATE,

    CONSTRAINT fk_product_subcategory
        FOREIGN KEY (subcategory_id)
        REFERENCES inmon_layer.subcategory(subcategory_id),

    CONSTRAINT chk_product_cost
        CHECK (cost >= 0),

    CONSTRAINT chk_product_price
        CHECK (price >= 0),

    CONSTRAINT chk_product_stock
        CHECK (stock_quantity >= 0)
);