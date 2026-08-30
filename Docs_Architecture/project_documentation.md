# End-to-End E-Commerce Data Engineering Platform

## 1. Project Overview

### 1.1 Project Name

**End-to-End E-Commerce Data Engineering Platform**

### 1.2 Project Goal

The goal of this project is to build a complete end-to-end Data Engineering platform for an international e-commerce business.

The platform will begin with **messy data coming from multiple heterogeneous sources**, ingest and preserve the raw data, progressively transform the data through the **Medallion Architecture**, and then make the resulting data available through analytical warehouse models based on **Kimball and Inmon methodologies**.

The final analytical data will be exposed through a Business Intelligence tool such as **Microsoft Power BI**.

The project is designed to demonstrate the complete lifecycle of data:

```text
                         DATA SOURCES
                              │
                              ▼
                       DATA INGESTION
                              │
                              ▼
                       RAW DATA STORAGE
                         (MinIO)
                              │
                              ▼
                         BRONZE LAYER
                              │
                              ▼
                         SILVER LAYER
                              │
                              ▼
                           GOLD LAYER
                              │
                    ┌─────────┴─────────┐
                    │                   │
                    ▼                   ▼
                 KIMBALL              INMON
              Data Warehouse        Enterprise DW
                    │                   │
                    ▼                   ▼
              Star Schema           Data Marts
                    │                   │
                    └─────────┬─────────┘
                              ▼
                          POWER BI
```

The project will also include:

* Data quality validation
* Incremental processing
* Pipeline orchestration
* Logging and monitoring
* Data lineage
* Automated testing
* Containerization
* Performance considerations

---

# 2. Project Objectives

The project has the following objectives:

### Data Engineering Objectives

* Build a complete ETL/ELT pipeline.
* Ingest data from multiple source types.
* Handle intentionally dirty source data.
* Preserve raw source data.
* Transform data through multiple stages.
* Support incremental data processing.
* Validate data quality.
* Automate the pipeline.

### Data Architecture Objectives

* Implement a Data Lake using MinIO.
* Implement the Medallion Architecture.
* Implement a Kimball dimensional warehouse.
* Implement an Inmon normalized Enterprise Data Warehouse.
* Create analytical data marts.
* Compare the different architectural approaches.

### Business Intelligence Objectives

* Build analytical datasets.
* Connect the warehouse to Power BI.
* Create business dashboards.
* Provide useful KPIs and visualizations.

---

# 3. Business Scenario

The project simulates an international e-commerce company that sells products to customers in multiple countries.

The company has multiple operational systems generating data independently.

These systems contain information about:

* Customers
* Products
* Orders
* Order items
* Payments
* Shipping
* Reviews
* Marketing activities
* Currency exchange rates

The source systems do not necessarily follow the same structure or data-quality standards.

The Data Engineering platform will integrate these sources into a centralized analytical environment.

---

# 4. Business Questions

The analytical platform should allow the business to answer questions such as:

## 4.1 Sales

* What is the total revenue?
* What is the total number of orders?
* How does revenue change over time?
* Which countries generate the highest revenue?
* Which products generate the highest revenue?
* What is the average order value?
* What is the total profit?

## 4.2 Customers

* How many customers are registered?
* How many new customers are acquired?
* How many customers are returning customers?
* Which customers generate the most revenue?
* How much revenue is generated per customer?

## 4.3 Products

* Which products sell the most?
* Which products generate the highest revenue?
* Which products generate the highest profit?
* Which categories perform best?

## 4.4 Shipping

* How many orders are delayed?
* What is the average delivery time?
* Which countries have the highest shipping delays?
* Which shipping methods perform best?

## 4.5 Marketing

* Which campaigns generate the most activity?
* Which channels attract the most customers?
* How do marketing activities relate to sales?

## 4.6 Data Engineering

The platform should also provide engineering metrics:

* Number of records processed
* Number of records rejected
* Number of duplicate records
* Data-quality percentage
* Pipeline execution time
* Last successful execution
* Pipeline status

---

# 5. Source Systems

The project will use multiple data sources to simulate a realistic e-commerce environment.

The main entities are:

```text
Customer
Product
Order
Order Item
Payment
Shipping
Review
Marketing Event
Exchange Rate
```

## The original project documentation defines these entities as the core source-domain objects. The existing Bronze implementation also includes these entities and ingestion metadata such as `source_file`, `ingestion_timestamp`, `batch_id`, and `source_system`.

# 6. Source Data Design

## 6.1 Customer

Example attributes:

```text
customer_id
first_name
last_name
email
phone
gender
date_of_birth
country
city
registration_date
customer_status
```

---

## 6.2 Product

```text
product_id
product_name
category
subcategory
brand
cost
price
stock_quantity
```

---

## 6.3 Order

```text
order_id
customer_id
order_date
order_status
currency
shipping_country
shipping_city
```

