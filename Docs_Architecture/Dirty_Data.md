
````markdown
# E-Commerce Data Lakehouse
# Dirty Data Design

## 1. Overview

### 1.1 Purpose

This document defines the dirty-data strategy for the e-commerce source
systems used in the data lakehouse project.

The purpose is to intentionally introduce realistic data-quality problems
into the generated source data so that the data engineering pipeline can
demonstrate data profiling, validation, cleansing, transformation,
quarantine, and monitoring.

The dirty-data design is based on the data-quality expectations defined in
the `Data_Dictionary.md`.

The generator will produce both valid and intentionally corrupted records.

---

### 1.2 Objectives

The dirty-data design has the following objectives:

1. Simulate realistic operational source-system data.
2. Introduce controlled data-quality problems.
3. Test the Bronze-to-Silver data-quality and cleansing processes.
4. Test referential-integrity validation.
5. Test schema and data-type validation.
6. Test business-rule validation.
7. Demonstrate handling of duplicate records.
8. Demonstrate handling of missing values.
9. Demonstrate standardization of inconsistent formats.
10. Produce measurable data-quality metrics.
11. Preserve the original dirty records in the Bronze layer.
12. Ensure that the Silver layer contains trusted and validated data.

---

### 1.3 Dirty Data Philosophy

The source systems are not assumed to produce perfectly clean data.

The project intentionally follows the principle:

> Raw data should represent realistic source-system conditions, while
> downstream layers are responsible for validating and improving data
> quality.

The generated data therefore contains:

- Valid records
- Missing values
- Duplicate records
- Invalid values
- Invalid foreign keys
- Invalid data types
- Inconsistent formats
- Business-rule violations

The dirty data should be controlled and configurable rather than randomly
corrupting every record.

The majority of generated records should remain valid so that the dataset
still represents a realistic operational system.

---

# 2. Data Quality Issue Categories

## 2.1 Missing Values

Missing values occur when an attribute contains `NULL`, an empty value, or
when the source system does not provide a value.

Missing values will primarily be introduced into attributes that are defined
as nullable in the data dictionary.

Examples:

```text
Customer.phone = NULL
Customer.gender = NULL
Customer.date_of_birth = NULL
Review.review_text = NULL
Shipping.delivery_date = NULL
````

Some missing values may also be introduced into mandatory attributes to
simulate source-system errors.

### Injection Strategy

* Introduce NULL values into selected nullable attributes.
* Introduce a smaller percentage of unexpected NULL values into mandatory
  attributes.
* Preserve the original NULL values in the Bronze layer.
* Validate missing values before loading trusted Silver data.

---

## 2.2 Duplicate Records

Duplicate records occur when the same logical record appears more than
once in the source data.

Duplicates will be generated using the appropriate primary key or business
key.

Examples:

```text
Customer:
customer_id = 1001 appears more than once

Product:
product_id = 101 appears more than once

Order:
order_id = 5001 appears more than once
```

For `Order_Item`, duplicates will be generated based on the composite key:

```text
(order_id, product_id)
```

For `Review`, duplicate business relationships may be generated using:

```text
(customer_id, product_id)
```

### Injection Strategy

* Duplicate a small percentage of existing records.
* Preserve duplicates in the Bronze layer.
* Detect duplicates during data-quality validation.
* Remove or quarantine duplicates during Silver processing according to the
  defined deduplication strategy.

---

## 2.3 Invalid Values

Invalid values are values that do not satisfy the allowed ranges or domain
rules defined in the data dictionary.

Examples include:

```text
Product.price = -50
Product.stock_quantity = -10
Order_Item.quantity = -5
Order_Item.unit_price = -20
Review.rating = 8
```

Invalid categorical values may include:

```text
Order.order_status = "UnknownStatus"
Payment.payment_status = "InvalidStatus"
Shipping.shipping_status = "UnknownStatus"
```

### Injection Strategy

* Select attributes with numerical or categorical restrictions.
* Generate values outside the allowed range.
* Generate values outside predefined categorical domains.
* Preserve invalid values in Bronze.
* Detect and handle them during validation.

---

## 2.4 Invalid Foreign Keys

Invalid foreign keys occur when a foreign-key value does not reference an
existing record in the corresponding parent entity.

Examples:

```text
Order.customer_id = 999999
```

when `999999` does not exist in `Customer.customer_id`.

Other examples include:

```text
Order_Item.order_id = 999999
Order_Item.product_id = 999999
Payment.order_id = 999999
Shipping.order_id = 999999
Review.customer_id = 999999
Review.product_id = 999999
Marketing_Event.customer_id = 999999
```

### Injection Strategy

Invalid foreign keys should be generated by replacing valid foreign-key
values with IDs that do not exist in the parent dataset.

The generator must ensure that these invalid IDs are outside the generated
parent-key space.

For example:

```text
Valid Customer IDs:
1001
1002
1003

