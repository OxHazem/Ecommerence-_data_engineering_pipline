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
# SHIPPING
# ============================================================

shipping_df = pd.DataFrame({
    "shipment_id": range(5001, 6001),

    "order_id": range(1, 1001),

    "shipping_date": pd.date_range(
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

shipping_order_dates = (
    shipping_df["order_id"]
    .map(order_dates)
)

print("Before injection:")

invalid_before = (
    shipping_df["shipping_date"]
    < shipping_order_dates
).sum()

print(
    "Shipping before order date:",
    invalid_before
)


# ============================================================
# INJECTION
# ============================================================

injector = BusinessRuleInjector(seed=42)

dirty_shipping = injector.inject(
    shipping_df,
    "shipping",
    "shipping_date",
    reference_df=order_df
)


# ============================================================
# AFTER INJECTION
# ============================================================

shipping_order_dates_after = (
    dirty_shipping["order_id"]
    .map(order_dates)
)

print("\nAfter injection:")

invalid_after = (
    dirty_shipping["shipping_date"]
    < shipping_order_dates_after
).sum()

print(
    "Shipping before order date:",
    invalid_after
)


# ============================================================
# SHOW INVALID RECORDS
# ============================================================

invalid_records = dirty_shipping.loc[
    dirty_shipping["shipping_date"]
    < shipping_order_dates_after,
    [
        "shipment_id",
        "order_id",
        "shipping_date"
    ]
]

print("\nInvalid records:")

print(invalid_records)