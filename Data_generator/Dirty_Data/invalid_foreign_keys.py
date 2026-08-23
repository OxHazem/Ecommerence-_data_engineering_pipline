# Data_generator/Dirty_Data/invalid_foreign_keys.py

import numpy as np
import pandas as pd

from .config import ENTITY_ERROR_RATES


# ============================================================
# FOREIGN KEY RELATIONSHIPS
#
# child_entity:
#     child_column -> parent_entity.parent_column
# ============================================================

FOREIGN_KEY_RELATIONSHIPS = {

    "order": {
        "customer_id": ("customer", "customer_id"),
    },

    "order_item": {
        "order_id": ("order", "order_id"),
        "product_id": ("product", "product_id"),
    },

    "payment": {
        "order_id": ("order", "order_id"),
    },

    "shipping": {
        "order_id": ("order", "order_id"),
    },

    "review": {
        "customer_id": ("customer", "customer_id"),
        "product_id": ("product", "product_id"),
    },

    "marketing_event": {
        "customer_id": ("customer", "customer_id"),
    },
}


class InvalidForeignKeyInjector:
    """
    Injects foreign-key values that do not exist in the
    corresponding parent DataFrame.
    """

    def __init__(self, seed=42):
        self.seed = seed

    def inject(
        self,
        child_df,
        parent_df,
        entity,
        column
    ):
        """
        Inject invalid foreign keys into one child column.

        Parameters
        ----------
        child_df : pandas.DataFrame
            Child entity DataFrame.

        parent_df : pandas.DataFrame
            Parent entity DataFrame.

        entity : str
            Child entity name.

        column : str
            Foreign-key column in the child entity.

        Returns
        -------
        pandas.DataFrame
            DataFrame with invalid foreign keys.
        """

        dirty_df = child_df.copy()

        self._validate_relationship(
            entity,
            column
        )

        parent_entity, parent_column = (
            FOREIGN_KEY_RELATIONSHIPS[entity][column]
        )

        if column not in dirty_df.columns:
            raise ValueError(
                f"Column '{column}' does not exist in "
                f"entity '{entity}'."
            )

        if parent_column not in parent_df.columns:
            raise ValueError(
                f"Parent column '{parent_column}' does not "
                f"exist in parent entity '{parent_entity}'."
            )

        rate = (
            ENTITY_ERROR_RATES
            .get(entity, {})
            .get("invalid_fk", {})
            .get(column)
        )

        if rate is None:
            raise ValueError(
                f"No invalid FK rate configured for "
                f"'{entity}.{column}'."
            )

        rng = np.random.default_rng(self.seed)

        invalid_value = self._generate_invalid_fk(
            parent_df[parent_column],
            rng
        )

        self._inject(
            dirty_df,
            column,
            rate,
            invalid_value,
            rng
        )

        return dirty_df

    @staticmethod
    def _validate_relationship(entity, column):
        """
        Verify that the configured FK relationship exists.
        """

        if entity not in FOREIGN_KEY_RELATIONSHIPS:
            raise ValueError(
                f"No FK relationships configured for "
                f"entity '{entity}'."
            )

        if column not in FOREIGN_KEY_RELATIONSHIPS[entity]:
            raise ValueError(
                f"No FK relationship configured for "
                f"'{entity}.{column}'."
            )

    @staticmethod
    def _generate_invalid_fk(
        parent_keys,
        rng
    ):
        """
        Generate an ID guaranteed not to exist in the
        parent key column.
        """

        valid_keys = set(
            parent_keys.dropna().tolist()
        )

        if not valid_keys:
            raise ValueError(
                "Parent key column contains no valid keys."
            )

        # Numeric IDs
        if pd.api.types.is_numeric_dtype(parent_keys):

            candidate = max(valid_keys) + 1

            while candidate in valid_keys:
                candidate += 1

            return candidate

        # String IDs
        candidate = "INVALID_FK_999999"

        while candidate in valid_keys:
            candidate = f"INVALID_FK_{rng.integers(100000, 999999)}"

        return candidate

    @staticmethod
    def _inject(
        df,
        column,
        rate,
        invalid_value,
        rng
    ):
        """
        Replace selected valid FK values with an invalid FK.
        """

        if not 0 <= rate <= 1:
            raise ValueError(
                f"Invalid FK rate {rate}. "
                f"Rate must be between 0 and 1."
            )

        n_rows = len(df)

        n_invalid = int(round(n_rows * rate))

        if n_invalid == 0:
            return

        if n_invalid > n_rows:
            raise ValueError(
                "Number of invalid foreign keys cannot "
                "exceed the number of rows."
            )

        selected_indices = rng.choice(
            df.index.to_numpy(),
            size=n_invalid,
            replace=False
        )

        df.loc[
            selected_indices,
            column
        ] = invalid_value