import pandas as pd
import os
import sys
import traceback

sys.path.append("/home/omar-hazem/projects/Ecommenrence_Data_enginerring pipeline")

from Data_generator.Dirty_Data.injector import DirtyDataInjector

clean_dir = "/home/omar-hazem/projects/Ecommenrence_Data_enginerring pipeline/Data/generated/clean"
md_path = "/home/omar-hazem/.gemini/antigravity-cli/brain/9ca05c8e-1ae0-4298-9c90-bfd05c8ddee6/injector_full_test_results.md"

def load_data():
    return {
        "customer": pd.read_json(os.path.join(clean_dir, "customers.json")),
        "product": pd.read_csv(os.path.join(clean_dir, "products.csv")),
        "order": pd.read_csv(os.path.join(clean_dir, "orders.csv")),
        "order_item": pd.read_csv(os.path.join(clean_dir, "order_items.csv")),
        "payment": pd.read_csv(os.path.join(clean_dir, "payments.csv")),
        "shipping": pd.read_csv(os.path.join(clean_dir, "shipping.csv")),
        "review": pd.read_json(os.path.join(clean_dir, "reviews.json")),
        "marketing_event": pd.read_csv(os.path.join(clean_dir, "marketing_events.csv")),
    }

def main():
    with open(md_path, "w") as f:
        f.write("# Full DirtyDataInjector Test Results\n\n")
        try:
            print("Loading clean data...")
            clean_data = load_data()
            f.write("## 1. Data Loading\n")
            f.write("✅ All clean datasets loaded successfully.\n\n")
            
            for k, v in clean_data.items():
                f.write(f"- `{k}`: {len(v)} rows\n")
            f.write("\n")
            
            print("Initializing injector...")
            injector = DirtyDataInjector(seed=42)
            
            print("Running injection... (This may take a minute for large datasets)")
            dirty_data = injector.inject(clean_data)
            
            f.write("## 2. Injection Execution\n")
            f.write("✅ `DirtyDataInjector.inject()` executed successfully across all entities without any exceptions!\n\n")
            
            f.write("## 3. High-Level Impact Summary\n\n")
            f.write("| Entity | Clean Rows | Dirty Rows | Clean Nulls | Dirty Nulls |\n")
            f.write("|--------|------------|------------|-------------|-------------|\n")
            
            for k in clean_data.keys():
                c_df = clean_data[k]
                d_df = dirty_data[k]
                
                c_rows = len(c_df)
                d_rows = len(d_df)
                
                c_nulls = c_df.isna().sum().sum()
                d_nulls = d_df.isna().sum().sum()
                
                f.write(f"| `{k}` | {c_rows} | {d_rows} | {c_nulls} | {d_nulls} |\n")
                
            print(f"Test completed successfully. Results written to {md_path}")
            
        except Exception as e:
            err = traceback.format_exc()
            print("Error occurred:\n", err)
            f.write("## ❌ Injection Failed\n\n")
            f.write("```text\n")
            f.write(err)
            f.write("\n```\n")

if __name__ == "__main__":
    main()
