
# Inmon Layer — Final Implementation Report

## 1. Objective

The purpose of the Inmon layer was to create a **normalized Enterprise Data Warehouse representation** of the Silver data.

The transformation focused on:

* Removing unnecessary data duplication.
* Resolving geographic dependencies such as city → country.
* Representing relationships through foreign keys.
* Preserving legitimate transactional attributes.
* Maintaining data integrity between entities.
* Keeping Silver row coverage intact wherever appropriate.

The project documentation establishes that the Inmon EDW is a later model derived from the source/Silver data rather than part of the original source model. 

---

# 2. Implemented Inmon Entities

The following entities have now been implemented:

```text
inmon_layer
│
├── country
├── city
├── customer
├── category
├── subcategory
├── product
├── orders
├── order_item
├── payment
├── shipping
├── review
├── marketing_event
└── exchange_rate
```

---

# 3. Customer

### Final structure

```text
customer
├── customer_id PK
├── first_name
├── last_name
├── email
├── phone
├── gender
├── date_of_birth
├── city_id FK
├── registration_date
└── customer_status
```

### Normalization

The original Silver customer contained:

```text
country
city
```

These were replaced by the normalized geographic relationship:

```text
customer
    ↓
city
    ↓
country
```

Therefore, country information is no longer duplicated inside every customer record.

### Validation

```text
Rows: 10,000
Invalid city relationships: 0
```

**Status: ✅ PASS**

---

# 4. Product

### Final structure

```text
product
├── product_id PK
├── product_name
├── subcategory_id FK
├── brand
├── supplier
├── cost
├── price
├── stock_quantity
├── product_status
└── launch_date
```

The original category/subcategory text relationship was normalized into:

```text
product
    ↓
subcategory
    ↓
category
```

The validation confirmed that products have valid subcategories and subcategories have valid categories.

The source design originally contained both `category` and `subcategory` directly in Product. 

**Status: ✅ PASS**

---

# 5. Orders

### Final structure

```text
orders
├── order_id PK
├── customer_id FK
├── order_date
├── order_status
├── currency
└── shipping_city_id FK
```

The geographic attributes:

```text
shipping_country
shipping_city
```

were normalized into:

```text
orders
    ↓
city
    ↓
country
```

### Currency decision

We investigated this using the actual generator.

The generator explicitly creates:

```text
customer_country
      ↓
currency
```

with:

```text
Egypt → EGP
Saudi Arabia → SAR
UAE → AED
```

However, `currency` represents the currency associated with the transaction and is required later for exchange-rate conversion.

Therefore, we **intentionally retained `currency` in Orders** rather than removing it solely because the generated dataset currently derives it from geography.

This is documented as an intentional design decision rather than an overlooked normalization issue.

**Status: ✅ PASS — intentional currency retention**

---

# 6. Order Item

### Final structure

```text
order_item
├── order_id FK
├── product_id FK
├── quantity
├── unit_price
├── discount
└── cost_at_sale
```

The natural key is:

```text
(order_id, product_id)
```

The normalization analysis found that the historical `unit_price` should **not** be replaced with the current Product price. The data showed that 149,964 of 150,000 rows had a different historical unit price, confirming that `unit_price` represents the price at the time of sale. 

Therefore:

```text
unit_price
cost_at_sale
```

are legitimate transactional attributes.

**Status: ✅ PASS**

The entity was successfully loaded with:

```text
146,993 rows
```

---

# 7. Payment

### Final structure

```text
payment
├── payment_id PK
├── order_id FK
├── payment_date
├── payment_method
├── amount
├── payment_status
└── transaction_reference UNIQUE
```

The original Silver payment contained `currency`. The normalization analysis identified this as a transitive dependency through the order/customer/geography chain. 

Therefore, in the Inmon layer:

```text
currency
```

was removed from Payment.

The final Payment table contains **no currency column**.

**Status: ✅ PASS**

---

# 8. Shipping

### Final structure

```text
shipping
├── shipment_id PK
├── order_id FK
├── shipping_date
├── estimated_delivery_date
├── delivery_date
├── shipping_city_id FK
├── shipping_method
├── shipping_status
└── shipping_cost
```

The normalization analysis identified:

```text
shipping_city → shipping_country
```

as a dependency. 

We therefore removed the duplicated country information and represent the relationship through:

```text
shipping
    ↓
city
    ↓
country
```

The actual Shipping source contains `shipment_id`, order information, dates, geographic fields, method, status and cost. 

**Status: ✅ PASS**

