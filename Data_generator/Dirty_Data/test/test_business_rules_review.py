import pandas as pd

from Data_generator.Dirty_Data.business_rules import (
    BusinessRuleInjector
)


# ============================================================
# CUSTOMER DATA
# ============================================================

customer_df = pd.DataFrame({
    "customer_id": range(1001, 2001),

    "registration_date": pd.date_range(
        start="2025-01-01",
        periods=1000,
        freq="D"
    )
})


# ============================================================
# REVIEW DATA
# ============================================================

review_df = pd.DataFrame({
    "review_id": range(2001, 3001),

    "customer_id": range(1001, 2001),

    "review_date": pd.date_range(
        start="2025-01-02",
        periods=1000,
        freq="D"
    )
})


# ============================================================
# BEFORE INJECTION
# ============================================================

registration_dates = (
    customer_df
    .set_index("customer_id")["registration_date"]
)

review_registration_dates = (
    review_df["customer_id"]
    .map(registration_dates)
)

print("Before injection:")

invalid_before = (
    review_df["review_date"]
    < review_registration_dates
).sum()

print(
    "Reviews before customer registration:",
    invalid_before
)


# ============================================================
# INJECTION
# ============================================================

injector = BusinessRuleInjector(seed=42)

dirty_review = injector.inject(
    review_df,
    "review",
    "review_date",
    reference_df=customer_df
)


# ============================================================
# AFTER INJECTION
# ============================================================

review_registration_dates_after = (
    dirty_review["customer_id"]
    .map(registration_dates)
)

print("\nAfter injection:")

invalid_after = (
    dirty_review["review_date"]
    < review_registration_dates_after
).sum()

print(
    "Reviews before customer registration:",
    invalid_after
)


# ============================================================
# INVALID RECORDS
# ============================================================

invalid_records = dirty_review.loc[
    dirty_review["review_date"]
    < review_registration_dates_after,
    [
        "review_id",
        "customer_id",
        "review_date"
    ]
]

print("\nInvalid records:")

print(invalid_records)