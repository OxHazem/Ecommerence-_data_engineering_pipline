from .missing_values import MissingValueInjector
from .duplicates import DuplicateInjector
from .invalid_values import InvalidValueInjector
from .invalid_foreign_keys import InvalidForeignKeyInjector
from .invalid_data_types import InvalidDataTypeInjector
from .inconsistent_formats import InconsistentFormatInjector
from .business_rules import BusinessRuleInjector


class DirtyDataInjector:
    """
    Main orchestrator for dirty-data injection.

    Receives all clean entity DataFrames and applies the
    configured dirty-data rules.
    """

    def __init__(self, seed=42):
        self.seed = seed

        self.missing_injector = MissingValueInjector(seed)
        self.duplicate_injector = DuplicateInjector(seed)
        self.invalid_value_injector = InvalidValueInjector(seed)
        self.invalid_fk_injector = InvalidForeignKeyInjector(seed)
        self.invalid_type_injector = InvalidDataTypeInjector(seed)
        self.format_injector = InconsistentFormatInjector(seed)
        self.business_rule_injector = BusinessRuleInjector(seed)

    def inject(self, data):
        """
        Inject dirty data into all entities.

        Parameters
        ----------
        data : dict[str, pandas.DataFrame]
            Dictionary containing the clean datasets.

        Returns
        -------
        dict[str, pandas.DataFrame]
            Dictionary containing dirty datasets.
        """

        dirty_data = {
            entity: df.copy(deep=True)
            for entity, df in data.items()
        }

        # ====================================================
        # 1. MISSING VALUES
        # ====================================================

        for entity, df in dirty_data.items():

            dirty_data[entity] = (
                self.missing_injector.inject(
                    df,
                    entity
                )
            )

        # ====================================================
        # 2. DUPLICATES
        # ====================================================

        for entity, df in dirty_data.items():

            dirty_data[entity] = (
                self.duplicate_injector.inject(
                    df,
                    entity
                )
            )

        # ====================================================
        # 3. INVALID VALUES
        # ====================================================

        for entity, df in dirty_data.items():

            dirty_data[entity] = (
                self.invalid_value_injector.inject(
                    df,
                    entity
                )
            )

        # ====================================================
        # 4. INVALID DATA TYPES
        # ====================================================

        for entity, df in dirty_data.items():

            dirty_data[entity] = (
                self.invalid_type_injector.inject(
                    df,
                    entity
                )
            )

        # ====================================================
        # 5. INCONSISTENT FORMATS
        # ====================================================

        for entity, df in dirty_data.items():

            dirty_data[entity] = (
                self.format_injector.inject(
                    df,
                    entity
                )
            )

        # ====================================================
        # 6. INVALID FOREIGN KEYS
        # ====================================================

        self._inject_invalid_foreign_keys(dirty_data)

        # ====================================================
        # 7. BUSINESS RULES
        # ====================================================

        self._inject_business_rules(dirty_data)

        return dirty_data

    # ========================================================
    # INVALID FOREIGN KEYS
    # ========================================================

    def _inject_invalid_foreign_keys(self, data):
        """
        Apply configured foreign-key violations.
        """

        # Order → Customer
        data["order"] = self.invalid_fk_injector.inject(
            data["order"],
            data["customer"],
            "order",
            "customer_id"
        )

        # Order_Item → Order
        data["order_item"] = self.invalid_fk_injector.inject(
            data["order_item"],
            data["order"],
            "order_item",
            "order_id"
        )

        # Order_Item → Product
        data["order_item"] = self.invalid_fk_injector.inject(
            data["order_item"],
            data["product"],
            "order_item",
            "product_id"
        )

        # Payment → Order
        data["payment"] = self.invalid_fk_injector.inject(
            data["payment"],
            data["order"],
            "payment",
            "order_id"
        )

        # Shipping → Order
        data["shipping"] = self.invalid_fk_injector.inject(
            data["shipping"],
            data["order"],
            "shipping",
            "order_id"
        )

        # Marketing Event → Customer
        data["marketing_event"] = (
            self.invalid_fk_injector.inject(
                data["marketing_event"],
                data["customer"],
                "marketing_event",
                "customer_id"
            )
        )

        # Review → Customer
        data["review"] = (
            self.invalid_fk_injector.inject(
                data["review"],
                data["customer"],
                "review",
                "customer_id"
            )
        )

        # Review → Product
        data["review"] = (
            self.invalid_fk_injector.inject(
                data["review"],
                data["product"],
                "review",
                "product_id"
            )
        )

    # ========================================================
    # BUSINESS RULES
    # ========================================================

    def _inject_business_rules(self, data):
        """
        Apply configured business-rule violations.
        """

        # ----------------------------------------------------
        # Customer
        # registration_date must not be in the future
        # ----------------------------------------------------

        data["customer"] = (
            self.business_rule_injector.inject(
                data["customer"],
                "customer",
                "registration_date"
            )
        )

        # ----------------------------------------------------
        # Order
        # ----------------------------------------------------

        data["order"] = (
            self.business_rule_injector.inject(
                data["order"],
                "order",
                "order_date_before_customer_registration",
                reference_df=data["customer"]
            )
        )

        data["order"] = (
            self.business_rule_injector.inject(
                data["order"],
                "order",
                "order_date_future"
            )
        )

        # ----------------------------------------------------
        # Payment
        # ----------------------------------------------------

        data["payment"] = (
            self.business_rule_injector.inject(
                data["payment"],
                "payment",
                "payment_date",
                reference_df=data["order"]
            )
        )

        # ----------------------------------------------------
        # Shipping
        # ----------------------------------------------------

        data["shipping"] = (
            self.business_rule_injector.inject(
                data["shipping"],
                "shipping",
                "shipping_date",
                reference_df=data["order"]
            )
        )

        data["shipping"] = (
            self.business_rule_injector.inject(
                data["shipping"],
                "shipping",
                "delivery_date"
            )
        )

        data["shipping"] = (
            self.business_rule_injector.inject(
                data["shipping"],
                "shipping",
                "estimated_delivery_date"
            )
        )

        # ----------------------------------------------------
        # Marketing Event
        # ----------------------------------------------------

        data["marketing_event"] = (
            self.business_rule_injector.inject(
                data["marketing_event"],
                "marketing_event",
                "event_timestamp",
                reference_df=data["customer"]
            )
        )

        # ----------------------------------------------------
        # Review
        # ----------------------------------------------------

        data["review"] = (
            self.business_rule_injector.inject(
                data["review"],
                "review",
                "review_date",
                reference_df=data["customer"]
            )
        )