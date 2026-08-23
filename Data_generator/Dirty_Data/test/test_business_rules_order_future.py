import pandas as pd

from Data_generator.Dirty_Data.business_rules import (
    BusinessRuleInjector
)


# ============================================================
# CLEAN ORDER DATA
# ============================================================

df = pd.DataFrame({
    "order_id": range(1, 1001),

    "order_date": pd.date_range(
        end=pd.Timestamp.today().normalize(),
        periods=1000,
        freq="D"
    )
})


# ============================================================
# BEFORE INJECTION
# ============================================================

today = pd.Timestamp.today().normalize()

print("Before injection:")

future_before = (
    pd.to_datetime(df["order_date"]) > today
).sum()

print(
    f"Future order dates: {future_before}"
)


# ============================================================
# INJECTION
# ============================================================

injector = BusinessRuleInjector(seed=42)

dirty_df = injector.inject(
    df,
    "order",
    "order_date_future"
)


# ============================================================
# AFTER INJECTION
# ============================================================

print("\nAfter injection:")

future_after = (
    pd.to_datetime(dirty_df["order_date"]) > today
).sum()

print(
    f"Future order dates: {future_after}"
)


# ============================================================
# SHOW INVALID VALUES
# ============================================================

print(
    "Future dates:",
    dirty_df.loc[
        pd.to_datetime(
            dirty_df["order_date"]
        ) > today,
        "order_date"
    ].tolist()
)