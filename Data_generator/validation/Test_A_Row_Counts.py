import os

from Data_generator.validation.validation_clean_data import (
    validate_row_counts,
)
from Data_generator.config import (
    CUSTOMER_COUNT,
    PRODUCT_COUNT,
    ORDER_COUNT,
    ORDER_ITEM_COUNT,
    PAYMENT_COUNT,
    SHIPPING_COUNT,
    REVIEW_COUNT,
    MARKETING_EVENT_COUNT
)

EXPECTED_ROW_COUNTS = {

    "customers.json": CUSTOMER_COUNT,

    "products.csv": PRODUCT_COUNT,

    "orders.csv": ORDER_COUNT,

    "order_items.csv": ORDER_ITEM_COUNT,

    "payments.csv": PAYMENT_COUNT,

    "shipping.csv": SHIPPING_COUNT,

    "reviews.json": REVIEW_COUNT,

    "marketing_events.csv": MARKETING_EVENT_COUNT
}




DATA_DIR = os.path.join(
    "Data",
    "generated",
    "clean"
)



if __name__ == "__main__":

    print("=" * 60)
    print("TEST A - ROW COUNTS")
    print("=" * 60)

    result = validate_row_counts(
        data_dir=DATA_DIR,
        expected_counts=EXPECTED_ROW_COUNTS
    )

    print("\n" + "=" * 60)

    if result:
        print("✓ TEST A PASSED")
    else:
        print("❌ TEST A FAILED")

    print("=" * 60)