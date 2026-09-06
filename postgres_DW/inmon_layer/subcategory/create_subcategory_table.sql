CREATE TABLE IF NOT EXISTS inmon_layer.subcategory (
    subcategory_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subcategory_name VARCHAR(100) NOT NULL,
    category_id INTEGER NOT NULL,

    CONSTRAINT fk_subcategory_category
        FOREIGN KEY (category_id)
        REFERENCES inmon_layer.category(category_id),

    CONSTRAINT uq_subcategory_category
        UNIQUE (category_id, subcategory_name)
);
