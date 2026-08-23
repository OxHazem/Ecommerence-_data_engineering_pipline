import pandas as pd
from Data_generator.Dirty_Data.invalid_data_types import InvalidDataTypeInjector

df = pd.DataFrame({
    "order_id": range(1, 101),
    "order_date": pd.date_range("2020-01-01", periods=100)
})
print("Before injection invalid date type:", df['order_date'].map(type).eq(str).sum())
injector = InvalidDataTypeInjector(seed=42)
dirty_df = injector.inject(df, "order")
print("After injection invalid date type:", dirty_df['order_date'].map(type).eq(str).sum())
