import os 
from Data_generator.validation.validation_clean_data import validate_all_business_rules

DATA_DIR = os.path.join(
    "Data",
    "generated",
    "clean"
)


if __name__ == "__main__":

    print("=" * 60)
    print("TEST F - Bussiness Rules")
    print("=" * 60)

    result = validate_all_business_rules(DATA_DIR)

    print("\n" + "=" * 60)

    if result:
        print("✓ TEST F PASSED")
    else:
        print("❌ TEST F FAILED")

    print("=" * 60)