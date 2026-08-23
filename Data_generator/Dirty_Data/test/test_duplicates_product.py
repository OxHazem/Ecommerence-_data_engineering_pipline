import pandas as pd
from Data_generator.Dirty_Data.duplicates import DuplicateInjector

df = pd.DataFrame({
    "product_id": range(1, 101),
    "product_name": [f"Product {i}" for i in range(1, 101)]
})
print("Before injection: Rows", len(df), "Duplicates:", df['product_id'].duplicated().sum())
injector = DuplicateInjector(seed=42)
dirty_df = injector.inject(df, "product")
print("After injection: Rows", len(dirty_df), "Duplicates:", dirty_df['product_id'].duplicated().sum())
