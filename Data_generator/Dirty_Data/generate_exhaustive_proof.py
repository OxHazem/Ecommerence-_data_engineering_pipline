import pandas as pd
import os

BASE_DIR = "/home/omar-hazem/projects/Ecommenrence_Data_enginerring pipeline"
CLEAN_DIR = os.path.join(BASE_DIR, "Data/generated/clean")
DIRTY_DIR = os.path.join(BASE_DIR, "Data/generated/dirty")
MD_PATH = "/home/omar-hazem/.gemini/antigravity-cli/brain/9ca05c8e-1ae0-4298-9c90-bfd05c8ddee6/exhaustive_dirtiness_proof.md"

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
    print("Loading datasets for exhaustive proof...")
    c_data = load_data(CLEAN_DIR)
    d_data = load_data(DIRTY_DIR)

    with open(MD_PATH, "w") as f:
        f.write("# Exhaustive Entity-by-Entity Dirty Data Proof\n\n")
        f.write("This report provides a real, line-by-line check extracting exactly how each file in `Data/generated/dirty` was corrupted compared to its clean counterpart.\n\n")
        
        for entity in c_data.keys():
            f.write(f"## Entity: `{entity.upper()}`\n\n")
            c_df = c_data[entity]
            d_df = d_data[entity]
            
            pk_map = {
                "customer": "customer_id",
                "product": "product_id",
                "order": "order_id",
                "payment": "payment_id",
                "shipping": "shipment_id",
                "review": "review_id",
                "marketing_event": "event_id",
                "order_item": ["order_id", "product_id"]
            }
            pk = pk_map[entity]
            
            # 1. Duplicates
            f.write("### 1. Duplicates\n")
            if type(pk) == list:
                dupes = d_df[d_df.duplicated(subset=pk, keep=False)]
            else:
                dupes = d_df[d_df.duplicated(subset=[pk], keep=False)]
            
            if len(dupes) > 0:
                f.write(f"Found {len(dupes)} explicitly duplicated rows. Example of a duplicate:\n```text\n")
                f.write(dupes.sort_values(by=pk).head(2).to_string() + "\n```\n\n")
            else:
                f.write("*No duplicates found.*\n\n")
                
            # 2. Missing Values
            f.write("### 2. Missing Values\n")
            if type(pk) == list:
                d_unique = d_df.drop_duplicates(subset=pk, keep='first')
            else:
                d_unique = d_df.drop_duplicates(subset=[pk], keep='first')
            
            missing_cols = []
            for col in c_df.columns:
                if d_unique[col].isna().sum() > c_df[col].isna().sum():
                    missing_cols.append(col)
            
            if missing_cols:
                f.write(f"Found newly injected `null` values in columns: `{missing_cols}`. Example:\n```text\n")
                col = missing_cols[0]
                ex = d_unique[d_unique[col].isna()].head(1)
                f.write(ex.to_string() + "\n```\n\n")
            else:
                f.write("*No injected missing values found.*\n\n")
                
            # 3. Modifications (Invalid Values, Types, Formats, Business Rules)
            f.write("### 3. Data Modifications (Invalid Values, Formats, Business Rules)\n")
            if type(pk) != list:
                aligned_c = c_df.set_index(pk).sort_index()
                aligned_d = d_unique.set_index(pk).sort_index()
                
                diffs = []
                for col in aligned_c.columns:
                    if col in aligned_d.columns:
                        mask = (aligned_c[col].astype(str) != aligned_d[col].astype(str)) & aligned_c[col].notna() & aligned_d[col].notna()
                        if mask.sum() > 0:
                            diffs.append((col, mask))
                
                if diffs:
                    for col, mask in diffs:
                        f.write(f"**Corruption in column `{col}`**:\n```text\n")
                        changed_idx = aligned_c[mask].index[0]
                        c_val = aligned_c.loc[changed_idx, col]
                        d_val = aligned_d.loc[changed_idx, col]
                        f.write(f"Row {pk}={changed_idx} | Clean value: '{c_val}' -> Dirty value: '{d_val}'\n```\n\n")
                else:
                    f.write("*No direct value modifications found.*\n\n")
                    
            # 4. Invalid Foreign Keys
            f.write("### 4. Invalid Foreign Keys\n")
            fk_checks = []
            if entity == "order": fk_checks.append(("customer_id", "customer", "customer_id"))
            if entity == "payment": fk_checks.append(("order_id", "order", "order_id"))
            if entity == "shipping": fk_checks.append(("order_id", "order", "order_id"))
            if entity == "review": 
                fk_checks.append(("customer_id", "customer", "customer_id"))
                fk_checks.append(("product_id", "product", "product_id"))
            if entity == "marketing_event": fk_checks.append(("customer_id", "customer", "customer_id"))
            if entity == "order_item":
                fk_checks.append(("order_id", "order", "order_id"))
                fk_checks.append(("product_id", "product", "product_id"))
                
            fk_found = False
            for fk_col, parent_entity, parent_pk in fk_checks:
                valid_ids = set(c_data[parent_entity][parent_pk])
                invalid_rows = d_df[~d_df[fk_col].isin(valid_ids) & d_df[fk_col].notna()]
                if len(invalid_rows) > 0:
                    fk_found = True
                    f.write(f"Found invalid `{fk_col}` pointing to non-existent `{parent_entity}`. Example of invalid ID:\n```text\n")
                    f.write(invalid_rows[[fk_col]].head(1).to_string() + "\n```\n\n")
                    
            if not fk_found:
                f.write("*No invalid foreign keys configured or found.*\n\n")
                
            f.write("---\n\n")
            
    print("Exhaustive proof generated.")

if __name__ == "__main__":
    main()
