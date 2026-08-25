-- ============================================================
-- E-Commerce Data Warehouse
-- Bronze Layer
-- PostgreSQL
-- ============================================================
--
-- Purpose:
--   Store raw/ingested source data from MinIO.
--
-- Important:
--   Bronze intentionally does NOT enforce source-system
--   primary keys, foreign keys, UNIQUE constraints, or
--   business rules.
--
--   Source data is intentionally dirty.
--   Invalid values and invalid data types must remain available
--   for traceability and later Silver-layer cleansing.
--
-- ============================================================


-- ============================================================
-- CUSTOMER
-- ============================================================

CREATE TABLE bronze.customer (
    customer_id         INTEGER,
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    email               VARCHAR(255),
    phone               VARCHAR(20),
    gender              VARCHAR(20),
    date_of_birth       DATE,
    country             VARCHAR(100),
    city                VARCHAR(100),
    registration_date   DATE,
    customer_status     VARCHAR(20),

    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);


-- ============================================================
-- PRODUCT
-- ============================================================

CREATE TABLE bronze.product (
    product_id       INTEGER,
    product_name     VARCHAR(255),
    category         VARCHAR(100),
    subcategory      VARCHAR(100),
    brand            VARCHAR(100),
    supplier         VARCHAR(100),
    cost             DECIMAL(10,2),
    price            DECIMAL(10,2),
    stock_quantity   INTEGER,
    product_status   VARCHAR(20),
    launch_date      DATE,

    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);


-- ============================================================
-- ORDERS
-- ============================================================

-- "order" is a SQL keyword, therefore the warehouse table
-- is named "orders".

CREATE TABLE bronze.orders (
    order_id          INTEGER,
    customer_id       INTEGER,
    order_date        DATE,
    order_status      VARCHAR(20),
    currency           CHAR(3),
    shipping_country   VARCHAR(100),
    shipping_city      VARCHAR(100),

    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);


-- ============================================================
-- ORDER ITEM
-- ============================================================

CREATE TABLE bronze.order_item (
    order_id       INTEGER,
    product_id     INTEGER,
    quantity       INTEGER,
    unit_price     DECIMAL(10,2),
    discount       DECIMAL(5,2),
    cost_at_sale   DECIMAL(10,2),

    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);


-- ============================================================
-- PAYMENT
-- ============================================================

CREATE TABLE bronze.payment (
    payment_id             INTEGER,
    order_id               INTEGER,
    payment_date           DATE,
    payment_method         VARCHAR(30),
    amount                 DECIMAL(12,2),
    currency               CHAR(3),
    payment_status         VARCHAR(20),
    transaction_reference  VARCHAR(100),

    source_file            TEXT NOT NULL,
    ingestion_timestamp    TIMESTAMPTZ NOT NULL,
    batch_id                UUID NOT NULL,
    source_system           TEXT NOT NULL
);


-- ============================================================
-- SHIPPING
-- ============================================================

CREATE TABLE bronze.shipping (
    shipment_id              INTEGER,
    order_id                 INTEGER,
    shipping_date            DATE,
    estimated_delivery_date  DATE,
    delivery_date            DATE,
    shipping_country         VARCHAR(100),
    shipping_city            VARCHAR(100),
    shipping_method          VARCHAR(30),
    shipping_status          VARCHAR(20),
    shipping_cost            DECIMAL(10,2),

    source_file              TEXT NOT NULL,
    ingestion_timestamp      TIMESTAMPTZ NOT NULL,
    batch_id                 UUID NOT NULL,
    source_system            TEXT NOT NULL
);

-- ============================================================
-- REVIEW
-- ============================================================

CREATE TABLE IF NOT EXISTS bronze.review (
    review_id          INTEGER,
    customer_id        INTEGER,
    product_id         INTEGER,
    rating             INTEGER,
    review_text        TEXT,
    review_date        DATE,
    verified_purchase  BOOLEAN,
    review_status      VARCHAR(20),

    source_file         TEXT NOT NULL,
    ingestion_timestamp TIMESTAMPTZ NOT NULL,
    batch_id            UUID NOT NULL,
    source_system       TEXT NOT NULL
);


-- ============================================================
-- MARKETING EVENT
-- ============================================================

CREATE TABLE IF NOT EXISTS bronze.marketing_event (
    event_id           INTEGER,
    customer_id        INTEGER,
    campaign_id        INTEGER,
    campaign_name      VARCHAR(150),
    event_type         VARCHAR(30),
    channel            VARCHAR(30),
    event_timestamp    TIMESTAMP,
    device_type        VARCHAR(20),
    country            VARCHAR(100),

    source_file         TEXT NOT NULL,
    ingestion_timestamp TIMESTAMPTZ NOT NULL,
    batch_id            UUID NOT NULL,
    source_system       TEXT NOT NULL
);


-- ============================================================
-- EXCHANGE RATES
-- ============================================================

CREATE TABLE IF NOT EXISTS bronze.exchange_rate (
    requested_date       DATE,
    date                 DATE,
    base                 CHAR(3),
    quote                CHAR(3),
    rate                 DECIMAL(18,8),

    -- Ingestion metadata
    source_file          TEXT NOT NULL,
    ingestion_timestamp  TIMESTAMPTZ NOT NULL,
    batch_id             UUID NOT NULL,
    source_system        TEXT NOT NULL
);