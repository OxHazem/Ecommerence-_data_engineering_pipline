-- ============================================================
-- KIMBALL - PRODUCT DIMENSION
-- ============================================================

DROP TABLE IF EXISTS kimball.dim_product;

CREATE TABLE kimball.dim_product (

    product_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    product_id INTEGER NOT NULL UNIQUE,

    product_name VARCHAR(255) NOT NULL,

    category VARCHAR(100),

    subcategory VARCHAR(100),

    brand VARCHAR(100),

    supplier VARCHAR(100),

    cost NUMERIC(18,2),

    price NUMERIC(18,2),

    stock_quantity INTEGER,

    product_status VARCHAR(30),

    launch_date DATE

);