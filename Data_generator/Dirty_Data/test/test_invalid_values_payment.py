import pandas as pd
from Data_generator.Dirty_Data.invalid_values import InvalidValueInjector

df = pd.DataFrame({
    "payment_id": range(1, 101),
    "amount": [100.0] * 100,
    "payment_status": ["Completed"] * 100
})
print("Before injection invalid amount:", (df['amount'] < 0).sum())
injector = InvalidValueInjector(seed=42)
dirty_df = injector.inject(df, "payment")
print("After injection invalid amount:", (dirty_df['amount'] < 0).sum())
