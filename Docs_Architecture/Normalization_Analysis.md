# Normalization Analysis Report

> **Project:** E-Commerce Data Engineering Pipeline  
> **Scope:** `Data/generated/clean/` — all 8 entity files  
> **Forms Evaluated:** 1NF, 2NF, 3NF, BCNF  
> **Date:** September 2026  
> **Method:** Automated Functional Dependency (FD) analysis using Python/Pandas on actual generated data

---

## Table of Contents

1. [Normal Forms Reference](#normal-forms-reference)
2. [Summary Table](#summary-table)
3. [Entity-by-Entity Analysis](#entity-by-entity-analysis)
   - [1. Customer](#1-customer)
   - [2. Orders](#2-orders)
   - [3. Products](#3-products)
   - [4. Order Items](#4-order-items)
   - [5. Payments](#5-payments)
   - [6. Shipping](#6-shipping)
   - [7. Reviews](#7-reviews)
   - [8. Marketing Events](#8-marketing-events)
4. [Transitive Dependency Chains](#transitive-dependency-chains)
5. [Recommended New Dimension Tables](#recommended-new-dimension-tables)
6. [Architectural Guidance](#architectural-guidance)

---

## Normal Forms Reference

| Form | Rule |
|------|------|
| **1NF** | All column values are **atomic** (no lists, sets, or repeating groups). Every row is uniquely identifiable. |
| **2NF** | Satisfies 1NF **+** no **partial dependencies** — every non-key attribute depends on the **entire** primary key (matters only when PK is composite). |
| **3NF** | Satisfies 2NF **+** no **transitive dependencies** — non-key attributes depend **only** on the primary key, not on other non-key attributes. |
| **BCNF** | Stricter 3NF — every **determinant** (left side of a functional dependency) must be a **candidate key**. |

> **Notation:** `A → B` means "A functionally determines B" (knowing A uniquely determines the value of B).

---

## Summary Table

| Entity | 1NF | 2NF | 3NF | BCNF | Highest Violation |
|--------|:---:|:---:|:---:|:----:|-------------------|
| **Customer** | ✅ | ✅ | ⚠️ | ⚠️ | `city → country` (transitive) |
| **Orders** | ✅ | ✅ | ⚠️ | ⚠️ | `city → country`, `customer_id → currency` |
| **Products** | ✅ | ✅ | ⚠️ | ⚠️ | `subcategory → category` (transitive) |
| **Order Items** | ✅ | ✅ | ✅ | ✅ | None — fully normalized |
| **Payments** | ✅ | ✅ | ⚠️ | ⚠️ | `order_id → currency` (transitive) |
| **Shipping** | ✅ | ✅ | ⚠️ | ⚠️ | `city → country` (transitive) |
| **Reviews** | ✅ | ✅ | ✅ | ✅ | None — fully normalized |
| **Marketing Events** | ✅ | ✅ | ❌ | ❌ | `campaign_name` not determined by `campaign_id` (data generator bug + design issue) |

> **All 8 entities pass 1NF and 2NF without exception.**

---

## Entity-by-Entity Analysis

---

### 1. Customer

**File:** `customers.json`  
**Primary Key:** `customer_id`  
**All Columns:** `customer_id`, `first_name`, `last_name`, `email`, `phone`, `gender`, `date_of_birth`, `country`, `city`, `registration_date`, `customer_status`

#### Evidence from Data Analysis
```
Cities mapping to more than 1 country : 0
Countries and their distinct cities   : {'Egypt': 4, 'Saudi Arabia': 3, 'UAE': 3}
```

#### 1NF — ✅ PASS
All column values are atomic (single values only). `customer_id` is unique across all rows. No repeating groups exist.

#### 2NF — ✅ PASS
The primary key is a single column (`customer_id`), so partial dependencies are mathematically impossible.

#### 3NF — ⚠️ VIOLATION

**Violation: `city → country`**

`city` is not a key, yet it functionally determines `country`. The data confirms this: **no city maps to more than one country**. This creates the transitive chain:

```
customer_id → city → country
```

Because `country` is determined by `city` (a non-key attribute), `country` is not directly dependent on the primary key — it is transitively dependent. This is a **3NF violation**.

**Impact:** If you update a city's country mapping, you would need to update thousands of customer rows instead of one row in a `Location` table.

#### BCNF — ⚠️ VIOLATION
`city` is a determinant of `country` but `city` is not a candidate key of the `customer` table. This violates BCNF.

---

### 2. Orders

**File:** `orders.csv`  
**Primary Key:** `order_id`  
**All Columns:** `order_id`, `customer_id`, `order_date`, `order_status`, `currency`, `shipping_country`, `shipping_city`

#### Evidence from Data Analysis
```
Duplicate order_ids                        : 0
Unique (shipping_country, shipping_city)   : 10 fixed combinations
Customers with more than 1 currency        : 0
Unique currencies per country              : {'Egypt': 1, 'Saudi Arabia': 1, 'UAE': 1}
```

#### 1NF — ✅ PASS
All values are atomic. `order_id` is unique.

#### 2NF — ✅ PASS
Single-column primary key — partial dependencies are impossible.

#### 3NF — ⚠️ TWO VIOLATIONS

**Violation 1: `shipping_city → shipping_country`**

The data confirms exactly 10 fixed city/country pairs. `shipping_country` is transitively determined:
```
order_id → shipping_city → shipping_country
```

**Violation 2: `customer_id → currency`**

Every customer uses exactly one currency, and every country has exactly one currency. This creates a full transitive chain:
```
order_id → customer_id → country → currency
```
`currency` can always be derived from the customer's country — storing it in `orders` is redundant and a potential source of inconsistency.

#### BCNF — ⚠️ VIOLATION
Both `shipping_city` and `customer_id` act as determinants within the `orders` table but neither is a candidate key of `orders`.

---

### 3. Products

**File:** `products.csv`  
**Primary Key:** `product_id`  
**All Columns:** `product_id`, `product_name`, `category`, `subcategory`, `brand`, `supplier`, `cost`, `price`, `stock_quantity`, `product_status`, `launch_date`

#### Evidence from Data Analysis
```
Unique categories           : 5
Unique subcategories        : 25
Subcategories → >1 category : 0   (every subcategory belongs to exactly 1 category)
Unique brands               : 12
Brands with >1 supplier     : 12  (ALL brands have multiple suppliers — no FD exists)
```

#### 1NF — ✅ PASS
All values are atomic. `product_id` is unique.

#### 2NF — ✅ PASS
Single-column primary key.

#### 3NF — ⚠️ VIOLATION

**Violation: `subcategory → category`**

Every subcategory belongs to exactly one category (confirmed: 0 subcategories map to more than 1 category). This means `category` is transitively determined:
```
product_id → subcategory → category
```
`category` is not directly dependent on `product_id`; it flows through `subcategory`.

**No Violation for `brand → supplier`:**
All 12 brands have 6–7 different suppliers, confirming there is **no functional dependency** between `brand` and `supplier`. Both are direct attributes of the product.

#### BCNF — ⚠️ VIOLATION
`subcategory` determines `category` but `subcategory` is not a candidate key of the `product` table.

---

### 4. Order Items

**File:** `order_items.csv`  
**Primary Key:** `(order_id, product_id)` — Composite  
**All Columns:** `order_id`, `product_id`, `quantity`, `unit_price`, `discount`, `cost_at_sale`

#### Evidence from Data Analysis
```
Duplicate (order_id, product_id) pairs        : 0
unit_price == current product.price           : 36 / 150,000 rows
unit_price != current product.price           : 149,964 / 150,000 rows
```

#### 1NF — ✅ PASS
All values are atomic. Composite PK is unique (0 duplicates).

#### 2NF — ✅ PASS

`unit_price` might appear to partially depend on `product_id` alone, but the data proves otherwise: **149,964 out of 150,000 rows have a `unit_price` that differs from the current `products.price`**. This confirms that `unit_price` is the **historical price at the time of sale**, not a current property of the product. It fully depends on the entire composite key `(order_id, product_id)`.

This is a well-recognized **justified denormalization** in transactional e-commerce data models — comparable to a Type 2 Slowly Changing Dimension at the fact level.

#### 3NF — ✅ PASS
No transitive dependencies. `quantity`, `discount`, and `cost_at_sale` all describe the specific order line item only.

#### BCNF — ✅ PASS
The only determinant is the full composite primary key `(order_id, product_id)`.

> **Conclusion: Order Items is the most normalized entity in the schema.**

---

### 5. Payments

**File:** `payments.csv`  
**Primary Key:** `payment_id`  
**All Columns:** `payment_id`, `order_id`, `payment_date`, `payment_method`, `amount`, `currency`, `payment_status`, `transaction_reference`

#### Evidence from Data Analysis
```
Duplicate payment_ids              : 0
Unique transaction_references      : 50,000 / 50,000  (completely unique)
Unique currencies per country      : {'Egypt': 1, 'Saudi Arabia': 1, 'UAE': 1}
```

#### 1NF — ✅ PASS
All values are atomic. `payment_id` is unique. `transaction_reference` is also completely unique (a natural candidate key).

#### 2NF — ✅ PASS
Single-column primary key.

#### 3NF — ⚠️ VIOLATION

**Violation: `order_id → currency`**

Since `order_id → customer_id → country → currency`, the `currency` column in `payments` is transitively determined through a chain of non-key attributes:
```
payment_id → order_id → customer_id → country → currency
```
Storing `currency` here is redundant — it can always be derived at query time.

#### BCNF — ⚠️ VIOLATION
`order_id` determines `currency` but `order_id` is not a candidate key of `payments`.

---

### 6. Shipping

**File:** `shipping.csv`  
**Primary Key:** `shipment_id`  
**All Columns:** `shipment_id`, `order_id`, `shipping_date`, `estimated_delivery_date`, `delivery_date`, `shipping_country`, `shipping_city`, `shipping_method`, `shipping_status`, `shipping_cost`

#### Evidence from Data Analysis
```
Unique (shipping_country, shipping_city) : 10 fixed combinations
shipping_cost range per method:
  Express  : $20.03 – $499.98  (10,915 distinct values)
  Next Day : $20.06 – $499.96  (11,035 distinct values)
  Same Day : $20.00 – $499.96  (11,077 distinct values)
  Standard : $20.06 – $500.00  (11,031 distinct values)
```

#### 1NF — ✅ PASS
All values are atomic. `shipment_id` is unique.

#### 2NF — ✅ PASS
Single-column primary key.

#### 3NF — ⚠️ VIOLATION

**Violation: `shipping_city → shipping_country`**

Same city/country transitive dependency confirmed (10 fixed pairs):
```
shipment_id → shipping_city → shipping_country
```

**No Violation for `shipping_method → shipping_cost`:**
`shipping_cost` ranges across the full spectrum ($20–$500) for every shipping method with tens of thousands of distinct values per method. There is **no functional dependency** between `shipping_method` and `shipping_cost`. Cost is a direct fact of each shipment.

#### BCNF — ⚠️ VIOLATION
`shipping_city` is a determinant of `shipping_country` but is not a candidate key of `shipping`.

---

### 7. Reviews

**File:** `reviews.json`  
**Primary Key:** `review_id`  
**All Columns:** `review_id`, `customer_id`, `product_id`, `rating`, `review_date`, `verified_purchase`, `review_status`

#### Evidence from Data Analysis
```
Duplicate review_ids                       : 0
Duplicate (customer_id, product_id) pairs  : 0
```

#### 1NF — ✅ PASS
All values are atomic. `review_id` is unique.

#### 2NF — ✅ PASS
Single-column primary key.

#### 3NF — ✅ PASS
All non-key attributes (`rating`, `review_date`, `verified_purchase`, `review_status`) depend **directly** on `review_id` with no transitive chain through any other non-key attribute.

#### BCNF — ✅ PASS
The only determinant is the primary key `review_id`. The composite `(customer_id, product_id)` is also a natural candidate key (0 duplicates confirmed), making the design doubly sound.

> **Conclusion: Reviews is fully normalized to BCNF.**

---

### 8. Marketing Events

**File:** `marketing_events.csv`  
**Primary Key:** `event_id`  
**All Columns:** `event_id`, `customer_id`, `campaign_id`, `campaign_name`, `event_type`, `channel`, `event_timestamp`, `device_type`, `country`

#### Evidence from Data Analysis
```
Total campaign_ids                          : 100
Total campaign_names                        : 8
campaign_ids mapping to >1 campaign_name    : 100  (ALL of them!)
campaign_names mapping to >1 campaign_id    : 8    (ALL of them!)
```
Every `campaign_id` maps to all 8 campaign names and every `campaign_name` maps to all 100 campaign IDs. There is **zero functional dependency** between `campaign_id` and `campaign_name`.

#### 1NF — ✅ PASS
All values are atomic. `event_id` is unique.

#### 2NF — ✅ PASS
Single-column primary key.

#### 3NF — ❌ MAJOR VIOLATION

**Violation: `campaign_name` should be determined by `campaign_id` but is not in the data.**

The intended design is:
```
event_id → campaign_id → campaign_name
```
If `campaign_id` properly determines `campaign_name`, then `campaign_name` is transitively dependent and should be extracted into a `Campaign` dimension table. However, the data generator assigned `campaign_name` **randomly per event** rather than consistently per `campaign_id`. This is simultaneously:

1. A **normalization violation** (design) — `campaign_name` should live in a separate `Campaign` table
2. A **data quality problem** (implementation) — the data generator creates inconsistent campaign names

#### BCNF — ❌ VIOLATION
In the correct design, `campaign_id` should be a determinant of `campaign_name` but is not a candidate key of `marketing_event`.

---

## Transitive Dependency Chains

The following shows all identified transitive dependency chains across the schema:

```
CUSTOMER TABLE
  customer_id ──► city ──► country

ORDERS TABLE
  order_id ──► shipping_city ──► shipping_country
  order_id ──► customer_id ──► country ──► currency

PAYMENTS TABLE
  payment_id ──► order_id ──► customer_id ──► country ──► currency

PRODUCTS TABLE
  product_id ──► subcategory ──► category

SHIPPING TABLE
  shipment_id ──► shipping_city ──► shipping_country

MARKETING_EVENTS TABLE (intended design — broken in data)
  event_id ──► campaign_id ──► campaign_name
```

---

## Recommended New Dimension Tables

To resolve all identified 3NF/BCNF violations, the following dimension tables are recommended:

### `dim_location`
Resolves the `city → country` transitive dependency appearing in **Customer**, **Orders**, and **Shipping**.

| Column | Type | Description |
|--------|------|-------------|
| `location_id` | `INTEGER PK` | Surrogate key |
| `city` | `VARCHAR(100)` | City name |
| `country` | `VARCHAR(100)` | Country name |

**Tables to update:** Replace `country` + `city` columns in `customer`, `orders`, and `shipping` with a single `location_id` FK.  
**Data:** Only 10 unique city/country combinations exist across the entire dataset — a very small lookup table.

---

### `dim_category`
Resolves the `subcategory → category` transitive dependency in **Products**.

| Column | Type | Description |
|--------|------|-------------|
| `category_id` | `INTEGER PK` | Surrogate key |
| `subcategory` | `VARCHAR(100)` | Subcategory name |
| `category` | `VARCHAR(100)` | Parent category name |

**Tables to update:** Replace `category` + `subcategory` in `product` with a single `category_id` FK.  
**Data:** 25 unique subcategories across 5 categories.

---

### `dim_campaign`
Resolves the 3NF violation in **Marketing Events** and fixes the data generator inconsistency.

| Column | Type | Description |
|--------|------|-------------|
| `campaign_id` | `INTEGER PK` | Campaign identifier |
| `campaign_name` | `VARCHAR(200)` | Unique canonical campaign name |

**Tables to update:** Remove `campaign_name` from `marketing_event`, keep only `campaign_id` as FK.  
**Data:** 100 campaign IDs, 8 unique campaign names (1-to-1 mapping must be enforced).

---

## Architectural Guidance

### Where to Resolve These Violations in the Medallion Architecture

| Violation | Bronze Layer | Silver Layer | Gold Layer |
|-----------|:------------:|:------------:|:----------:|
| Preserve all raw columns as-is | ✅ | — | — |
| Fix `campaign_name` inconsistency | — | ✅ Standardize per campaign_id | ✅ Dim table |
| Drop redundant `currency` in orders/payments | — | ✅ Recommended | — |
| Extract `city → country` into dim | — | Optional | ✅ `dim_location` |
| Extract `subcategory → category` into dim | — | Optional | ✅ `dim_category` |
| Create `dim_campaign` | — | — | ✅ Required |

**Bronze Layer:** Preserve all raw data exactly as ingested — no normalization. The goal is complete fidelity to the source.

**Silver Layer:** The right place to standardize `campaign_name` (pick one canonical name per `campaign_id`). The redundant `currency` column can also be dropped here since it is fully derivable from the customer's country.

**Gold Layer (Star Schema):** The primary place to introduce `dim_location`, `dim_category`, and `dim_campaign`. The Star Schema already designed for this project (see `star_schema.svg`) should incorporate these dimension tables to deliver a clean, analytically optimized layer that is free from transitive dependencies.

> **Note:** All normalization violations identified are 3NF/BCNF — extremely common in raw operational schemas. None are critical blockers for the Bronze or Silver layers. They become important when designing the Gold/analytical layer.
