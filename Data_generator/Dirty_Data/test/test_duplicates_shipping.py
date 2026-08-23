import pandas as pd
from Data_generator.Dirty_Data.duplicates import DuplicateInjector

df = pd.DataFrame({
    "shipment_id": range(1, 101),
    "order_id": range(1, 101)
})
print("Before injection: Rows", len(df), "Duplicates:", df['shipment_id'].duplicated().sum())
injector = DuplicateInjector(seed=42)
dirty_df = injector.inject(df, "shipping")
print("After injection: Rows", len(dirty_df), "Duplicates shipment_id:", dirty_df['shipment_id'].duplicated().sum(), "order_id:", dirty_df['order_id'].duplicated().sum())