Invalid Customer ID:
999999
```

Invalid foreign keys should be detected through referential-integrity
checks.

---

## 2.5 Invalid Data Types

Invalid data types occur when a source value cannot be interpreted as the
expected data type.

Examples:

```text
Customer.customer_id = "ABC123"

Product.price = "fifty dollars"

Order_Item.quantity = "five"

Review.rating = "excellent"

Payment.payment_date = "yesterday"
```

### Injection Strategy

Selected records will contain values that cannot be safely converted to
their expected data type.

Examples:

```text
INTEGER → "five"
DECIMAL → "100 USD"
DATE → "not-a-date"
TIMESTAMP → "invalid-timestamp"
```

The original value must be preserved in the Bronze layer.

Records that cannot be safely converted should be flagged or quarantined
during Silver processing.

---

## 2.6 Inconsistent Formats

Inconsistent formats occur when equivalent information is represented using
different formats.

Examples:

### Country

```text
Egypt
egypt
EG
EGY
```

### City

```text
Cairo
cairo
CAIRO
```

### Phone

```text
01012345678
+201012345678
010-123-45678
```

### Date

```text
2026-01-15
15/01/2026
01-15-2026
15-Jan-2026
```

### Status

```text
Shipped
shipped
SHIPPED
```

### Injection Strategy

The generator should create equivalent values using different
representations.

The Bronze layer should preserve these original representations.

The Silver layer should standardize them into the project's canonical
format.

---

## 2.7 Business Rule Violations

Business-rule violations occur when a record satisfies basic schema and
data-type requirements but violates the logical rules of the e-commerce
business.

Examples include:

```text
Customer.registration_date > current_date
```

```text
Order.order_date < Customer.registration_date
```

```text
Payment.payment_date < Order.order_date
```

```text
Shipping.delivery_date < Shipping.shipping_date
```

```text
Review.review_date < Customer.registration_date
```

```text
Review.rating < 1 OR Review.rating > 5
```

### Injection Strategy

Business-rule violations should be generated by manipulating otherwise
valid records.

For example:

```text
Customer registration date:
2026-06-10

