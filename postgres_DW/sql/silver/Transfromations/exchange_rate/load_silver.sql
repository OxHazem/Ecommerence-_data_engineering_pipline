-- ============================================================
-- EXCHANGE RATE LOAD
-- ============================================================

INSERT INTO silver.exchange_rate (
    requested_date,
    date,
    base,
    quote,
    rate,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system
)

SELECT
    requested_date::DATE,
    date::DATE,
    TRIM(base)::CHAR(3),
    TRIM(quote)::CHAR(3),
    rate::NUMERIC,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system

FROM bronze.exchange_rate;