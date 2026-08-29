-- ============================================================
-- LOAD ORDER ITEM INTO SILVER
-- ============================================================

INSERT INTO silver.order_item (
    order_id,
    product_id,
    quantity,
    unit_price,
    discount,
    cost_at_sale,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system
)

WITH deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id, product_id
            ORDER BY ingestion_timestamp DESC
        ) AS rn

    FROM bronze.order_item
),

cleaned AS (

    SELECT
        oi.order_id::INTEGER AS order_id,
        oi.product_id::INTEGER AS product_id,

        -- ====================================================
        -- QUANTITY
        -- Invalid type / negative value -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(oi.quantity) !~ '^[0-9]+$'
            THEN NULL

            ELSE TRIM(oi.quantity)::INTEGER
        END AS quantity,

        -- ====================================================
        -- UNIT PRICE
        -- Invalid type / negative value -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(oi.unit_price) !~ '^[0-9]+(\.[0-9]+)?$'
            THEN NULL

            ELSE TRIM(oi.unit_price)::DECIMAL(10,2)
        END AS unit_price,

        oi.discount::DECIMAL(10,2) AS discount,
        oi.cost_at_sale::DECIMAL(10,2) AS cost_at_sale,

        oi.source_file,
        oi.ingestion_timestamp,
        oi.batch_id,
        oi.source_system

    FROM deduplicated oi

    INNER JOIN silver.orders o
        ON oi.order_id::INTEGER = o.order_id

    INNER JOIN silver.product p
        ON oi.product_id::INTEGER = p.product_id

    WHERE oi.rn = 1
)

SELECT
    order_id,
    product_id,
    quantity,
    unit_price,
    discount,
    cost_at_sale,
    source_file,
    ingestion_timestamp,
    batch_id,
    source_system

FROM cleaned;
