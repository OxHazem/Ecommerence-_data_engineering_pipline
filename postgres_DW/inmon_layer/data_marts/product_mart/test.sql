SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (
        WHERE oi.product_id IS NOT NULL
    ) AS products_with_sales,
    COUNT(*) FILTER (
        WHERE oi.product_id IS NULL
    ) AS products_without_sales
FROM inmon_layer.product p
LEFT JOIN (
    SELECT DISTINCT product_id
    FROM inmon_layer.order_item
) oi
    ON p.product_id = oi.product_id;






SELECT COUNT(*) AS invalid_product_references
FROM inmon_layer.order_item oi
LEFT JOIN inmon_layer.product p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;







SELECT
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT product_id) AS products_with_sales,
    SUM(quantity) AS total_quantity
FROM inmon_layer.order_item;








SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE sc.subcategory_id IS NULL) AS missing_subcategory,
    COUNT(*) FILTER (WHERE cat.category_id IS NULL) AS missing_category
FROM inmon_layer.product p
LEFT JOIN inmon_layer.subcategory sc
    ON p.subcategory_id = sc.subcategory_id
LEFT JOIN inmon_layer.category cat
    ON sc.category_id = cat.category_id;






SELECT
    COUNT(DISTINCT product_id) FILTER (
        WHERE unit_price IS NULL
    ) AS products_with_missing_price,

    COUNT(DISTINCT product_id) FILTER (
        WHERE cost_at_sale IS NULL
    ) AS products_with_missing_cost
FROM inmon_layer.order_item;






SELECT
    COUNT(DISTINCT oi.product_id) FILTER (
        WHERE o.order_date IS NULL
    ) AS products_with_missing_order_date
FROM inmon_layer.order_item oi
JOIN inmon_layer.orders o
    ON oi.order_id = o.order_id;






SELECT COUNT(*) AS product_mart_rows
FROM inmon_mart.product_mart;




SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS distinct_products
FROM inmon_mart.product_mart;







SELECT
    pm.total_orders,
    sm.total_orders,
    pm.total_items,
    sm.total_items,
    pm.total_quantity,
    sm.total_quantity,
    pm.total_revenue_egp,
    sm.total_revenue_egp,
    pm.total_cost_egp,
    sm.total_cost_egp,
    pm.total_profit_egp,
    sm.total_profit_egp
FROM
(
    SELECT
        SUM(total_orders) AS total_orders,
        SUM(total_items) AS total_items,
        SUM(total_quantity) AS total_quantity,
        SUM(total_revenue_egp) AS total_revenue_egp,
        SUM(total_cost_egp) AS total_cost_egp,
        SUM(total_profit_egp) AS total_profit_egp
    FROM inmon_mart.product_mart
) pm
CROSS JOIN
(
    SELECT
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS total_items,
        SUM(quantity) AS total_quantity,
        SUM(revenue_egp) AS total_revenue_egp,
        SUM(cost_egp) AS total_cost_egp,
        SUM(profit_egp) AS total_profit_egp
    FROM inmon_mart.sales_mart
) sm;





SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE subcategory IS NULL) AS missing_subcategory
FROM inmon_mart.product_mart;











SELECT
    COUNT(*) FILTER (WHERE first_sale_date IS NULL) AS missing_first_sale,
    COUNT(*) FILTER (WHERE last_sale_date IS NULL) AS missing_last_sale,
    COUNT(*) FILTER (
        WHERE first_sale_date > last_sale_date
    ) AS invalid_date_range
FROM inmon_mart.product_mart;





SELECT
    SUM(pm.total_orders) AS product_mart_order_product_combinations,
    COUNT(DISTINCT oi.order_id) AS actual_distinct_orders
FROM inmon_mart.product_mart pm
CROSS JOIN (
    SELECT DISTINCT order_id
    FROM inmon_layer.order_item
) oi;



SELECT
    SUM(total_orders) AS sum_product_order_counts,
    SUM(total_items) AS total_items,
    SUM(total_quantity) AS total_quantity
FROM inmon_mart.product_mart;




SELECT
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(*) AS total_items,
    SUM(quantity) AS total_quantity
FROM inmon_layer.order_item;