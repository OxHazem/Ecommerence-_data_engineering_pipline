import pandas as pd

from Data_generator.Dirty_Data.invalid_foreign_keys import (
    InvalidForeignKeyInjector
)


# ============================================================
# PARENT: ORDER
# ============================================================

order_df = pd.DataFrame({
    "order_id": range(1, 101),
})


# ============================================================
# CHILD: PAYMENT
# ============================================================

payment_df = pd.DataFrame({
    "payment_id": range(1001, 1101),
    "order_id": range(1, 101),
})


# ============================================================
# CHILD: SHIPPING
# ============================================================

shipping_df = pd.DataFrame({
    "shipment_id": range(2001, 2101),
    "order_id": range(1, 101),
})


# ============================================================
# VALID PARENT KEYS
# ============================================================

valid_order_ids = set(
    order_df["order_id"]
)


# ============================================================
# BEFORE INJECTION
# ============================================================

print("Before injection:")

invalid_payment_before = (
    ~payment_df["order_id"]
    .isin(valid_order_ids)
).sum()

invalid_shipping_before = (
    ~shipping_df["order_id"]
    .isin(valid_order_ids)
).sum()

print(
    f"Invalid Payment.order_id: "
    f"{invalid_payment_before}"
)

print(
    f"Invalid Shipping.order_id: "
    f"{invalid_shipping_before}"
)


# ============================================================
# INJECTION
# ============================================================

injector = InvalidForeignKeyInjector(seed=42)


dirty_payment = injector.inject(
    payment_df,
    order_df,
    "payment",
    "order_id"
)


dirty_shipping = injector.inject(
    shipping_df,
    order_df,
    "shipping",
    "order_id"
)


# ============================================================
# AFTER INJECTION
# ============================================================

print("\nAfter injection:")

invalid_payment_after = (
    ~dirty_payment["order_id"]
    .isin(valid_order_ids)
).sum()

invalid_shipping_after = (
    ~dirty_shipping["order_id"]
    .isin(valid_order_ids)
).sum()

print(
    f"Invalid Payment.order_id: "
    f"{invalid_payment_after}"
)

print(
    f"Invalid Shipping.order_id: "
    f"{invalid_shipping_after}"
)


# ============================================================
# SHOW INVALID VALUES
# ============================================================

print(
    "Invalid Payment.order_id values:",
    dirty_payment.loc[
        ~dirty_payment["order_id"].isin(valid_order_ids),
        "order_id"
    ].tolist()
)

print(
    "Invalid Shipping.order_id values:",
    dirty_shipping.loc[
        ~dirty_shipping["order_id"].isin(valid_order_ids),
        "order_id"
    ].tolist()
)