Order date:
2026-06-05
```

This creates a logically invalid order while maintaining valid data types.

---

# 3. Entity-Level Dirty Data Design

## 3.1 Customer

The `Customer` entity will contain the following controlled data-quality
issues:

| Issue Type          | Attribute           | Example                  | Target Rate |
| ------------------- | ------------------- | ------------------------ | ----------: |
| Missing Value       | `phone`             | `NULL`                   |          5% |
| Missing Value       | `gender`            | `NULL`                   |          3% |
| Missing Value       | `date_of_birth`     | `NULL`                   |          3% |
| Invalid Value       | `gender`            | `UnknownGender`          |          1% |
| Invalid Data Type   | `date_of_birth`     | `not-a-date`             |        0.5% |
| Inconsistent Format | `country`           | `Egypt` / `EG` / `egypt` |          5% |
| Inconsistent Format | `city`              | `Cairo` / `cairo`        |          3% |
| Invalid Value       | `email`             | `omar@`                  |          1% |
| Duplicate           | `customer_id`       | Duplicate customer       |          1% |
| Business Rule       | `registration_date` | Future date              |        0.5% |

---

## 3.2 Product

The `Product` entity will contain the following controlled data-quality
issues:

| Issue Type          | Attribute        | Example                       | Target Rate |
| ------------------- | ---------------- | ----------------------------- | ----------: |
| Missing Value       | `description`    | `NULL`                        |          5% |
| Invalid Value       | `price`          | `-50`                         |          1% |
| Invalid Value       | `cost`           | `-20`                         |          1% |
| Invalid Value       | `stock_quantity` | `-10`                         |          1% |
| Invalid Data Type   | `price`          | `fifty dollars`               |        0.5% |
| Inconsistent Format | `category`       | `Electronics` / `electronics` |          5% |
| Inconsistent Format | `brand`          | `Samsung` / `SAMSUNG`         |          3% |
| Duplicate           | `product_id`     | Duplicate product             |          1% |

---

## 3.3 Order

The `Order` entity will contain the following controlled data-quality
issues:

| Issue Type          | Attribute      | Example                      | Target Rate |
| ------------------- | -------------- | ---------------------------- | ----------: |
| Invalid Foreign Key | `customer_id`  | Non-existent customer        |          1% |
| Duplicate           | `order_id`     | Duplicate order              |          1% |
| Invalid Data Type   | `order_date`   | `not-a-date`                 |        0.5% |
| Invalid Value       | `order_status` | `UnknownStatus`              |          1% |
| Inconsistent Format | `order_status` | `Shipped` / `shipped`        |          3% |
| Business Rule       | `order_date`   | Before customer registration |        0.5% |
| Business Rule       | `order_date`   | Future date                  |        0.5% |

---

## 3.4 Order Item

The `Order_Item` entity will contain the following controlled data-quality
issues:

| Issue Type          | Attribute                | Example               | Target Rate |
| ------------------- | ------------------------ | --------------------- | ----------: |
| Invalid Foreign Key | `order_id`               | Non-existent order    |          1% |
| Invalid Foreign Key | `product_id`             | Non-existent product  |          1% |
| Duplicate           | `(order_id, product_id)` | Duplicate combination |          1% |
| Invalid Value       | `quantity`               | `-5`                  |          1% |
| Invalid Value       | `unit_price`             | `-20`                 |          1% |
| Invalid Data Type   | `quantity`               | `five`                |        0.5% |
| Invalid Data Type   | `unit_price`             | `invalid-price`       |        0.5% |

---

## 3.5 Payment

The `Payment` entity will contain the following controlled data-quality
issues:

| Issue Type          | Attribute        | Example                         | Target Rate |
| ------------------- | ---------------- | ------------------------------- | ----------: |
| Invalid Foreign Key | `order_id`       | Non-existent order              |          1% |
| Duplicate           | `payment_id`     | Duplicate payment               |          1% |
| Duplicate           | `order_id`       | Multiple payments for one order |          1% |
| Invalid Value       | `payment_amount` | Negative amount                 |          1% |
| Invalid Value       | `payment_status` | `InvalidStatus`                 |          1% |
| Invalid Data Type   | `payment_amount` | `one hundred`                   |        0.5% |
| Invalid Data Type   | `payment_date`   | `not-a-date`                    |        0.5% |
| Business Rule       | `payment_date`   | Before order date               |        0.5% |

---

## 3.6 Shipping

The `Shipping` entity will contain the following controlled data-quality
issues:

| Issue Type          | Attribute         | Example                          | Target Rate |
| ------------------- | ----------------- | -------------------------------- | ----------: |
| Invalid Foreign Key | `order_id`        | Non-existent order               |          1% |
| Duplicate           | `shipment_id`     | Duplicate shipment               |          1% |
| Duplicate           | `order_id`        | Multiple shipments for one order |          1% |
| Missing Value       | `delivery_date`   | `NULL`                           |         10% |
| Invalid Value       | `shipping_status` | `UnknownStatus`                  |          1% |
| Invalid Data Type   | `shipping_date`   | `not-a-date`                     |        0.5% |
| Business Rule       | `delivery_date`   | Before shipping date             |        0.5% |
| Business Rule       | `shipping_date`   | Before order date                |        0.5% |

A NULL `delivery_date` can be valid when the shipment has not yet been
delivered. Therefore, not every NULL in this field represents an error.

---

## 3.7 Review

The `Review` entity will contain the following controlled data-quality
issues:

| Issue Type          | Attribute                   | Example                       | Target Rate |
| ------------------- | --------------------------- | ----------------------------- | ----------: |
| Invalid Foreign Key | `customer_id`               | Non-existent customer         |          1% |
| Invalid Foreign Key | `product_id`                | Non-existent product          |          1% |
| Duplicate           | `(customer_id, product_id)` | Duplicate review relationship |          1% |
| Missing Value       | `review_text`               | `NULL`                        |          5% |
| Invalid Value       | `rating`                    | `0` or `6`                    |          1% |
| Invalid Data Type   | `rating`                    | `excellent`                   |        0.5% |
| Invalid Data Type   | `review_date`               | `not-a-date`                  |        0.5% |
| Business Rule       | `review_date`               | Before customer registration  |        0.5% |

---

## 3.8 Marketing Event

The `Marketing_Event` entity will contain the following controlled
data-quality issues:

| Issue Type          | Attribute         | Example                      | Target Rate |
| ------------------- | ----------------- | ---------------------------- | ----------: |
| Invalid Foreign Key | `customer_id`     | Non-existent customer        |          1% |
| Duplicate           | `event_id`        | Duplicate event              |          1% |
| Missing Value       | `campaign_id`     | `NULL`                       |          3% |
| Invalid Value       | `event_type`      | `InvalidEvent`               |          1% |
| Inconsistent Format | `device_type`     | `Mobile` / `mobile`          |          3% |
| Invalid Data Type   | `event_timestamp` | `invalid-date`               |        0.5% |
| Business Rule       | `event_timestamp` | Before customer registration |        0.5% |

---

# 4. Error Injection Rates

## 4.1 Global Error Rates

The following rates provide the initial target for the data generator.

These values are configuration targets rather than strict guarantees. The
generator should allow them to be modified.

| Data Quality Issue       | Default Rate |
| ------------------------ | -----------: |
| Missing Values           |           3% |
| Duplicate Records        |           1% |
| Invalid Values           |           1% |
| Invalid Foreign Keys     |           1% |
| Invalid Data Types       |         0.5% |
| Inconsistent Formats     |           3% |
| Business Rule Violations |         0.5% |

The rates are applied only to attributes or entities where the specific
quality issue is applicable.

---

## 4.2 Entity-Specific Error Rates

Entity-specific rates may override global rates when necessary.

For example:

```text
Shipping.delivery_date
```

may have a higher NULL rate because undelivered orders naturally have no
delivery date.

Similarly, format inconsistencies may be more common in customer
attributes such as:

```text
country
city
phone
```

The generator configuration should therefore support both:

```text
GLOBAL_ERROR_RATE
```

and:

```text
ENTITY_SPECIFIC_ERROR_RATE
```

---

# 5. Error Injection Rules

## 5.1 Record-Level Rules

The generator should first create valid records.

After valid records have been generated, a controlled error-injection
process will modify selected records.

```text
Valid Data
    ↓
