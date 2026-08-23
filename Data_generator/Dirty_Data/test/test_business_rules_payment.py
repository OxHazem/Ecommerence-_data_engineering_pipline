import pandas as pd

from Data_generator.Dirty_Data.business_rules import (
    BusinessRuleInjector
)


# ============================================================
# ORDER
# ============================================================

order_df = pd.DataFrame({
    "order_id": range(1, 1001),

    "order_date": pd.date_range(
        start="2025-01-01",
        periods=1000,
        freq="D"
    )
})


# ============================================================
# PAYMENT
# ============================================================

payment_df = pd.DataFrame({
    "payment_id": range(5001, 6001),

    "order_id": range(1, 1001),

    "payment_date": pd.date_range(
        start="2025-01-02",
        periods=1000,
        freq="D"
    )
})


# ============================================================
# BEFORE INJECTION
# ============================================================

order_dates = (
    order_df
    .set_index("order_id")["order_date"]
)

payment_order_dates = (
    payment_df["order_id"]
    .map(order_dates)
)

print("Before injection:")

invalid_before = (
    payment_df["payment_date"]
    < payment_order_dates
).sum()

print(
    "Payments before order date:",
    invalid_before
)


# ============================================================
# INJECTION
# ============================================================

injector = BusinessRuleInjector(seed=42)

dirty_payments = injector.inject(
    payment_df,
    "payment",
    "payment_date",
    reference_df=order_df
)


# ============================================================
# AFTER INJECTION
# ============================================================

payment_order_dates_after = (
    dirty_payments["order_id"]
    .map(order_dates)
)

print("\nAfter injection:")

invalid_after = (
    dirty_payments["payment_date"]
    < payment_order_dates_after
).sum()

print(
    "Payments before order date:",
    invalid_after
)


# ============================================================
# SHOW INVALID RECORDS
# ============================================================

invalid_records = dirty_payments.loc[
    dirty_payments["payment_date"]
    < payment_order_dates_after,
    [
        "payment_id",
        "order_id",
        "payment_date"
    ]
]

print("\nInvalid records:")

print(invalid_records)