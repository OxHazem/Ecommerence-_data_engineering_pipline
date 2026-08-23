import pandas as pd
from Data_generator.Dirty_Data.invalid_values import InvalidValueInjector

df = pd.DataFrame({
    "order_id": range(1, 101),
    "order_status": ["Pending"] * 100
})
print("Before injection invalid order_status:", (~df['order_status'].isin(["Pending", "Processing", "Shipped", "Delivered", "Cancelled"])).sum())
injector = InvalidValueInjector(seed=42)
dirty_df = injector.inject(df, "order")
print("After injection invalid order_status:", (~dirty_df['order_status'].isin(["Pending", "Processing", "Shipped", "Delivered", "Cancelled"])).sum())