---

## 6.4 Order Item

```text
order_id
product_id
quantity
unit_price
discount
cost_at_sale
```

An order can contain multiple products, therefore the relationship between orders and products is represented through the order-item entity.

---

## 6.5 Payment

```text
payment_id
order_id
payment_date
payment_method
amount
currency
payment_status
transaction_reference
```

---

## 6.6 Shipping

```text
shipment_id
order_id
shipping_date
estimated_delivery_date
delivery_date
shipping_country
shipping_city
shipping_method
shipping_status
shipping_cost
```

---

## 6.7 Review

```text
review_id
customer_id
product_id
rating
review_text
review_date
verified_purchase
review_status
```

---

## 6.8 Marketing Event

```text
event_id
customer_id
campaign_id
event_type
channel
event_timestamp
device_type
country
```

---

## 6.9 Exchange Rate

```text
requested_date
date
base
quote
rate
```

Exchange-rate data will allow transactions recorded in different currencies to be converted into a common reporting currency when required.

---

# 7. Intentionally Dirty Source Data

The source data should not be perfectly clean.

The purpose is to simulate the problems that Data Engineers encounter in real-world systems.

Examples include:

### Missing values

```text
email = NULL
city = NULL
price = NULL
```

### Duplicate records

The same customer, order, or payment may appear more than once.

### Invalid values

```text
quantity = -5
price = -100
rating = 8
```

### Invalid relationships

An order may reference a customer that does not exist.

### Inconsistent country names

```text
Egypt
egypt
EG
EGY
```

### Inconsistent text formatting

```text
Cairo
CAIRO
cairo
```

### Invalid dates

Examples include:

* Future registration dates
* Delivery dates before shipping dates
* Payment dates inconsistent with order dates

### Invalid email addresses

```text
omar@
user.com
abc
```

The purpose of introducing these problems is to provide realistic requirements for the Bronze, Silver, Gold, and data-quality processes.

---

# 8. Raw Data Storage

## 8.1 MinIO

MinIO will be used as the project's **object-storage system representing the Data Lake**.

Its primary purpose is to preserve the raw source data before transformation.

The conceptual structure can be:

```text
MinIO
│
└── ecommerce-data
    │
    └── raw/
        ├── customers/
        ├── products/
        ├── orders/
        ├── order_items/
        ├── payments/
        ├── shipping/
        ├── reviews/
        ├── marketing/
        └── exchange_rates/
```

The raw data should remain as close as possible to the original source representation.

### Important distinction

MinIO is **not** the Bronze/Silver/Gold architecture itself.

MinIO is the **storage technology**.

Bronze, Silver, and Gold are **logical data-processing layers**.

The project can use PostgreSQL schemas for these layers, while MinIO preserves the raw files.

---

# 9. Overall Data Architecture

The project's architecture is divided into several logical stages.

```text
SOURCE SYSTEMS
      │
      ▼
DATA INGESTION
      │
      ▼
RAW STORAGE
    MINIO
      │
      ▼
   BRONZE
      │
      ▼
   SILVER
      │
      ▼
    GOLD
      │
      ├──────────────────┐
      ▼                  ▼
   KIMBALL             INMON
      │                  │
      ▼                  ▼
STAR SCHEMA          NORMALIZED EDW
      │                  │
      ▼                  ▼
   POWER BI          DATA MARTS
                         │
                         ▼
                      POWER BI
```

The central Medallion flow is:

```text
Bronze → Silver → Gold
```

The warehouse methodologies are separate modeling approaches that use the refined data.

---

# 10. Medallion Architecture

The Medallion Architecture organizes data according to its degree of refinement.

```text
Bronze
   ↓
Silver
   ↓
Gold
```

Each layer has a different responsibility.

---

# 11. Bronze Layer

## 11.1 Purpose

The Bronze layer represents the first persistent representation of the ingested data.

It should preserve the source structure as much as practical while adding ingestion metadata required for traceability.

The project uses a PostgreSQL `bronze` schema containing tables such as:

```text
bronze.customer
bronze.product
bronze.orders
bronze.order_item
bronze.payment
bronze.shipping
bronze.review
bronze.marketing_event
bronze.exchange_rate
```

The existing Bronze design includes metadata such as:

```text
source_file
ingestion_timestamp
batch_id
source_system
```

which provides lineage and ingestion traceability.

## 11.2 Bronze Responsibilities

The Bronze layer should:

* Preserve ingested records.
* Maintain source information.
* Record ingestion timestamps.
* Record batch identifiers.
* Preserve source-system information.
* Avoid unnecessary business transformations.
* Provide a reliable input for downstream processing.

Bronze should **not** be treated as the final analytical layer.

---

# 12. Silver Layer

## 12.1 Purpose

The Silver layer contains cleaned, standardized, validated, and structurally improved data.

