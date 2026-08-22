import os
import csv
import json


def count_rows(file_path):
    """
    Count the number of records in a CSV or JSON file.
    """

    if file_path.endswith(".csv"):

        with open(file_path, "r", encoding="utf-8") as file:
            reader = csv.reader(file)

            # Skip header
            next(reader, None)

            return sum(1 for _ in reader)

    elif file_path.endswith(".json"):

        with open(file_path, "r", encoding="utf-8") as file:
            data = json.load(file)

        return len(data)

    else:
        raise ValueError(
            f"Unsupported file format: {file_path}"
        )


def validate_row_counts(data_dir, expected_counts):
    """
    Validate the number of rows in each generated dataset.

    Parameters
    ----------
    data_dir : str
        Path to the directory containing the generated data.

    expected_counts : dict
        Dictionary containing expected row counts.

    Returns
    -------
    bool
        True if all row counts are correct.
        False if one or more row counts are incorrect.
    """

    all_valid = True

    print("\n" + "=" * 60)
    print("ROW COUNT VALIDATION")
    print("=" * 60)

    for file_name, expected_count in expected_counts.items():

        file_path = os.path.join(data_dir, file_name)

        # ----------------------------------------------------
        # Check if file exists
        # ----------------------------------------------------

        if not os.path.exists(file_path):

            print(f"❌ {file_name}: FILE NOT FOUND")

            all_valid = False
            continue

        # ----------------------------------------------------
        # Count actual rows
        # ----------------------------------------------------

        actual_count = count_rows(file_path)

        # ----------------------------------------------------
        # Compare actual vs expected
        # ----------------------------------------------------

        if actual_count == expected_count:

            print(
                f"✓ {file_name}: "
                f"{actual_count:,} rows"
            )

        else:

            print(
                f"❌ {file_name}: "
                f"Expected {expected_count:,}, "
                f"Found {actual_count:,}"
            )

            all_valid = False

    # --------------------------------------------------------
    # Final result
    # --------------------------------------------------------

    print("=" * 60)

    if all_valid:
        print("✓ ROW COUNT VALIDATION PASSED")
    else:
        print("❌ ROW COUNT VALIDATION FAILED")

    print("=" * 60)



    return all_valid

def load_data(file_path):
    """
    Load a CSV or JSON file and return a list of dictionaries.
    """

    if file_path.endswith(".csv"):

        with open(file_path, "r", encoding="utf-8") as file:
            reader = csv.DictReader(file)
            return list(reader)

    elif file_path.endswith(".json"):

        with open(file_path, "r", encoding="utf-8") as file:
            return json.load(file)

    else:
        raise ValueError(
            f"Unsupported file format: {file_path}"
        )


def validate_primary_key(data, primary_key):
    """
    Validate a single-column primary key.

    Checks:
        1. No NULL / empty values
        2. No duplicate values

    Returns:
        True  -> validation passed
        False -> validation failed
    """

    valid = True

    primary_key_values = []

    null_count = 0

    for row in data:

        value = row.get(primary_key)

        # ----------------------------------------------------
        # Check NULL / empty value
        # ----------------------------------------------------

        if value is None or str(value).strip() == "":
            null_count += 1

        else:
            primary_key_values.append(value)

    # --------------------------------------------------------
    # Report NULL / empty values
    # --------------------------------------------------------

    if null_count > 0:

        print(
            f"    ❌ {primary_key}: "
            f"{null_count:,} NULL/empty values"
        )

        valid = False

    else:

        print(
            f"    ✓ {primary_key}: "
            f"no NULL/empty values"
        )

    # --------------------------------------------------------
    # Check duplicates
    # --------------------------------------------------------

    duplicates = (
        len(primary_key_values)
        - len(set(primary_key_values))
    )

    if duplicates > 0:

        print(
            f"    ❌ {primary_key}: "
            f"{duplicates:,} duplicate values"
        )

        valid = False

    else:

        print(
            f"    ✓ {primary_key}: "
            f"no duplicate values"
        )

    return valid

def validate_composite_primary_key(data, primary_keys):
    """
    Validate a composite primary key.

    Checks:
        1. No NULL / empty values in any PK column
        2. No duplicate combinations

    Example:
        primary_keys = ["order_id", "product_id"]

    Returns:
        True  -> validation passed
        False -> validation failed
    """

    valid = True

    primary_key_values = []

    null_count = 0

    for row in data:

        key = tuple(
            row.get(column)
            for column in primary_keys
        )

        # ----------------------------------------------------
        # Check NULL / empty values
        # ----------------------------------------------------

        if any(
            value is None or str(value).strip() == ""
            for value in key
        ):

            null_count += 1

        else:

            primary_key_values.append(key)

    # --------------------------------------------------------
    # Report NULL / empty values
    # --------------------------------------------------------

    if null_count > 0:

        print(
            f"    ❌ {primary_keys}: "
            f"{null_count:,} rows contain "
            f"NULL/empty PK values"
        )

        valid = False

    else:

        print(
            f"    ✓ {primary_keys}: "
            f"no NULL/empty values"
        )

    # --------------------------------------------------------
    # Check duplicate combinations
    # --------------------------------------------------------

    duplicates = (
        len(primary_key_values)
        - len(set(primary_key_values))
    )

    if duplicates > 0:

        print(
            f"    ❌ {primary_keys}: "
            f"{duplicates:,} duplicate combinations"
        )

        valid = False

    else:

        print(
            f"    ✓ {primary_keys}: "
            f"no duplicate combinations"
        )

    return valid


