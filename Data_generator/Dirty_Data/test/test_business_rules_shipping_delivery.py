import pandas as pd

from Data_generator.Dirty_Data.business_rules import (
    BusinessRuleInjector
)


# ============================================================
# CLEAN SHIPPING DATA
# ============================================================

shipping_df = pd.DataFrame({
    "shipment_id": range(5001, 6001),

    "order_id": range(1, 1001),

    "shipping_date": pd.date_range(
        start="2025-01-01",
        periods=1000,
        freq="D"
    ),

    "delivery_date": pd.date_range(
        start="2025-01-04",
        periods=1000,
        freq="D"
    )
})


# ============================================================
# BEFORE INJECTION
# ============================================================

shipping_dates = pd.to_datetime(
    shipping_df["shipping_date"]
)

delivery_dates = pd.to_datetime(
    shipping_df["delivery_date"]
)

print("Before injection:")

invalid_before = (
    delivery_dates < shipping_dates
).sum()

print(
    "Delivery before shipping date:",
    invalid_before
)


# ============================================================
# INJECTION
# ============================================================

injector = BusinessRuleInjector(seed=42)

dirty_shipping = injector.inject(
    shipping_df,
    "shipping",
    "delivery_date"
)


# ============================================================
# AFTER INJECTION
# ============================================================

delivery_dates_after = pd.to_datetime(
    dirty_shipping["delivery_date"]
)

shipping_dates_after = pd.to_datetime(
    dirty_shipping["shipping_date"]
)

print("\nAfter injection:")

invalid_after = (
    delivery_dates_after < shipping_dates_after
).sum()

print(
    "Delivery before shipping date:",
    invalid_after
)


# ============================================================
# SHOW INVALID RECORDS
# ============================================================

invalid_records = dirty_shipping.loc[
    delivery_dates_after < shipping_dates_after,
    [
        "shipment_id",
        "order_id",
        "shipping_date",
        "delivery_date"
    ]
]

print("\nInvalid records:")

print(invalid_records)