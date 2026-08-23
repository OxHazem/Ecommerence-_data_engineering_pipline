# Data_generator/Dirty_Data/invalid_values.py

import numpy as np
import pandas as pd

from .config import ENTITY_ERROR_RATES


# ============================================================
# INVALID VALUE DEFINITIONS
#
# These values are based on the examples defined in
# Dirty_Data.md.
# ============================================================

INVALID_VALUES = {

    "customer": {
        "gender": "UnknownGender",
        "email": "omar@",
    },

    "product": {
        "price": -50,
        "cost": -20,
        "stock_quantity": -10,
    },

    "order": {
        "order_status": "UnknownStatus",
    },

    "order_item": {
        "quantity": -5,
        "unit_price": -20,
    },

    "payment": {
        "amount": -100,
        "payment_status": "InvalidStatus",
    },

    "shipping": {
        "shipping_status": "UnknownStatus",
    },

    "review": {
        "rating": 0,
    },

    "marketing_event": {
        "event_type": "InvalidEvent",
    },
}


class InvalidValueInjector:
    """
    Inject invalid values into configured columns.

    The injection rate is read from ENTITY_ERROR_RATES
    in config.py.
    """

    def __init__(self, seed=42):
        self.seed = seed

    def inject(self, df, entity):
        """
        Inject all configured invalid values for an entity.

        Parameters
        ----------
        df : pandas.DataFrame
            Clean input DataFrame.

        entity : str
            Entity name from config.py.

        Returns
        -------
        pandas.DataFrame
            DataFrame containing invalid values.
        """

        dirty_df = df.copy()

        entity_config = ENTITY_ERROR_RATES.get(entity, {})

        invalid_rules = entity_config.get(
            "invalid_value",
            {}
        )

        if not invalid_rules:
            return dirty_df

        invalid_entity_values = INVALID_VALUES.get(
            entity,
            {}
        )

        rng = np.random.default_rng(self.seed)

        for column, rate in invalid_rules.items():

            if column not in dirty_df.columns:
                raise ValueError(
                    f"Column '{column}' does not exist in "
                    f"entity '{entity}'."
                )

            if column not in invalid_entity_values:
                raise ValueError(
                    f"No invalid value defined for "
                    f"'{entity}.{column}'."
                )

            invalid_value = invalid_entity_values[column]

            self._inject_column_invalid_value(
                dirty_df,
                column,
                rate,
                invalid_value,
                rng
            )

        return dirty_df

    @staticmethod
    def _inject_column_invalid_value(
        df,
        column,
        rate,
        invalid_value,
        rng
    ):
        """
        Inject an invalid value into a selected percentage
        of rows in one column.
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

        df.loc[
            selected_indices,
            column
        ] = invalid_value