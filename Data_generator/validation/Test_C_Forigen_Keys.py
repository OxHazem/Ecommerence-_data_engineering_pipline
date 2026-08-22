import os 
from Data_generator.validation.validation_clean_data import validate_all_foreign_keys

DATA_DIR = os.path.join(
    "Data",
    "generated",
    "clean"
)

if __name__ == "__main__":

    print("=" * 60)
    print("TEST C - Foriegn KEYS")
    print("=" * 60)

    result = validate_all_foreign_keys(DATA_DIR)

    print("\n" + "=" * 60)

    if result:
        print("✓ TEST C PASSED")
    else:
        print("❌ TEST C FAILED")

    print("=" * 60)