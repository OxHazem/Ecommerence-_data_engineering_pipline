# Full DirtyDataInjector Test Results

## 1. Data Loading
✅ All clean datasets loaded successfully.

- `customer`: 10000 rows
- `product`: 2000 rows
- `order`: 50000 rows
- `order_item`: 150000 rows
- `payment`: 50000 rows
- `shipping`: 50000 rows
- `review`: 20000 rows
- `marketing_event`: 200000 rows

## 2. Injection Execution
✅ `DirtyDataInjector.inject()` executed successfully across all entities without any exceptions!

## 3. High-Level Impact Summary

| Entity | Clean Rows | Dirty Rows | Clean Nulls | Dirty Nulls |
|--------|------------|------------|-------------|-------------|
| `customer` | 10000 | 10100 | 0 | 1108 |
| `product` | 2000 | 2020 | 0 | 0 |
| `order` | 50000 | 50500 | 0 | 0 |
| `order_item` | 150000 | 151500 | 0 | 0 |
| `payment` | 50000 | 51005 | 0 | 255 |
| `shipping` | 50000 | 51005 | 40032 | 42136 |
| `review` | 20000 | 20200 | 0 | 101 |
| `marketing_event` | 200000 | 202000 | 0 | 7074 |
