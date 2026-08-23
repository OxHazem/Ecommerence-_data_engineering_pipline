# Data_generator/Dirty_Data/invalid_data_types.py

import numpy as np

from .config import ENTITY_ERROR_RATES


# ============================================================
# INVALID DATA TYPE DEFINITIONS
#
# Values are based on the examples defined in Dirty_Data.md.
# ============================================================

INVALID_TYPE_VALUES = {

    "customer": {
        "date_of_birth": "not-a-date",
    },

    "product": {
        "price": "fifty dollars",
    },

    "order": {
        "order_date": "not-a-date",
    },

    "order_item": {
        "quantity": "five",
        "unit_price": "one hundred",
    },

    "payment": {
        "amount": "one hundred",
        "payment_date": "not-a-date",
    },

    "shipping": {
        "shipping_date": "not-a-date",
    },

    "review": {
        "rating": "five stars",
        "review_date": "not-a-date",
    },

    "marketing_event": {
        "event_timestamp": "not-a-timestamp",
    },
}


class InvalidDataTypeInjector:
    """
    Inject values with incorrect data types into configured
    columns.
    """

    def __init__(self, seed=42):
        self.seed = seed

    def inject(self, df, entity):
        """
        Inject invalid data types according to config.py.
        """

        dirty_df = df.copy()

        entity_config = ENTITY_ERROR_RATES.get(entity, {})

        type_rules = entity_config.get(
            "invalid_type",
            {}
        )

        if not type_rules:
            return dirty_df

        invalid_entity_values = INVALID_TYPE_VALUES.get(
            entity,
            {}
        )

        rng = np.random.default_rng(self.seed)

        for column, rate in type_rules.items():

            if column not in dirty_df.columns:
                raise ValueError(
                    f"Column '{column}' does not exist in "
                    f"entity '{entity}'."
                )

            if column not in invalid_entity_values:
                raise ValueError(
                    f"No invalid data-type value defined for "
                    f"'{entity}.{column}'."
                )

            invalid_value = invalid_entity_values[column]

            self._inject_column_invalid_type(
                dirty_df,
                column,
                rate,
                invalid_value,
                rng
            )

        return dirty_df

    @staticmethod
    def _inject_column_invalid_type(
        df,
        column,
        rate,
        invalid_value,
        rng
    ):
        """
        Inject invalid-type values into a selected percentage
        of rows.
        """

        if not 0 <= rate <= 1:
            raise ValueError(
                f"Invalid rate {rate} for column '{column}'. "
                f"Rate must be between 0 and 1."
            )

        n_rows = len(df)

        n_invalid = int(round(n_rows * rate))

        if n_invalid == 0:
            return

        selected_indices = rng.choice(
            df.index.to_numpy(),
            size=n_invalid,
            replace=False
        )

        # Using .loc allows the selected cells to contain
        # values of a different Python type.
        df[column] = df[column].astype(object)

        df.loc[
            selected_indices,
            column
        ] = invalid_value