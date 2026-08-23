import pandas as pd

from Data_generator.Dirty_Data.duplicates import DuplicateInjector


df = pd.DataFrame({
    "customer_id": range(1, 101),
    "phone": [f"01000000{i:03d}" for i in range(1, 101)],
    "gender": ["Male"] * 100,
})


print("Before injection:")
print(f"Rows: {len(df)}")
print(
    f"Duplicate customer_id: "
    f"{df['customer_id'].duplicated().sum()}"
)


injector = DuplicateInjector(seed=42)

dirty_df = injector.inject(
    df,
    "customer"
)


print("\nAfter injection:")
print(f"Rows: {len(dirty_df)}")
print(
    f"Duplicate customer_id: "
    f"{dirty_df['customer_id'].duplicated().sum()}"
)