The transformation process can include:

```text
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

## 12.2 Silver Responsibilities

Examples include:

* Standardizing country codes.
* Standardizing text values.
* Correcting data types.
* Removing or handling duplicates.
* Validating dates.
* Validating numeric values.
* Validating relationships.
* Handling missing values.
* Separating invalid records when appropriate.

Invalid records should not simply disappear.

Where appropriate, they should be stored in a quarantine/rejected-record area so that the pipeline remains auditable.

---

# 13. Gold Layer

## 13.1 Purpose

The Gold layer contains **business-ready analytical data**.

Unlike Silver, which focuses primarily on data quality and consistency, Gold focuses on making the data useful for business analysis.

The Gold layer should be designed around the business questions.

Examples include:

```text
gold.daily_sales
gold.monthly_sales
gold.product_sales
gold.customer_sales
gold.country_sales
gold.shipping_performance
gold.marketing_performance
```

## 13.2 Example Gold Dataset

```text
gold.daily_sales

date
orders
customers
units_sold
revenue
cost
profit
average_order_value
```

The Gold layer therefore transforms cleaned operational data into datasets that directly support analytical requirements.

---

# 14. Gold Layer Design Principles

Gold datasets should:

* Be business-oriented.
* Contain meaningful metrics.
* Reduce unnecessary complexity for analytical users.
* Support reporting requirements.
* Use consistent business definitions.
* Avoid exposing unnecessary operational complexity.

The Gold layer is the **final stage of the Medallion data refinement process**.

It is not automatically the same thing as a Kimball warehouse.

---

# 15. Data Warehouse Layer

After the Medallion pipeline produces refined analytical data, the project will demonstrate two different warehouse methodologies:

```text
                    GOLD
                     │
             ┌───────┴───────┐
             │               │
             ▼               ▼
          KIMBALL          INMON
             │               │
             ▼               ▼
       Dimensional          EDW
       Warehouse
```

These approaches will be implemented and compared to demonstrate architectural understanding.

---

# 16. Kimball Methodology

## 16.1 Purpose

Kimball focuses on dimensional modeling for analytical workloads.

The warehouse will organize information into:

* Fact tables
* Dimension tables

The primary structure will be a Star Schema.

---

# 17. Kimball Star Schema

The primary sales model will use:

```text
                    dim_customer
                         │
                         │
dim_product ─────── fact_sales ─────── dim_date
                         │
                         │
                    dim_payment
```

---

# 18. Fact Sales

The fact table will represent the selected business grain.

### Proposed grain

> One row in `fact_sales` represents one product line within one customer order.

Possible columns:

```text
sales_key
order_id
customer_key
product_key
date_key
payment_key
quantity
unit_price
discount
revenue
cost
profit
```

The grain must be clearly documented because it determines what each row represents and prevents incorrect aggregation.

---

# 19. Customer Dimension

```text
dim_customer

customer_key
customer_id
first_name
last_name
email
country
city
registration_date
customer_status
```

`customer_key` will act as the warehouse surrogate key.

---

# 20. Product Dimension

```text
dim_product

product_key
product_id
product_name
category
subcategory
brand
```

---

# 21. Date Dimension

A dedicated date dimension should be created.

Example:

```text
dim_date

date_key
full_date
day
month
month_name
quarter
year
week
day_of_week
```

This allows Power BI and SQL queries to perform flexible time-based analysis.

---

# 22. Payment Dimension

```text
dim_payment

payment_key
payment_method
payment_status
```

Depending on the final warehouse design, additional payment attributes can be included.

---

# 23. Slowly Changing Dimensions

At least one Slowly Changing Dimension Type 2 implementation should be demonstrated.

Customer is the preferred example.

Suppose:

```text
Customer 100
Country = Egypt
```

Later the customer's country changes:

```text
Country = UAE
```

Instead of overwriting historical information, the warehouse keeps both versions:

```text
customer_key | customer_id | country | effective_date | expiration_date | is_current
-------------|-------------|---------|----------------|-----------------|-----------
1            | 100         | Egypt   | 2025-01-01     | 2026-06-01      | 0
2            | 100         | UAE     | 2026-06-01     | NULL            | 1
```

This allows historical analysis using the customer attributes that were valid at the time of the transaction.

---

# 24. Inmon Methodology

## 24.1 Purpose

The Inmon approach will demonstrate a centralized, normalized Enterprise Data Warehouse.

Unlike the Kimball model, the EDW will emphasize enterprise integration and normalization.

A simplified structure can contain:

```text
EDW
│
├── customer
├── customer_country
├── product
├── product_category
├── order
├── order_item
├── payment
├── shipping
└── review
```

The exact normalized structure should follow the relationships and business rules of the source domain.

---

# 25. Inmon Data Marts

The normalized EDW can then provide data to downstream subject-oriented data marts.

For example:

```text
                Enterprise Data Warehouse
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
         Sales Mart   Customer Mart  Product Mart
