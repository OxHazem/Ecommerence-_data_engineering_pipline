import pandas as pd
from Data_generator.Dirty_Data.business_rules import BusinessRuleInjector

customer_df = pd.DataFrame({
    "customer_id": range(1001, 1101),
    "registration_date": pd.date_range("2026-01-01", periods=100)
})
df = pd.DataFrame({
    "event_id": range(1, 101),
    "customer_id": range(1001, 1101),
    "event_timestamp": pd.date_range("2026-02-01", periods=100)
})
print("Before injection:")
merged = df.merge(customer_df, on="customer_id")
print("Event before reg:", (pd.to_datetime(merged['event_timestamp']) < pd.to_datetime(merged['registration_date'])).sum())

injector = BusinessRuleInjector(seed=42)
dirty_df = injector.inject(df, "marketing_event", "event_timestamp", customer_df)

print("After injection:")
merged_dirty = dirty_df.merge(customer_df, on="customer_id")
print("Event before reg:", (pd.to_datetime(merged_dirty['event_timestamp']) < pd.to_datetime(merged_dirty['registration_date'])).sum())
