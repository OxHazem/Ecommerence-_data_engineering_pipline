import os 
from Data_generator.validation.validation_clean_data import validate_all_allowed_values

DATA_DIR = os.path.join(
    "Data",
    "generated",
    "clean"
)


if __name__ == "__main__":

    print("=" * 60)
    print("TEST E - Allowes_Values")
    print("=" * 60)

    result = validate_all_allowed_values(DATA_DIR)

    print("\n" + "=" * 60)

    if result:
        print("✓ TEST E PASSED")
    else:
        print("❌ TEST E FAILED")

    print("=" * 60)