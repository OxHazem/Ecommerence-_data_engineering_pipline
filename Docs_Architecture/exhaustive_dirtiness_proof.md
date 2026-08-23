# Exhaustive Entity-by-Entity Dirty Data Proof

This report provides a real, line-by-line check extracting exactly how each file in `Data/generated/dirty` was corrupted compared to its clean counterpart.

## Entity: `CUSTOMER`

### 1. Duplicates
Found 200 explicitly duplicated rows. Example of a duplicate:
```text
       customer_id first_name last_name                   email           phone gender date_of_birth               country       city        registration_date customer_status
436            437    Desiree     Smith  butleromar@example.net  +971 562205950  Other    2008-05-11  United Arab Emirates  Abu Dhabi  2020-06-17T00:00:00.000        Inactive
10072          437    Desiree     Smith  butleromar@example.net  +971 562205950  Other    2008-05-11  United Arab Emirates  Abu Dhabi  2020-06-17T00:00:00.000        Inactive
```

### 2. Missing Values
Found newly injected `null` values in columns: `['phone', 'gender', 'date_of_birth']`. Example:
```text
    customer_id first_name last_name                         email phone gender date_of_birth country        city        registration_date customer_status
52           53      Karen  Chambers  lindsayhernandez@example.org   NaN  Other    1973-05-27   Egypt  Alexandria  2016-12-21T00:00:00.000          Active
```

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
**Corruption in column `email`**:
```text
Row customer_id=196 | Clean value: 'johnsonjacob@example.net' -> Dirty value: 'omar@'
```

**Corruption in column `gender`**:
```text
Row customer_id=441 | Clean value: 'Unknown' -> Dirty value: 'UnknownGender'
```

**Corruption in column `date_of_birth`**:
```text
Row customer_id=644 | Clean value: '1974-02-19' -> Dirty value: 'not-a-date'
```

**Corruption in column `country`**:
```text
Row customer_id=47 | Clean value: 'Egypt' -> Dirty value: 'EG'
```

**Corruption in column `city`**:
```text
Row customer_id=37 | Clean value: 'Cairo' -> Dirty value: 'cairo'
```

**Corruption in column `registration_date`**:
```text
Row customer_id=1 | Clean value: '1990-06-16' -> Dirty value: '1990-06-16T00:00:00.000'
```

### 4. Invalid Foreign Keys
*No invalid foreign keys configured or found.*

---

## Entity: `PRODUCT`

### 1. Duplicates
Found 40 explicitly duplicated rows. Example of a duplicate:
```text
      product_id product_name category subcategory brand            supplier   cost    price  stock_quantity product_status launch_date
170          171       Put Mr     Home     Kitchen  Nike  Prime Distribution  789.7  1527.58             141   Discontinued  2023-01-12
2011         171       Put Mr     Home     Kitchen  Nike  Prime Distribution  789.7  1527.58             141   Discontinued  2023-01-12
```

### 2. Missing Values
*No injected missing values found.*

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
**Corruption in column `category`**:
```text
Row product_id=85 | Clean value: 'Electronics' -> Dirty value: 'electronics'
```

**Corruption in column `brand`**:
```text
Row product_id=28 | Clean value: 'Samsung' -> Dirty value: 'SAMSUNG'
```

**Corruption in column `cost`**:
```text
Row product_id=89 | Clean value: '476.19' -> Dirty value: '-20.0'
```

**Corruption in column `price`**:
```text
Row product_id=173 | Clean value: '30.46' -> Dirty value: '-50.0'
```

**Corruption in column `stock_quantity`**:
```text
Row product_id=196 | Clean value: '391' -> Dirty value: '-10'
```

### 4. Invalid Foreign Keys
*No invalid foreign keys configured or found.*

---

## Entity: `ORDER`

### 1. Duplicates
Found 1000 explicitly duplicated rows. Example of a duplicate:
```text
       order_id  customer_id  order_date order_status currency shipping_country shipping_city
264         265         2882  2020-06-09    Cancelled      EGP            Egypt          Giza
50315       265         2882  2027-08-23    Cancelled      EGP            Egypt          Giza
```

