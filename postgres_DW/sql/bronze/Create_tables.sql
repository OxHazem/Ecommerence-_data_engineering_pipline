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
-- CLEANUP EXISTING TABLES
-- ============================================================
DROP TABLE IF EXISTS bronze.customer CASCADE;
DROP TABLE IF EXISTS bronze.product CASCADE;
DROP TABLE IF EXISTS bronze.orders CASCADE;
DROP TABLE IF EXISTS bronze.order_item CASCADE;
DROP TABLE IF EXISTS bronze.payment CASCADE;
DROP TABLE IF EXISTS bronze.shipping CASCADE;
DROP TABLE IF EXISTS bronze.review CASCADE;
DROP TABLE IF EXISTS bronze.marketing_event CASCADE;
DROP TABLE IF EXISTS bronze.exchange_rate CASCADE;


-- ============================================================
-- CUSTOMER
-- ============================================================

CREATE TABLE bronze.customer (
    customer_id         TEXT,
    first_name          TEXT,
    last_name           TEXT,
    email               TEXT,
    phone               TEXT,
    gender              TEXT,
    date_of_birth       TEXT,
    country             TEXT,
    city                TEXT,
    registration_date   TEXT,
    customer_status     TEXT,

    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);


-- ============================================================
-- PRODUCT
-- ============================================================

CREATE TABLE bronze.product (
    product_id       TEXT,
    product_name     TEXT,
    category         TEXT,
    subcategory      TEXT,
    brand            TEXT,
    supplier         TEXT,
    cost             TEXT,
    price            TEXT,
    stock_quantity   TEXT,
    product_status   TEXT,
    launch_date      TEXT,

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
    order_id          TEXT,
    customer_id       TEXT,
    order_date        TEXT,
    order_status      TEXT,
    currency           TEXT,
    shipping_country   TEXT,
    shipping_city      TEXT,

    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);


-- ============================================================
-- ORDER ITEM
-- ============================================================

CREATE TABLE bronze.order_item (
    order_id       TEXT,
    product_id     TEXT,
    quantity       TEXT,
    unit_price     TEXT,
    discount       TEXT,
    cost_at_sale   TEXT,

    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);


-- ============================================================
-- PAYMENT
-- ============================================================

CREATE TABLE bronze.payment (
    payment_id             TEXT,
    order_id               TEXT,
    payment_date           TEXT,
    payment_method         TEXT,
    amount                 TEXT,
    currency               TEXT,
    payment_status         TEXT,
    transaction_reference  TEXT,

    source_file            TEXT NOT NULL,
    ingestion_timestamp    TIMESTAMPTZ NOT NULL,
    batch_id                UUID NOT NULL,
    source_system           TEXT NOT NULL
);


-- ============================================================
-- SHIPPING
-- ============================================================

CREATE TABLE bronze.shipping (
    shipment_id              TEXT,
    order_id                 TEXT,
    shipping_date            TEXT,
    estimated_delivery_date  TEXT,
    delivery_date            TEXT,
    shipping_country         TEXT,
    shipping_city            TEXT,
    shipping_method          TEXT,
    shipping_status          TEXT,
    shipping_cost            TEXT,

    source_file              TEXT NOT NULL,
    ingestion_timestamp      TIMESTAMPTZ NOT NULL,
    batch_id                 UUID NOT NULL,
    source_system            TEXT NOT NULL
);

-- ============================================================
-- REVIEW
-- ============================================================

CREATE TABLE IF NOT EXISTS bronze.review (
    review_id          TEXT,
    customer_id        TEXT,
    product_id         TEXT,
    rating             TEXT,
    review_text        TEXT,
    review_date        TEXT,
    verified_purchase  TEXT,
    review_status      TEXT,

    source_file         TEXT NOT NULL,
    ingestion_timestamp TIMESTAMPTZ NOT NULL,
    batch_id            UUID NOT NULL,
    source_system       TEXT NOT NULL
);


-- ============================================================
-- MARKETING EVENT
-- ============================================================

CREATE TABLE IF NOT EXISTS bronze.marketing_event (
    event_id           TEXT,
    customer_id        TEXT,
    campaign_id        TEXT,
    campaign_name      TEXT,
    event_type         TEXT,
    channel            TEXT,
    event_timestamp    TEXT,
    device_type        TEXT,
    country            TEXT,

    source_file         TEXT NOT NULL,
    ingestion_timestamp TIMESTAMPTZ NOT NULL,
    batch_id            UUID NOT NULL,
    source_system       TEXT NOT NULL
);


-- ============================================================
-- EXCHANGE RATES
-- ============================================================

CREATE TABLE IF NOT EXISTS bronze.exchange_rate (
    requested_date       TEXT,
    date                 TEXT,
    base                 TEXT,
    quote                TEXT,
    rate                 TEXT,

    -- Ingestion metadata
    source_file          TEXT NOT NULL,
    ingestion_timestamp  TIMESTAMPTZ NOT NULL,
    batch_id             UUID NOT NULL,
    source_system        TEXT NOT NULL
);