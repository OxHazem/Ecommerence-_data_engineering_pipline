import pandas as pd
from Data_generator.Dirty_Data.invalid_data_types import InvalidDataTypeInjector

df = pd.DataFrame({
    "customer_id": range(1, 101),
    "date_of_birth": pd.date_range("1990-01-01", periods=100)
})
print("Before injection invalid dob type:", df['date_of_birth'].map(type).eq(str).sum())
injector = InvalidDataTypeInjector(seed=42)
dirty_df = injector.inject(df, "customer")
print("After injection invalid dob type:", dirty_df['date_of_birth'].map(type).eq(str).sum())
