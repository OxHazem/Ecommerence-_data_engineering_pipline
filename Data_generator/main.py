import os
import csv
import json

from Data_generator.generators.Data_generator import data_generator
from Data_generator.config import (
    SEED,
    CUSTOMER_COUNT,
    PRODUCT_COUNT,
    ORDER_COUNT,
    ORDER_ITEM_COUNT,
    PAYMENT_COUNT,
    SHIPPING_COUNT,
    REVIEW_COUNT,
    MARKETING_EVENT_COUNT
)


# ============================================================
# Output Configuration
# ============================================================

OUTPUT_DIR = "Data/generated/clean"


# ============================================================
# Helper Functions
# ============================================================

def save_csv(data, filename):
    """
    Save a list of dictionaries as a CSV file.
    """

    if not data:
        return

    filepath = os.path.join(OUTPUT_DIR, filename)

    with open(filepath, "w", newline="", encoding="utf-8") as file:

        writer = csv.DictWriter(
            file,
            fieldnames=data[0].keys()
        )

        writer.writeheader()
        writer.writerows(data)

    print(f"Saved: {filepath}")


def save_json(data, filename):
    """
    Save a list of dictionaries as a JSON file.
    """

    filepath = os.path.join(OUTPUT_DIR, filename)

    with open(filepath, "w", encoding="utf-8") as file:

        json.dump(
            data,
            file,
            indent=4,
            default=str
        )

    print(f"Saved: {filepath}")


# ============================================================
# Main Data Generation Pipeline
# ============================================================

def main():

    print("=" * 60)
    print("E-COMMERCE DATA GENERATION")
    print("=" * 60)

    # --------------------------------------------------------
    # Create output directory
    # --------------------------------------------------------

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # --------------------------------------------------------
    # Initialize generator
    # --------------------------------------------------------

    generator = data_generator(
        seed=SEED
    )

    print(f"\nSeed: {SEED}")
    print(f"Output directory: {OUTPUT_DIR}")

    # ========================================================
    # 1. Customer
    # ========================================================

    print("\n[1/8] Generating Customers...")

    customers = generator.generator_customer(
        CUSTOMER_COUNT
    )

    save_json(
        customers,
        "customers.json"
    )

    print(f"Generated {len(customers):,} customers")

    # ========================================================
    # 2. Product
    # ========================================================

    print("\n[2/8] Generating Products...")

    products = generator.generator_product(
        PRODUCT_COUNT
    )

    save_csv(
        products,
        "products.csv"
    )

    print(f"Generated {len(products):,} products")

    # ========================================================
    # 3. Order
    # ========================================================

    print("\n[3/8] Generating Orders...")

    orders = generator.generator_order(
        customers,
        ORDER_COUNT
    )

    save_csv(
        orders,
        "orders.csv"
    )

    print(f"Generated {len(orders):,} orders")

    # ========================================================
    # 4. Order Item
    # ========================================================

    print("\n[4/8] Generating Order Items...")

    order_items = generator.generator_order_item(
        orders,
        products,
        ORDER_ITEM_COUNT
    )

    save_csv(
        order_items,
        "order_items.csv"
    )

    print(f"Generated {len(order_items):,} order items")

    # ========================================================
    # 5. Payment
    # ========================================================

    print("\n[5/8] Generating Payments...")

    payments = generator.generator_payment(
        orders,
        PAYMENT_COUNT
    )

    save_csv(
        payments,
        "payments.csv"
    )

    print(f"Generated {len(payments):,} payments")

    # ========================================================
    # 6. Shipping
    # ========================================================

    print("\n[6/8] Generating Shipping...")

    shipping = generator.generator_shipping(
        orders,
        SHIPPING_COUNT
    )

    save_csv(
        shipping,
        "shipping.csv"
    )

    print(f"Generated {len(shipping):,} shipping records")

    # ========================================================
    # 7. Review
    # ========================================================

    print("\n[7/8] Generating Reviews...")

    reviews = generator.generator_review(
        customers,
        products,
        REVIEW_COUNT
    )

    save_json(
        reviews,
        "reviews.json"
    )

    print(f"Generated {len(reviews):,} reviews")

    # ========================================================
    # 8. Marketing Event
    # ========================================================

    print("\n[8/8] Generating Marketing Events...")

    marketing_events = generator.generator_marketing_event(
        customers,
        MARKETING_EVENT_COUNT
    )

    save_csv(
        marketing_events,
        "marketing_events.csv"
    )

    print(
        f"Generated "
        f"{len(marketing_events):,} marketing events"
    )

    # ========================================================
    # Summary
    # ========================================================

    print("\n" + "=" * 60)
    print("DATA GENERATION COMPLETED")
    print("=" * 60)

    print(f"""
Customers:          {len(customers):,}
Products:           {len(products):,}
Orders:             {len(orders):,}
Order Items:        {len(order_items):,}
Payments:           {len(payments):,}
Shipping:           {len(shipping):,}
Reviews:            {len(reviews):,}
Marketing Events:   {len(marketing_events):,}
""")

    print(f"Output: {OUTPUT_DIR}")
    print("=" * 60)


# ============================================================
# Entry Point
# ============================================================

if __name__ == "__main__":
    main()