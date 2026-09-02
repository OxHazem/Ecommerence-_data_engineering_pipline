-- ============================================================
-- KIMBALL - DATE DIMENSION
-- ============================================================

DROP TABLE IF EXISTS kimball.dim_date;

CREATE TABLE kimball.dim_date (

    date_key INTEGER PRIMARY KEY,

    full_date DATE NOT NULL UNIQUE,

    day INTEGER NOT NULL,

    day_name VARCHAR(20) NOT NULL,

    week INTEGER NOT NULL,

    month INTEGER NOT NULL,

    month_name VARCHAR(20) NOT NULL,

    quarter INTEGER NOT NULL,

    year INTEGER NOT NULL,

    is_weekend BOOLEAN NOT NULL

);