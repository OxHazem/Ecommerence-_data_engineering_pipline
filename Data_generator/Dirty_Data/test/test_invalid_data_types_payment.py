import pandas as pd
from Data_generator.Dirty_Data.invalid_data_types import InvalidDataTypeInjector

df = pd.DataFrame({
    "payment_id": range(1, 101),
    "amount": [100.0] * 100,
    "payment_date": pd.date_range("2020-01-01", periods=100)
})
print("Before injection invalid amount type:", df['amount'].map(type).eq(str).sum())
injector = InvalidDataTypeInjector(seed=42)
dirty_df = injector.inject(df, "payment")
print("After injection invalid amount type:", dirty_df['amount'].map(type).eq(str).sum())