Select Records
    ↓
Select Error Type
    ↓
Inject Error
    ↓
Dirty Source Data
```

A record may contain one or more data-quality issues, but the generator
should avoid making the majority of records unusable.

---

## 5.2 Column-Level Rules

Error injection should be performed only on attributes where the error type
makes logical sense.

For example:

```text
Customer.phone
    → Missing value

Product.price
    → Invalid numerical value

Review.rating
    → Invalid range

Order.customer_id
    → Invalid foreign key
```

The generator should not randomly corrupt every column.

---

## 5.3 Relationship-Level Rules

Relationship-level errors should target foreign keys and relationship
constraints.

Examples:

```text
Order.customer_id
Order_Item.order_id
Order_Item.product_id
Payment.order_id
Shipping.order_id
Review.customer_id
Review.product_id
Marketing_Event.customer_id
```

The generator should intentionally create a small number of orphan
relationships.

---

# 6. Dirty Data Generation Strategy

## 6.1 Valid Data Generation

The generator must first create a valid dataset.

Valid data must satisfy:

* Primary-key constraints.
* Foreign-key constraints.
* Data-type requirements.
* Allowed-value requirements.
* Business rules.
* Relationship rules.

The valid dataset forms the foundation for the dirty-data injection process.

---

## 6.2 Error Injection

After valid data has been generated, the generator applies controlled
quality problems.

```text
                  Valid Source Data
                         │
                         ▼
                 Error Injection
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
   Missing Values    Duplicates      Invalid Values
        │                │                │
        └────────────────┼────────────────┘
                         ▼
                  Dirty Source Data
                         │
                         ▼
                    Data Lakehouse