def validate_foreign_key(
    child_data,
    child_column,
    parent_data,
    parent_column
):
    """
    Validate a mandatory foreign key relationship.

    Checks:
        1. No NULL / empty foreign-key values.
        2. Every foreign-key value exists in the parent table.

    Parameters
    ----------
    child_data : list[dict]
        Child entity records.

    child_column : str
        Foreign-key column in the child entity.

    parent_data : list[dict]
        Parent entity records.

    parent_column : str
        Referenced primary-key column.

    Returns
    -------
    bool
        True if the foreign key is valid.
        False otherwise.
    """

    # --------------------------------------------------------
    # Create a set containing all parent PK values
    # --------------------------------------------------------

    parent_keys = {
        str(row.get(parent_column)).strip()
        for row in parent_data
        if row.get(parent_column) is not None
        and str(row.get(parent_column)).strip() != ""
    }

    # --------------------------------------------------------
    # Find invalid child FK values
    # --------------------------------------------------------

    invalid_values = []

    for row in child_data:

        value = row.get(child_column)

        # Mandatory FK → NULL/empty is invalid
        if value is None or str(value).strip() == "":
            invalid_values.append(value)
            continue

        value = str(value).strip()

        if value not in parent_keys:
            invalid_values.append(value)

    # --------------------------------------------------------
    # Report result
    # --------------------------------------------------------

    if invalid_values:

        print(
            f"    ❌ {child_column} → {parent_column}: "
            f"{len(invalid_values):,} invalid FK values"
        )

        print(
            f"       Examples: {invalid_values[:5]}"
        )

        return False

    print(
        f"    ✓ {child_column} → {parent_column}: "
        f"referential integrity valid"
    )

    return True


def validate_all_primary_keys(data_dir):
    """
    Validate primary keys for all source entities.
    """

    print("\n" + "=" * 60)
    print("PRIMARY KEY VALIDATION")
    print("=" * 60)

    all_valid = True

    # ========================================================
    # Customer
    # ========================================================

    print("\nCustomer")

    customer_data = load_data(
        os.path.join(data_dir, "customers.json")
    )

    if not validate_primary_key(
        customer_data,
        "customer_id"
    ):
        all_valid = False

    # ========================================================
    # Product
    # ========================================================

    print("\nProduct")

    product_data = load_data(
        os.path.join(data_dir, "products.csv")
    )

    if not validate_primary_key(
        product_data,
        "product_id"
    ):
        all_valid = False

    # ========================================================
    # Order
    # ========================================================

    print("\nOrder")

    order_data = load_data(
        os.path.join(data_dir, "orders.csv")
    )

    if not validate_primary_key(
        order_data,
        "order_id"
    ):
        all_valid = False

    # ========================================================
    # Order Item
    # ========================================================

    print("\nOrder Item")

    order_item_data = load_data(
        os.path.join(data_dir, "order_items.csv")
    )

    if not validate_composite_primary_key(
        order_item_data,
        ["order_id", "product_id"]
    ):
        all_valid = False

    # ========================================================
    # Payment
    # ========================================================

    print("\nPayment")

    payment_data = load_data(
        os.path.join(data_dir, "payments.csv")
    )

    if not validate_primary_key(
        payment_data,
        "payment_id"
    ):
        all_valid = False

    # ========================================================
    # Shipping
    # ========================================================

    print("\nShipping")

    shipping_data = load_data(
        os.path.join(data_dir, "shipping.csv")
    )

    if not validate_primary_key(
        shipping_data,
        "shipment_id"
    ):
        all_valid = False

    # ========================================================
    # Review
    # ========================================================

    print("\nReview")

    review_data = load_data(
        os.path.join(data_dir, "reviews.json")
    )

    if not validate_primary_key(
        review_data,
        "review_id"
    ):
        all_valid = False

    # ========================================================
    # Marketing Event
    # ========================================================

    print("\nMarketing Event")

    marketing_data = load_data(
        os.path.join(
            data_dir,
            "marketing_events.csv"
        )
    )

    if not validate_primary_key(
        marketing_data,
        "event_id"
    ):
        all_valid = False

    # ========================================================
    # Final Result
    # ========================================================

    print("\n" + "=" * 60)

    if all_valid:

        print("✓ PRIMARY KEY VALIDATION PASSED")

    else:

        print("❌ PRIMARY KEY VALIDATION FAILED")

    print("=" * 60)

    return all_valid



def validate_all_foreign_keys(data_dir):
    """
    Validate all foreign-key relationships
    defined in the Data Dictionary.
    """

    print("\n" + "=" * 60)
    print("FOREIGN KEY VALIDATION")
    print("=" * 60)

    all_valid = True

    # ========================================================
    # Load parent entities
    # ========================================================

    customers = load_data(
        os.path.join(data_dir, "customers.json")
    )

    products = load_data(
        os.path.join(data_dir, "products.csv")
    )

    orders = load_data(
        os.path.join(data_dir, "orders.csv")
    )

    # ========================================================
    # 1. Order.customer_id → Customer.customer_id
    # ========================================================

    print("\nOrder → Customer")

    if not validate_foreign_key(
        child_data=orders,
        child_column="customer_id",
        parent_data=customers,
        parent_column="customer_id"
    ):
        all_valid = False

    # ========================================================
    # Load child entities
    # ========================================================

    order_items = load_data(
        os.path.join(data_dir, "order_items.csv")
    )

    payments = load_data(
        os.path.join(data_dir, "payments.csv")
    )

    shipping = load_data(
        os.path.join(data_dir, "shipping.csv")
    )

    reviews = load_data(
        os.path.join(data_dir, "reviews.json")
    )

    marketing_events = load_data(
        os.path.join(
            data_dir,
            "marketing_events.csv"
        )
    )

    # ========================================================
    # 2. Order_Item.order_id → Order.order_id
    # ========================================================

    print("\nOrder Item → Order")

    if not validate_foreign_key(
        child_data=order_items,
        child_column="order_id",
        parent_data=orders,
        parent_column="order_id"
    ):
        all_valid = False

    # ========================================================
    # 3. Order_Item.product_id → Product.product_id
    # ========================================================

    print("\nOrder Item → Product")

    if not validate_foreign_key(
        child_data=order_items,
        child_column="product_id",
        parent_data=products,
        parent_column="product_id"
    ):
        all_valid = False

    # ========================================================
    # 4. Payment.order_id → Order.order_id
    # ========================================================

    print("\nPayment → Order")

    if not validate_foreign_key(
        child_data=payments,
        child_column="order_id",
        parent_data=orders,
        parent_column="order_id"
    ):
        all_valid = False

    # ========================================================
    # 5. Shipping.order_id → Order.order_id
    # ========================================================

    print("\nShipping → Order")

    if not validate_foreign_key(
        child_data=shipping,
        child_column="order_id",
        parent_data=orders,
        parent_column="order_id"
    ):
        all_valid = False

    # ========================================================
    # 6. Review.customer_id → Customer.customer_id
    # ========================================================

    print("\nReview → Customer")

    if not validate_foreign_key(
        child_data=reviews,
        child_column="customer_id",
        parent_data=customers,
        parent_column="customer_id"
    ):
        all_valid = False

    # ========================================================
    # 7. Review.product_id → Product.product_id
    # ========================================================

    print("\nReview → Product")

    if not validate_foreign_key(
        child_data=reviews,
        child_column="product_id",
        parent_data=products,
        parent_column="product_id"
    ):
        all_valid = False

    # ========================================================
    # 8. Marketing_Event.customer_id → Customer.customer_id
    # ========================================================

    print("\nMarketing Event → Customer")

    if not validate_foreign_key(
        child_data=marketing_events,
        child_column="customer_id",
        parent_data=customers,
        parent_column="customer_id"
    ):
        all_valid = False

    # ========================================================
    # Final Result
    # ========================================================

    print("\n" + "=" * 60)

    if all_valid:
        print("✓ FOREIGN KEY VALIDATION PASSED")
    else:
        print("❌ FOREIGN KEY VALIDATION FAILED")

    print("=" * 60)

    return all_valid


