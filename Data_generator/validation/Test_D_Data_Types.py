import os 
from Data_generator.validation.validation_clean_data import validate_all_data_types

DATA_DIR = os.path.join(
    "Data",
    "generated",
    "clean"
)

if __name__ == "__main__":

    print("=" * 60)
    print("TEST D - Data Types")
    print("=" * 60)

    result = validate_all_data_types(DATA_DIR)

    print("\n" + "=" * 60)

    if result:
        print("✓ TEST D PASSED")
    else:
        print("❌ TEST D FAILED")

    print("=" * 60)