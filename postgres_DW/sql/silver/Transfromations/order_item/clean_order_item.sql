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
        -- Invalid type -> NULL
        -- Negative quantity -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(oi.quantity) !~ '^[0-9]+$'
            THEN NULL

            ELSE TRIM(oi.quantity)::INTEGER
        END AS quantity,


        -- ====================================================
        -- UNIT PRICE
        -- Invalid type -> NULL
        -- Negative value -> NULL
        -- ====================================================
        CASE
            WHEN TRIM(oi.unit_price) !~ '^[0-9]+(\.[0-9]+)?$'
            THEN NULL

            ELSE TRIM(oi.unit_price)::DECIMAL(10,2)
        END AS unit_price,
        oi.discount,
        oi.cost_at_sale,

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

SELECT *
FROM cleaned;














-- ALTER TABLE silver.order_item
-- ALTER COLUMN unit_price DROP NOT NULL;


-- ALTER TABLE silver.order_item
-- ALTER COLUMN quantity DROP NOT NULL;


SELECT COUNT(*)
FROM silver.order_item;



SELECT
    order_id,
    product_id,
    COUNT(*) AS occurrences
FROM silver.order_item
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;



SELECT oi.product_id
FROM silver.order_item oi
LEFT JOIN silver.product p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


SELECT
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_quantity,
    COUNT(*) FILTER (WHERE unit_price < 0) AS negative_unit_price
FROM silver.order_item;