# ============================================================
# E-Commerce Data Engineering Project
# Data Generator Configuration
# ============================================================


# ============================================================
# General Configuration
# ============================================================

SEED = 42


# ============================================================
# Source Data Volumes
# ============================================================

CUSTOMER_COUNT = 10_000

PRODUCT_COUNT = 2_000

ORDER_COUNT = 50_000

ORDER_ITEM_COUNT = 150_000

PAYMENT_COUNT = 50_000

SHIPPING_COUNT = 50_000

REVIEW_COUNT = 20_000

MARKETING_EVENT_COUNT = 200_000


# ============================================================
# Countries and Cities
# ============================================================

COUNTRIES = {
    "Egypt": [
        "Cairo",
        "Alexandria",
        "Giza",
        "Luxor"
    ],

    "Saudi Arabia": [
        "Riyadh",
        "Jeddah",
        "Mecca"
    ],

    "United Arab Emirates": [
        "Dubai",
        "Abu Dhabi",
        "Sharjah"
    ]
}


# ============================================================
# Currency Mapping
# ============================================================

CURRENCIES = {
    "Egypt": "EGP",
    "Saudi Arabia": "SAR",
    "United Arab Emirates": "AED"
}


# ============================================================
# Customer
# ============================================================

GENDERS = [
    "Male",
    "Female",
    "Other",
    "Unknown"
]

CUSTOMER_STATUSES = [
    "Active",
    "Inactive",
    "Suspended"
]


# ============================================================
# Product
# ============================================================

PRODUCT_STATUSES = [
    "Active",
    "Inactive",
    "Discontinued"
]


# ============================================================
# Order
# ============================================================

ORDER_STATUSES = [
    "Pending",
    "Processing",
    "Shipped",
    "Delivered",
    "Cancelled"
]


# ============================================================
# Payment
# ============================================================

PAYMENT_METHODS = [
    "Credit Card",
    "Debit Card",
    "PayPal",
    "Bank Transfer",
    "Cash on Delivery"
]

PAYMENT_STATUSES = [
    "Pending",
    "Completed",
    "Failed",
    "Refunded"
]


# ============================================================
# Shipping
# ============================================================

SHIPPING_METHODS = [
    "Standard",
    "Express",
    "Same Day",
    "Economy"
]

SHIPPING_STATUSES = [
    "Pending",
    "Shipped",
    "In Transit",
    "Delivered",
    "Returned"
]


# ============================================================
# Review
# ============================================================

REVIEW_STATUSES = [
    "Published",
    "Pending",
    "Rejected"
]

RATING_VALUES = [
    1,
    2,
    3,
    4,
    5
]


# ============================================================
# Marketing Event
# ============================================================

EVENT_TYPES = [
    "Impression",
    "Click",
    "View",
    "Add to Cart",
    "Purchase"
]

MARKETING_CHANNELS = [
    "Email",
    "Social Media",
    "Search",
    "Display",
    "Direct"
]

DEVICE_TYPES = [
    "Desktop",
    "Mobile",
    "Tablet"
]


# ============================================================
# Global Dirty Data Rates
# ============================================================
#
# These are DEFAULT rates.
# Entity/attribute-specific rates below override them.
#
# These values come from Dirty_Data.md.
# ============================================================

GLOBAL_DIRTY_DATA_RATES = {

    "missing_value": 0.03,

    "duplicate": 0.01,

    "invalid_value": 0.01,

    "invalid_foreign_key": 0.01,

    "invalid_data_type": 0.005,

    "inconsistent_format": 0.03,

    "business_rule_violation": 0.005
}


# ============================================================
# Entity-Specific Dirty Data Configuration
# ============================================================
#
# Structure:
#
# Entity
#   └── Attribute
#         └── Issue Type : Rate
#
# These values override the global defaults.
# ============================================================