```

This approach makes it easier to control and test individual data-quality
scenarios.

---

## 6.3 Reproducibility

The generator must support reproducible data generation.

A fixed random seed should produce the same dataset and the same dirty-data
patterns.

Example:

```python
SEED = 42
```

This allows the same test scenario to be reproduced when debugging or
testing the pipeline.

---

## 6.4 Configurability

The error rates and dataset sizes should not be hard-coded inside individual
generator modules.

They should be configurable.

Example:

```text
CUSTOMER_COUNT=1000
PRODUCT_COUNT=200
ORDER_COUNT=5000

MISSING_VALUE_RATE=0.03
DUPLICATE_RATE=0.01
INVALID_VALUE_RATE=0.01
INVALID_FK_RATE=0.01
INVALID_DATA_TYPE_RATE=0.005
INCONSISTENT_FORMAT_RATE=0.03
BUSINESS_RULE_VIOLATION_RATE=0.005
```

This allows the same generator to produce different test scenarios.

---

# 7. Expected Dirty Data Summary

| Entity          | Missing Values | Duplicates | Invalid Values | Invalid FKs | Invalid Types | Inconsistent Formats | Business Rules |
| --------------- | -------------- | ---------- | -------------- | ----------- | ------------- | -------------------- | -------------- |
| Customer        | Yes            | Yes        | Yes            | No          | Yes           | Yes                  | Yes            |
| Product         | Yes            | Yes        | Yes            | No          | Yes           | Yes                  | Yes            |
| Order           | Limited        | Yes        | Yes            | Yes         | Yes           | Yes                  | Yes            |
| Order Item      | Limited        | Yes        | Yes            | Yes         | Yes           | Limited              | Yes            |
| Payment         | Limited        | Yes        | Yes            | Yes         | Yes           | Limited              | Yes            |
| Shipping        | Yes            | Yes        | Yes            | Yes         | Yes           | Limited              | Yes            |
| Review          | Yes            | Yes        | Yes            | Yes         | Yes           | Limited              | Yes            |
| Marketing Event | Yes            | Yes        | Yes            | Yes         | Yes           | Yes                  | Yes            |

---

# 8. Bronze and Silver Expectations

The dirty-data design directly supports the Medallion architecture.

## Bronze Layer

The Bronze layer should preserve the source data as received.

Therefore:

```text
Dirty Source Data
       ↓
    Bronze
```

The Bronze layer should not silently remove or correct dirty records.

This provides traceability and allows the pipeline to reproduce and
investigate source-system problems.

---

## Silver Layer

The Silver layer is responsible for validation, cleansing, and
standardization.

```text
Bronze
   ↓
