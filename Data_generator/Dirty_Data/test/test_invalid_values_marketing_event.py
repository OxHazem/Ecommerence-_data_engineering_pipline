import pandas as pd
from Data_generator.Dirty_Data.invalid_values import InvalidValueInjector

df = pd.DataFrame({
    "event_id": range(1, 101),
    "event_type": ["Click"] * 100
})
print("Before injection invalid event_type:", (~df['event_type'].isin(["Impression", "Click", "View", "Add to Cart", "Conversion"])).sum())
injector = InvalidValueInjector(seed=42)
dirty_df = injector.inject(df, "marketing_event")
print("After injection invalid event_type:", (~dirty_df['event_type'].isin(["Impression", "Click", "View", "Add to Cart", "Conversion"])).sum())