Loaded:

```text
48,999 rows
```

---

# 9. Review

### Final structure

```text
review
├── review_id PK
├── customer_id FK
├── product_id FK
├── rating
├── review_date
├── verified_purchase
└── review_status
```

The normalization analysis found Reviews already passed 1NF, 2NF, 3NF and BCNF. 

No unnecessary decomposition was therefore required.

**Status: ✅ PASS**

Loaded:

```text
19,799 rows
```

---

# 10. Marketing Event

### Final structure

```text
marketing_event
├── event_id PK
├── customer_id FK
├── campaign_id
├── campaign_name
├── event_type
├── channel
├── event_timestamp
└── device_type
```

The important discovery here was that:

```python
campaign_id = random.randint(1, 100)
campaign_name = random.choice(campaign_names)
```

are generated independently.

Therefore:

```text
campaign_id → campaign_name
```

is **not actually a functional dependency** in the generated data.

The normalization analysis confirms that every campaign ID maps to multiple campaign names and every campaign name maps to multiple IDs. 

Therefore we correctly **did not create a fake Campaign dimension/table**.

We also removed:

```text
country
```

because it is inherited from the selected customer.

The resulting relationship is:

```text
marketing_event
       ↓
   customer
       ↓
      city
       ↓
    country
```

There are:

```text
5,938 NULL campaign_id
```

which were preserved rather than artificially repaired.

**Status: ✅ PASS**

Loaded:

```text
197,999 rows
```

---

# 11. Exchange Rate

Exchange Rate was not included in the normalization analysis because the project documentation treats it separately as an external API entity. 

The source structure is:

```text
requested_date
date
base
quote
rate
```

plus ingestion metadata.

We validated:

```text
12,632 rows
No duplicate (date, base, quote)
No NULL date
No NULL base
No NULL quote
No NULL rate
```

The Inmon table uses:

```text
(date, base, quote)
```

as the composite primary key.

The ingestion metadata remains outside the normalized business entity.

**Status: ✅ PASS**

Loaded:

```text
12,632 rows
```

---

# 12. Overall Result

### Inmon implementation status

| Entity          | Result |
| --------------- | ------ |
| Country         | ✅      |
| City            | ✅      |
| Customer        | ✅      |
| Category        | ✅      |
| Subcategory     | ✅      |
| Product         | ✅      |
| Orders          | ✅      |
| Order Item      | ✅      |
| Payment         | ✅      |
| Shipping        | ✅      |
| Review          | ✅      |
| Marketing Event | ✅      |
| Exchange Rate   | ✅      |

### Major normalization changes

```text
Customer
city + country
      ↓
city_id → city → country
```

```text
Product
category + subcategory
      ↓
subcategory_id → subcategory → category
```

```text
Orders
shipping_city + shipping_country
      ↓
shipping_city_id → city → country
```

```text
Shipping
shipping_city + shipping_country
      ↓
shipping_city_id → city → country
```

```text
Payment
currency removed
```

```text
Marketing Event
country removed
```

```text
Exchange Rate
(date, base, quote) → rate
```

---

# 13. Important Design Decisions

There are **two cases where we deliberately did not blindly follow the original normalization analysis**.

### Orders — Currency

We verified the generator and found that currency is generated from customer country. Nevertheless, we retained order currency because it is directly relevant to the transaction and to the later exchange-rate conversion.

### Marketing Event — Campaign

The normalization analysis assumed a `campaign_id → campaign_name` dependency, but inspection of the actual generator proved that both values are independently randomized.

Therefore, creating a Campaign table based on `campaign_id` would have been incorrect.

These decisions are important because they show that the Inmon model was built based on **actual data behavior and business meaning**, rather than mechanically applying theoretical dependencies.

---

# 14. Final Conclusion

> **The Inmon layer implementation is complete. ✅**

All planned entities have been created, normalized where justified, connected through appropriate relationships, and validated against the Silver layer.

The project documentation identifies the Inmon EDW as a model derived later from the source data, while the source architecture includes the eight core business entities plus Exchange Rate. 

The next step should therefore **not be another entity transformation**.

The next step is:

```text
Silver
   ↓
Inmon EDW
   ↓
FINAL INMON AUDIT
   ↓
Document completion
   ↓
Next architectural phase
```

I recommend that we now run **one comprehensive final audit SQL script** over the entire `inmon_layer`—row counts, PKs, FK integrity, duplicates, NULLs, and the important business rules—and save its results as the official **Inmon Validation Report**.
