import pandas as pd
from Data_generator.Dirty_Data.inconsistent_formats import InconsistentFormatInjector

df = pd.DataFrame({
    "event_id": range(1, 101),
    "device_type": ["Mobile"] * 100
})
print("Before injection lower device:", (df['device_type'] == "mobile").sum())
injector = InconsistentFormatInjector(seed=42)
dirty_df = injector.inject(df, "marketing_event")
print("After injection lower device:", (dirty_df['device_type'] == "mobile").sum())
