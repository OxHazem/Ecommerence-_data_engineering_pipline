import pandas as pd
from Data_generator.Dirty_Data.duplicates import DuplicateInjector

df = pd.DataFrame({
    "order_id": range(1, 101)
})
print("Before injection: Rows", len(df), "Duplicates:", df['order_id'].duplicated().sum())
injector = DuplicateInjector(seed=42)
dirty_df = injector.inject(df, "order")
print("After injection: Rows", len(dirty_df), "Duplicates:", dirty_df['order_id'].duplicated().sum())