```

The data marts can then provide simplified analytical datasets for BI consumption.

---

# 26. Kimball vs. Inmon

The project should explicitly compare the two approaches.

| Area           | Kimball                      | Inmon                        |
| -------------- | ---------------------------- | ---------------------------- |
| Primary focus  | Analytics                    | Enterprise integration       |
| Core model     | Dimensional                  | Normalized                   |
| Main structure | Star schema                  | Normalized EDW               |
| Facts          | Central                      | Not necessarily central      |
| Dimensions     | Central concept              | Less central                 |
| Data marts     | Often dimensional and direct | Usually downstream from EDW  |
| BI usability   | High                         | Requires additional modeling |
| Main strength  | Business analytics           | Enterprise-wide integration  |

The project should not present one methodology as universally superior.

Instead, it should explain the trade-offs and appropriate use cases.

---

# 27. Relationship Between Medallion, Kimball, and Inmon

These concepts should not be treated as three competing names for the same thing.

They solve different architectural problems.

### Medallion

Defines **data refinement stages**:

```text
Bronze → Silver → Gold
```

### Kimball

Defines a **dimensional warehouse modeling approach**:

```text
Facts + Dimensions
```

### Inmon

Defines a **normalized Enterprise Data Warehouse approach**:

```text
Normalized EDW → Data Marts
```

Therefore, the project can use them together.

For example:

```text
Raw
 ↓
Bronze
 ↓
Silver
 ↓
Gold
 ↓
Kimball Warehouse
 ↓
Power BI
```

while also demonstrating:

```text
Gold / Refined Data
 ↓
Inmon EDW
 ↓
Data Marts
 ↓
Power BI
```

---

# 28. Data Warehouse Technology

PostgreSQL will be used as the relational database platform for the warehouse implementations.

The project can logically separate schemas such as:

```text
PostgreSQL
│
├── bronze
├── silver
├── gold
│
├── kimball
│
└── inmon
```

This makes the architectural boundaries clear while allowing all components to be demonstrated in a local development environment.

---

# 29. Data Ingestion

Python will be used to implement the initial ingestion processes.

The ingestion layer should:

1. Read source data.
2. Validate basic file/source availability.
3. Assign ingestion metadata.
4. Generate a batch identifier.
5. Load raw data into the appropriate storage.
6. Preserve source information.
7. Record execution information.

Conceptually:

```text
Source
  ↓
Python Ingestion
  ↓
MinIO Raw Storage
  ↓
PostgreSQL Bronze
```

---

# 30. Batch Processing

The initial implementation will use batch processing.

For example:

```text
Daily Batch
     ↓
Read new source data
     ↓
Ingest
     ↓
Transform
     ↓
Validate
     ↓
Load analytical structures
```

The batch identifier will allow individual executions to be traced.

---

# 31. Incremental Processing

The pipeline should support incremental processing rather than reprocessing all historical records during every execution.

A watermark or timestamp can be used.

Example:

```text
last_processed_timestamp
```

New records can then be identified using:

```sql
SELECT *
FROM orders
WHERE updated_at > last_processed_timestamp;
```

The exact implementation should depend on the available source attributes.

---

# 32. Data Quality Framework

Data quality is a central part of the project.

The pipeline should validate:

### Completeness

Required fields should not be NULL.

### Uniqueness

Primary identifiers should not contain unexpected duplicates.

### Validity

Values should fall within acceptable ranges.

Example:

```text
rating BETWEEN 1 AND 5
quantity > 0
price >= 0
```

### Referential Integrity

Relationships should be valid.

Example:

```text
order.customer_id
        ↓
customer.customer_id
```

### Consistency

Related fields should not contradict one another.

Example:

```text
delivery_date >= shipping_date
```

### Timeliness

Data should arrive within the expected processing window.

---

# 33. Rejected and Quarantined Data

Invalid records should be handled explicitly.

Conceptually:

```text
                Silver Transformation
                       │
              ┌────────┴────────┐
              │                 │
              ▼                 ▼
          Valid Data        Invalid Data
              │                 │
              ▼                 ▼
           Silver          Quarantine
```

The quarantine area should preserve enough information to investigate the failure.

---

# 34. Data Quality Metrics

The project should calculate metrics such as:

```text
Total records
Valid records
Rejected records
Duplicate records
NULL violations
Referential-integrity violations
Validation success rate
```

Example:

```text
Total records:        100,000
Valid records:         97,500
Rejected records:       2,500