from datetime import datetime
from decimal import Decimal, InvalidOperation


def is_integer(value):
    """
    Check whether a value can be interpreted as an INTEGER.
    """

    if value is None or str(value).strip() == "":
        return False

    try:
        int(str(value).strip())
        return True

    except (ValueError, TypeError):
        return False


def is_decimal(value):
    """
    Check whether a value can be interpreted as a DECIMAL.
    """

    if value is None or str(value).strip() == "":
        return False

    try:
        Decimal(str(value).strip())
        return True

    except (InvalidOperation, ValueError, TypeError):
        return False


def is_date(value):
    """
    Check whether a value is a valid DATE.

    Expected format:
        YYYY-MM-DD
    """

    if value is None or str(value).strip() == "":
        return False

    try:
        datetime.strptime(
            str(value).strip(),
            "%Y-%m-%d"
        )

        return True

    except (ValueError, TypeError):
        return False


def is_timestamp(value):
    """
    Check whether a value is a valid TIMESTAMP.

    Accepted formats:
        YYYY-MM-DD HH:MM:SS
        YYYY-MM-DD HH:MM:SS.microseconds
        YYYY-MM-DDTHH:MM:SS
        YYYY-MM-DDTHH:MM:SS.microseconds
    """

    if value is None or str(value).strip() == "":
        return False

    value = str(value).strip()

    formats = [
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M:%S.%f",
        "%Y-%m-%dT%H:%M:%S",
        "%Y-%m-%dT%H:%M:%S.%f"
    ]

    for fmt in formats:

        try:
            datetime.strptime(value, fmt)
            return True

        except ValueError:
            continue

    return False


def is_boolean(value):
    """
    Check whether a value is a BOOLEAN.

    Only actual Python boolean values are accepted.
    """

    return isinstance(value, bool)


def validate_column_data_type(data, column, expected_type):
    """
    Validate the data type of one column.

    Parameters
    ----------
    data : list[dict]
        Dataset records.

    column : str
        Column to validate.

    expected_type : str
        Expected data type.

    Returns
    -------
    bool
        True if all non-null values have the expected type.
        False otherwise.
    """

    validators = {
        "INTEGER": is_integer,
        "DECIMAL": is_decimal,
        "DATE": is_date,
        "TIMESTAMP": is_timestamp,
        "BOOLEAN": is_boolean
    }

    # --------------------------------------------------------
    # Get validator for expected data type
    # --------------------------------------------------------

    validator = validators.get(expected_type)

    if validator is None:

        raise ValueError(
            f"Unsupported data type: {expected_type}"
        )

    # --------------------------------------------------------
    # Check whether the column exists
    # --------------------------------------------------------

    if data and column not in data[0]:

        print(
            f"    ❌ {column}: "
            f"column not found"
        )

        return False

    invalid_values = []

    # --------------------------------------------------------
    # Validate every value in the column
    # --------------------------------------------------------

    for row in data:

        value = row.get(column)

        # ----------------------------------------------------
        # Skip NULL / empty values.
        #
        # NULLability is handled separately.
        # ----------------------------------------------------

        if value is None or str(value).strip() == "":
            continue

        # ----------------------------------------------------
        # Validate data type
        # ----------------------------------------------------

        if not validator(value):

            invalid_values.append(value)

    # --------------------------------------------------------
    # Report validation result
    # --------------------------------------------------------

    if invalid_values:

        print(
            f"    ❌ {column}: "
            f"{len(invalid_values):,} invalid "
            f"{expected_type} values"
        )

        print(
            f"       Examples: "
            f"{invalid_values[:5]}"
        )

        return False

    print(
        f"    ✓ {column}: "
        f"valid {expected_type}"
    )

    return True


EXPECTED_DATA_TYPES = {

    "customers.json": {

        "customer_id": "INTEGER",
        "date_of_birth": "DATE",
        "registration_date": "DATE"
    },

    "products.csv": {

        "product_id": "INTEGER",
        "price": "DECIMAL",
        "cost": "DECIMAL",
        "stock_quantity": "INTEGER"
    },

    "orders.csv": {

        "order_id": "INTEGER",
        "customer_id": "INTEGER",
        "order_date": "DATE"
    },

    "order_items.csv": {

        "order_id": "INTEGER",
        "product_id": "INTEGER",
        "quantity": "INTEGER",
        "unit_price": "DECIMAL",
        "discount": "DECIMAL",
        "cost_at_sale": "DECIMAL"
    },

    "payments.csv": {

        "payment_id": "INTEGER",
        "order_id": "INTEGER",
        "amount": "DECIMAL",
        "payment_date": "DATE"
    },

    "shipping.csv": {

        "shipment_id": "INTEGER",
        "order_id": "INTEGER",
        "shipping_date": "DATE",
        "estimated_delivery_date": "DATE",
        "delivery_date": "DATE"
    },

    "reviews.json": {

        "review_id": "INTEGER",
        "customer_id": "INTEGER",
        "product_id": "INTEGER",
        "rating": "INTEGER",
        "review_date": "DATE",
        "verified_purchase": "BOOLEAN"
    },

    "marketing_events.csv": {

        "event_id": "INTEGER",
        "customer_id": "INTEGER",
        "campaign_id": "INTEGER",
        "event_timestamp": "TIMESTAMP"
    }
}

