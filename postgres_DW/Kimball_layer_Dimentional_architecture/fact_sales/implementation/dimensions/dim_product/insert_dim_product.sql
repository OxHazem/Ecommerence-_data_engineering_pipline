-- ============================================================
-- LOAD PRODUCT DIMENSION
-- ============================================================

INSERT INTO kimball.dim_product (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    supplier,
    cost,
    price,
    stock_quantity,
    product_status,
    launch_date
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.supplier,
    p.cost,
    p.price,
    p.stock_quantity,
    p.product_status,
    p.launch_date

FROM silver.product p;