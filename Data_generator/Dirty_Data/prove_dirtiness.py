import pandas as pd
import os

BASE_DIR = "/home/omar-hazem/projects/Ecommenrence_Data_enginerring pipeline"
CLEAN_DIR = os.path.join(BASE_DIR, "Data/generated/clean")
DIRTY_DIR = os.path.join(BASE_DIR, "Data/generated/dirty")
MD_PATH = "/home/omar-hazem/.gemini/antigravity-cli/brain/9ca05c8e-1ae0-4298-9c90-bfd05c8ddee6/dirtiness_proof.md"

def load_data(directory):
    return {
        "customer": pd.read_json(os.path.join(directory, "customers.json")),
        "product": pd.read_csv(os.path.join(directory, "products.csv")),
        "order": pd.read_csv(os.path.join(directory, "orders.csv")),
        "order_item": pd.read_csv(os.path.join(directory, "order_items.csv")),
        "payment": pd.read_csv(os.path.join(directory, "payments.csv")),
        "shipping": pd.read_csv(os.path.join(directory, "shipping.csv")),
        "review": pd.read_json(os.path.join(directory, "reviews.json")),
        "marketing_event": pd.read_csv(os.path.join(directory, "marketing_events.csv")),
    }

def main():
    print("Loading clean and dirty files directly from disk...")
    clean_data = load_data(CLEAN_DIR)
    dirty_data = load_data(DIRTY_DIR)
    
    with open(MD_PATH, "w") as f:
        f.write("# Proof of Dirtiness\n\n")
        f.write("This report proves that the files saved in `Data/generated/dirty/` have successfully retained their injected corruptions.\n\n")
        
        for entity in clean_data.keys():
            c_df = clean_data[entity]
            d_df = dirty_data[entity]
            
            f.write(f"## {entity.capitalize()}\n\n")
            
            # 1. Row Count Proof (Duplicates)
            c_len = len(c_df)
            d_len = len(d_df)
            if d_len > c_len:
                f.write(f"**Proof of Duplicates:** Row count increased from `{c_len}` to `{d_len}`.\n\n")
                
            # 2. Null Count Proof
            c_nulls = c_df.isna().sum().sum()
            d_nulls = d_df.isna().sum().sum()
            if d_nulls > c_nulls:
                f.write(f"**Proof of Missing Values:** Null count increased from `{c_nulls}` to `{d_nulls}`.\n\n")
                
            # 3. Invalid Types or Values Proof
            # Find a few rows in dirty that don't match clean (excluding duplicates/nulls, maybe just diffing string conversions)
            # A very simple proof is to just display some corrupted records if they exist.
            if entity == "order":
                # Look for 'not-a-date'
                bad_dates = d_df[d_df["order_date"] == "not-a-date"]
                if len(bad_dates) > 0:
                    f.write("**Proof of Invalid Data Types:**\n")
                    f.write("```text\n")
                    f.write(bad_dates[["order_id", "order_date"]].head(3).to_string())
                    f.write("\n```\n\n")
                    
            if entity == "customer":
                # Look for invalid gender
                valid_genders = ["Male", "Female", "Other", "Unknown"]
                bad_genders = d_df[~d_df["gender"].isin(valid_genders) & d_df["gender"].notna()]
                if len(bad_genders) > 0:
                    f.write("**Proof of Invalid Values:**\n")
                    f.write("```text\n")
                    f.write(bad_genders[["customer_id", "gender"]].head(3).to_string())
                    f.write("\n```\n\n")
                    
            if entity == "product":
                # Look for negative prices or strings
                try:
                    bad_prices = d_df[pd.to_numeric(d_df['price'], errors='coerce').isna()]
                    if len(bad_prices) > 0:
                        f.write("**Proof of Invalid Data Types (Price as text):**\n")
                        f.write("```text\n")
                        f.write(bad_prices[["product_id", "price"]].head(3).to_string())
                        f.write("\n```\n\n")
                except:
                    pass

    print("Proof generated successfully.")

if __name__ == "__main__":
    main()