def validate_all_data_types(data_dir):
    """
    Validate data types for all source entities.
    """

    print("\n" + "=" * 60)
    print("DATA TYPE VALIDATION")
    print("=" * 60)

    all_valid = True

    for file_name, columns in EXPECTED_DATA_TYPES.items():

        print(f"\n{file_name}")

        file_path = os.path.join(
            data_dir,
            file_name
        )

        # ----------------------------------------------------
        # Check file
        # ----------------------------------------------------

        if not os.path.exists(file_path):

            print(
                f"    ❌ File not found: "
                f"{file_name}"
            )

            all_valid = False
            continue

        # ----------------------------------------------------
        # Load data
        # ----------------------------------------------------

        data = load_data(file_path)

        # ----------------------------------------------------
        # Validate each column
        # ----------------------------------------------------

        for column, expected_type in columns.items():

            result = validate_column_data_type(
                data=data,
                column=column,
                expected_type=expected_type
            )

            if not result:
                all_valid = False

    # ========================================================
    # Final Result
    # ========================================================

    print("\n" + "=" * 60)

    if all_valid:
        print("✓ DATA TYPE VALIDATION PASSED")
    else:
        print("❌ DATA TYPE VALIDATION FAILED")

    print("=" * 60)

    return all_valid


ALLOWED_VALUES = {

    "customers.json": {
        "gender": [
            "Male",
            "Female",
            "Other",
            "Unknown"
        ],

        "customer_status": [
            "Active",
            "Inactive",
            "Suspended"
        ],

        "country": [
            "Egypt",
            "Saudi Arabia",
            "United Arab Emirates"
        ]
    },

    "products.csv": {
        "product_status": [
            "Active",
            "Inactive",
            "Discontinued"
        ]
    },

    "orders.csv": {
        "order_status": [
            "Pending",
            "Processing",
            "Shipped",
            "Delivered",
            "Cancelled"
        ],

        "currency": [
            "EGP",
            "SAR",
            "AED"
        ],

        "shipping_country": [
            "Egypt",
            "Saudi Arabia",
            "United Arab Emirates"
        ]
    },

    "order_items.csv": {
    },

    "payments.csv": {
        "payment_method": [
            "Credit Card",
            "Debit Card",
            "PayPal",
            "Cash",
            "Bank Transfer"
        ],

        "payment_status": [
            "Pending",
            "Completed",
            "Failed",
            "Refunded"
        ],

        "currency": [
            "EGP",
            "SAR",
            "AED"
        ]
    },

    "shipping.csv": {
        "shipping_method": [
            "Standard",
            "Express",
            "Same Day",
            "Next Day"
        ],

        "shipping_status": [
            "Pending",
            "Shipped",
            "In Transit",
            "Delivered",
            "Returned"
        ]
    },

    "reviews.json": {
        "review_status": [
            "Published",
            "Pending",
            "Rejected"
        ]
    },

    "marketing_events.csv": {
        "event_type": [
            "Impression",
            "Click",
            "View",
            "Add to Cart",
            "Purchase"
        ],

        "channel": [
            "Email",
            "Social Media",
            "Google Ads",
            "Website",
            "Mobile App"
        ],

        "device_type": [
            "Desktop",
            "Mobile",
            "Tablet"
        ],

        "country": [
            "Egypt",
            "Saudi Arabia",
            "United Arab Emirates"
        ]
    }
}
def validate_allowed_values(data, column, allowed_values):
    """
    Validate that all non-null values belong
    to the allowed set.

    Returns
    -------
    bool
        True if all non-null values are allowed.
        False otherwise.
    """

    # --------------------------------------------------------
    # Check whether the column exists
    # --------------------------------------------------------

    if data and column not in data[0]:

        print(
            f"    ❌ {column}: "
            f"column not found"
        )

        return False

    # --------------------------------------------------------
    # Normalize allowed values
    # --------------------------------------------------------

    allowed_values = {
        str(value).strip()
        for value in allowed_values
    }

    invalid_values = []

    # --------------------------------------------------------
    # Validate values
    # --------------------------------------------------------

    for row in data:

        value = row.get(column)

        # NULLability is handled separately.
        if value is None or str(value).strip() == "":
            continue

        value = str(value).strip()

        if value not in allowed_values:
            invalid_values.append(value)

    # --------------------------------------------------------
    # Report result
    # --------------------------------------------------------

    if invalid_values:

        print(
            f"    ❌ {column}: "
            f"{len(invalid_values):,} invalid values"
        )

        print(
            f"       Examples: "
            f"{invalid_values[:5]}"
        )

        return False

    print(
        f"    ✓ {column}: "
        f"all values are allowed"
    )

    return True


def validate_numeric_range(
    data,
    column,
    minimum=None,
    maximum=None
):
    """
    Validate numeric values against an allowed range.

    Parameters
    ----------
    data : list[dict]
        Dataset records.

    column : str
        Numeric column to validate.

    minimum : int or float, optional
        Minimum allowed value.

    maximum : int or float, optional
        Maximum allowed value.

    Returns
    -------
    bool
        True if all valid numeric values are within range.
        False otherwise.
    """

    # --------------------------------------------------------
    # Check whether the column exists
    # --------------------------------------------------------

    if data and column not in data[0]:

        print(
            f"    ❌ {column}: "
            f"column not found"
        )

        return False

    invalid_values = []

    # --------------------------------------------------------
    # Validate values
    # --------------------------------------------------------

    for row in data:

        value = row.get(column)

        # NULLability is handled separately.
        if value is None or str(value).strip() == "":
            continue

        try:
            value = float(value)

        except (ValueError, TypeError):
            # Invalid data types are handled by D.
            continue

        # ----------------------------------------------------
        # Check minimum
        # ----------------------------------------------------

        if minimum is not None and value < minimum:

            invalid_values.append(value)
            continue

        # ----------------------------------------------------
        # Check maximum
        # ----------------------------------------------------

        if maximum is not None and value > maximum:

            invalid_values.append(value)

    # --------------------------------------------------------
    # Report result
    # --------------------------------------------------------

    if invalid_values:

        print(
            f"    ❌ {column}: "
            f"{len(invalid_values):,} values outside "
            f"range [{minimum}, {maximum}]"
        )

        print(
            f"       Examples: "
            f"{invalid_values[:5]}"
        )

        return False

    print(
        f"    ✓ {column}: "
        f"values within allowed range"
    )

    return True

