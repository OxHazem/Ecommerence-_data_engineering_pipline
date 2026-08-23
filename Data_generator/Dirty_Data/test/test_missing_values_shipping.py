import pandas as pd
from Data_generator.Dirty_Data.missing_values import MissingValueInjector

df = pd.DataFrame({
    "shipment_id": range(1, 101),
    "delivery_date": pd.date_range("2026-01-01", periods=100)
})

print("Before injection:\n", df.isna().sum())
injector = MissingValueInjector(seed=42)
dirty_df = injector.inject(df, "shipping")
print("\nAfter injection:\n", dirty_df.isna().sum())
