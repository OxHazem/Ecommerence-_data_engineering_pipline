import pandas as pd

from Data_generator.Dirty_Data.invalid_data_types import (
    InvalidDataTypeInjector
)


df = pd.DataFrame({
    "product_id": range(1, 1001),
    "product_name": [
        f"Product {i}" for i in range(1, 1001)
    ],
    "category": ["Electronics"] * 1000,
    "brand": ["Samsung"] * 1000,
    "cost": [50.0] * 1000,
    "price": [100.0] * 1000,
    "stock_quantity": [20] * 1000,
})

print("Before injection:")
print(
    f"Invalid price type: "
    f"{(df['price'].map(type) == str).sum()}"
)


injector = InvalidDataTypeInjector(seed=42)

dirty_df = injector.inject(
    df,
    "product"
)


print("\nAfter injection:")

invalid_type_count = (
    dirty_df["price"]
    .map(type)
    .eq(str)
    .sum()
)

print(
    f"Invalid price type: "
    f"{invalid_type_count}"
)

print(
    f"Invalid price value: "
    f"{dirty_df.loc[
        dirty_df['price'].map(type).eq(str),
        'price'
    ].tolist()}"
)