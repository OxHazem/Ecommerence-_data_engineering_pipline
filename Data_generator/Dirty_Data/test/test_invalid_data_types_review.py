import pandas as pd
from Data_generator.Dirty_Data.invalid_data_types import InvalidDataTypeInjector

df = pd.DataFrame({
    "review_id": range(1, 101),
    "rating": [5] * 100,
    "review_date": pd.date_range("2020-01-01", periods=100)
})
print("Before injection invalid rating type:", df['rating'].map(type).eq(str).sum())
injector = InvalidDataTypeInjector(seed=42)
dirty_df = injector.inject(df, "review")
print("After injection invalid rating type:", dirty_df['rating'].map(type).eq(str).sum())
