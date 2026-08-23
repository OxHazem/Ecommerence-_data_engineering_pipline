import pandas as pd
from Data_generator.Dirty_Data.inconsistent_formats import InconsistentFormatInjector

df = pd.DataFrame({
    "customer_id": range(1, 101),
    "country": ["Egypt"] * 100,
    "city": ["Cairo"] * 100
})
print("Before injection lower country:", (df['country'] == "egypt").sum())
injector = InconsistentFormatInjector(seed=42)
dirty_df = injector.inject(df, "customer")
print("After injection lower country:", (dirty_df['country'] == "egypt").sum())
