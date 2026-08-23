import pandas as pd
import numpy as np

from .config import (
    ENTITY_ERROR_RATES,
    DUPLICATE_KEY_COLUMNS,
)


class DuplicateInjector:
    """
    Inject duplicate records or duplicate business keys
    according to the configuration.
    """

    def __init__(self, seed=42):
        self.seed = seed

    def inject(self, df, entity):
        """
        Inject all configured duplicate rules for an entity.

        Parameters
        ----------
        df : pandas.DataFrame
            Clean input DataFrame.

        entity : str
            Entity name from ENTITY_ERROR_RATES.

        Returns
        -------
        pandas.DataFrame
            DataFrame containing injected duplicates.
        """

        dirty_df = df.copy()

        entity_config = ENTITY_ERROR_RATES.get(entity, {})

        duplicate_rules = entity_config.get("duplicate", {})

        if not duplicate_rules:
            return dirty_df

        key_config = DUPLICATE_KEY_COLUMNS.get(entity, {})

        rng = np.random.default_rng(self.seed)

        for duplicate_rule, rate in duplicate_rules.items():

            if duplicate_rule not in key_config:
                raise ValueError(
                    f"No duplicate key configuration found for "
                    f"'{entity}.{duplicate_rule}'."
                )

            columns = key_config[duplicate_rule]

            self._validate_columns(
                dirty_df,
                columns,
                entity,
                duplicate_rule
            )

            dirty_df = self._inject_duplicates(
                dirty_df,
                columns,
                rate,
                rng
            )

        return dirty_df

    @staticmethod
    def _validate_columns(
        df,
        columns,
        entity,
        duplicate_rule
    ):
        """
        Make sure all configured duplicate-key columns exist.
        """

        missing_columns = [
            column
            for column in columns
            if column not in df.columns
        ]

        if missing_columns:
            raise ValueError(
                f"Missing columns {missing_columns} for "
                f"duplicate rule '{entity}.{duplicate_rule}'."
            )

    @staticmethod
    def _inject_duplicates(
        df,
        columns,
        rate,
        rng
    ):
        """
        Select existing records and append copies of them.
        """

        if not 0 <= rate <= 1:
            raise ValueError(
                f"Duplicate rate must be between 0 and 1. "
                f"Received: {rate}"
            )

        n_rows = len(df)

        n_duplicates = int(round(n_rows * rate))

        if n_duplicates == 0:
            return df

        if n_duplicates > n_rows:
            raise ValueError(
                "Number of duplicates cannot exceed "
                "the number of source rows."
            )

        selected_indices = rng.choice(
            df.index.to_numpy(),
            size=n_duplicates,
            replace=False
        )

        duplicate_rows = df.loc[selected_indices].copy()

        return pd.concat(
            [df, duplicate_rows],
            ignore_index=True
        )