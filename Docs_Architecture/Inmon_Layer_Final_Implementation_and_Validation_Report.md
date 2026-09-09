# Inmon Layer --- Final Implementation & Validation Report

## 1. Purpose

The Inmon phase implements a normalized Enterprise Data Warehouse (EDW)
representation of the e-commerce data.

The project documentation describes Inmon as a normalized EDW focused on
enterprise integration, normalization, and a centralized enterprise
warehouse, with downstream data marts.

## 2. Final Inmon Layer

The final `inmon_layer` contains 13 tables:

-   `country`
-   `city`
-   `category`
-   `subcategory`
-   `customer`
-   `product`
-   `orders`
-   `order_item`
-   `payment`
-   `shipping`
-   `review`
-   `marketing_event`
-   `exchange_rate`

An unused duplicate `order_items` table was identified during the final
audit. It contained 0 rows and was removed.

## 3. Normalization Implemented

### Geographic normalization

``` text
country
   ↑
city
   ↑
customer
orders
shipping
```

Customer, Orders, and Shipping use city foreign keys instead of
duplicated country/city descriptions. Marketing Event does not store
country because its country context is available through the customer
relationship.

### Product hierarchy

``` text
category
   ↑
subcategory
   ↑
product
```

### Payment

Payment does not retain duplicated currency information. It references
the order, where transaction currency is represented.

### Order Item

`unit_price` and `cost_at_sale` are retained because they represent
historical transactional values at sale time rather than current Product
attributes.

### Marketing Event

The generator independently creates `campaign_id` and `campaign_name`.
Therefore the observed data does not establish:

``` text
campaign_id → campaign_name
```

A separate Campaign table keyed only by `campaign_id` would therefore be
incorrect. Both attributes remain in `marketing_event`.

The 5,938 NULL `campaign_id` values were preserved.

### Exchange Rate

Exchange Rate was not covered by the normalization analysis, so no
unsupported decomposition was introduced.

The business key is:

``` text
(date, base, quote)
```

The ingestion metadata is not part of the normalized business entity.

## 4. Silver → Inmon Row-Count Validation

  Entity               Silver     Inmon Result
  ----------------- --------- --------- --------
  Customer             10,000    10,000 PASS
  Product               2,000     2,000 PASS
  Orders               49,498    49,498 PASS
  Order Item          146,993   146,993 PASS
  Payment              49,000    49,000 PASS
  Shipping             48,999    48,999 PASS
  Review               19,799    19,799 PASS
  Marketing Event     197,999   197,999 PASS
  Exchange Rate        12,632    12,632 PASS

**All 9 Silver → Inmon row-count validations passed.**

## 5. Referential Integrity Validation

  Relationship                   Invalid Rows Result
  ---------------------------- -------------- --------
  Customer → City                           0 PASS
  Product → Subcategory                     0 PASS
  Orders → Customer                         0 PASS
  Orders → Shipping City                    0 PASS
  Order Item → Order                        0 PASS
  Order Item → Product                      0 PASS
  Payment → Order                           0 PASS
  Shipping → Order                          0 PASS
  Shipping → City                           0 PASS
  Review → Customer                         0 PASS
  Review → Product                          0 PASS
  Marketing Event → Customer                0 PASS

**All 12 referential-integrity checks passed with zero orphan records.**

## 6. Structural Constraint Validation

The final audit confirmed appropriate structural controls:

-   Primary keys on the main entities.
-   Foreign keys for entity relationships.
-   NOT NULL checks on required fields.
-   UNIQUE constraints where required.
-   Numeric/business-rule checks.
-   Rating validation.
-   Transaction-reference uniqueness.
-   Geographic hierarchy uniqueness.
-   Composite primary key `(date, base, quote)` for Exchange Rate.

## 7. Exchange Rate Validation

Silver Exchange Rate contained:

-   12,632 rows.
-   No NULL dates.
-   No NULL base currencies.
-   No NULL quote currencies.
-   No NULL rates.
-   No duplicate `(date, base, quote)` combinations.

The Inmon table contains all 12,632 rows.

## 8. Important Design Decisions

### Orders --- Currency

Currency was intentionally retained in `orders`. Although the generator
derives it from customer country, it is directly relevant to the
transaction and required for exchange-rate conversion.

### Marketing Event --- Campaign

`campaign_id` and `campaign_name` are independently generated, so they
were not incorrectly decomposed into a Campaign table.

### Marketing Event --- Country

`country` was removed because it duplicates information available
through `customer_id`.

### Exchange Rate

No unsupported normalization rule was applied. The demonstrated business
key `(date, base, quote)` was used.

## 9. Final Audit Summary

  Audit Area                              Result
  --------------------------------------- --------
  Final table inventory                   PASS
  Duplicate empty `order_items` removed   PASS
  Silver → Inmon row preservation         PASS
  Foreign-key integrity                   PASS
  Primary keys                            PASS
  Foreign keys                            PASS
  Required-field controls                 PASS
  UNIQUE constraints                      PASS
  Business-rule checks                    PASS
  Exchange-rate uniqueness                PASS
  Geographic normalization                PASS
  Product hierarchy normalization         PASS

## 10. Final Conclusion

# INMON LAYER: COMPLETE AND VALIDATED

The normalized Inmon EDW has been implemented and validated against the
available Silver data.

The completed implementation demonstrates normalized enterprise
structures, integrated relationships, primary/foreign-key enforcement,
Silver row preservation, business-rule constraints, and explicit
handling of data-quality exceptions.

The Inmon layer is now ready as the normalized EDW component of the
project architecture.

## 11. Next Phase

The project documentation defines the Inmon flow as:

``` text
Source
   ↓
Normalized EDW
   ↓
Data Marts
   ↓
BI
```

The Inmon implementation is therefore complete. The next work should
focus on the remaining project deliverables and downstream
serving/comparison components rather than further changing the completed
Inmon entities.

------------------------------------------------------------------------

**Status: INMON PHASE COMPLETE --- PASS**
