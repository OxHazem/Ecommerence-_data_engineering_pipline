import pandas as pd

from Data_generator.Dirty_Data.business_rules import (
    BusinessRuleInjector
)


# ============================================================
# CUSTOMER
# ============================================================

customer_df = pd.DataFrame({
    "customer_id": range(1001, 2001),

    "registration_date": pd.date_range(
        end=pd.Timestamp("2025-01-01"),
        periods=1000,
        freq="D"
    )
})


# ============================================================
# ORDER
# ============================================================

order_df = pd.DataFrame({
    "order_id": range(1, 1001),

    "customer_id": range(1001, 2001),

    "order_date": pd.date_range(
        start="2025-01-02",
        periods=1000,
        freq="D"
    )
})


# ============================================================
# BEFORE INJECTION
# ============================================================

customer_registration = (
    customer_df
    .set_index("customer_id")["registration_date"]
)

order_dates = pd.to_datetime(
    order_df["order_date"]
)

registration_dates = (
    order_df["customer_id"]
    .map(customer_registration)
)

print("Before injection:")

invalid_before = (
    order_dates < registration_dates
).sum()

print(
    "Orders before customer registration:",
    invalid_before
)


# ============================================================
# INJECTION
# ============================================================

injector = BusinessRuleInjector(seed=42)

dirty_orders = injector.inject(
    order_df,
    "order",
    "order_date_before_customer_registration",
    reference_df=customer_df
)


# ============================================================
# AFTER INJECTION
# ============================================================

order_dates_after = pd.to_datetime(
    dirty_orders["order_date"]
)

registration_dates_after = (
    dirty_orders["customer_id"]
    .map(customer_registration)
)

print("\nAfter injection:")

invalid_after = (
    order_dates_after < registration_dates_after
).sum()

print(
    "Orders before customer registration:",
    invalid_after
)


# ============================================================
# SHOW INVALID RECORDS
# ============================================================

invalid_records = dirty_orders.loc[
    order_dates_after < registration_dates_after,
    [
        "order_id",
        "customer_id",
        "order_date"
    ]
]

print("\nInvalid records:")

print(invalid_records)