Validation
   ↓
Cleansing
   ↓
Standardization
   ↓
Silver
```

Examples include:

* Removing or handling duplicates.
* Standardizing formats.
* Validating foreign keys.
* Handling missing values.
* Validating data types.
* Validating allowed values.
* Detecting business-rule violations.
* Quarantining invalid records.

---

# 9. Data Quality Measurement

The pipeline should calculate data-quality metrics for the generated source
data.

Examples include:

```text
Total Records
Valid Records
Invalid Records
Duplicate Records
Missing Values
Invalid Foreign Keys
Invalid Values
Invalid Data Types
Format Violations
Business Rule Violations
```

Example:

```text
Total Orders:              5,000
Valid Orders:              4,850
Invalid Orders:              150
Invalid Foreign Keys:         40
Duplicate Orders:             30
Invalid Values:               35
Business Rule Violations:     25
Invalid Data Types:           20
```

These metrics will later be useful for monitoring the quality of the
pipeline and can be exposed through the project's analytics and reporting
layers.

---

# 10. Design Principles

The dirty-data generation process must follow these principles:

1. Generate valid data first.
2. Inject errors in a controlled manner.
3. Keep error rates configurable.
4. Use reproducible random generation.
5. Preserve original dirty records in Bronze.
6. Never silently modify source data.
7. Maintain valid relationships for normal records.
8. Intentionally create invalid relationships for testing.
9. Ensure dirty data represents realistic operational problems.
10. Make every injected error detectable by a defined data-quality rule.
11. Keep the generator deterministic when a fixed seed is used.
12. Ensure the generated data supports the downstream Silver, Gold,
    dimensional-modeling, and Power BI requirements.

---

# 11. Relationship With the Data Generator

The `Dirty_Data_Design.md` document serves as the specification for the
Python source-data generator.

The implementation should follow this sequence:

```text
Data Dictionary
      ↓
Dirty Data Design
      ↓
Python Data Generator
      ↓
Valid Source Data
      ↓
Controlled Error Injection
      ↓
Dirty Source Data
      ↓
MinIO / Raw
      ↓
Bronze
      ↓
Silver
```

The Python generator should therefore be implemented only after the rules in
this document have been defined and reviewed.

````

### Where this leaves us

You now have the two important specifications:

```text
Data_Dictionary.md
        │
        │ defines
        ▼
What valid data looks like
        │
        ▼
Dirty_Data_Design.md
        │
        │ defines
        ▼
How we intentionally make it dirty
        │
        ▼
Python Data Generator
````

**One thing I would keep as-is for now:** the percentages in this document are **design targets**, not final measured results. When we implement the generator, we'll make them configurable and then verify the actual generated percentages with data-quality tests.


Absolutely. The important thing is that **I did not choose those percentages because there is a universal industry standard saying “missing phone must be 5%.”** I chose them as **engineering design targets** for a synthetic dataset.

The goal is to make your source data:

1. Dirty enough to exercise the pipeline.
2. Clean enough to remain realistic.
3. Predictable enough to test your Silver-layer rules.
4. Configurable enough to increase/decrease difficulty later.

Here is how I reasoned about each percentage.

---

# 1. First, the overall principle

I divided the problems into roughly three levels:

|     Rate | Meaning                                   |
| -------: | ----------------------------------------- |
| **0.5%** | Rare/severe problem                       |
|   **1%** | Occasional problem                        |
|   **3%** | Moderate inconsistency                    |
|   **5%** | Relatively common problem                 |
|  **10%** | Very common/usually explainable condition |

So we don't just randomly assign numbers.

For example:

```text
Invalid date type     → 0.5%
Invalid FK             → 1%
Invalid rating         → 1%
Country formatting     → 5%
Missing phone          → 5%
Undelivered shipment   → 10%
```

