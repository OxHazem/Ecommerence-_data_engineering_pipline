import pandas as pd
from Data_generator.Dirty_Data.invalid_values import InvalidValueInjector

df = pd.DataFrame({
    "customer_id": range(1, 101),
    "gender": ["Male"] * 100,
    "email": ["test@test.com"] * 100
})
print("Before injection invalid gender:", (~df['gender'].isin(["Male", "Female", "Other", "Unknown"])).sum())
injector = InvalidValueInjector(seed=42)
dirty_df = injector.inject(df, "customer")
print("After injection invalid gender:", (~dirty_df['gender'].isin(["Male", "Female", "Other", "Unknown"])).sum())
