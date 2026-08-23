import pandas as pd
from Data_generator.Dirty_Data.duplicates import DuplicateInjector

df = pd.DataFrame({
    "payment_id": range(1, 101),
    "order_id": range(1, 101)
})
print("Before injection: Rows", len(df), "Duplicates:", df['payment_id'].duplicated().sum())
injector = DuplicateInjector(seed=42)
dirty_df = injector.inject(df, "payment")
print("After injection: Rows", len(dirty_df), "Duplicates payment_id:", dirty_df['payment_id'].duplicated().sum(), "order_id:", dirty_df['order_id'].duplicated().sum())