### 2. Missing Values
*No injected missing values found.*

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
**Corruption in column `customer_id`**:
```text
Row order_id=268 | Clean value: '1989' -> Dirty value: '10001'
```

**Corruption in column `order_date`**:
```text
Row order_id=368 | Clean value: '2023-01-20' -> Dirty value: '2014-04-29'
```

**Corruption in column `order_status`**:
```text
Row order_id=88 | Clean value: 'Shipped' -> Dirty value: 'shipped'
```

### 4. Invalid Foreign Keys
Found invalid `customer_id` pointing to non-existent `customer`. Example of invalid ID:
```text
     customer_id
267        10001
```

---

## Entity: `ORDER_ITEM`

### 1. Duplicates
Found 4459 explicitly duplicated rows. Example of a duplicate:
```text
        order_id  product_id quantity unit_price  discount  cost_at_sale
64661         22        1249        7    2159.65         5        850.93
150183        22        1249        7    2159.65         5        850.93
```

### 2. Missing Values
*No injected missing values found.*

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
### 4. Invalid Foreign Keys
Found invalid `order_id` pointing to non-existent `order`. Example of invalid ID:
```text
     order_id
186     50001
```

Found invalid `product_id` pointing to non-existent `product`. Example of invalid ID:
```text
     product_id
186        2001
```

---

## Entity: `PAYMENT`

### 1. Duplicates
Found 1996 explicitly duplicated rows. Example of a duplicate:
```text
       payment_id  order_id payment_date payment_method   amount currency payment_status                     transaction_reference
62             63     41199   2023-12-22         PayPal  3721.33      AED  InvalidStatus  TXN-894a05e4-30b1-47ef-b10c-0c003fa7f104
50595          63     41199   2023-12-22         PayPal  3721.33      AED       Refunded  TXN-894a05e4-30b1-47ef-b10c-0c003fa7f104
```

### 2. Missing Values
Found newly injected `null` values in columns: `['payment_date']`. Example:
```text
     payment_id  order_id payment_date payment_method   amount currency payment_status                     transaction_reference
359         360     38997          NaN  Bank Transfer  3389.12      AED      Completed  TXN-6e191042-370b-4063-9d90-e79eb888f6ed
```

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
**Corruption in column `order_id`**:
```text
Row payment_id=271 | Clean value: '15926' -> Dirty value: '50001'
```

**Corruption in column `payment_date`**:
```text
Row payment_id=372 | Clean value: '2015-02-14' -> Dirty value: '2011-10-16'
```

**Corruption in column `amount`**:
```text
Row payment_id=271 | Clean value: '1464.19' -> Dirty value: '-100.0'
```

**Corruption in column `payment_status`**:
```text
Row payment_id=63 | Clean value: 'Refunded' -> Dirty value: 'InvalidStatus'
```

### 4. Invalid Foreign Keys
Found invalid `order_id` pointing to non-existent `order`. Example of invalid ID:
```text
     order_id
270     50001
```

---

## Entity: `SHIPPING`

### 1. Duplicates
Found 1996 explicitly duplicated rows. Example of a duplicate:
```text
       shipment_id  order_id shipping_date estimated_delivery_date delivery_date      shipping_country shipping_city shipping_method shipping_status  shipping_cost
62              63     41199    2016-07-13              2022-02-09    2018-01-03  United Arab Emirates         Dubai         Express       Delivered          94.98
50595           63     41199    2016-07-13              2022-02-09    2018-01-03  United Arab Emirates         Dubai         Express       Delivered          94.98
```

### 2. Missing Values
Found newly injected `null` values in columns: `['shipping_date', 'delivery_date']`. Example:
```text
     shipment_id  order_id shipping_date estimated_delivery_date delivery_date shipping_country shipping_city shipping_method shipping_status  shipping_cost
374          375     38252           NaN              2026-06-28           NaN            Egypt    Alexandria        Same Day        Returned         171.89
```

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
**Corruption in column `order_id`**:
```text
Row shipment_id=271 | Clean value: '15926' -> Dirty value: '50001'
```