import re


import re


def validate_email_format(data, column="email"):
    """
    Validate email address format.

    Returns
    -------
    bool
        True if all non-null emails have a valid format.
        False otherwise.
    """

    # --------------------------------------------------------
    # Check whether the column exists
    # --------------------------------------------------------

    if data and column not in data[0]:

        print(
            f"    ❌ {column}: "
            f"column not found"
        )

        return False

    # --------------------------------------------------------
    # Email pattern
    # --------------------------------------------------------

    pattern = re.compile(
        r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
    )

    invalid_values = []

    # --------------------------------------------------------
    # Validate values
    # --------------------------------------------------------

    for row in data:

        value = row.get(column)

        # NULLability is handled separately.
        if value is None or str(value).strip() == "":
            continue

        value = str(value).strip()

        if not pattern.fullmatch(value):

            invalid_values.append(value)

    # --------------------------------------------------------
    # Report result
    # --------------------------------------------------------

    if invalid_values:

        print(
            f"    ❌ {column}: "
            f"{len(invalid_values):,} invalid email formats"
        )

        print(
            f"       Examples: "
            f"{invalid_values[:5]}"
        )

        return False

    print(
        f"    ✓ {column}: "
        f"valid email format"
    )

    return True



def validate_phone_format(data, column="phone"):
    """
    Validate phone number format for supported countries.

    Supported formats:
        Egypt:
            +20 10XXXXXXXX
            +20 11XXXXXXXX
            +20 12XXXXXXXX
            +20 15XXXXXXXX

        Saudi Arabia:
            +966 5XXXXXXXX

        United Arab Emirates:
            +971 50XXXXXXX
            +971 52XXXXXXX
            +971 54XXXXXXX
            +971 55XXXXXXX
            +971 56XXXXXXX

    Returns
    -------
    bool
        True if all non-null phone numbers are valid.
        False otherwise.
    """

    # --------------------------------------------------------
    # Check whether the column exists
    # --------------------------------------------------------

    if data and column not in data[0]:

        print(
            f"    ❌ {column}: "
            f"column not found"
        )

        return False

    # --------------------------------------------------------
    # Phone number pattern
    # --------------------------------------------------------

    pattern = re.compile(
        r"^\+(20 (10|11|12|15)\d{8}"
        r"|966 5\d{8}"
        r"|971 (50|52|54|55|56)\d{7})$"
    )

    invalid_values = []

    # --------------------------------------------------------
    # Validate values
    # --------------------------------------------------------

    for row in data:

        value = row.get(column)

        # NULLability is handled separately.
        if value is None or str(value).strip() == "":
            continue

        value = str(value).strip()

        if not pattern.fullmatch(value):

            invalid_values.append(value)

    # --------------------------------------------------------
    # Report result
    # --------------------------------------------------------

    if invalid_values:

        print(
            f"    ❌ {column}: "
            f"{len(invalid_values):,} invalid phone formats"
        )

        print(
            f"       Examples: "
            f"{invalid_values[:5]}"
        )

        return False

    print(
        f"    ✓ {column}: "
        f"valid phone format"
    )

    return True




def validate_all_allowed_values(data_dir):

    print("\n" + "=" * 60)
    print("ALLOWED VALUES / FORMAT VALIDATION")
    print("=" * 60)

    all_valid = True

    for file_name, columns in ALLOWED_VALUES.items():

        print(f"\n{file_name}")

        file_path = os.path.join(
            data_dir,
            file_name
        )

        if not os.path.exists(file_path):

            print(
                f"    ❌ File not found: {file_name}"
            )

            all_valid = False
            continue

        data = load_data(file_path)

        # ----------------------------------------------------
        # Allowed categorical values
        # ----------------------------------------------------

        for column, allowed_values in columns.items():

            result = validate_allowed_values(
                data,
                column,
                allowed_values
            )

            if not result:
                all_valid = False

        # ----------------------------------------------------
        # Email
        # ----------------------------------------------------

        if file_name == "customers.json":

            result = validate_email_format(
                data,
                "email"
            )

            if not result:
                all_valid = False

        # ----------------------------------------------------
        # Phone
        # ----------------------------------------------------

        if file_name == "customers.json":

            result = validate_phone_format(
                data,
                "phone"
            )

            if not result:
                all_valid = False

        # ----------------------------------------------------
        # Review rating
        # ----------------------------------------------------

        if file_name == "reviews.json":

            result = validate_numeric_range(
                data,
                "rating",
                minimum=1,
                maximum=5
            )

            if not result:
                all_valid = False

        # ----------------------------------------------------
        # Order Item discount
        # ----------------------------------------------------

        if file_name == "order_items.csv":

            result = validate_numeric_range(
                data,
                "discount",
                minimum=0,
                maximum=100
            )

            if not result:
                all_valid = False

        if file_name == "products.csv":

            if not validate_numeric_range(
                data=data,
                column="price",
                minimum=0
            ):
                all_valid = False

            if not validate_numeric_range(
                data=data,
                column="cost",
                minimum=0
            ):
                all_valid = False

            if not validate_numeric_range(
                data=data,
                column="stock_quantity",
                minimum=0
            ):
                all_valid = False

    # ========================================================
    # Final result
    # ========================================================

    print("\n" + "=" * 60)

    if all_valid:
        print(
            "✓ ALLOWED VALUES / FORMAT VALIDATION PASSED"
        )
    else:
        print(
            "❌ ALLOWED VALUES / FORMAT VALIDATION FAILED"
        )

    print("=" * 60)

    return all_valid

from datetime import datetime, date


def parse_date(value):
    """
    Convert a YYYY-MM-DD value into a date object.

    Returns
    -------
    date or None
        Parsed date if valid.
        None if the value is NULL, empty, or invalid.
    """

    if value is None or str(value).strip() == "":
        return None

    try:
        return datetime.strptime(
            str(value).strip(),
            "%Y-%m-%d"
        ).date()

    except (ValueError, TypeError):
        return None


