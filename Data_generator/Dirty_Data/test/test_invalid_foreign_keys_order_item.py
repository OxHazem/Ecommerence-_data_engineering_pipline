import pandas as pd

from Data_generator.Dirty_Data.invalid_foreign_keys import (
    InvalidForeignKeyInjector
)


# ------------------------------------------------------------
# Parent: Order
# ------------------------------------------------------------

order_df = pd.DataFrame({
    "order_id": range(1, 101),
})


# ------------------------------------------------------------
# Parent: Product
# ------------------------------------------------------------

product_df = pd.DataFrame({
    "product_id": range(1001, 1101),
})


# ------------------------------------------------------------
# Child: Order_Item
# ------------------------------------------------------------

order_item_df = pd.DataFrame({
    "order_id": range(1, 101),
    "product_id": range(1001, 1101),
})


# ------------------------------------------------------------
# Before injection
# ------------------------------------------------------------

valid_order_ids = set(order_df["order_id"])
valid_product_ids = set(product_df["product_id"])


print("Before injection:")

invalid_order_ids_before = (
    ~order_item_df["order_id"]
    .isin(valid_order_ids)
).sum()

invalid_product_ids_before = (
    ~order_item_df["product_id"]
    .isin(valid_product_ids)
).sum()

print(
    f"Invalid order_id: {invalid_order_ids_before}"
)

print(
    f"Invalid product_id: {invalid_product_ids_before}"
)


# ------------------------------------------------------------
# Injection
# ------------------------------------------------------------

injector = InvalidForeignKeyInjector(seed=42)

dirty_order_items = injector.inject(
    order_item_df,
    order_df,
    "order_item",
    "order_id"
)

dirty_order_items = injector.inject(
    dirty_order_items,
    product_df,
    "order_item",
    "product_id"
)


# ------------------------------------------------------------
# After injection
# ------------------------------------------------------------

print("\nAfter injection:")

invalid_order_ids_after = (
    ~dirty_order_items["order_id"]
    .isin(valid_order_ids)
).sum()

invalid_product_ids_after = (
    ~dirty_order_items["product_id"]
    .isin(valid_product_ids)
).sum()

print(
    f"Invalid order_id: {invalid_order_ids_after}"
)

print(
    f"Invalid product_id: {invalid_product_ids_after}"
)

print(
    "Invalid order_id values:",
    dirty_order_items.loc[
        ~dirty_order_items["order_id"].isin(valid_order_ids),
        "order_id"
    ].tolist()
)

print(
    "Invalid product_id values:",
    dirty_order_items.loc[
        ~dirty_order_items["product_id"].isin(valid_product_ids),
        "product_id"
    ].tolist()
)