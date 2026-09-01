-- ============================================================
-- GOLD - SHIPPING PERFORMANCE
-- ============================================================

TRUNCATE TABLE gold.shipping_performance;


INSERT INTO gold.shipping_performance (
    country,
    shipping_method,
    shipments,
    delivered_shipments,
    delayed_shipments,
    delivery_rate,
    delay_rate,
    average_delivery_days,
    average_shipping_cost
)

SELECT

    -- ========================================================
    -- COUNTRY
    -- ========================================================

    COALESCE(
        NULLIF(TRIM(s.shipping_country), ''),
        'Unknown'
    ) AS country,


    -- ========================================================
    -- SHIPPING METHOD
    -- ========================================================

    COALESCE(
        NULLIF(TRIM(s.shipping_method), ''),
        'Unknown'
    ) AS shipping_method,


    -- ========================================================
    -- TOTAL SHIPMENTS
    -- ========================================================

    COUNT(*) AS shipments,


    -- ========================================================
    -- DELIVERED SHIPMENTS
    --
    -- NULL delivery_date means not delivered yet.
    -- ========================================================

    COUNT(*) FILTER (
        WHERE s.delivery_date IS NOT NULL
    ) AS delivered_shipments,


    -- ========================================================
    -- DELAYED SHIPMENTS
    --
    -- A shipment is delayed when the actual delivery date
    -- is after the estimated delivery date.
    --
    -- We require both dates to exist.
    -- ========================================================

    COUNT(*) FILTER (
        WHERE s.delivery_date IS NOT NULL
          AND s.estimated_delivery_date IS NOT NULL
          AND s.delivery_date > s.estimated_delivery_date
    ) AS delayed_shipments,


    -- ========================================================
    -- DELIVERY RATE
    --
    -- Delivered shipments / total shipments
    -- ========================================================

    COALESCE(
        ROUND(
            COUNT(*) FILTER (
                WHERE s.delivery_date IS NOT NULL
            )::NUMERIC
            /
            NULLIF(COUNT(*), 0)
            * 100,
            2
        ),
        0
    ) AS delivery_rate,


    -- ========================================================
    -- DELAY RATE
    --
    -- Delayed shipments / delivered shipments
    -- ========================================================

    COALESCE(
        ROUND(
            COUNT(*) FILTER (
                WHERE s.delivery_date IS NOT NULL
                  AND s.estimated_delivery_date IS NOT NULL
                  AND s.delivery_date > s.estimated_delivery_date
            )::NUMERIC
            /
            NULLIF(
                COUNT(*) FILTER (
                    WHERE s.delivery_date IS NOT NULL
                ),
                0
            )
            * 100,
            2
        ),
        0
    ) AS delay_rate,


    -- ========================================================
    -- AVERAGE DELIVERY TIME
    --
    -- Only completed deliveries participate.
    -- ========================================================

    COALESCE(
        ROUND(
            AVG(
                CASE
                    WHEN s.delivery_date IS NOT NULL
                     AND s.shipping_date IS NOT NULL
                    THEN
                        s.delivery_date - s.shipping_date
                END
            ),
            2
        ),
        0
    ) AS average_delivery_days,


    -- ========================================================
    -- AVERAGE SHIPPING COST
    -- ========================================================

    COALESCE(
        ROUND(
            AVG(s.shipping_cost),
            2
        ),
        0
    ) AS average_shipping_cost


FROM silver.shipping s


-- ============================================================
-- GROUP AT COUNTRY + SHIPPING METHOD GRAIN
-- ============================================================

GROUP BY
    COALESCE(
        NULLIF(TRIM(s.shipping_country), ''),
        'Unknown'
    ),

    COALESCE(
        NULLIF(TRIM(s.shipping_method), ''),
        'Unknown'
    )


ORDER BY
    country,
    shipping_method;