import pandas as pd
from Data_generator.Dirty_Data.missing_values import MissingValueInjector

df = pd.DataFrame({
    "event_id": range(1, 101),
    "campaign_id": range(1, 101)
})

print("Before injection:\n", df.isna().sum())
injector = MissingValueInjector(seed=42)
dirty_df = injector.inject(df, "marketing_event")
print("\nAfter injection:\n", dirty_df.isna().sum())
