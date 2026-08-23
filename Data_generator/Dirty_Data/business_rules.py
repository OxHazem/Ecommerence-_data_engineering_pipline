# Data_generator/Dirty_Data/business_rules.py

import numpy as np
import pandas as pd

from .config import ENTITY_ERROR_RATES


class BusinessRuleInjector:
    """
    Injects business-rule violations into otherwise valid data.
    """

    def __init__(self, seed=42):
        self.seed = seed

    def inject(
        self,
        df,
        entity,
        rule,
        reference_df=None
    ):
        """
        Inject a business-rule violation.

        Parameters
        ----------
        df : pandas.DataFrame
            DataFrame being corrupted.

        entity : str
            Entity being corrupted.

        rule : str
            Business rule to violate.

        reference_df : pandas.DataFrame, optional
            Reference DataFrame required for cross-table rules.
        """

        dirty_df = df.copy()

        entity_config = ENTITY_ERROR_RATES.get(
            entity,
            {}
        )

        business_rules = entity_config.get(
            "business_rule",
            {}
        )

        if rule not in business_rules:
            raise ValueError(
                f"No business-rule rate configured for "
                f"'{entity}.{rule}'."
            )

        rate = business_rules[rule]

        rng = np.random.default_rng(self.seed)

        # ----------------------------------------------------
        # CUSTOMER
        # ----------------------------------------------------

        if entity == "customer":

            if rule == "registration_date":

                self._inject_customer_registration_date(
                    dirty_df,
                    rate,
                    rng
                )

        # ----------------------------------------------------
        # ORDER
        # ----------------------------------------------------

        elif entity == "order":

            if rule == "order_date_before_customer_registration":

                if reference_df is None:
                    raise ValueError(
                        "Customer DataFrame is required for "
                        "order_date_before_customer_registration."
                    )

                self._inject_order_before_customer_registration(
                    dirty_df,
                    reference_df,
                    rate,
                    rng
                )

            elif rule == "order_date_future":

                self._inject_order_future(
                    dirty_df,
                    rate,
                    rng
                )

            else:
                raise ValueError(
                    f"Business rule '{rule}' is not implemented "
                    f"for entity '{entity}'."
                )
        elif entity == "payment":

            if rule == "payment_date":

                if reference_df is None:
                    raise ValueError(
                        "Order DataFrame is required for "
                        "payment_date business rule."
                    )

                self._inject_payment_before_order(
                    dirty_df,
                    reference_df,
                    rate,
                    rng
                )

            else:
                    raise ValueError(
                        f"Business rule '{rule}' is not implemented "
                        f"for entity '{entity}'."
                    )

            
        elif entity == "shipping":

            if rule == "shipping_date":

                if reference_df is None:
                    raise ValueError(
                        "Order DataFrame is required for "
                        "shipping_date business rule."
                    )

                self._inject_shipping_before_order(
                    dirty_df,
                    reference_df,
                    rate,
                    rng
                )

            elif rule == "delivery_date":

                self._inject_delivery_before_shipping(
                    dirty_df,
                    rate,
                    rng
                )

            elif rule == "estimated_delivery_date":

                self._inject_estimated_delivery_before_shipping(
                    dirty_df,
                    rate,
                    rng
                )

            else:
                raise ValueError(
                    f"Business rule '{rule}' is not implemented "
                    f"for entity '{entity}'."
                )

        elif entity == "review":

            if rule == "review_date":

                if reference_df is None:
                    raise ValueError(
                        "Customer DataFrame is required for "
                        "review_date business rule."
                    )

                self._inject_review_before_registration(
                    dirty_df,
                    reference_df,
                    rate,
                    rng
                )

            else:
                raise ValueError(
                    f"Business rule '{rule}' is not implemented "
                    f"for entity '{entity}'."
                )

        elif entity == "marketing_event":

            if rule == "event_timestamp":

                if reference_df is None:
                    raise ValueError(
                        "Customer DataFrame is required for "
                        "marketing event event_timestamp rule."
                    )

                self._inject_event_before_customer_registration(
                    dirty_df,
                    reference_df,
                    rate,
                    rng
                )

            else:
                raise ValueError(
                    f"Business rule '{rule}' is not implemented "
                    f"for entity '{entity}'."
                )
        else:

            raise ValueError(
                f"Business-rule injection for entity "
                f"'{entity}' is not implemented yet."
            )

        return dirty_df

    # ========================================================
    # CUSTOMER
    # ========================================================

    @staticmethod
    def _inject_customer_registration_date(
        df,
        rate,
        rng
    ):
        """
        Violate:

            registration_date <= current_date
        """

        if "registration_date" not in df.columns:
            raise ValueError(
                "Column 'registration_date' does not exist "
                "in customer DataFrame."
            )

        BusinessRuleInjector._validate_rate(rate)

        n_rows = len(df)

        n_invalid = int(round(n_rows * rate))

        if n_invalid == 0:
            return

        df["registration_date"] = pd.to_datetime(
            df["registration_date"]
        , errors="coerce")

        selected_indices = rng.choice(
            df.index.to_numpy(),
            size=n_invalid,
            replace=False
        )

        future_date = (
            pd.Timestamp.today().normalize()
            + pd.Timedelta(days=365)
        )

        df.loc[
            selected_indices,
            "registration_date"
        ] = future_date

    # ========================================================
    # ORDER
    # ========================================================
    @staticmethod
    def _inject_order_future(
        df,
        rate,
        rng
    ):
        """
        Violate:

            order_date <= current_date

        by replacing selected order dates with future dates.
        """

        if "order_date" not in df.columns:
            raise ValueError(
                "Column 'order_date' does not exist "
                "in order DataFrame."
            )

        BusinessRuleInjector._validate_rate(rate)

        n_rows = len(df)

        n_invalid = int(round(n_rows * rate))

        if n_invalid == 0:
            return

        df["order_date"] = pd.to_datetime(
            df["order_date"]
        , errors="coerce")

        selected_indices = rng.choice(
            df.index.to_numpy(),
            size=n_invalid,
            replace=False
        )

        future_date = (
            pd.Timestamp.today().normalize()
            + pd.Timedelta(days=365)
        )

        df.loc[
            selected_indices,
            "order_date"
        ] = future_date

    @staticmethod
    def _inject_payment_before_order(
        payment_df,
        order_df,
        rate,
        rng
    ):
        """
        Violate:

            payment_date >= order_date

        by making payment_date earlier than order_date.
        """

        required_payment_columns = {
            "order_id",
            "payment_date"
        }

        required_order_columns = {
            "order_id",
            "order_date"
        }

        missing_payment_columns = (
            required_payment_columns
            - set(payment_df.columns)
        )

        missing_order_columns = (
            required_order_columns
            - set(order_df.columns)
        )

        if missing_payment_columns:
            raise ValueError(
                "Payment DataFrame is missing columns: "
                f"{missing_payment_columns}"
            )

        if missing_order_columns:
            raise ValueError(
                "Order DataFrame is missing columns: "
                f"{missing_order_columns}"
            )

        BusinessRuleInjector._validate_rate(rate)

        if len(payment_df) == 0:
            return

        payment_df["payment_date"] = pd.to_datetime(
            payment_df["payment_date"]
        , errors="coerce")

        order_df["order_date"] = pd.to_datetime(
            order_df["order_date"]
        , errors="coerce")

        order_dates = (
            order_df[
                [
                    "order_id",
                    "order_date"
                ]
            ]
            .drop_duplicates(
                subset=["order_id"]
            )
            .set_index("order_id")["order_date"]
        )

        merged = payment_df[
            [
                "order_id",
                "payment_date"
            ]
        ].join(
            order_dates,
            on="order_id"
        )

        eligible_mask = (
            merged["order_date"].notna()
            & merged["payment_date"].notna()
        )

        eligible_indices = merged.index[
            eligible_mask
        ].to_numpy()

        n_invalid = int(
            round(len(payment_df) * rate)
        )

        if n_invalid == 0:
            return

        if len(eligible_indices) < n_invalid:
            raise ValueError(
                "Not enough eligible payments to inject "
                "the requested number of violations."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_invalid,
            replace=False
        )

        for index in selected_indices:

            order_date = merged.loc[
                index,
                "order_date"
            ]

            invalid_payment_date = (
                order_date
                - pd.Timedelta(days=1)
            )

            payment_df.loc[
                index,
                "payment_date"
            ] = invalid_payment_date


    @staticmethod
    def _inject_shipping_before_order(
        shipping_df,
        order_df,
        rate,
        rng
    ):
        """
        Violate:

            shipping_date >= order_date

        by making shipping_date earlier than order_date.
        """

        required_shipping_columns = {
            "order_id",
            "shipping_date"
        }

        required_order_columns = {
            "order_id",
            "order_date"
        }

        missing_shipping_columns = (
            required_shipping_columns
            - set(shipping_df.columns)
        )

        missing_order_columns = (
            required_order_columns
            - set(order_df.columns)
        )

        if missing_shipping_columns:
            raise ValueError(
                "Shipping DataFrame is missing columns: "
                f"{missing_shipping_columns}"
            )

        if missing_order_columns:
            raise ValueError(
                "Order DataFrame is missing columns: "
                f"{missing_order_columns}"
            )

        BusinessRuleInjector._validate_rate(rate)

        if len(shipping_df) == 0:
            return

        shipping_df["shipping_date"] = pd.to_datetime(
            shipping_df["shipping_date"]
        , errors="coerce")

        order_df["order_date"] = pd.to_datetime(
            order_df["order_date"]
        , errors="coerce")

        order_dates = (
            order_df[
                [
                    "order_id",
                    "order_date"
                ]
            ]
            .drop_duplicates(
                subset=["order_id"]
            )
            .set_index("order_id")["order_date"]
        )

        merged = shipping_df[
            [
                "order_id",
                "shipping_date"
            ]
        ].join(
            order_dates,
            on="order_id"
        )

        eligible_mask = (
            merged["order_date"].notna()
            & merged["shipping_date"].notna()
        )

        eligible_indices = merged.index[
            eligible_mask
        ].to_numpy()

        n_invalid = int(
            round(len(shipping_df) * rate)
        )

        if n_invalid == 0:
            return

        if len(eligible_indices) < n_invalid:
            raise ValueError(
                "Not enough eligible shipments to inject "
                "the requested number of violations."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_invalid,
            replace=False
        )

        for index in selected_indices:

            order_date = merged.loc[
                index,
                "order_date"
            ]

            invalid_shipping_date = (
                order_date
                - pd.Timedelta(days=1)
            )

            shipping_df.loc[
                index,
                "shipping_date"
            ] = invalid_shipping_date
    @staticmethod
    def _inject_delivery_before_shipping(
        df,
        rate,
        rng
    ):
        """
        Violate:

            delivery_date >= shipping_date

        by making delivery_date earlier than shipping_date.
        """

        required_columns = {
            "shipping_date",
            "delivery_date"
        }

        missing_columns = (
            required_columns
            - set(df.columns)
        )

        if missing_columns:
            raise ValueError(
                "Shipping DataFrame is missing columns: "
                f"{missing_columns}"
            )

        BusinessRuleInjector._validate_rate(rate)

        if len(df) == 0:
            return

        df["shipping_date"] = pd.to_datetime(
            df["shipping_date"]
        , errors="coerce")

        df["delivery_date"] = pd.to_datetime(
            df["delivery_date"]
        , errors="coerce")

        # Only non-NULL delivery dates are eligible.
        eligible_mask = (
            df["shipping_date"].notna()
            & df["delivery_date"].notna()
        )

        eligible_indices = df.index[
            eligible_mask
        ].to_numpy()

        n_invalid = int(
            round(len(df) * rate)
        )

        if n_invalid == 0:
            return

        if len(eligible_indices) < n_invalid:
            raise ValueError(
                "Not enough eligible shipments to inject "
                "the requested number of violations."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_invalid,
            replace=False
        )

        for index in selected_indices:

            shipping_date = df.loc[
                index,
                "shipping_date"
            ]

            invalid_delivery_date = (
                shipping_date
                - pd.Timedelta(days=1)
            )

            df.loc[
                index,
                "delivery_date"
            ] = invalid_delivery_date

    @staticmethod
    def _inject_estimated_delivery_before_shipping(
        df,
        rate,
        rng
    ):
        """
        Violate:

            estimated_delivery_date >= shipping_date

        by making estimated_delivery_date earlier
        than shipping_date.
        """

        required_columns = {
            "shipping_date",
            "estimated_delivery_date"
        }

        missing_columns = (
            required_columns
            - set(df.columns)
        )

        if missing_columns:
            raise ValueError(
                "Shipping DataFrame is missing columns: "
                f"{missing_columns}"
            )

        BusinessRuleInjector._validate_rate(rate)

        if len(df) == 0:
            return

        df["shipping_date"] = pd.to_datetime(
            df["shipping_date"]
        , errors="coerce")

        df["estimated_delivery_date"] = pd.to_datetime(
            df["estimated_delivery_date"]
        , errors="coerce")

        eligible_mask = (
            df["shipping_date"].notna()
            & df["estimated_delivery_date"].notna()
        )

        eligible_indices = df.index[
            eligible_mask
        ].to_numpy()

        n_invalid = int(
            round(len(df) * rate)
        )

        if n_invalid == 0:
            return

        if len(eligible_indices) < n_invalid:
            raise ValueError(
                "Not enough eligible shipments to inject "
                "the requested number of violations."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_invalid,
            replace=False
        )

        for index in selected_indices:

            shipping_date = df.loc[
                index,
                "shipping_date"
            ]

            invalid_estimated_date = (
                shipping_date
                - pd.Timedelta(days=1)
            )

            df.loc[
                index,
                "estimated_delivery_date"
            ] = invalid_estimated_date

    @staticmethod
    def _inject_review_before_registration(
        review_df,
        customer_df,
        rate,
        rng
    ):
        """
        Violate:

            review_date >= customer.registration_date

        by making review_date earlier than the
        customer's registration_date.
        """

        required_review_columns = {
            "customer_id",
            "review_date"
        }

        required_customer_columns = {
            "customer_id",
            "registration_date"
        }

        missing_review_columns = (
            required_review_columns
            - set(review_df.columns)
        )

        missing_customer_columns = (
            required_customer_columns
            - set(customer_df.columns)
        )

        if missing_review_columns:
            raise ValueError(
                "Review DataFrame is missing columns: "
                f"{missing_review_columns}"
            )

        if missing_customer_columns:
            raise ValueError(
                "Customer DataFrame is missing columns: "
                f"{missing_customer_columns}"
            )

        BusinessRuleInjector._validate_rate(rate)

        if len(review_df) == 0:
            return

        review_df["review_date"] = pd.to_datetime(
            review_df["review_date"]
        , errors="coerce")

        customer_df["registration_date"] = pd.to_datetime(
            customer_df["registration_date"]
        , errors="coerce")

        registration_dates = (
            customer_df[
                [
                    "customer_id",
                    "registration_date"
                ]
            ]
            .drop_duplicates(
                subset=["customer_id"]
            )
            .set_index("customer_id")["registration_date"]
        )

        merged = review_df[
            [
                "customer_id",
                "review_date"
            ]
        ].join(
            registration_dates,
            on="customer_id"
        )

        eligible_mask = (
            merged["registration_date"].notna()
            & merged["review_date"].notna()
        )

        eligible_indices = merged.index[
            eligible_mask
        ].to_numpy()

        n_invalid = int(
            round(len(review_df) * rate)
        )

        if n_invalid == 0:
            return

        if len(eligible_indices) < n_invalid:
            raise ValueError(
                "Not enough eligible reviews to inject "
                "the requested number of violations."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_invalid,
            replace=False
        )

        for index in selected_indices:

            registration_date = merged.loc[
                index,
                "registration_date"
            ]

            invalid_review_date = (
                registration_date
                - pd.Timedelta(days=1)
            )

            review_df.loc[
                index,
                "review_date"
            ] = invalid_review_date

    @staticmethod
    def _inject_order_before_customer_registration(
        order_df,
        customer_df,
        rate,
        rng
    ):
        """
        Violate:

            order_date >= customer.registration_date

        by making order_date earlier than the customer's
        registration_date.
        """

        required_order_columns = {
            "customer_id",
            "order_date"
        }

        required_customer_columns = {
            "customer_id",
            "registration_date"
        }

        missing_order_columns = (
            required_order_columns
            - set(order_df.columns)
        )

        missing_customer_columns = (
            required_customer_columns
            - set(customer_df.columns)
        )

        if missing_order_columns:
            raise ValueError(
                "Order DataFrame is missing columns: "
                f"{missing_order_columns}"
            )

        if missing_customer_columns:
            raise ValueError(
                "Customer DataFrame is missing columns: "
                f"{missing_customer_columns}"
            )

        BusinessRuleInjector._validate_rate(rate)

        if len(order_df) == 0:
            return

        order_df["order_date"] = pd.to_datetime(
            order_df["order_date"]
        , errors="coerce")

        customer_df["registration_date"] = pd.to_datetime(
            customer_df["registration_date"]
        , errors="coerce")

        registration_dates = (
            customer_df[
                [
                    "customer_id",
                    "registration_date"
                ]
            ]
            .drop_duplicates(
                subset=["customer_id"]
            )
            .set_index("customer_id")["registration_date"]
        )

        merged = order_df[
            [
                "customer_id",
                "order_date"
            ]
        ].join(
            registration_dates,
            on="customer_id"
        )

        eligible_mask = (
            merged["registration_date"].notna()
            & merged["order_date"].notna()
        )

        eligible_indices = merged.index[
            eligible_mask
        ].to_numpy()

        n_invalid = int(
            round(len(order_df) * rate)
        )

        if n_invalid == 0:
            return

        if len(eligible_indices) < n_invalid:
            raise ValueError(
                "Not enough eligible orders to inject "
                "the requested number of violations."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_invalid,
            replace=False
        )

        for index in selected_indices:

            registration_date = merged.loc[
                index,
                "registration_date"
            ]

            invalid_order_date = (
                registration_date
                - pd.Timedelta(days=1)
            )

            order_df.loc[
                index,
                "order_date"
            ] = invalid_order_date



    @staticmethod
    def _inject_event_before_customer_registration(
        event_df,
        customer_df,
        rate,
        rng
    ):
        """
        Violate:

            event_timestamp >= customer.registration_date

        by making event_timestamp earlier than the
        customer's registration_date.
        """

        required_event_columns = {
            "customer_id",
            "event_timestamp"
        }

        required_customer_columns = {
            "customer_id",
            "registration_date"
        }

        missing_event_columns = (
            required_event_columns
            - set(event_df.columns)
        )

        missing_customer_columns = (
            required_customer_columns
            - set(customer_df.columns)
        )

        if missing_event_columns:
            raise ValueError(
                "Marketing Event DataFrame is missing columns: "
                f"{missing_event_columns}"
            )

        if missing_customer_columns:
            raise ValueError(
                "Customer DataFrame is missing columns: "
                f"{missing_customer_columns}"
            )

        BusinessRuleInjector._validate_rate(rate)

        if len(event_df) == 0:
            return

        event_df["event_timestamp"] = pd.to_datetime(
            event_df["event_timestamp"]
        , errors="coerce")

        customer_df["registration_date"] = pd.to_datetime(
            customer_df["registration_date"]
        , errors="coerce")

        registration_dates = (
            customer_df[
                [
                    "customer_id",
                    "registration_date"
                ]
            ]
            .drop_duplicates(
                subset=["customer_id"]
            )
            .set_index("customer_id")["registration_date"]
        )

        merged = event_df[
            [
                "customer_id",
                "event_timestamp"
            ]
        ].join(
            registration_dates,
            on="customer_id"
        )

        eligible_mask = (
            merged["registration_date"].notna()
            & merged["event_timestamp"].notna()
        )

        eligible_indices = merged.index[
            eligible_mask
        ].to_numpy()

        n_invalid = int(
            round(len(event_df) * rate)
        )

        if n_invalid == 0:
            return

        if len(eligible_indices) < n_invalid:
            raise ValueError(
                "Not enough eligible marketing events to "
                "inject the requested number of violations."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_invalid,
            replace=False
        )

        for index in selected_indices:

            registration_date = merged.loc[
                index,
                "registration_date"
            ]

            invalid_event_timestamp = (
                registration_date
                - pd.Timedelta(days=1)
            )

            event_df.loc[
                index,
                "event_timestamp"
            ] = invalid_event_timestamp
    # ========================================================
    # VALIDATION HELPERS
    # ========================================================

    @staticmethod
    def _validate_rate(rate):

        if not 0 <= rate <= 1:
            raise ValueError(
                f"Invalid business-rule rate: {rate}. "
                f"Rate must be between 0 and 1."
            )