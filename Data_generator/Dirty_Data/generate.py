import os
import sys
import pandas as pd

# Add project root to path
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../..'))
sys.path.append(BASE_DIR)

from Data_generator.Dirty_Data.injector import DirtyDataInjector

CLEAN_DIR = os.path.join(BASE_DIR, "Data/generated/clean")
DIRTY_DIR = os.path.join(BASE_DIR, "Data/generated/dirty")

def main():
    # Ensure dirty directory exists
    os.makedirs(DIRTY_DIR, exist_ok=True)
    
    print(f"Loading clean data from {CLEAN_DIR}...")
    clean_data = {
        "customer": pd.read_json(os.path.join(CLEAN_DIR, "customers.json")),
        "product": pd.read_csv(os.path.join(CLEAN_DIR, "products.csv")),
        "order": pd.read_csv(os.path.join(CLEAN_DIR, "orders.csv")),
        "order_item": pd.read_csv(os.path.join(CLEAN_DIR, "order_items.csv")),
        "payment": pd.read_csv(os.path.join(CLEAN_DIR, "payments.csv")),
        "shipping": pd.read_csv(os.path.join(CLEAN_DIR, "shipping.csv")),
        "review": pd.read_json(os.path.join(CLEAN_DIR, "reviews.json")),
        "marketing_event": pd.read_csv(os.path.join(CLEAN_DIR, "marketing_events.csv")),
    }
    
    print("Injecting dirty data... (This may take a moment)")
    injector = DirtyDataInjector(seed=42)
    dirty_data = injector.inject(clean_data)
    
    print(f"Saving dirty datasets to {DIRTY_DIR}...")
    dirty_data["customer"].to_json(os.path.join(DIRTY_DIR, "customers.json"), orient="records", date_format="iso")
    dirty_data["product"].to_csv(os.path.join(DIRTY_DIR, "products.csv"), index=False)
    dirty_data["order"].to_csv(os.path.join(DIRTY_DIR, "orders.csv"), index=False)
    dirty_data["order_item"].to_csv(os.path.join(DIRTY_DIR, "order_items.csv"), index=False)
    dirty_data["payment"].to_csv(os.path.join(DIRTY_DIR, "payments.csv"), index=False)
    dirty_data["shipping"].to_csv(os.path.join(DIRTY_DIR, "shipping.csv"), index=False)
    dirty_data["review"].to_json(os.path.join(DIRTY_DIR, "reviews.json"), orient="records", date_format="iso")
    dirty_data["marketing_event"].to_csv(os.path.join(DIRTY_DIR, "marketing_events.csv"), index=False)
    
    print("All dirty datasets have been successfully saved!")

if __name__ == "__main__":
    main()