def parse_timestamp(value):
    """
    Convert a timestamp value into a datetime object.

    Supported formats:
        YYYY-MM-DD HH:MM:SS
        YYYY-MM-DDTHH:MM:SS

    Returns
    -------
    datetime or None
        Parsed timestamp if valid.
        None otherwise.
    """

    if value is None or str(value).strip() == "":
        return None

    formats = [
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%dT%H:%M:%S"
    ]

    for fmt in formats:

        try:
            return datetime.strptime(
                str(value).strip(),
                fmt
            )

        except (ValueError, TypeError):
            continue

    return None

def validate_customer_dates(data):
    """
    Validate Customer date business rules.

    Rules:
        1. registration_date <= today
        2. date_of_birth < registration_date

    Invalid date formats are handled by D.
    """

    valid = True

    today = date.today()

    future_registration_count = 0
    invalid_birth_count = 0

    for row in data:

        registration_date = parse_date(
            row.get("registration_date")
        )

        date_of_birth = parse_date(
            row.get("date_of_birth")
        )

        # ----------------------------------------------------
        # registration_date must not be in the future
        # ----------------------------------------------------

        if (
            registration_date is not None
            and registration_date > today
        ):
            future_registration_count += 1

        # ----------------------------------------------------
        # date_of_birth must be before registration_date
        # ----------------------------------------------------

        if (
            date_of_birth is not None
            and registration_date is not None
            and date_of_birth >= registration_date
        ):
            invalid_birth_count += 1

    # --------------------------------------------------------
    # Report registration date violations
    # --------------------------------------------------------

    if future_registration_count > 0:

        print(
            f"    ❌ registration_date: "
            f"{future_registration_count:,} "
            f"future dates"
        )

        valid = False

    else:

        print(
            "    ✓ registration_date: "
            "no future dates"
        )

    # --------------------------------------------------------
    # Report birth date violations
    # --------------------------------------------------------

    if invalid_birth_count > 0:

        print(
            f"    ❌ date_of_birth: "
            f"{invalid_birth_count:,} invalid "
            f"birth/registration relationships"
        )

        valid = False

    else:

        print(
            "    ✓ date_of_birth: "
            "before registration_date"
        )

    return valid

def validate_product_rules(data):
    """
    Validate Product business rules.

    Rules:
        price >= 0
        cost >= 0
        stock_quantity >= 0
    """

    valid = True

    invalid_price = 0
    invalid_cost = 0
    invalid_stock = 0

    for row in data:

        # ----------------------------------------------------
        # Price
        # ----------------------------------------------------

        try:
            price = float(row.get("price"))

            if price < 0:
                invalid_price += 1

        except (ValueError, TypeError):
            # Data type validation handles this.
            continue

        # ----------------------------------------------------
        # Cost
        # ----------------------------------------------------

        try:
            cost = float(row.get("cost"))

            if cost < 0:
                invalid_cost += 1

        except (ValueError, TypeError):
            continue

        # ----------------------------------------------------
        # Stock
        # ----------------------------------------------------

        try:
            stock = int(row.get("stock_quantity"))

            if stock < 0:
                invalid_stock += 1

        except (ValueError, TypeError):
            continue

    # --------------------------------------------------------
    # Report
    # --------------------------------------------------------

    if invalid_price > 0:

        print(
            f"    ❌ price: "
            f"{invalid_price:,} negative values"
        )

        valid = False
    else:
        print("    ✓ price >= 0")

    if invalid_cost > 0:

        print(
            f"    ❌ cost: "
            f"{invalid_cost:,} negative values"
        )

        valid = False
    else:
        print("    ✓ cost >= 0")

    if invalid_stock > 0:

        print(
            f"    ❌ stock_quantity: "
            f"{invalid_stock:,} negative values"
        )

        valid = False
    else:
        print("    ✓ stock_quantity >= 0")

    return valid

def validate_order_dates(orders, customers):
    """
    Validate the relationship between Orders and Customers.

    Rule:
        order_date >= customer.registration_date

    Invalid date formats are handled by D.
    """

    valid = True

    customer_registration = {}

    # --------------------------------------------------------
    # Build customer registration-date lookup
    # --------------------------------------------------------

    for customer in customers:

        customer_id = str(
            customer.get("customer_id")
        ).strip()

        registration_date = parse_date(
            customer.get("registration_date")
        )

        customer_registration[customer_id] = (
            registration_date
        )

    invalid_count = 0
    missing_customer_count = 0

    # --------------------------------------------------------
    # Validate each order
    # --------------------------------------------------------

    for order in orders:

        customer_id = str(
            order.get("customer_id")
        ).strip()

        order_date = parse_date(
            order.get("order_date")
        )

        # ----------------------------------------------------
        # Find customer's registration date
        # ----------------------------------------------------

        if customer_id not in customer_registration:

            missing_customer_count += 1
            continue

        registration_date = customer_registration.get(
            customer_id
        )

        # ----------------------------------------------------
        # order_date must be on or after registration_date
        # ----------------------------------------------------

        if (
            order_date is not None
            and registration_date is not None
            and order_date < registration_date
        ):
            invalid_count += 1

    # --------------------------------------------------------
    # Report missing customer relationships
    # --------------------------------------------------------

    if missing_customer_count > 0:

        print(
            f"    ❌ customer_id: "
            f"{missing_customer_count:,} orders reference "
            f"non-existing customers"
        )

        valid = False

    else:

        print(
            "    ✓ customer_id: "
            "all orders reference existing customers"
        )

    # --------------------------------------------------------
    # Report date violations
    # --------------------------------------------------------

    if invalid_count > 0:

        print(
            f"    ❌ order_date: "
            f"{invalid_count:,} orders occur "
            f"before customer registration"
        )

        valid = False

    else:

        print(
            "    ✓ order_date >= "
            "customer registration_date"
        )

    return valid


