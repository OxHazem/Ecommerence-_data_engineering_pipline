import pandas as pd

from Data_generator.Dirty_Data.missing_values import MissingValueInjector


# Small test dataset
df = pd.DataFrame({
    "customer_id": range(1, 101),
    "phone": [f"01000000{i:03d}" for i in range(1, 101)],
    "gender": ["Male"] * 100,
    "date_of_birth": pd.date_range(
        start="1990-01-01",
        periods=100,
        freq="D"
    )
})


print("Before injection:")
print(df.isna().sum())


injector = MissingValueInjector(seed=42)

dirty_df = injector.inject(
    df,
    "customer"
)


print("\nAfter injection:")
print(dirty_df.isna().sum())