# Proof of Dirtiness

This report proves that the files saved in `Data/generated/dirty/` have successfully retained their injected corruptions.

## Customer

**Proof of Duplicates:** Row count increased from `10000` to `10100`.

**Proof of Missing Values:** Null count increased from `0` to `1108`.

**Proof of Invalid Values:**
```text
     customer_id         gender
440          441  UnknownGender
640          641  UnknownGender
682          683  UnknownGender
```

## Product

**Proof of Duplicates:** Row count increased from `2000` to `2020`.

**Proof of Invalid Data Types (Price as text):**
```text
     product_id          price
173         174  fifty dollars
179         180  fifty dollars
190         191  fifty dollars
```

## Order

**Proof of Duplicates:** Row count increased from `50000` to `50500`.

## Order_item

**Proof of Duplicates:** Row count increased from `150000` to `151500`.

## Payment

**Proof of Duplicates:** Row count increased from `50000` to `51005`.

**Proof of Missing Values:** Null count increased from `0` to `255`.

## Shipping

**Proof of Duplicates:** Row count increased from `50000` to `51005`.

**Proof of Missing Values:** Null count increased from `40032` to `42136`.

## Review

**Proof of Duplicates:** Row count increased from `20000` to `20200`.

**Proof of Missing Values:** Null count increased from `0` to `101`.

## Marketing_event

**Proof of Duplicates:** Row count increased from `200000` to `202000`.

**Proof of Missing Values:** Null count increased from `0` to `7074`.

