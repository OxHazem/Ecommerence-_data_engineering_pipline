# Dirty Data Generator Test Results

This document contains a summary of the dirty data generator tests created to fulfill the requirements from `Dirty_Data.md`.

## 1. Missing Values
**Status: ✅ Passed**

* **Shipping (`delivery_date`)**: Missing values successfully injected (10/100).
* **Marketing Event (`campaign_id`)**: Missing values successfully injected (3/100).
* **Customer (`phone`, `gender`, `date_of_birth`)**: Missing values successfully injected (5, 3, 3 respectively).

## 2. Duplicates
**Status: ✅ Passed**

* **Customer**: 1 duplicate created.
* **Product**: 1 duplicate created.
* **Order**: 1 duplicate created.
* **Payment**: 1 duplicate created (for `payment_id` and `order_id`).
* **Shipping**: 1 duplicate created (for `shipment_id` and `order_id`).
* **Review**: 1 duplicate created.
* **Marketing Event**: 1 duplicate created.
* **Order Item**: 1 duplicate combination created for `(order_id, product_id)`.

## 3. Invalid Values
**Status: ✅ Passed**

* **Customer**: `gender` invalid values injected.
* **Product**: `price`, `cost`, `stock_quantity` invalid values injected.
* **Order**: `order_status` invalid values injected.
* **Payment**: `amount` invalid values injected.
* **Shipping**: `shipping_status` invalid values injected.
* **Review**: `rating` invalid values injected.
* **Marketing Event**: `event_type` invalid values injected.
* **Order Item**: `quantity`, `unit_price` invalid values injected.

## 4. Invalid Data Types
**Status: ✅ Passed**

* **Customer**: `date_of_birth` type errors injected.
* **Product**: `price` type errors injected.
* **Order**: `order_date` type errors injected.
* **Order Item**: `quantity`, `unit_price` type errors injected.
* **Payment**: `amount`, `payment_date` type errors injected.
* **Shipping**: `shipping_date` type errors injected.
* **Review**: `rating`, `review_date` type errors injected.
* **Marketing Event**: `event_timestamp` type errors injected.

## 5. Inconsistent Formats
**Status: ✅ Passed**

* **Customer**: `country`, `city` formats altered.
* **Product**: `category`, `brand` formats altered.
* **Order**: `order_status` formats altered.
* **Marketing Event**: `device_type` formats altered.

## 6. Invalid Foreign Keys
**Status: ✅ Passed**

* **Customer -> Order**: Invalid `customer_id` injected.
* **Marketing Event**: Invalid `customer_id` injected.
* **Order Item**: Invalid `order_id`, `product_id` injected.
* **Payment & Shipping**: Invalid `order_id` injected.
* **Review**: Invalid `customer_id`, `product_id` injected.

## 7. Business Rules
**Status: ⚠️ Partially Passed / Errors Found**

* **Customer**: `registration_date` > current date (✅ Passed)
* **Payment**: `payment_date` < `order_date` (✅ Passed)
* **Shipping**: `delivery_date` < `shipping_date` (✅ Passed)
* **Shipping**: `shipping_date` < `order_date` (✅ Passed)
* **Review**: `review_date` < `registration_date` (✅ Passed)
* **Order**: `order_date` > future (✅ Passed)

**Failed Tests (Missing Implementation in `business_rules.py`):**
* **Order**: `order_date` < `customer_registration_date`
  * **Error:** `AttributeError: 'BusinessRuleInjector' object has no attribute '_inject_order_before_customer_registration'`
* **Marketing Event**: `event_timestamp` < `customer_registration_date`
  * **Error:** `ValueError: Business-rule injection for entity 'marketing_event' is not implemented yet.`

---

### Conclusion
The **24 missing test files** were successfully created. Upon running all tests, we verified that the injectors work beautifully for missing values, duplicates, format inconsistencies, invalid types, invalid values, and foreign keys across all entities. 

However, we uncovered that the **`BusinessRuleInjector` in `business_rules.py` is incomplete**. It is missing the logic required to implement cross-entity business rules for Marketing Events and Orders related to Customer registrations.
