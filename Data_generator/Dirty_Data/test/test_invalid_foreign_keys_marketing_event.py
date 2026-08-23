import pandas as pd

from Data_generator.Dirty_Data.invalid_foreign_keys import (
    InvalidForeignKeyInjector
)


# ============================================================
# PARENT: CUSTOMER
# ============================================================

customer_df = pd.DataFrame({
    "customer_id": range(1001, 1101),
})


# ============================================================
# CHILD: MARKETING EVENT
# ============================================================

marketing_event_df = pd.DataFrame({
    "event_id": range(1, 101),
    "customer_id": range(1001, 1101),
})


# ============================================================
# VALID CUSTOMER KEYS
# ============================================================

valid_customer_ids = set(
    customer_df["customer_id"]
)


# ============================================================
# BEFORE INJECTION
# ============================================================

print("Before injection:")

invalid_before = (
    ~marketing_event_df["customer_id"]
    .isin(valid_customer_ids)
).sum()

print(
    f"Invalid customer_id: {invalid_before}"
)


# ============================================================
# INJECTION
# ============================================================

injector = InvalidForeignKeyInjector(seed=42)

dirty_marketing_events = injector.inject(
    marketing_event_df,
    customer_df,
    "marketing_event",
    "customer_id"
)


# ============================================================
# AFTER INJECTION
# ============================================================

print("\nAfter injection:")

invalid_after = (
    ~dirty_marketing_events["customer_id"]
    .isin(valid_customer_ids)
).sum()

print(
    f"Invalid customer_id: {invalid_after}"
)


# ============================================================
# SHOW INVALID VALUES
# ============================================================

print(
    "Invalid customer_id values:",
    dirty_marketing_events.loc[
        ~dirty_marketing_events["customer_id"].isin(
            valid_customer_ids
        ),
        "customer_id"
    ].tolist()
)