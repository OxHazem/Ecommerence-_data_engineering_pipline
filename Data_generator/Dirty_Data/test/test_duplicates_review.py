import pandas as pd
from Data_generator.Dirty_Data.duplicates import DuplicateInjector

df = pd.DataFrame({
    "review_id": range(1, 101),
    "customer_id": range(1, 101),
    "product_id": range(1, 101)
})
print("Before injection: Rows", len(df))
injector = DuplicateInjector(seed=42)
dirty_df = injector.inject(df, "review")
print("After injection: Rows", len(dirty_df))