def validate_order_item_rules(order_items, orders, products):
    """
    Validate Order Item business rules.

    Rules:
        1. order_id must reference an existing order.
        2. product_id must reference an existing product.
        3. quantity > 0.

    Numeric data-type errors are handled by D.
    Numeric range checks such as negative prices are handled by E.
    """

    valid = True

    order_ids = {
        str(order.get("order_id")).strip()
        for order in orders
        if order.get("order_id") is not None
    }

    product_ids = {
        str(product.get("product_id")).strip()
        for product in products
        if product.get("product_id") is not None
    }

    missing_orders = 0
    missing_products = 0
    invalid_quantity = 0

    for item in order_items:

        order_id = str(
            item.get("order_id")
        ).strip()

        product_id = str(
            item.get("product_id")
        ).strip()

        quantity = item.get("quantity")

        # ----------------------------------------------------
        # order_id must exist
        # ----------------------------------------------------

        if order_id not in order_ids:
            missing_orders += 1

        # ----------------------------------------------------
        # product_id must exist
        # ----------------------------------------------------

        if product_id not in product_ids:
            missing_products += 1

        # ----------------------------------------------------
        # quantity must be greater than zero
        # ----------------------------------------------------

        if quantity is None or str(quantity).strip() == "":
            continue

        try:
            quantity = int(quantity)

        except (ValueError, TypeError):
            # D handles invalid data types.
            continue

        if quantity <= 0:
            invalid_quantity += 1

    # --------------------------------------------------------
    # Report order relationships
    # --------------------------------------------------------

    if missing_orders > 0:

        print(
            f"    ❌ order_id: "
            f"{missing_orders:,} order items reference "
            f"non-existing orders"
        )

        valid = False

    else:

        print(
            "    ✓ order_id: "
            "all order items reference existing orders"
        )

    # --------------------------------------------------------
    # Report product relationships
    # --------------------------------------------------------

    if missing_products > 0:

        print(
            f"    ❌ product_id: "
            f"{missing_products:,} order items reference "
            f"non-existing products"
        )

        valid = False

    else:

        print(
            "    ✓ product_id: "
            "all order items reference existing products"
        )

    # --------------------------------------------------------
    # Report quantity
    # --------------------------------------------------------

    if invalid_quantity > 0:

        print(
            f"    ❌ quantity: "
            f"{invalid_quantity:,} values <= 0"
        )

        valid = False

    else:

        print(
            "    ✓ quantity > 0"
        )

    return valid


def validate_payment_dates(payments, orders):
    """
    Validate Payment business rules.

    Rules:
        1. order_id must reference an existing order.
        2. payment_date >= order_date.

    Invalid date formats are handled by D.
    """

    valid = True

    order_dates = {}

    for order in orders:

        order_id = str(
            order.get("order_id")
        ).strip()

        order_date = parse_date(
            order.get("order_date")
        )

        order_dates[order_id] = order_date

    missing_orders = 0
    invalid_dates = 0

    for payment in payments:

        order_id = str(
            payment.get("order_id")
        ).strip()

        payment_date = parse_date(
            payment.get("payment_date")
        )

        # ----------------------------------------------------
        # order_id must exist
        # ----------------------------------------------------

        if order_id not in order_dates:

            missing_orders += 1
            continue

        order_date = order_dates[order_id]

        # ----------------------------------------------------
        # payment_date >= order_date
        # ----------------------------------------------------

        if (
            payment_date is not None
            and order_date is not None
            and payment_date < order_date
        ):
            invalid_dates += 1

    # --------------------------------------------------------
    # Report order relationship
    # --------------------------------------------------------

    if missing_orders > 0:

        print(
            f"    ❌ order_id: "
            f"{missing_orders:,} payments reference "
            f"non-existing orders"
        )

        valid = False

    else:

        print(
            "    ✓ order_id: "
            "all payments reference existing orders"
        )

    # --------------------------------------------------------
    # Report payment date
    # --------------------------------------------------------

    if invalid_dates > 0:

        print(
            f"    ❌ payment_date: "
            f"{invalid_dates:,} payments occur "
            f"before order_date"
        )

        valid = False

    else:

        print(
            "    ✓ payment_date >= order_date"
        )

    return valid



def validate_shipping_dates(shipping, orders):
    """
    Validate Shipping business rules.

    Rules:
        1. order_id must reference an existing order.
        2. shipping_date >= order_date.
        3. estimated_delivery_date >= shipping_date.
        4. delivery_date >= shipping_date.

    Invalid date formats are handled by D.
    """

    valid = True

    order_dates = {}

    # --------------------------------------------------------
    # Build order lookup
    # --------------------------------------------------------

    for order in orders:

        order_id = str(
            order.get("order_id")
        ).strip()

        order_dates[order_id] = parse_date(
            order.get("order_date")
        )

    missing_orders = 0
    invalid_shipping = 0
    invalid_delivery = 0
    invalid_estimated = 0

    # --------------------------------------------------------
    # Validate shipments
    # --------------------------------------------------------

    for shipment in shipping:

        order_id = str(
            shipment.get("order_id")
        ).strip()

        shipping_date = parse_date(
            shipment.get("shipping_date")
        )

        estimated_delivery_date = parse_date(
            shipment.get("estimated_delivery_date")
        )

        delivery_date = parse_date(
            shipment.get("delivery_date")
        )

        # ----------------------------------------------------
        # Check order relationship
        # ----------------------------------------------------

        if order_id not in order_dates:

            missing_orders += 1
            continue

        order_date = order_dates[order_id]

        # ----------------------------------------------------
        # shipping_date >= order_date
        # ----------------------------------------------------

        if (
            shipping_date is not None
            and order_date is not None
            and shipping_date < order_date
        ):
            invalid_shipping += 1

        # ----------------------------------------------------
        # estimated_delivery_date >= shipping_date
        # ----------------------------------------------------

        if (
            estimated_delivery_date is not None
            and shipping_date is not None
            and estimated_delivery_date < shipping_date
        ):
            invalid_estimated += 1

        # ----------------------------------------------------
        # delivery_date >= shipping_date
        # ----------------------------------------------------

        if (
            delivery_date is not None
            and shipping_date is not None
            and delivery_date < shipping_date
        ):
            invalid_delivery += 1

    # ========================================================
    # Report
    # ========================================================

    if missing_orders > 0:

        print(
            f"    ❌ order_id: "
            f"{missing_orders:,} shipments reference "
            f"non-existing orders"
        )

        valid = False

    else:

        print(
            "    ✓ order_id: "
            "all shipments reference existing orders"
        )

    if invalid_shipping > 0:

        print(
            f"    ❌ shipping_date: "
            f"{invalid_shipping:,} before order_date"
        )

        valid = False

    else:

        print(
            "    ✓ shipping_date >= order_date"
        )

    if invalid_estimated > 0:

        print(
            f"    ❌ estimated_delivery_date: "
            f"{invalid_estimated:,} before shipping_date"
        )

        valid = False

    else:

        print(
            "    ✓ estimated_delivery_date >= shipping_date"
        )

    if invalid_delivery > 0:

        print(
            f"    ❌ delivery_date: "
            f"{invalid_delivery:,} before shipping_date"
        )

        valid = False

    else:

        print(
            "    ✓ delivery_date >= shipping_date"
        )

    return valid


