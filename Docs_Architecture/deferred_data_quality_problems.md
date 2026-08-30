# Gold Layer — Deferred Data Quality Problems

## Purpose

This document records data-quality problems discovered during implementation of the Gold layer that should be investigated and corrected later.

These issues are documented separately so that the current Gold-layer implementation is not changed without first confirming the correct business rule and the appropriate layer for the fix.

---

## 1. Product–Brand Business Relationship Mismatch

### Problem

Some generated products have combinations of `category`, `subcategory`, `product_name`, and `brand` that do not appear logically consistent.

Examples observed in `gold.product_sales`:

| Product | Category | Subcategory | Brand |
|---|---|---|---|
| Ago Site | Electronics | Laptops | Zara |
| Dog Chair | Beauty | Skincare | Adidas |
| Require Sit | Beauty | Skincare | Lenovo |
| Begin Performance | Sports | Outdoor | Nike |

These combinations are suspicious because the brand may not normally correspond to the product/category.

### Current assessment

The issue appears to originate in the generated source data rather than in the Gold-layer transformation.

The `product_sales` transformation currently preserves the values coming from Silver, which is the correct behavior for this investigation stage.

### Important distinction

This is different from simple brand-format inconsistency such as:

- `Samsung`
- `samsung`
- `SAMSUNG`

Format inconsistency is a data-quality problem already identified separately.

The issue documented here concerns the **business relationship between brand and product/category**.

### Why it matters

Incorrect relationships can reduce the realism and analytical usefulness of:

- Product analysis
- Brand analysis
- Category analysis
- Product recommendations
- Power BI dashboards

### Recommended future action

Investigate the product-data generator.

Determine whether:

1. Brand selection is completely random.
2. Category selection is completely random.
3. Product names are generated independently.
4. A mapping between category/subcategory and valid brands should exist.

If appropriate, redesign the generator using controlled relationships such as:

`Category → Subcategory → Product → Brand`

Do not silently correct these values in the Gold layer.

---

## 2. Incomplete Order-Item Financial Data

### Problem

Some `order_item` records contain missing values in financial fields, particularly:

- `quantity`
- `unit_price`
- `cost_at_sale`

### Current Gold-layer handling

An incomplete item is not allowed to create an artificial financial result.

For financial calculations, an item is considered complete when:

- `quantity IS NOT NULL`
- `unit_price IS NOT NULL`
- `cost_at_sale IS NOT NULL`

Incomplete items are excluded from the relevant financial calculations and are counted using:

`incomplete_items`

### Why it matters

If missing prices or quantities are interpreted as zero, the Gold layer can incorrectly create:

- Artificial revenue
- Artificial cost
- Artificial negative profit

### Current decision

Keep the incomplete-item indicator in Gold.

Do not replace missing financial values with zero unless a documented business rule supports that replacement.

### Future action

Review the generator and Silver-layer handling to determine whether missing values are intentionally generated dirty data or require additional business treatment.

---

## 3. Negative Profit Investigation

### Problem

Some Gold records have negative profit.

Negative profit is not automatically an error.

### Current business rule

For financially complete items:

`Profit = Revenue - Cost`

Therefore, negative profit is valid when:

`Cost > Revenue`

### Important distinction

There are two possible causes:

#### A. Artificial negative profit

Caused by incomplete data, for example:

- quantity exists
- unit_price is NULL
- cost_at_sale exists

If missing values are treated incorrectly as zero, this can create an artificial loss.

#### B. Genuine negative profit

All required financial fields are present, but:

`Revenue < Cost`

This may represent a legitimate loss according to the generated business data.

### Current decision

Do not automatically convert negative profit to zero.

Do not remove negative-profit records from Gold.

Investigate remaining negative-profit products/days/months only after confirming that the underlying order-item data is complete.

---

## 4. Deferred Investigation Policy

These issues should be investigated **after the current Gold-layer implementation is complete** unless they prevent the current transformation from being correct.

The preferred correction order is:

1. Identify the root cause in the data generator.
2. Decide whether the behavior is intentional dirty data or a generator defect.
3. Define the business rule.
4. Correct the appropriate upstream layer.
5. Regenerate/reload affected data if necessary.
6. Re-run Silver validation.
7. Re-run Gold validation.
8. Confirm that Power BI metrics remain consistent.

### Principle

Do not use the Gold layer to hide upstream data-generation problems.

Gold should apply documented business rules and expose useful data-quality indicators while preserving trustworthy analytical results.