Data Quality Rate:
97.5%
```

---

# 35. dbt

dbt will be used to organize and test SQL-based transformations.

A possible structure is:

```text
dbt/
│
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
│
├── tests/
├── macros/
└── dbt_project.yml
```

Example models:

```text
stg_orders
stg_customers
stg_products
```

Intermediate models:

```text
int_orders_clean
int_customer_history
```

Analytical models:

```text
fct_sales
dim_customer
dim_product
```

dbt tests should include:

```text
unique
not_null
relationships
accepted_values
```

The purpose is to provide structured transformations, testing, documentation, and lineage.

---

# 36. Airflow

Apache Airflow will orchestrate the complete pipeline.

The pipeline should eventually resemble:

```text
                         START
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
         Customers      Products       Orders
             │             │             │
             └─────────────┼─────────────┘
                           ▼
                      Bronze Load
                           │
                           ▼
                    Silver Transformation
                           │
                           ▼
                      Gold Creation
                           │
                 ┌─────────┴─────────┐
                 ▼                   ▼
             Kimball               Inmon
             Warehouse               EDW
                 │                   │
                 └─────────┬─────────┘
                           ▼
                     Data Quality
                           │
                           ▼
                          END
```

Airflow should handle:

* Scheduling
* Task dependencies
* Retries
* Failure handling
* Logging
* Pipeline monitoring

---

# 37. Pipeline Logging

Each pipeline execution should record information such as:

```text
run_id
pipeline_name
start_time
end_time
status
records_processed
records_rejected
```

This provides visibility into pipeline behavior.

---

# 38. Data Lineage

The project should document where data comes from and how it changes.

Example:

```text
orders.csv
    ↓
bronze.orders
    ↓
silver.orders
    ↓
gold.daily_sales
    ↓
kimball.fact_sales
    ↓
Power BI
```

This makes the transformation path understandable and auditable.

---

# 39. Power BI

Power BI will be used as the primary Business Intelligence and visualization tool.

The preferred analytical source for the main dashboard will be the **Kimball warehouse**, because the Star Schema is designed specifically for analytical querying.

The conceptual flow is:

```text
Kimball Warehouse
       ↓
    Power BI
       ↓
Dashboards & Reports
```

The Inmon implementation can also be exposed through its data marts where appropriate.

---

# 40. Power BI Dashboard

The dashboard should contain multiple analytical pages.

## Page 1 — Executive Overview

KPIs:

```text
Total Revenue
Total Orders
Total Customers
Total Profit
Average Order Value
```

Visualizations:

* Revenue over time
* Revenue by country
* Revenue by category

---

## Page 2 — Sales Analysis

Visualizations:

* Monthly revenue
* Top products
* Sales by country
* Units sold
* Profit by category

---

## Page 3 — Customer Analysis

Visualizations:

* Customer count
* New customers
* Returning customers
* Revenue per customer
* Top customers

---

## Page 4 — Operations

Visualizations:

* Shipping delays
* Average delivery time
* Shipping performance by country
* Shipping method performance

---

## Page 5 — Data Engineering

This page demonstrates the health of the pipeline.

Metrics:

```text
Pipeline Status
Records Processed
Records Rejected
Data Quality %
Last Successful Run
Pipeline Duration
```

---

# 41. Docker

Docker will be used to simplify the local project environment.

Possible services include:

```text
PostgreSQL
MinIO
Airflow
dbt
```

Additional services should only be introduced when they provide a clear purpose.

The infrastructure should be reproducible through:

```text
docker-compose.yml
```

---

# 42. Apache Spark

Spark is an optional advanced component.

It should not be introduced merely because it is a popular Data Engineering technology.

The project should demonstrate the reason for using Spark.

For example:

```text
Small dataset
     ↓
Python / Pandas
```

versus:

```text
Very large dataset
     ↓