def validate_review_rules(reviews, customers):
    """
    Validate Review business rules.

    Rule:
        review_date >= customer.registration_date

    Note:
        Rating range validation is handled by E.
    """

    valid = True

    customer_registration = {}

    # --------------------------------------------------------
    # Build customer registration-date lookup
    # --------------------------------------------------------

    for customer in customers:

        customer_id = str(
            customer.get("customer_id")
        ).strip()

        customer_registration[customer_id] = parse_date(
            customer.get("registration_date")
        )

    invalid_date = 0

    # --------------------------------------------------------
    # Validate reviews
    # --------------------------------------------------------

    for review in reviews:

        customer_id = str(
            review.get("customer_id")
        ).strip()

        review_date = parse_date(
            review.get("review_date")
        )

        registration_date = customer_registration.get(
            customer_id
        )

        # ----------------------------------------------------
        # review_date >= registration_date
        # ----------------------------------------------------

        if (
            review_date is not None
            and registration_date is not None
            and review_date < registration_date
        ):
            invalid_date += 1

    # --------------------------------------------------------
    # Report
    # --------------------------------------------------------

    if invalid_date > 0:

        print(
            f"    ❌ review_date: "
            f"{invalid_date:,} reviews occur "
            f"before customer registration"
        )

        valid = False

    else:

        print(
            "    ✓ review_date >= "
            "registration_date"
        )

    return valid


def validate_marketing_event_dates(
    marketing_events,
    customers
):
    """
    Validate Marketing Event business rules.

    Rule:
        event_timestamp >= customer.registration_date

    The comparison is performed at the date level.
    """

    valid = True

    customer_registration = {}

    # --------------------------------------------------------
    # Build customer registration-date lookup
    # --------------------------------------------------------

    for customer in customers:

        customer_id = str(
            customer.get("customer_id")
        ).strip()

        customer_registration[customer_id] = parse_date(
            customer.get("registration_date")
        )

    invalid_count = 0

    # --------------------------------------------------------
    # Validate events
    # --------------------------------------------------------

    for event in marketing_events:

        customer_id = str(
            event.get("customer_id")
        ).strip()

        event_timestamp = parse_timestamp(
            event.get("event_timestamp")
        )

        registration_date = customer_registration.get(
            customer_id
        )

        # ----------------------------------------------------
        # event date must not be before registration date
        # ----------------------------------------------------

        if (
            event_timestamp is not None
            and registration_date is not None
            and event_timestamp.date() < registration_date
        ):
            invalid_count += 1

    # --------------------------------------------------------
    # Report
    # --------------------------------------------------------

    if invalid_count > 0:

        print(
            f"    ❌ event_timestamp: "
            f"{invalid_count:,} events occur "
            f"before customer registration"
        )

        valid = False

    else:

        print(
            "    ✓ event_timestamp >= "
            "customer registration_date"
        )

    return valid


def validate_all_business_rules(data_dir):
    """
    Validate all business rules defined
    in the Data Dictionary.
    """

    print("\n" + "=" * 60)
    print("BUSINESS RULE VALIDATION")
    print("=" * 60)

    all_valid = True

    # ========================================================
    # Load datasets
    # ========================================================

    customers = load_data(
        os.path.join(data_dir, "customers.json")
    )

    products = load_data(
        os.path.join(data_dir, "products.csv")
    )

    orders = load_data(
        os.path.join(data_dir, "orders.csv")
    )

    order_items = load_data(
        os.path.join(data_dir, "order_items.csv")
    )

    payments = load_data(
        os.path.join(data_dir, "payments.csv")
    )

    shipping = load_data(
        os.path.join(data_dir, "shipping.csv")
    )

    reviews = load_data(
        os.path.join(data_dir, "reviews.json")
    )

    marketing_events = load_data(
        os.path.join(
            data_dir,
            "marketing_events.csv"
        )
    )

    # ========================================================
    # Customer
    # ========================================================

    print("\nCustomer")

    if not validate_customer_dates(customers):
        all_valid = False

    # ========================================================
    # Product
    # ========================================================

    print("\nProduct")

    if not validate_product_rules(products):
        all_valid = False

    # ========================================================
    # Order
    # ========================================================

    print("\nOrder")

    if not validate_order_dates(
        orders,
        customers
    ):
        all_valid = False

    # ========================================================
    # Order Item
    # ========================================================

    print("\nOrder Item")

    if not validate_order_item_rules(
        order_items,
        orders,
        products
    ):
        all_valid = False

    # ========================================================
    # Payment
    # ========================================================

    print("\nPayment")

    if not validate_payment_dates(
        payments,
        orders
    ):
        all_valid = False

    # ========================================================
    # Shipping
    # ========================================================

    print("\nShipping")

    if not validate_shipping_dates(
        shipping,
        orders
    ):
        all_valid = False

    # ========================================================
    # Review
    # ========================================================

    print("\nReview")

    if not validate_review_rules(
        reviews,
        customers
    ):
        all_valid = False

    # ========================================================
    # Marketing Event
    # ========================================================

    print("\nMarketing Event")

    if not validate_marketing_event_dates(
        marketing_events,
        customers
    ):
        all_valid = False

    # ========================================================
    # Final Result
    # ========================================================

    print("\n" + "=" * 60)

    if all_valid:
        print("✓ BUSINESS RULE VALIDATION PASSED")
    else:
        print("❌ BUSINESS RULE VALIDATION FAILED")

    print("=" * 60)

    return all_valid
