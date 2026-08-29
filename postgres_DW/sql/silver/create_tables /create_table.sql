CREATE TABLE silver.customer (
    customer_id        INTEGER PRIMARY KEY,
    first_name         VARCHAR(50) NOT NULL,
    last_name          VARCHAR(50) NOT NULL,
    email              VARCHAR(255) ,
    phone              VARCHAR(20),
    gender             VARCHAR(20),
    date_of_birth      DATE,
    country            VARCHAR(100) NOT NULL,
    city               VARCHAR(100) NOT NULL,
    registration_date  DATE ,
    customer_status    VARCHAR(20) NOT NULL,

    source_file        TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id           UUID,
    source_system      TEXT
);

CREATE TABLE silver.product (
    product_id        INTEGER PRIMARY KEY,
    product_name      VARCHAR(255) NOT NULL,
    category          VARCHAR(100) NOT NULL,
    subcategory       VARCHAR(100) NOT NULL,
    brand             VARCHAR(100) NOT NULL,
    supplier          VARCHAR(255) NOT NULL,
    cost              DECIMAL(10,2) ,
    price             DECIMAL(10,2) ,
    stock_quantity    INTEGER ,
    product_status    VARCHAR(20) NOT NULL,
    launch_date       DATE NOT NULL,

    -- Data lineage / audit metadata
    source_file       TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id          UUID,
    source_system     TEXT
);

CREATE TABLE silver.orders (
    order_id          INTEGER PRIMARY KEY,
    customer_id       INTEGER NOT NULL,
    order_date        DATE NOT NULL,
    order_status      VARCHAR(20) NOT NULL,
    currency          CHAR(3) NOT NULL,
    shipping_country  VARCHAR(100) NOT NULL,
    shipping_city     VARCHAR(100) NOT NULL,

    source_file       TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id          UUID,
    source_system     TEXT,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES silver.customer(customer_id)
);


-- ============================================================
-- SILVER ORDER ITEM TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS silver.order_item (
    order_id       INTEGER NOT NULL,
    product_id     INTEGER NOT NULL,
    quantity       INTEGER NOT NULL,
    unit_price     DECIMAL(10,2) NOT NULL,
    discount       DECIMAL(5,2),
    cost_at_sale   DECIMAL(10,2) NOT NULL,

    -- Metadata
    source_file           TEXT,
    ingestion_timestamp   TIMESTAMPTZ,
    batch_id              UUID,
    source_system         TEXT,

    -- Composite Primary Key
    CONSTRAINT pk_order_item
        PRIMARY KEY (order_id, product_id),

    -- Foreign Keys
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES silver.orders(order_id),

    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES silver.product(product_id)
);





-- ============================================================
-- SILVER PAYMENT TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS silver.payment (
    payment_id             INTEGER PRIMARY KEY,
    order_id               INTEGER NOT NULL UNIQUE,
    payment_date           DATE,
    payment_method         VARCHAR(30) NOT NULL,
    amount                 DECIMAL(12,2),
    currency               CHAR(3) NOT NULL,
    payment_status         VARCHAR(20),
    transaction_reference  VARCHAR(100) NOT NULL,

    -- Metadata
    source_file             TEXT,
    ingestion_timestamp     TIMESTAMPTZ,
    batch_id                UUID,
    source_system           TEXT,

    -- Foreign Key
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES silver.orders(order_id)
);



-- ============================================================
-- SILVER SHIPPING TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS silver.shipping (

    shipment_id              INTEGER PRIMARY KEY,

    order_id                 INTEGER NOT NULL UNIQUE,

    shipping_date            DATE,
    estimated_delivery_date  DATE,
    delivery_date            DATE,

    shipping_country         VARCHAR(100) NOT NULL,
    shipping_city            VARCHAR(100) NOT NULL,
    shipping_method           VARCHAR(50) NOT NULL,
    shipping_status          VARCHAR(20) NOT NULL,
    shipping_cost            DECIMAL(10,2) NOT NULL,

    -- ========================================================
    -- METADATA
    -- ========================================================
    source_file              TEXT,
    ingestion_timestamp      TIMESTAMPTZ,
    batch_id                 UUID,
    source_system            TEXT,

    -- ========================================================
    -- FOREIGN KEY
    -- ========================================================
    CONSTRAINT fk_shipping_order
        FOREIGN KEY (order_id)
        REFERENCES silver.orders(order_id)
);



-- ============================================================
-- SILVER REVIEW TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS silver.review (

    review_id           INTEGER PRIMARY KEY,

    customer_id         INTEGER NOT NULL,

    product_id          INTEGER NOT NULL,

    rating              INTEGER,

    review_date         DATE,

    verified_purchase   BOOLEAN NOT NULL,

    review_status       VARCHAR(20) NOT NULL,


    -- ========================================================
    -- UNIQUE CONSTRAINT
    -- One review per customer-product combination
    -- ========================================================
    CONSTRAINT uq_review_customer_product
        UNIQUE (customer_id, product_id),


    -- ========================================================
    -- FOREIGN KEYS
    -- ========================================================
    CONSTRAINT fk_review_customer
        FOREIGN KEY (customer_id)
        REFERENCES silver.customer(customer_id),

    CONSTRAINT fk_review_product
        FOREIGN KEY (product_id)
        REFERENCES silver.product(product_id)
);

-- ============================================================
-- SILVER MARKETING EVENT TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS silver.marketing_event (

    event_id          INTEGER PRIMARY KEY,

    customer_id       INTEGER NOT NULL,

    campaign_id       INTEGER,

    campaign_name     VARCHAR(100),

    event_type        VARCHAR(30) NOT NULL,

    channel           VARCHAR(30) NOT NULL,

    event_timestamp   TIMESTAMPTZ,

    device_type       VARCHAR(20),

    country           VARCHAR(100) NOT NULL,

    -- ========================================================
    -- FOREIGN KEY
    -- ========================================================
    CONSTRAINT fk_marketing_event_customer
        FOREIGN KEY (customer_id)
        REFERENCES silver.customer(customer_id)
);



-- ============================================================
-- SILVER EXCHANGE RATE TABLE
-- ============================================================

CREATE SCHEMA IF NOT EXISTS silver;

CREATE TABLE IF NOT EXISTS silver.exchange_rate (

    requested_date DATE NOT NULL,

    date DATE NOT NULL,

    base CHAR(3) NOT NULL,

    quote CHAR(3) NOT NULL,

    rate DECIMAL(18,8) NOT NULL,

    -- ========================================================
    -- METADATA
    -- ========================================================
    source_file TEXT NOT NULL,
    ingestion_timestamp TIMESTAMPTZ NOT NULL,
    batch_id UUID NOT NULL,
    source_system TEXT NOT NULL,

    -- ========================================================
    -- NATURAL KEY
    -- One exchange rate for a currency pair on a given date.
    -- ========================================================
    CONSTRAINT pk_exchange_rate
        PRIMARY KEY (date, base, quote)
);