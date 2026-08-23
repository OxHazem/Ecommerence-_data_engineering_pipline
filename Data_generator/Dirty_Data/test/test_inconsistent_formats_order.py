import pandas as pd
from Data_generator.Dirty_Data.inconsistent_formats import InconsistentFormatInjector

df = pd.DataFrame({
    "order_id": range(1, 101),
    "order_status": ["Shipped"] * 100
})
print("Before injection lower status:", (df['order_status'] == "shipped").sum())
injector = InconsistentFormatInjector(seed=42)
dirty_df = injector.inject(df, "order")
print("After injection lower status:", (dirty_df['order_status'] == "shipped").sum())