**Corruption in column `shipping_date`**:
```text
Row shipment_id=371 | Clean value: '2022-11-06' -> Dirty value: '2005-06-26'
```

**Corruption in column `estimated_delivery_date`**:
```text
Row shipment_id=373 | Clean value: '2026-05-11' -> Dirty value: '2024-03-27'
```

**Corruption in column `delivery_date`**:
```text
Row shipment_id=307 | Clean value: '2004-01-14' -> Dirty value: '2004-01-12'
```

**Corruption in column `shipping_status`**:
```text
Row shipment_id=271 | Clean value: 'Delivered' -> Dirty value: 'UnknownStatus'
```

### 4. Invalid Foreign Keys
Found invalid `order_id` pointing to non-existent `order`. Example of invalid ID:
```text
     order_id
270     50001
```

---

## Entity: `REVIEW`

### 1. Duplicates
Found 400 explicitly duplicated rows. Example of a duplicate:
```text
       review_id  customer_id  product_id rating              review_date  verified_purchase review_status
146          147         5512          59      4  2015-07-02T00:00:00.000               True       Pending
20107        147         5512          59      4  2015-07-02T00:00:00.000               True       Pending
```

### 2. Missing Values
Found newly injected `null` values in columns: `['review_date']`. Example:
```text
     review_id  customer_id  product_id rating review_date  verified_purchase review_status
393        394         4497         257      5         NaN               True     Published
```

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
**Corruption in column `customer_id`**:
```text
Row review_id=148 | Clean value: '3476' -> Dirty value: '10001'
```

**Corruption in column `product_id`**:
```text
Row review_id=148 | Clean value: '727' -> Dirty value: '2001'
```

**Corruption in column `rating`**:
```text
Row review_id=148 | Clean value: '5' -> Dirty value: '0'
```

**Corruption in column `review_date`**:
```text
Row review_id=1 | Clean value: '2004-09-15' -> Dirty value: '2004-09-15T00:00:00.000'
```

### 4. Invalid Foreign Keys
Found invalid `customer_id` pointing to non-existent `customer`. Example of invalid ID:
```text
     customer_id
147        10001
```

Found invalid `product_id` pointing to non-existent `product`. Example of invalid ID:
```text
     product_id
147        2001
```

---

## Entity: `MARKETING_EVENT`

### 1. Duplicates
Found 4000 explicitly duplicated rows. Example of a duplicate:
```text
        event_id  customer_id  campaign_id campaign_name event_type     channel             event_timestamp device_type               country
201381       246         9820          8.0   Summer Sale      Click  Google Ads  2012-12-21 15:22:03.260447      Mobile  United Arab Emirates
245          246         9820          8.0   Summer Sale      Click  Google Ads  2012-12-21 15:22:03.260447      Mobile  United Arab Emirates
```

### 2. Missing Values
Found newly injected `null` values in columns: `['campaign_id', 'event_timestamp']`. Example:
```text
   event_id  customer_id  campaign_id   campaign_name event_type       channel             event_timestamp device_type               country
0         1         1825          NaN  Back to School      Click  Social Media  2004-09-15 09:01:56.803149      mobile  United Arab Emirates
```

### 3. Data Modifications (Invalid Values, Formats, Business Rules)
**Corruption in column `customer_id`**:
```text
Row event_id=249 | Clean value: '8726' -> Dirty value: '10001'
```

**Corruption in column `campaign_id`**:
```text
Row event_id=2 | Clean value: '87' -> Dirty value: '87.0'
```

**Corruption in column `event_type`**:
```text
Row event_id=249 | Clean value: 'Purchase' -> Dirty value: 'InvalidEvent'
```

**Corruption in column `event_timestamp`**:
```text
Row event_id=879 | Clean value: '2008-12-07 03:52:05.506278' -> Dirty value: '2005-12-22 00:00:00.000000'
```

**Corruption in column `device_type`**:
```text
Row event_id=1 | Clean value: 'Mobile' -> Dirty value: 'mobile'
```

### 4. Invalid Foreign Keys
Found invalid `customer_id` pointing to non-existent `customer`. Example of invalid ID:
```text
     customer_id
248        10001
```

---

