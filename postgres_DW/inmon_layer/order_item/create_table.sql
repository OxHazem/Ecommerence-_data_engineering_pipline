CREATE TABLE IF NOT EXISTS inmon_layer.order_item (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,

    quantity INTEGER,
    unit_price NUMERIC(12,2),
    discount NUMERIC(5,2),
    cost_at_sale NUMERIC(12,2),

    CONSTRAINT pk_order_item
        PRIMARY KEY (order_id, product_id),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES inmon_layer.orders(order_id),

    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES inmon_layer.product(product_id),

    CONSTRAINT chk_order_item_quantity
        CHECK (quantity >= 0),

    CONSTRAINT chk_order_item_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_order_item_discount
        CHECK (discount >= 0 AND discount <= 100),

    CONSTRAINT chk_order_item_cost
        CHECK (cost_at_sale >= 0)
);