Apache Spark
```

The project can demonstrate:

* Distributed processing
* Spark SQL
* PySpark transformations
* Parquet
* Partitioning

---

# 43. Performance Optimization

Performance should be considered at multiple levels.

## Storage

Compare:

```text
CSV
vs
Parquet
```

Consider:

* Compression
* Partitioning
* File sizes

## PostgreSQL

Consider:

* Indexes
* Query plans
* Join strategies
* Aggregations

## Pipeline

Consider:

* Incremental processing
* Parallel execution
* Batch sizes

## Spark

Consider:

* Partitioning
* Shuffle
* Broadcast joins
* Caching

Performance improvements should be measured rather than simply claimed.

---

# 44. Testing Strategy

Testing will occur at multiple levels.

## Unit Tests

Test individual Python functions.

## Data Tests

Validate:

```text
Unique IDs
Required fields
Foreign keys
Valid values
Valid dates
```

## Transformation Tests

Verify:

```text
Bronze → Silver
Silver → Gold
```

## Warehouse Tests

Verify:

```text
Fact relationships
Dimension relationships
Surrogate keys
Historical records
```

## Integration Tests

Verify that the major components work together.

---

# 45. Repository Structure

The final repository should be organized professionally.

```text
ecommerce-data-platform/
│
├── README.md
│
├── docs/
│   ├── architecture.md
│   ├── business_requirements.md
│   ├── data_dictionary.md
│   ├── medallion.md
│   ├── kimball.md
│   ├── inmon.md
│   └── data_quality.md
│
├── data_generator/
│
├── ingestion/
│
├── sql/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   ├── kimball/
│   └── inmon/
│
├── dbt/
│   ├── models/
│   ├── tests/
│   └── macros/
│
├── airflow/
│   └── dags/
│
├── powerbi/
│
├── tests/
│
├── docker/
│
├── scripts/
│
├── config/
│
└── docker-compose.yml
```

---

# 46. End-to-End Pipeline

The complete pipeline should ultimately represent:

```text
                         SOURCE SYSTEMS
                              │
             ┌────────────────┼────────────────┐
             │                │                │
            CSV              JSON             API
             │                │                │
             └────────────────┼────────────────┘
                              ▼
                       PYTHON INGESTION
                              │
                              ▼
                    ┌──────────────────┐
                    │      MINIO       │
                    │   RAW STORAGE    │
                    └────────┬─────────┘
                             │
                             ▼
                         BRONZE
                    PostgreSQL schema
                             │
                             ▼
                         SILVER
                    PostgreSQL schema
                             │
                             ▼
                          GOLD
                    PostgreSQL schema
                             │
                 ┌───────────┴───────────┐
                 │                       │
                 ▼                       ▼
              KIMBALL                  INMON
          Dimensional DW             Normalized EDW
                 │                       │
                 ▼                       ▼
             Star Schema             Data Marts
                 │                       │
                 └───────────┬───────────┘
                             ▼
                          POWER BI
```

---

# 47. Where Each Technology Fits

| Technology | Purpose                            |
| ---------- | ---------------------------------- |
| Python     | Data generation and ingestion      |
| MinIO      | Raw/object storage                 |
| PostgreSQL | Relational database and warehouse  |
| Bronze     | First persistent data layer        |
| Silver     | Cleaned and validated data         |
| Gold       | Business-ready analytical data     |
| Kimball    | Dimensional warehouse methodology  |
| Inmon      | Normalized EDW methodology         |
| dbt        | SQL transformation and testing     |
| Airflow    | Pipeline orchestration             |
| Docker     | Environment/container management   |
| Spark      | Large-scale distributed processing |
| Power BI   | Business Intelligence              |
| Git        | Version control                    |

---

# 48. Recommended Implementation Sequence

The project should be developed progressively.

## Phase 1 — Business Requirements

Define:

* Business scenario
* Business questions
* KPIs
* Entities
* Relationships

---

## Phase 2 — Source Data

Define:

* Source systems
* File/API formats
* Schemas
* Data types
* Relationships
* Expected data-quality problems

---

## Phase 3 — Data Generation

Generate realistic data and intentionally introduce data-quality issues.

---

## Phase 4 — Ingestion

Implement Python ingestion.

Load source data into raw storage and the Bronze layer.

---

## Phase 5 — Bronze

Create the Bronze schema and ingestion metadata.

---

## Phase 6 — Silver

Implement cleaning, standardization, validation, deduplication, and quarantine handling.

---

## Phase 7 — Gold

Create business-ready analytical datasets based on the defined business questions.

---

## Phase 8 — Kimball

Design:

```text
Fact tables
+
Dimension tables
+
Surrogate keys
+
Date dimension
+
SCD Type 2
```

---

## Phase 9 — Inmon

Design:

```text
Normalized EDW
       ↓
Data Marts
```

---

## Phase 10 — Architecture Comparison

Compare:

```text
Medallion
Kimball
Inmon
```

Explain their purposes, strengths, weaknesses, and appropriate use cases.

---

## Phase 11 — dbt

Introduce structured SQL transformations, tests, documentation, and lineage.

---

## Phase 12 — Airflow

Automate the complete workflow.

---

## Phase 13 — Incremental Processing

Implement processing of new/changed records without reprocessing the entire historical dataset.

---

## Phase 14 — Data Quality Framework

Create automated validation and quality reporting.

---

## Phase 15 — Power BI

Build the analytical dashboards.

---

## Phase 16 — Docker

Containerize the required infrastructure.

---

## Phase 17 — Testing

Perform:

* Unit testing
* Data testing
* Integration testing
* Pipeline testing

---

## Phase 18 — Performance

Investigate:

* Query optimization
* Indexing
* Parquet
* Partitioning
* Incremental processing

---

## Phase 19 — Final Documentation

Document:

* Architecture
* Data sources
* Data dictionary
* Data quality
* Medallion
* Kimball
* Inmon
* Pipeline
* Airflow
* dbt
* Power BI
* Testing
* Performance
* Setup instructions

---

# 49. Minimum Viable Pipeline

Before implementing every advanced feature, the core pipeline should work end-to-end:

```text
Source
  ↓
