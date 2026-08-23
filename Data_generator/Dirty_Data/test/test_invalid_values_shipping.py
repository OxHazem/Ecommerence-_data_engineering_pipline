import pandas as pd
from Data_generator.Dirty_Data.invalid_values import InvalidValueInjector

df = pd.DataFrame({
    "shipment_id": range(1, 101),
    "shipping_status": ["Pending"] * 100
})
print("Before injection invalid shipping_status:", (~df['shipping_status'].isin(["Pending", "Shipped", "In Transit", "Delivered", "Returned"])).sum())
injector = InvalidValueInjector(seed=42)
dirty_df = injector.inject(df, "shipping")
print("After injection invalid shipping_status:", (~dirty_df['shipping_status'].isin(["Pending", "Shipped", "In Transit", "Delivered", "Returned"])).sum())
