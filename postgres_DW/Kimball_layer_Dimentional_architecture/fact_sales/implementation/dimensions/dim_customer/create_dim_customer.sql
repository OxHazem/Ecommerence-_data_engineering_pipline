-- ============================================================
-- KIMBALL - CUSTOMER DIMENSION
-- ============================================================
-- Grain:
-- One row represents one customer version.
--
-- customer_key = surrogate key
-- customer_id  = business/natural key
--
-- SCD Type 2 columns are included for historical tracking.
-- ============================================================

DROP TABLE IF EXISTS kimball.dim_customer;

CREATE TABLE kimball.dim_customer (

    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id INTEGER NOT NULL,

    first_name VARCHAR(50) NOT NULL,

    last_name VARCHAR(50) NOT NULL,

    gender VARCHAR(20),

    email VARCHAR(255),

    phone VARCHAR(20),

    country VARCHAR(100),

    city VARCHAR(100),

    customer_status VARCHAR(20),

    registration_date DATE,

    -- ========================================================
    -- SCD TYPE 2
    -- ========================================================

    effective_date DATE NOT NULL,

    expiration_date DATE NOT NULL,

    is_current BOOLEAN NOT NULL

);