Python
  ↓
MinIO
  ↓
Bronze
  ↓
Silver
  ↓
Gold
  ↓
Kimball Warehouse
  ↓
Power BI
```

Once this pipeline works, additional capabilities can be added without destroying the core architecture.

---

# 50. Final Project Outcome

The completed project should demonstrate that a Data Engineer can take intentionally messy, heterogeneous e-commerce source data and build a reliable analytical platform from it.

The final system should demonstrate:

```text
                    MESSY DATA
                        │
                        ▼
                   INGESTION
                        │
                        ▼
                  RAW STORAGE
                     MINIO
                        │
                        ▼
                     BRONZE
                        │
                        ▼
                     SILVER
                        │
                        ▼
                      GOLD
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
           KIMBALL              INMON
              │                   │
              ▼                   ▼
        STAR SCHEMA            EDW
              │                   │
              │                DATA MARTS
              │                   │
              └─────────┬─────────┘
                        ▼
                    POWER BI
```

The project should therefore demonstrate not only the ability to build pipelines, but also the ability to understand **why each architectural component exists and what problem it solves**.

The final portfolio statement should be:

> **I built an end-to-end E-commerce Data Engineering platform that ingests intentionally messy multi-source data, preserves raw data in object storage, progressively transforms it through a Medallion architecture, implements both Kimball dimensional modeling and an Inmon Enterprise Data Warehouse, automates the pipeline with orchestration and data-quality validation, and exposes the resulting analytical data through Power BI.**

---

# 51. Key Architectural Principles

The following principles should guide the implementation:

### Principle 1 — Preserve Raw Data

Raw source data should be preserved so that the pipeline can be reproduced and investigated.

### Principle 2 — Separate Data Processing Stages

Bronze, Silver, and Gold should have clearly defined responsibilities.

### Principle 3 — Do Not Confuse Medallion With Data Warehouse Modeling

Medallion describes **progressive data refinement**.

Kimball and Inmon describe **warehouse modeling approaches**.

### Principle 4 — Business Requirements Drive Gold and Warehouse Design

The business questions should determine which metrics, facts, dimensions, and marts are required.

### Principle 5 — Data Quality Is Part of the Pipeline

Validation should occur as part of data processing rather than being treated as an afterthought.

### Principle 6 — Automate After the Pipeline Works

First build a reliable pipeline manually, then introduce orchestration.

### Principle 7 — Every Technology Must Have a Purpose

A technology should be included because it solves a specific engineering problem, not simply because it is popular.

---

# 52. Final Architecture Summary

The project's architecture can be summarized in four major sections:

### Data Lake / Medallion

```text
MinIO
  ↓
Bronze
  ↓
Silver
  ↓
Gold
```

### Kimball

```text
Gold / Refined Data
       ↓
Dimensional Warehouse
       ↓
Fact + Dimensions
       ↓
Power BI
```

### Inmon

```text
Refined Data
     ↓
Normalized EDW
     ↓
Data Marts
     ↓
Power BI
```

### Orchestration and Quality

```text
             Airflow
                │
                ▼
      ┌───────────────────┐
      │ Complete Pipeline │
      └─────────┬─────────┘
                │
                ▼
        Data Quality Tests
                │
                ▼
         Logging / Monitoring
