import os 
from Data_generator.validation.validation_clean_data import validate_all_primary_keys


DATA_DIR = os.path.join(
    "Data",
    "generated",
    "clean"
)

if __name__ == "__main__":

    print("=" * 60)
    print("TEST B - PRIMARY KEYS")
    print("=" * 60)

    result = validate_all_primary_keys(DATA_DIR)

    print("\n" + "=" * 60)

    if result:
        print("✓ TEST B PASSED")
    else:
        print("❌ TEST B FAILED")

    print("=" * 60)