DIRTY_DATA_CONFIG = {


    # ========================================================
    # Customer
    # ========================================================

    "customer": {

        "phone": {
            "missing_value": 0.05
        },

        "gender": {
            "missing_value": 0.03,
            "invalid_value": 0.01
        },

        "date_of_birth": {
            "missing_value": 0.03,
            "invalid_data_type": 0.005
        },

        "country": {
            "inconsistent_format": 0.05
        },

        "city": {
            "inconsistent_format": 0.03
        },

        "email": {
            "invalid_value": 0.01
        },

        "customer_id": {
            "duplicate": 0.01
        },

        "registration_date": {
            "business_rule_violation": 0.005
        }
    },


    # ========================================================
    # Product
    # ========================================================

    "product": {

        "description": {
            "missing_value": 0.05
        },

        "price": {
            "invalid_value": 0.01,
            "invalid_data_type": 0.005
        },

        "cost": {
            "invalid_value": 0.01
        },

        "stock_quantity": {
            "invalid_value": 0.01
        },

        "category": {
            "inconsistent_format": 0.05
        },

        "brand": {
            "inconsistent_format": 0.03
        },

        "product_id": {
            "duplicate": 0.01
        }
    },


    # ========================================================
    # Order
    # ========================================================

    "order": {

        "customer_id": {
            "invalid_foreign_key": 0.01
        },

        "order_id": {
            "duplicate": 0.01
        },

        "order_date": {
            "invalid_data_type": 0.005,
            "business_rule_violation": 0.005
        },

        "order_status": {
            "invalid_value": 0.01,
            "inconsistent_format": 0.03
        },

        "order_date_future": {
            "business_rule_violation": 0.005
        }
    },


    # ========================================================
    # Order Item
    # ========================================================

    "order_item": {

        "order_id": {
            "invalid_foreign_key": 0.01
        },

        "product_id": {
            "invalid_foreign_key": 0.01
        },

        "(order_id, product_id)": {
            "duplicate": 0.01
        },

        "quantity": {
            "invalid_value": 0.01,
            "invalid_data_type": 0.005
        },

        "unit_price": {
            "invalid_value": 0.01,
            "invalid_data_type": 0.005
        }
    },


    # ========================================================
    # Payment
    # ========================================================

    "payment": {

        "order_id": {
            "invalid_foreign_key": 0.01,
            "duplicate": 0.01
        },

        "payment_id": {
            "duplicate": 0.01
        },

        "payment_amount": {
            "invalid_value": 0.01,
            "invalid_data_type": 0.005
        },

        "payment_status": {
            "invalid_value": 0.01
        },

        "payment_date": {
            "invalid_data_type": 0.005,
            "business_rule_violation": 0.005
        }
    },


    # ========================================================
    # Shipping
    # ========================================================

    "shipping": {

        "order_id": {
            "invalid_foreign_key": 0.01,
            "duplicate": 0.01
        },

        "shipment_id": {
            "duplicate": 0.01
        },

        "delivery_date": {
            "missing_value": 0.10,
            "business_rule_violation": 0.005
        },

        "shipping_status": {
            "invalid_value": 0.01
        },

        "shipping_date": {
            "invalid_data_type": 0.005,
            "business_rule_violation": 0.005
        }
    },


    # ========================================================
    # Review
    # ========================================================

    "review": {

        "customer_id": {
            "invalid_foreign_key": 0.01
        },

        "product_id": {
            "invalid_foreign_key": 0.01
        },

        "(customer_id, product_id)": {
            "duplicate": 0.01
        },

        "review_text": {
            "missing_value": 0.05
        },

        "rating": {
            "invalid_value": 0.01,
            "invalid_data_type": 0.005
        },

        "review_date": {
            "invalid_data_type": 0.005,
            "business_rule_violation": 0.005
        }
    },


    # ========================================================
    # Marketing Event
    # ========================================================

    "marketing_event": {

        "customer_id": {
            "invalid_foreign_key": 0.01
        },

        "event_id": {
            "duplicate": 0.01
        },

        "campaign_id": {
            "missing_value": 0.03
        },

        "event_type": {
            "invalid_value": 0.01
        },

        "device_type": {
            "inconsistent_format": 0.03
        },

        "event_timestamp": {
            "invalid_data_type": 0.005,
            "business_rule_violation": 0.005
        }
    }
}