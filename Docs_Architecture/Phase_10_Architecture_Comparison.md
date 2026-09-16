# Phase 10 --- Medallion, Kimball, and Inmon Architecture Comparison

## 1. Purpose

This document records the comparison between the three architectural
approaches used in the E-Commerce Data Engineering Platform:

-   Medallion Architecture
-   Kimball Dimensional Modeling
-   Inmon Enterprise Data Warehouse

The project uses these approaches together because they solve different
architectural problems.

------------------------------------------------------------------------

## 2. Project Architecture

``` text
Source Systems
      │
      ▼
Data Ingestion
      │
      ▼
Raw Storage
   (MinIO)
      │
      ▼
   Bronze
      │
      ▼
   Silver
      │
      ▼
    Gold
      │
      ├──────────────────────┐
      ▼                      ▼
   Kimball                 Inmon
      │                      │
      ▼                      ▼
 Star Schema          Normalized EDW
      │                      │
      ▼                      ▼
  Power BI             Data Marts
                             │
                             ▼
                         Power BI
```

The project documentation defines Medallion as the data-refinement
architecture, Kimball as a dimensional warehouse approach, and Inmon as
a normalized Enterprise Data Warehouse followed by downstream Data
Marts.

------------------------------------------------------------------------

# 3. Medallion Architecture

## 3.1 Purpose

Medallion organizes data according to its degree of refinement.

``` text
Bronze
   ↓
Silver
   ↓
Gold
```

### Bronze

Bronze is the first persistent representation of ingested data. It
preserves source information and ingestion metadata and provides a
reliable input for downstream processing.

### Silver

Silver contains cleaned, standardized, validated, and structurally
improved data.

Typical processing:

``` text
Bronze
  ↓
Data type correction
  ↓
Deduplication
  ↓
Standardization
  ↓
Validation
  ↓
Relationship checks
  ↓
Silver
```

### Gold

Gold contains business-ready analytical datasets such as:

``` text
gold.daily_sales
gold.monthly_sales
gold.product_sales
gold.customer_sales
gold.country_sales
gold.shipping_performance
gold.marketing_performance
```

Gold focuses on business-oriented metrics and analytical usability.

## 3.2 What Medallion solves

Medallion primarily answers:

> How should data become progressively cleaner, more reliable, and more
> business-ready?

It is a **data refinement architecture**, not a dimensional or
normalized warehouse methodology.

------------------------------------------------------------------------

# 4. Kimball Methodology

## 4.1 Purpose

Kimball focuses on dimensional modeling for analytical workloads.

The central concepts are:

``` text
Fact Tables
     +
Dimension Tables
     ↓
Star Schema
```

The project's primary Kimball model is:

``` text
                    dim_customer
                         │
                         │
dim_product ─────── fact_sales ─────── dim_date
                         │
                         │
                    dim_payment
```

## 4.2 Fact Sales

The grain of `kimball.fact_sales` is:

> One row represents one product line within one customer order.

The fact contains measures such as:

``` text
quantity
unit_price
discount
revenue
cost
profit
```

## 4.3 Dimensions

The implemented Kimball warehouse contains:

``` text
kimball.dim_date
kimball.dim_customer
kimball.dim_product
kimball.dim_payment
kimball.fact_sales
```

The Customer dimension implements SCD Type 2 so historical customer
attributes can be preserved when they change.

## 4.4 What Kimball solves

Kimball primarily answers:

> How should data be structured so that analytical queries and BI
> reporting are straightforward?

It emphasizes dimensional structures, facts, dimensions, and analytical
usability.

------------------------------------------------------------------------

# 5. Inmon Methodology

## 5.1 Purpose

Inmon emphasizes a centralized, normalized Enterprise Data Warehouse.

The project's Inmon implementation uses:

``` text
inmon_layer
```

The EDW contains normalized entities including:

``` text
country
city
category
subcategory
customer
product
orders
order_item
payment
shipping
review
marketing_event
exchange_rate
```

## 5.2 Data Marts

The normalized EDW feeds downstream subject-oriented Data Marts:

``` text
                 Inmon EDW
                     │
          ┌──────────┼──────────┐
          │          │          │
          ▼          ▼          ▼
     Sales Mart  Customer Mart Product Mart
```

The implemented marts are:

``` text
inmon_mart.sales_mart
inmon_mart.customer_mart
inmon_mart.product_mart
```

### Sales Mart

Grain:

> One row per product line within an order.

It provides sales-oriented attributes and EGP-standardized financial
metrics.

### Customer Mart

Grain:

> One row per customer.

It provides customer attributes and aggregated customer purchasing
metrics.

### Product Mart

Grain:

> One row per product.

It provides product attributes and aggregated product sales performance.

## 5.3 What Inmon solves

Inmon primarily answers:

> How should enterprise data be integrated and maintained in a
> normalized central warehouse before being exposed to analytical
> consumers?

------------------------------------------------------------------------

