# Data_generator/dirty_data/config.py


# ============================================================
# GLOBAL DEFAULT ERROR RATES
# ============================================================

GLOBAL_ERROR_RATES = {
    "missing": 0.03,
    "duplicate": 0.01,
    "invalid_value": 0.01,
    "invalid_fk": 0.01,
    "invalid_type": 0.005,
    "inconsistent_format": 0.03,
    "business_rule": 0.005,
}


# ============================================================
# ENTITY-SPECIFIC ERROR RATES
#
# Entity-specific rates override GLOBAL_ERROR_RATES.
# ============================================================

ENTITY_ERROR_RATES = {

    # --------------------------------------------------------
    # CUSTOMER
    # --------------------------------------------------------

    "customer": {

        "missing": {
            "phone": 0.05,
            "gender": 0.03,
            "date_of_birth": 0.03,
        },

        "invalid_value": {
            "gender": 0.01,
            "email": 0.01,
        },

        "invalid_type": {
            "date_of_birth": 0.005,
        },

        "inconsistent_format": {
            "country": 0.05,
            "city": 0.03,
        },

        "duplicate": {
            "customer_id": 0.01,
        },

        "business_rule": {
            "registration_date": 0.005,
        },
    },


    # --------------------------------------------------------
    # PRODUCT
    # --------------------------------------------------------

    "product": {
        
        "invalid_value": {
            "price": 0.01,
            "cost": 0.01,
            "stock_quantity": 0.01,
        },
        "invalid_type": {
            "price": 0.005,
        },
        "inconsistent_format": {
            "category": 0.05,
            "brand": 0.03,
        },
        "duplicate": {
            "product_id": 0.01,
        },
    },


    # --------------------------------------------------------
    # ORDER
    # --------------------------------------------------------


    "order": {

        "invalid_fk": {
            "customer_id": 0.01,
        },

        "duplicate": {
            "order_id": 0.01,
        },

        "invalid_type": {
            "order_date": 0.005,
        },

        "invalid_value": {
            "order_status": 0.01,
        },

        "inconsistent_format": {
            "order_status": 0.03,
        },

        "business_rule": {
            "order_date_before_customer_registration": 0.005,
            "order_date_future": 0.005,
        },
    },


    # --------------------------------------------------------
    # ORDER ITEM
    # --------------------------------------------------------

    "order_item": {

        "invalid_fk": {
            "order_id": 0.01,
            "product_id": 0.01,
        },

        "duplicate": {
            "order_product": 0.01,
        },

        "invalid_value": {
            "quantity": 0.01,
            "unit_price": 0.01,
        },

        "invalid_type": {
            "quantity": 0.005,
            "unit_price": 0.005,
        },
    },


    # --------------------------------------------------------
    # PAYMENT
    # --------------------------------------------------------

    "payment": {

        "invalid_fk": {
            "order_id": 0.01,
        },

        "duplicate": {
            "payment_id": 0.01,
            "order_id": 0.01,
        },

        "invalid_value": {
            "amount": 0.01,
            "payment_status": 0.01,
        },

        "invalid_type": {
            "amount": 0.005,
            "payment_date": 0.005,
        },

        "business_rule": {
            "payment_date": 0.005,
        },
    },


    # --------------------------------------------------------
    # SHIPPING
    # --------------------------------------------------------

    "shipping": {

        "invalid_fk": {
            "order_id": 0.01,
        },

        "duplicate": {
            "shipment_id": 0.01,
            "order_id": 0.01,
        },

        "missing": {
            "delivery_date": 0.10,
        },

        "invalid_value": {
            "shipping_status": 0.01,
        },

        "invalid_type": {
            "shipping_date": 0.005,
        },

        "business_rule": {
            "delivery_date": 0.005,
            "shipping_date": 0.005,
            "estimated_delivery_date": 0.005,
        },
    },


    # --------------------------------------------------------
    # REVIEW
    # --------------------------------------------------------

    "review": {

        "invalid_fk": {
            "customer_id": 0.01,
            "product_id": 0.01,
        },

        "duplicate": {
            "customer_product": 0.01,
        },

        "invalid_value": {
            "rating": 0.01,
        },

        "invalid_type": {
            "rating": 0.005,
            "review_date": 0.005,
        },

        "business_rule": {
            "review_date": 0.005,
        },

    },


    # --------------------------------------------------------
    # MARKETING EVENT
    # --------------------------------------------------------

    "marketing_event": {

        "invalid_fk": {
            "customer_id": 0.01,
        },

        "duplicate": {
            "event_id": 0.01,
        },

        "missing": {
            "campaign_id": 0.03,
        },

        "invalid_value": {
            "event_type": 0.01,
        },

        "inconsistent_format": {
            "device_type": 0.03,
        },

        "invalid_type": {
            "event_timestamp": 0.005,
        },

        "business_rule": {
            "event_timestamp": 0.005,
        },
    },
}
# ============================================================
# DUPLICATE DETECTION KEYS
#
# Defines which columns represent the duplicate/business key
# for each configured duplicate rule.
# ============================================================

DUPLICATE_KEY_COLUMNS = {

    "customer": {
        "customer_id": ["customer_id"],
    },

    "product": {
        "product_id": ["product_id"],
    },

    "order": {
        "order_id": ["order_id"],
    },

    "order_item": {
        "order_product": ["order_id", "product_id"],
    },

    "payment": {
        "payment_id": ["payment_id"],
        "order_id": ["order_id"],
    },

    "shipping": {
        "shipment_id": ["shipment_id"],
        "order_id": ["order_id"],
    },

    "review": {
        "customer_product": ["customer_id", "product_id"],
    },

    "marketing_event": {
        "event_id": ["event_id"],
    },
}
