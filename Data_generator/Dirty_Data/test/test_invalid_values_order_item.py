import pandas as pd

from Data_generator.Dirty_Data.invalid_values import (
    InvalidValueInjector
)


df = pd.DataFrame({
    "order_id": range(1, 101),
    "product_id": range(101, 201),
    "quantity": [5] * 100,
    "unit_price": [100.0] * 100,
})


print("Before injection:")

print(
    f"Invalid quantity: "
    f"{(df['quantity'] < 0).sum()}"
)

print(
    f"Invalid unit_price: "
    f"{(df['unit_price'] < 0).sum()}"
)


injector = InvalidValueInjector(seed=42)

dirty_df = injector.inject(
    df,
    "order_item"
)


print("\nAfter injection:")

print(
    f"Invalid quantity: "
    f"{(dirty_df['quantity'] < 0).sum()}"
)

print(
    f"Invalid unit_price: "
    f"{(dirty_df['unit_price'] < 0).sum()}"
)