# 6. Direct Comparison

  -----------------------------------------------------------------------
  Area              Medallion         Kimball           Inmon
  ----------------- ----------------- ----------------- -----------------
  Primary purpose   Data refinement   Analytical        Enterprise
                                      modeling          integration

  Core structure    Bronze → Silver → Facts +           Normalized EDW
                    Gold              Dimensions        

  Main model        Layered data      Dimensional /     Normalized
                    stages            Star Schema       relational model

  Main concern      Data quality and  BI and analytical Enterprise-wide
                    refinement        usability         consistency

  Central concept   Refinement layer  Fact and          Normalized
                                      dimension         entities

  Data marts        Not the defining  Often used as     Downstream from
                    concept           dimensional       EDW
                                      analytical        
                                      structures        

  Historical        Not the defining  SCD Type 2 can be Depends on EDW
  dimension         concept           used              design
  handling                                              

  Project           `bronze`,         `kimball`         `inmon_layer` +
  implementation    `silver`, `gold`                    `inmon_mart`

  BI path           Gold can support  Star schema → BI  EDW → Data Marts
                    analytics                           → BI
  -----------------------------------------------------------------------

The project documentation states that the comparison should explain
trade-offs and appropriate use cases rather than present one methodology
as universally superior.

------------------------------------------------------------------------

# 7. How They Work Together

These architectures operate at different levels.

## Medallion = Refinement

``` text
Raw
 ↓
Bronze
 ↓
Silver
 ↓
Gold
```

This answers:

> What stage of refinement is the data in?

## Kimball = Dimensional Modeling

``` text
Refined Data
     ↓
Kimball
     ↓
Facts + Dimensions
     ↓
Power BI
```

This answers:

> How should the refined data be modeled for analytics?

## Inmon = Enterprise Integration

``` text
Refined Data
     ↓
Normalized EDW
     ↓
Data Marts
     ↓
Power BI
```

This answers:

> How should enterprise data be integrated and normalized before
> analytical consumption?

------------------------------------------------------------------------

# 8. Why the Project Uses All Three

The approaches are complementary rather than mutually exclusive.

``` text
                    DATA
                     │
                     ▼
               MEDALLION
          Bronze → Silver → Gold
                     │
             ┌───────┴───────┐
             │               │
             ▼               ▼
          KIMBALL          INMON
             │               │
             ▼               ▼
        Star Schema      Normalized EDW
             │               │
             │               ▼
             │          Data Marts
             │               │
             └───────┬───────┘
                     ▼
                  Power BI
```

Each approach contributes something different:

-   **Medallion** provides progressive data refinement.
-   **Kimball** provides a dimensional model for analytical use.
-   **Inmon** provides a normalized enterprise data model and downstream
    subject-oriented marts.

------------------------------------------------------------------------

# 9. Implemented Project Components

## Medallion

``` text
MinIO / Raw
     ↓
Bronze
     ↓
Silver
     ↓
Gold
```

## Kimball

``` text
kimball.dim_date
kimball.dim_customer
kimball.dim_product
kimball.dim_payment
kimball.fact_sales
```

## Inmon

``` text
inmon_layer
    ↓
inmon_mart.sales_mart
inmon_mart.customer_mart
inmon_mart.product_mart
```

------------------------------------------------------------------------

# 10. Validation Status

## Kimball

Validated areas include:

-   Fact table grain
-   Dimension relationships
-   Surrogate keys
-   Date dimension
-   Customer SCD Type 2
-   Foreign-key integrity
-   Financial calculations
-   Currency conversion
-   Fact completeness

## Inmon

Validated areas include:

-   Normalized EDW table coverage
-   Primary keys
-   Foreign keys
-   Check constraints
-   Entity relationships
-   Row counts
-   Exchange-rate data
-   Data Mart construction

## Inmon Data Marts

### Sales Mart

Validated:

-   146,993 order-line rows
-   Correct `(order_id, product_id)` grain
-   Currency preservation
-   EGP conversion
-   Revenue, cost, and profit calculations
-   Cancelled-order treatment
-   Cross-mart financial consistency

### Customer Mart

Validated:

-   10,000 customers
-   76 customers without orders retained
-   49,498 orders represented
-   146,993 order-item rows represented
-   803,941 total quantity represented
-   Financial totals match Sales Mart

### Product Mart

Validated:

-   2,000 products
-   All products have sales
-   146,993 order-item rows represented
-   803,941 total quantity represented
-   Category/subcategory relationships
-   Financial totals match Sales Mart
-   Sales date ranges

------------------------------------------------------------------------

# 11. Final Architectural Interpretation

``` text
┌──────────────────────────────────────────────┐
│              MEDALLION ARCHITECTURE          │
│                                              │
│       Bronze → Silver → Gold                 │
│          Data refinement                     │
└──────────────────────┬───────────────────────┘
                       │
             ┌─────────┴─────────┐
             │                   │
             ▼                   ▼
┌─────────────────────┐ ┌─────────────────────┐
│       KIMBALL       │ │        INMON        │
│                     │ │                     │
│ Star Schema         │ │ Normalized EDW      │
│                     │ │         ↓           │
│ Fact + Dimensions   │ │    Data Marts       │
└──────────┬──────────┘ └──────────┬──────────┘
           │                       │
           └───────────┬───────────┘
                       ▼
                   POWER BI
```

The key conclusion is:

> **Medallion defines how data is refined; Kimball defines a dimensional
> analytical model; Inmon defines a normalized enterprise warehouse with
> downstream Data Marts.**

These concepts operate at different architectural levels and can
therefore coexist within the same E-Commerce Data Engineering Platform.

------------------------------------------------------------------------

# 12. Phase 10 Completion

**Phase 10 --- Architecture Comparison: COMPLETE**

The project now has implemented examples of:

-   Medallion Architecture
-   Kimball Dimensional Warehouse
-   Inmon Normalized EDW
-   Inmon Sales Mart
-   Inmon Customer Mart
-   Inmon Product Mart

The next phase in the project plan is **Phase 11 --- dbt**.
