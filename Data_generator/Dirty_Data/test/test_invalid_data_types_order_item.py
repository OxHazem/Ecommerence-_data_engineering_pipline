import pandas as pd
from Data_generator.Dirty_Data.invalid_data_types import InvalidDataTypeInjector

df = pd.DataFrame({
    "order_id": range(1, 101),
    "quantity": [1] * 100,
    "unit_price": [10.0] * 100
})
print("Before injection invalid quantity type:", df['quantity'].map(type).eq(str).sum())
injector = InvalidDataTypeInjector(seed=42)
dirty_df = injector.inject(df, "order_item")
print("After injection invalid quantity type:", dirty_df['quantity'].map(type).eq(str).sum())
