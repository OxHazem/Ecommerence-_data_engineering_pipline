import pandas as pd

from Data_generator.Dirty_Data.invalid_foreign_keys import (
    InvalidForeignKeyInjector
)


# ------------------------------------------------------------
# Parent: Customer
# ------------------------------------------------------------

customer_df = pd.DataFrame({
    "customer_id": range(1001, 1101),
    "first_name": [
        f"Customer{i}"
        for i in range(1, 101)
    ],
})


# ------------------------------------------------------------
# Child: Order
# ------------------------------------------------------------

order_df = pd.DataFrame({
    "order_id": range(1, 101),
    "customer_id": range(1001, 1101),
})


print("Before injection:")

valid_customer_ids = set(
    customer_df["customer_id"]
)

invalid_before = (
    ~order_df["customer_id"]
    .isin(valid_customer_ids)
).sum()

print(
    f"Invalid customer_id: {invalid_before}"
)


# ------------------------------------------------------------
# Injection
# ------------------------------------------------------------

injector = InvalidForeignKeyInjector(seed=42)

dirty_orders = injector.inject(
    order_df,
    customer_df,
    "order",
    "customer_id"
)


# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------

print("\nAfter injection:")

invalid_after = (
    ~dirty_orders["customer_id"]
    .isin(valid_customer_ids)
).sum()

print(
    f"Invalid customer_id: {invalid_after}"
)

print(
    "Invalid FK values:",
    dirty_orders.loc[
        ~dirty_orders["customer_id"].isin(
            valid_customer_ids
        ),
        "customer_id"
    ].tolist()
)