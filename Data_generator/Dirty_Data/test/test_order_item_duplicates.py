import pandas as pd

from Data_generator.Dirty_Data.duplicates import DuplicateInjector


df = pd.DataFrame({
    "order_id": range(1, 101),
    "product_id": [1] * 100,
    "quantity": [2] * 100,
    "unit_price": [100.0] * 100,
})


print("Before injection:")
print(f"Rows: {len(df)}")

duplicate_count = df.duplicated(
    subset=["order_id", "product_id"]
).sum()

print(
    f"Duplicate (order_id, product_id): "
    f"{duplicate_count}"
)


injector = DuplicateInjector(seed=42)

dirty_df = injector.inject(
    df,
    "order_item"
)


print("\nAfter injection:")
print(f"Rows: {len(dirty_df)}")

duplicate_count = dirty_df.duplicated(
    subset=["order_id", "product_id"]
).sum()

print(
    f"Duplicate (order_id, product_id): "
    f"{duplicate_count}"
)