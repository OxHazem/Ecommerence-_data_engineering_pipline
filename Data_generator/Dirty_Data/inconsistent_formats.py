# Data_generator/Dirty_Data/inconsistent_formats.py

import numpy as np

from .config import ENTITY_ERROR_RATES


# ============================================================
# FORMAT TRANSFORMATIONS
#
# These transformations preserve the meaning of the original
# value while changing its representation.
# ============================================================

FORMAT_TRANSFORMATIONS = {

    "customer": {
        "country": {
            "Egypt": "EG",
            "EG": "Egypt",
            "egypt": "EG",
        },

        "city": {
            "Cairo": "cairo",
            "cairo": "CAIRO",
            "CAIRO": "Cairo",
        },
    },

    "product": {
        "category": {
            "Electronics": "electronics",
            "electronics": "Electronics",
        },

        "brand": {
            "Samsung": "SAMSUNG",
            "SAMSUNG": "Samsung",
        },
    },

    "order": {
        "order_status": {
            "Shipped": "shipped",
            "shipped": "SHIPPED",
            "SHIPPED": "Shipped",
        },
    },

    "marketing_event": {
        "device_type": {
            "Mobile": "mobile",
            "mobile": "MOBILE",
            "MOBILE": "Mobile",
        },
    },
}


class InconsistentFormatInjector:
    """
    Injects inconsistent representations of otherwise valid
    values according to config.py.
    """

    def __init__(self, seed=42):
        self.seed = seed

    def inject(self, df, entity):
        """
        Inject inconsistent formats into a DataFrame.

        Parameters
        ----------
        df : pandas.DataFrame
            Clean input DataFrame.

        entity : str
            Entity name from config.py.

        Returns
        -------
        pandas.DataFrame
            DataFrame containing inconsistent formats.
        """

        dirty_df = df.copy()

        entity_config = ENTITY_ERROR_RATES.get(
            entity,
            {}
        )

        format_rules = entity_config.get(
            "inconsistent_format",
            {}
        )

        if not format_rules:
            return dirty_df

        entity_transformations = FORMAT_TRANSFORMATIONS.get(
            entity,
            {}
        )

        rng = np.random.default_rng(self.seed)

        for column, rate in format_rules.items():

            if column not in dirty_df.columns:
                raise ValueError(
                    f"Column '{column}' does not exist in "
                    f"entity '{entity}'."
                )

            if column not in entity_transformations:
                raise ValueError(
                    f"No format transformations defined for "
                    f"'{entity}.{column}'."
                )

            self._inject_column_format(
                dirty_df,
                column,
                rate,
                entity_transformations[column],
                rng
            )

        return dirty_df

    @staticmethod
    def _inject_column_format(
        df,
        column,
        rate,
        transformations,
        rng
    ):
        """
        Change the representation of selected values while
        preserving their meaning.
        """

        if not 0 <= rate <= 1:
            raise ValueError(
                f"Invalid rate {rate} for column '{column}'. "
                f"Rate must be between 0 and 1."
            )

        n_rows = len(df)

        n_inconsistent = int(round(n_rows * rate))

        if n_inconsistent == 0:
            return

        # Find rows whose current value has a known
        # inconsistent-format transformation.
        eligible_indices = [
            index
            for index, value in df[column].items()
            if value in transformations
        ]

        if len(eligible_indices) < n_inconsistent:
            raise ValueError(
                f"Not enough eligible values in '{column}' "
                f"to inject {n_inconsistent} inconsistent "
                f"formats."
            )

        selected_indices = rng.choice(
            eligible_indices,
            size=n_inconsistent,
            replace=False
        )

        for index in selected_indices:

            current_value = df.at[index, column]

            df.at[
                index,
                column
            ] = transformations[current_value]