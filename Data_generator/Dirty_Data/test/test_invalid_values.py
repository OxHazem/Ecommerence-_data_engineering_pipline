import pandas as pd

from Data_generator.Dirty_Data.invalid_values import (
    InvalidValueInjector
)


df = pd.DataFrame({
    "product_id": range(1, 101),
    "product_name": [f"Product {i}" for i in range(1, 101)],
    "category": ["Electronics"] * 100,
    "brand": ["Samsung"] * 100,
    "cost": [50.0] * 100,
    "price": [100.0] * 100,
    "stock_quantity": [20] * 100,
})


print("Before injection:")

print(
    f"Invalid price: "
    f"{(df['price'] < 0).sum()}"
)

print(
    f"Invalid cost: "
    f"{(df['cost'] < 0).sum()}"
)

print(
    f"Invalid stock_quantity: "
    f"{(df['stock_quantity'] < 0).sum()}"
)


injector = InvalidValueInjector(seed=42)

dirty_df = injector.inject(
    df,
    "product"
)


print("\nAfter injection:")

print(
    f"Invalid price: "
    f"{(dirty_df['price'] < 0).sum()}"
)

print(
    f"Invalid cost: "
    f"{(dirty_df['cost'] < 0).sum()}"
)

print(
    f"Invalid stock_quantity: "
    f"{(dirty_df['stock_quantity'] < 0).sum()}"
)