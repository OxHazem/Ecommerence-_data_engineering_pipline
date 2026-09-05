# Kimball Data Warehouse — Implementation & Validation

## 1. Purpose

The Kimball phase implements a dimensional data warehouse for analytical workloads using a Star Schema.

The project documentation defines Kimball as a dimensional warehouse approach based on fact and dimension tables, with `fact_sales` at the selected business grain and Customer implemented as an SCD Type 2 dimension. The documented architecture places the Kimball warehouse after the refined Medallion data and before BI consumption.

## 2. Architecture

```text
Silver
   |
   v
Kimball Warehouse
   |
   +-------------------+
   |                   |
   v                   v
Star Schema          Power BI
```

Star Schema:

```text
                    dim_customer
                         |
dim_product -------- fact_sales -------- dim_date
                         |
                    dim_payment
```

## 3. Fact Table

### `kimball.fact_sales`

**Grain:** One row represents one product line within one customer order.

Columns:

```text
sales_key, order_id, customer_key, product_key, date_key, payment_key,
quantity, unit_price, discount, revenue, cost, profit
```

Financial values are normalized to EGP.

For financially complete order items:

```text
revenue = quantity × unit_price × (1 - discount / 100) × exchange_rate
cost    = quantity × cost_at_sale × exchange_rate
profit  = revenue - cost
```

Revenue and cost are rounded to two decimal places before profit is calculated.

Cancelled orders are excluded from `fact_sales`.

## 4. Dimensions

### `kimball.dim_date`

Provides calendar attributes for time analysis.

**Rows:** 4,214

### `kimball.dim_customer`

Contains customer descriptive attributes and SCD Type 2 history.

Key attributes include:

```text
customer_key
customer_id
first_name
last_name
gender
email
phone
country
city
customer_status
registration_date
effective_date
expiration_date
is_current
```

**Rows:** 10,000

`customer_key` is the surrogate warehouse key.

### Customer SCD Type 2

Customer changes are handled using:

```text
effective_date
expiration_date
is_current
```

When a tracked attribute changes, the current version is expired and a new surrogate-key version is inserted, preserving the historical version.

The fact-to-customer lookup uses:

```text
order_date >= effective_date
AND order_date < expiration_date
```

Some Silver customer records had NULL `registration_date`. The initial Kimball fallback to the current date created future effective dates for historical customers. The affected Kimball records were corrected using each customer's earliest valid non-cancelled order date. Silver data was not changed.

After correction:

- Invalid future effective dates: 0
- Orders before customer effective date: 0
- Affected customers remaining: 0

### `kimball.dim_product`

Key attributes:

```text
product_key
product_id
product_name
category
subcategory
brand
supplier
cost
price
stock_quantity
product_status
launch_date
```

**Rows:** 2,000

### `kimball.dim_payment`

```text
payment_key
payment_id
payment_method
currency
payment_status
transaction_reference
```

**Rows:** 49,000

## 5. Referential Integrity

`fact_sales` has foreign keys to:

```text
dim_customer(customer_key)
dim_product(product_key)
dim_date(date_key)
dim_payment(payment_key)
```

Validation:

| Check | Result |
|---|---:|
| Customer orphan rows | 0 |
| Product orphan rows | 0 |
| Date orphan rows | 0 |
| Payment orphan rows | 0 |

NULL-key validation:

| Key | NULL rows |
|---|---:|
| customer_key | 0 |
| product_key | 0 |
| date_key | 0 |
| payment_key | 918 |

The 918 NULL payment keys are valid because those sales have no matching payment record.

## 6. Fact Completeness and Grain

Final fact row count: **87,593**

Validation confirmed:

- Expected eligible Silver rows: 87,593
- Loaded fact rows: 87,593
- Duplicate order/product fact combinations: 0
- Unmatched fact rows to Silver order items: 0

## 7. Financial Validation

| Check | Result |
|---|---:|
| Fact rows | 87,593 |
| Profit mismatches | 0 |
| Negative revenue | 0 |
| Negative cost | 0 |

Stored revenue and cost values also have no unexpected precision beyond two decimal places.

## 8. Exchange-Rate Validation

Non-EGP transactions use the latest applicable historical rate on or before the order date.

Validation found:

**0 non-EGP rows without an applicable exchange rate.**

EGP uses a rate of 1. AED and SAR transactions are converted to EGP.

## 9. Gold Reconciliation

Kimball daily sales were compared with `gold.daily_sales`.

Results were consistent, with only small cent-level differences on some dates caused by differences in calculation/rounding order.

Aggregate difference observed:

```text
Revenue: +8.78 EGP
Cost:    +0.54 EGP
Profit:  +7.88 EGP
```

This is a rounding/calculation-order variance, not missing fact data.

`gold.daily_sales` is an aggregated reporting table and may contain zero-sales dates, including dates where only cancelled orders exist. `fact_sales` is an atomic sales fact and excludes cancelled orders. Therefore, direct row-for-row date existence between the two tables is not required.

## 10. Final Validation Summary

| Area | Status |
|---|---|
| Star Schema | PASS |
| Fact grain | PASS |
| Surrogate keys | PASS |
| Date dimension | PASS |
| Customer dimension | PASS |
| Product dimension | PASS |
| Payment dimension | PASS |
| Customer SCD Type 2 | PASS |
| Foreign-key integrity | PASS |
| Fact completeness | PASS |
| Duplicate/grain checks | PASS |
| Financial consistency | PASS |
| Exchange-rate coverage | PASS |
| Required NULL foreign keys | PASS |
| Gold reconciliation | PASS — minor documented rounding variance |

## 11. Final Status

**Kimball implementation complete and technically validated.**

The warehouse provides a business-oriented Star Schema for analytical workloads and preserves historical Customer changes through SCD Type 2.

No Silver-layer changes are required as a result of the Kimball validation.

## 12. Next Phase

Continue with the project's existing implementation plan. Later documented phases include the data quality framework, Power BI, Docker, testing, performance, and final documentation. dbt and Airflow are also part of the planned transformation/orchestration workflow.
