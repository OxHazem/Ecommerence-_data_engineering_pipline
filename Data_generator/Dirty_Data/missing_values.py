# Data_generator/dirty_data/missing_values.py

import numpy as np
import pandas as pd

from .config import ENTITY_ERROR_RATES


class MissingValueInjector:
    """
    Injects missing values into columns according to the
    entity-specific configuration in config.py.
    """

    def __init__(self, seed=42):
        self.seed = seed

    def inject(self, df, entity):
        """
        Inject missing values into a DataFrame.

        Parameters
        ----------
        df : pandas.DataFrame
            Clean input DataFrame.

        entity : str
            Entity name used in ENTITY_ERROR_RATES.

        Returns
        -------
        pandas.DataFrame
            DataFrame containing injected missing values.
        """

        dirty_df = df.copy()

        entity_config = ENTITY_ERROR_RATES.get(entity, {})

        missing_rules = entity_config.get("missing", {})

        if not missing_rules:
            return dirty_df

        rng = np.random.default_rng(self.seed)

        for column, rate in missing_rules.items():

            if column not in dirty_df.columns:
                raise ValueError(
                    f"Column '{column}' does not exist in "
                    f"entity '{entity}'."
                )

            self._inject_column_missing(
                dirty_df,
                column,
                rate,
                rng
            )

        return dirty_df

    @staticmethod
    def _inject_column_missing(df, column, rate, rng):
        """
        Inject missing values into one column.
        """

        if not 0 <= rate <= 1:
            raise ValueError(
                f"Invalid missing rate {rate} for column '{column}'. "
                f"Rate must be between 0 and 1."
            )

        n_rows = len(df)

        n_missing = int(round(n_rows * rate))

        if n_missing == 0:
            return

        selected_indices = rng.choice(
            df.index.to_numpy(),
            size=n_missing,
            replace=False
        )

        df.loc[selected_indices, column] = np.nan