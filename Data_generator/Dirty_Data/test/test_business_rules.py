import pandas as pd

from Data_generator.Dirty_Data.business_rules import (
    BusinessRuleInjector
)


# ============================================================
# CLEAN CUSTOMER DATA
# ============================================================

df = pd.DataFrame({
    "customer_id": range(1001, 2001),

    "first_name": [
        f"Customer{i}"
        for i in range(1, 1001)
    ],

    "registration_date": pd.date_range(
    end=pd.Timestamp.today().normalize(),
    periods=1000,
    freq="D"
    ),
})


# ============================================================
# BEFORE INJECTION
# ============================================================

today = pd.Timestamp.today().normalize()

print("Before injection:")

future_before = (
    pd.to_datetime(df["registration_date"]) > today
).sum()

print(
    f"Future registration dates: "
    f"{future_before}"
)


# ============================================================
# INJECTION
# ============================================================

injector = BusinessRuleInjector(seed=42)

dirty_df = injector.inject(
    df,
    "customer",
    "registration_date"
)


# ============================================================
# AFTER INJECTION
# ============================================================

print("\nAfter injection:")

future_after = (
    pd.to_datetime(
        dirty_df["registration_date"]
    ) > today
).sum()

print(
    f"Future registration dates: "
    f"{future_after}"
)


# ============================================================
# SHOW INVALID VALUES
# ============================================================

print(
    "Future dates:",
    dirty_df.loc[
        pd.to_datetime(
            dirty_df["registration_date"]
        ) > today,
        "registration_date"
    ].tolist()
)