The reasoning is that **the more disruptive or unusual the problem is, the lower we make its rate.**

---

# 2. Why 0.5% for invalid data types?

Consider:

```text
date_of_birth = "not-a-date"
quantity = "five"
price = "fifty dollars"
```

These are serious source-system errors.

A real operational system usually isn't going to produce:

```text
quantity = "banana"
```

for a large percentage of its records.

If we generated 10% invalid data types:

```text
10,000 records
    ↓
1,000 records with invalid types
```

That would make the source system look extremely broken.

So I chose:

**0.5%**

For 1,000 customers:

```text
1,000 × 0.005 = 5 records
```

Only about **5 customers** might have an invalid data type.

That's enough for us to test:

```text
Bronze
   ↓
Schema validation
   ↓
Invalid records
   ↓
Quarantine
```

without destroying the dataset.

---

# 3. Why 1% for invalid foreign keys?

Foreign-key problems are also relatively serious.

For example:

```text
Order.customer_id = 999999
```

when customer `999999` doesn't exist.

If we have:

```text
5,000 orders
```

then:

```text
5,000 × 1% = 50 orders
```

So we might have approximately:

**50 orders with invalid customer IDs.**

That's a good number for demonstrating:

```text
Order
   │
   ├── Valid customer_id
   │
   └── Invalid customer_id
             ↓
       Referential Integrity
             ↓
          Reject
```

If we used 10%:

```text
500 / 5,000 orders
```

would have invalid customers.

That is unnecessarily high for our simulation.

So:

**Invalid FK → 1%**

is a good starting target.

---

# 4. Why 1% for duplicates?

Duplicates are important because deduplication is one of the things your Silver layer should demonstrate.

But we don't want:

```text
5,000 orders
500 duplicates
```

because that means 10% of the system is duplicated.

Instead:

```text
5,000 × 1% = 50
```

So approximately 50 duplicate records.

That gives us enough data to test:

```text
Bronze
   ↓
Duplicate detection
   ↓
Deduplication
   ↓
Silver
```

Therefore:

**Duplicate → 1%**

---

# 5. Why 1% for invalid values?

Examples:

```text
Product.price = -50
Order_Item.quantity = -5
Review.rating = 8
```

These values violate the domain rules.

For example:

```text
Review.rating
1 ≤ rating ≤ 5
```

We don't want 10% of reviews to have:

```text
rating = 8
```

because that would be very unrealistic.

But 1% gives us enough cases to test:

```text
rating = 1 ✓
rating = 3 ✓
rating = 5 ✓
rating = 8 ✗
rating = 0 ✗
```

Therefore:

**Invalid values → 1%**

---

# 6. Why 3% for inconsistent formats?

This one is different.

Format inconsistency is much less severe.

Imagine:

```text
Egypt
EG
egypt
EGY
```

These may all represent the same country.

Similarly:

```text
Cairo
cairo
CAIRO
```

The underlying information isn't necessarily wrong.

It's just **not standardized**.

Therefore, I made the rate higher:

**3%**

For 1,000 customers:

```text
1,000 × 3% = 30
```

Approximately 30 customers might have inconsistent country/city formatting.

That gives us enough data to demonstrate:

```text
Bronze
   ↓
"Egypt"
"EG"
"egypt"
   ↓
Standardization
   ↓
"Egypt"
   ↓
Silver
```

---

# 7. Why 5% for missing phone numbers?

This is a relatively common and less severe problem.

A customer may simply not provide a phone number.

For example:

```text
customer_id | phone
------------|--------------
1001        | +2010...
1002        | NULL
1003        | +2011...
1004        | NULL
```

A missing phone doesn't necessarily make the customer record unusable.

So I chose:

**5%**

For 1,000 customers:

```text
1,000 × 5% = 50
```

Approximately 50 customers could have missing phone numbers.

That gives us a meaningful test of:

```text
NULL detection
↓
Missing-value profiling
↓
Business decision
↓
Silver
```