```

Together, these components form a complete Data Engineering platform rather than a collection of unrelated technologies.





# Project Architecture — High-Level Overview

The project is designed as an end-to-end E-commerce Data Engineering platform. It takes raw, heterogeneous source data and progressively transforms it into reliable, business-ready analytical data, which is then modeled for data warehousing and consumed through Business Intelligence tools.

## Overall Architecture

```text
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA SOURCES                                │
│                                                                     │
│   CSV Files        JSON Files        APIs        Other Sources      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         INGESTION                                   │
│                                                                     │
│                         Python                                     │
│                                                                     │
│  • Extract data                                                    │
│  • Generate ingestion metadata                                     │
│  • Track batches                                                   │
│  • Handle source-specific ingestion                                │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      RAW DATA STORAGE                               │
│                                                                     │
│                            MinIO                                    │
│                                                                     │
│  Preserves the original source data before transformation           │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
╔═════════════════════════════════════════════════════════════════════╗
║                     MEDALLION ARCHITECTURE                         ║
╠═════════════════════════════════════════════════════════════════════╣
║                                                                     ║
║   ┌──────────────┐       ┌──────────────┐       ┌──────────────┐   ║
║   │    BRONZE    │ ───▶  │    SILVER    │ ───▶  │     GOLD     │   ║
║   │              │       │              │       │              │   ║
║   │ Raw /        │       │ Cleaned /    │       │ Business-    │   ║
║   │ minimally    │       │ validated /  │       │ ready /      │   ║
║   │ transformed  │       │ standardized │       │ analytical   │   ║
║   └──────────────┘       └──────────────┘       └───────┬──────┘   ║
║                                                         │          ║
╚═════════════════════════════════════════════════════════╪══════════╝
                                                          │
                              ┌───────────────────────────┴────────────┐
                              │                                        │
                              ▼                                        ▼
                 ┌────────────────────────┐             ┌────────────────────────┐
                 │        KIMBALL         │             │         INMON          │
                 │   Dimensional Model    │             │    Enterprise DW      │
                 │                        │             │                        │
                 │   Fact Tables          │             │   Normalized EDW       │
                 │   Dimensions           │             │          ↓             │
                 │   Star Schema          │             │     Data Marts         │
                 │   SCD Type 2           │             │                        │
                 └────────────┬───────────┘             └────────────┬───────────┘
                              │                                      │
                              └──────────────────┬───────────────────┘
                                                 │
                                                 ▼
                              ┌──────────────────────────────────────┐
                              │          BUSINESS INTELLIGENCE       │
                              │                                      │
                              │              Power BI                 │
                              │                                      │
                              │  • Sales Dashboard                   │
                              │  • Customer Analytics                │
                              │  • Product Analytics                 │
                              │  • Operations / Shipping             │
                              │  • Data Quality / Pipeline KPIs      │
                              └──────────────────────────────────────┘


       ┌─────────────────────────────────────────────────────────┐
       │                  SUPPORTING COMPONENTS                   │
       │                                                         │
       │  Airflow       → Pipeline orchestration                 │
       │  dbt           → SQL transformations & testing          │
       │  PostgreSQL    → Relational storage / warehouse         │
       │  Docker        → Containerized environment              │
       │  Git           → Version control                         │
       │  Data Quality  → Validation, monitoring & quarantine     │
       │  Spark         → Optional distributed processing         │
       └─────────────────────────────────────────────────────────┘
```

## Architecture Flow

The complete data journey can be summarized as:

```text
SOURCE
  │
  ▼
PYTHON INGESTION
  │
  ▼
MINIO
Raw Data Storage
  │
  ▼
BRONZE
Raw / minimally transformed
  │
  ▼
SILVER
Cleaned / validated / standardized
  │
  ▼
GOLD
Business-ready analytical data
  │
  ├─────────────────────────┐
  ▼                         ▼
KIMBALL                    INMON
Star Schema                Normalized EDW
  │                         │
  │                         ▼
  │                      Data Marts
  │                         │
  └────────────┬────────────┘
               ▼
            POWER BI
               │
               ▼
        Business Insights
```

## Role of Each Major Component

| Component          | Main Responsibility                                                    |
| ------------------ | ---------------------------------------------------------------------- |
| **Source Systems** | Provide heterogeneous and potentially dirty data                       |
| **Python**         | Extract and ingest source data                                         |
| **MinIO**          | Preserve raw source data in object storage                             |
| **Bronze**         | Store the first persistent representation of ingested data             |
| **Silver**         | Clean, validate, standardize, and integrate data                       |
| **Gold**           | Produce business-ready analytical datasets                             |
| **Kimball**        | Model analytical data using facts, dimensions, and star schemas        |
| **Inmon**          | Build a normalized Enterprise Data Warehouse and downstream data marts |
| **PostgreSQL**     | Provide relational database and warehouse storage                      |
| **dbt**            | Manage SQL transformations, tests, documentation, and lineage          |
| **Airflow**        | Orchestrate and schedule the data pipeline                             |
| **Data Quality**   | Detect, measure, quarantine, and report data-quality problems          |
| **Docker**         | Provide a reproducible development environment                         |
| **Spark**          | Provide optional distributed processing for large-scale workloads      |
| **Power BI**       | Provide dashboards, reports, KPIs, and business analysis               |
| **Git**            | Manage source code and project versioning                              |

## Architectural Concepts

It is important to distinguish the three major architectural concepts used in the project.

### 1. Medallion Architecture

The Medallion Architecture describes **how data becomes progressively refined**:

```text
Bronze → Silver → Gold
```

### 2. Kimball

Kimball describes **how analytical warehouse data is modeled**:

```text
Fact Tables + Dimension Tables
             ↓
         Star Schema
```

### 3. Inmon

Inmon describes **how an enterprise data warehouse can be organized around normalized enterprise data**:

```text
Normalized EDW
      ↓
 Data Marts
```

Therefore, these are not three competing layers of the same pipeline. They address different architectural concerns and can be demonstrated together within the same project.

## Final Architecture Principle

The project follows the principle:

> **Store raw data first, progressively improve its quality through the Medallion layers, then model the refined data for analytical consumption using established warehouse methodologies, and finally expose the analytical results through Business Intelligence.**
