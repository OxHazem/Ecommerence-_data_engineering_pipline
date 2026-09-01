-- ============================================================
-- GOLD - SHIPPING PERFORMANCE
-- ============================================================
-- Grain:
-- One row per shipping country + shipping method.
--
-- Purpose:
-- Analyze shipment volume, delivery performance,
-- delays, delivery time, and shipping cost.
-- ============================================================

CREATE TABLE IF NOT EXISTS gold.shipping_performance (

    country VARCHAR(100) NOT NULL,

    shipping_method VARCHAR(30) NOT NULL,

    shipments INTEGER NOT NULL,

    delivered_shipments INTEGER NOT NULL,

    delayed_shipments INTEGER NOT NULL,

    delivery_rate NUMERIC(6,2) NOT NULL,

    delay_rate NUMERIC(6,2) NOT NULL,

    average_delivery_days NUMERIC(10,2) NOT NULL,

    average_shipping_cost NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (
        country,
        shipping_method
    )

);