import pandas as pd

from Data_generator.Dirty_Data.inconsistent_formats import (
    InconsistentFormatInjector
)


df = pd.DataFrame({
    "product_id": range(1, 101),

    "product_name": [
        f"Product {i}"
        for i in range(1, 101)
    ],

    "category": ["Electronics"] * 100,

    "brand": ["Samsung"] * 100,

    "cost": [50.0] * 100,

    "price": [100.0] * 100,

    "stock_quantity": [20] * 100,
})


print("Before injection:")

print(
    "Electronics:",
    (df["category"] == "Electronics").sum()
)

print(
    "electronics:",
    (df["category"] == "electronics").sum()
)

print(
    "Samsung:",
    (df["brand"] == "Samsung").sum()
)

print(
    "SAMSUNG:",
    (df["brand"] == "SAMSUNG").sum()
)


injector = InconsistentFormatInjector(seed=42)

dirty_df = injector.inject(
    df,
    "product"
)


print("\nAfter injection:")

print(
    "Electronics:",
    (dirty_df["category"] == "Electronics").sum()
)

print(
    "electronics:",
    (dirty_df["category"] == "electronics").sum()
)

print(
    "Samsung:",
    (dirty_df["brand"] == "Samsung").sum()
)

print(
    "SAMSUNG:",
    (dirty_df["brand"] == "SAMSUNG").sum()
)