---

# 8. Why 3% for missing values like gender?

For optional demographic information, I chose a smaller/moderate rate.

For example:

```text
gender = NULL
```

is not necessarily a serious data-quality failure.

The customer may simply not have provided it.

So:

**3%**

means:

```text
1,000 customers
× 3%
≈ 30 customers
```

That's enough to demonstrate nullable attributes without making the data excessively incomplete.

---

# 9. Why 10% for `Shipping.delivery_date`?

This one is special.

I **don't really consider all 10% dirty**.

Suppose:

```text
shipping_status = Shipped
delivery_date = NULL
```

That could be perfectly valid.

The shipment simply hasn't arrived yet.

So we can intentionally generate something like:

```text
Shipping status       Delivery date
------------------------------------
Delivered             2026-08-15
Delivered             2026-08-16
In Transit            NULL
In Transit            NULL
Pending               NULL
```

Here, NULL is actually meaningful.

That's why a larger percentage like:

**10%**

makes sense.

But we need to distinguish:

```text
NULL because shipment hasn't arrived
                ↓
             VALID
```

from:

```text
Delivered + delivery_date = NULL
                ↓
             INVALID
```

This is actually a **very good business-rule example** for your project.

---

# 10. Why 0.5% for business-rule violations?

Business-rule violations are severe logical problems.

For example:

```text
Customer registration:
2026-08-10

Order:
2026-08-05
```

An order occurring before the customer registered doesn't make sense.

Or:

```text
Order date:
2026-08-10

Payment date:
2026-08-05
```

Potentially invalid.

These shouldn't happen frequently.

So:

**0.5%**

is enough to create test cases without making the source system ridiculous.

For 5,000 orders:

```text
5,000 × 0.5% = 25
```

Approximately 25 problematic orders.

That's enough to demonstrate business-rule validation.

---

# 11. Why different entities have different rates

This is very important.

We **shouldn't force every entity to have exactly the same dirty-data percentages.**

Different source systems naturally behave differently.

For example:

### Customer

More likely to have:

```text
Missing phone
Missing demographic information
Format inconsistencies
```

So:

```text
5% missing phone
3% missing gender
3–5% formatting issues
```

### Product

More likely to have:

```text
Category formatting
Brand formatting
Missing description
```

### Order

More important problems:

```text
Invalid customer FK
Invalid status
Invalid dates
```

### Shipping

Naturally has:

```text
NULL delivery_date
```

because not every shipment has been delivered.

### Marketing Events

Could have many:

```text
format inconsistencies
missing campaign information
```

So the percentages should reflect the **type of data**, not simply use one universal number.

---

# 12. The most important concept

Think of the percentages as **test parameters**, not claims about real-world statistics.

We are not saying:

> "Exactly 5% of e-commerce customers in the real world have missing phone numbers."

We are saying:

> "For this synthetic project, we will generate approximately 5% missing phone numbers so that our data-quality pipeline has enough cases to demonstrate the required functionality."

That's a much more defensible engineering decision.

---

# 13. Our final philosophy

I would summarize our choices like this:

```text
Rare / severe
      ↓
   0.5%

Occasional / severe
      ↓
     1%

Moderately common
      ↓
     3%

Common optional/incomplete information
      ↓
     5%

Naturally occurring condition
      ↓
    10%
```

And then the generator will allow us to change them:

```python
INVALID_FK_RATE = 0.01
DUPLICATE_RATE = 0.01
INVALID_TYPE_RATE = 0.005
FORMAT_INCONSISTENCY_RATE = 0.03
MISSING_PHONE_RATE = 0.05
```

### One recommendation

I would **keep these as our initial design targets**, but add a note to `Dirty_Data_Design.md` saying that these are **engineering/testing targets, not empirical industry statistics**. That makes your documentation much more academically and technically sound.

Then, when we build the generator, we can calculate the **actual percentage produced** and compare it with the target.

