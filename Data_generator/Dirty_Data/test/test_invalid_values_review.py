import pandas as pd

from Data_generator.Dirty_Data.invalid_values import (
    InvalidValueInjector
)


# ============================================================
# CLEAN REVIEW DATA
# ============================================================

review_df = pd.DataFrame({
    "review_id": range(2001, 3001),

    "customer_id": range(1001, 2001),

    "product_id": range(101, 1101),

    "rating": [1, 2, 3, 4, 5] * 200
})


# ============================================================
# BEFORE INJECTION
# ============================================================

print("Before injection:")

invalid_before = (
    (review_df["rating"] < 1)
    | (review_df["rating"] > 5)
).sum()

print(
    "Invalid rating:",
    invalid_before
)


# ============================================================
# INJECTION
# ============================================================

injector = InvalidValueInjector(seed=42)

dirty_review = injector.inject(
    review_df,
    "review"
)


# ============================================================
# AFTER INJECTION
# ============================================================

print("\nAfter injection:")

invalid_after = (
    (dirty_review["rating"] < 1)
    | (dirty_review["rating"] > 5)
).sum()

print(
    "Invalid rating:",
    invalid_after
)


# ============================================================
# INVALID VALUES
# ============================================================

invalid_records = dirty_review.loc[
    (dirty_review["rating"] < 1)
    | (dirty_review["rating"] > 5),
    [
        "review_id",
        "rating"
    ]
]

print("\nInvalid records:")

print(invalid_records)