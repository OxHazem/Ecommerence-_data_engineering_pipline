import pandas as pd
from Data_generator.Dirty_Data.duplicates import DuplicateInjector

df = pd.DataFrame({
    "event_id": range(1, 101)
})
print("Before injection: Rows", len(df))
injector = DuplicateInjector(seed=42)
dirty_df = injector.inject(df, "marketing_event")
print("After injection: Rows", len(dirty_df), "Duplicates:", dirty_df['event_id'].duplicated().sum())
