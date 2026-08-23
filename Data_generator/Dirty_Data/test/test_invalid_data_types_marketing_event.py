import pandas as pd
from Data_generator.Dirty_Data.invalid_data_types import InvalidDataTypeInjector

df = pd.DataFrame({
    "event_id": range(1, 101),
    "event_timestamp": pd.date_range("2020-01-01", periods=100)
})
print("Before injection invalid date type:", df['event_timestamp'].map(type).eq(str).sum())
injector = InvalidDataTypeInjector(seed=42)
dirty_df = injector.inject(df, "marketing_event")
print("After injection invalid date type:", dirty_df['event_timestamp'].map(type).eq(str).sum())
