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
# PARENT: PRODUCT
# ============================================================

product_df = pd.DataFrame({
    "product_id": range(2001, 2101),
})


# ============================================================
# CHILD: REVIEW
# ============================================================

review_df = pd.DataFrame({
    "customer_id": range(1001, 1101),
    "product_id": range(2001, 2101),
})


# ============================================================
# VALID KEYS
# ============================================================

valid_customer_ids = set(
    customer_df["customer_id"]
)

valid_product_ids = set(
    product_df["product_id"]
)


# ============================================================
# BEFORE INJECTION
# ============================================================

print("Before injection:")

invalid_customer_before = (
    ~review_df["customer_id"]
    .isin(valid_customer_ids)
).sum()

invalid_product_before = (
    ~review_df["product_id"]
    .isin(valid_product_ids)
).sum()

print(
    f"Invalid customer_id: "
    f"{invalid_customer_before}"
)

print(
    f"Invalid product_id: "
    f"{invalid_product_before}"
)


# ============================================================
# INJECTION
# ============================================================

injector = InvalidForeignKeyInjector(seed=42)


dirty_review = injector.inject(
    review_df,
    customer_df,
    "review",
    "customer_id"
)


dirty_review = injector.inject(
    dirty_review,
    product_df,
    "review",
    "product_id"
)


# ============================================================
# AFTER INJECTION
# ============================================================

print("\nAfter injection:")

invalid_customer_after = (
    ~dirty_review["customer_id"]
    .isin(valid_customer_ids)
).sum()

invalid_product_after = (
    ~dirty_review["product_id"]
    .isin(valid_product_ids)
).sum()

print(
    f"Invalid customer_id: "
    f"{invalid_customer_after}"
)

print(
    f"Invalid product_id: "
    f"{invalid_product_after}"
)


# ============================================================
# SHOW INVALID VALUES
# ============================================================

print(
    "Invalid customer_id values:",
    dirty_review.loc[
        ~dirty_review["customer_id"].isin(
            valid_customer_ids
        ),
        "customer_id"
    ].tolist()
)

print(
    "Invalid product_id values:",
    dirty_review.loc[
        ~dirty_review["product_id"].isin(
            valid_product_ids
        ),
        "product_id"
    ].tolist()
)