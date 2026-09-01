# from datetime import date, datetime, timezone
# from io import BytesIO
# from uuid import uuid4

# import pandas as pd

# from Data_generator.exchange_rate.config import (
#     BASE_CURRENCY,
#     SUPPORTED_CURRENCIES,
# )
# from Data_generator.exchange_rate.service import ExchangeRateService

# from ingestion.config import MINIO_RAW_BUCKET, SOURCE_SYSTEM
# from ingestion.minio_client import create_minio_client


# def generate_batch_id() -> str:
#     """Generate a unique ingestion batch ID."""
#     return str(uuid4())


# def fetch_exchange_rates(rate_date=None) -> pd.DataFrame:
#     """
#     Fetch supported currency exchange rates against the
#     base currency for one specific requested date.
#     """

#     if rate_date is None:
#         rate_date = date.today()

#     if isinstance(rate_date, str):
#         rate_date = date.fromisoformat(rate_date)

#     service = ExchangeRateService()

#     records = []

#     for currency in SUPPORTED_CURRENCIES:

#         if currency == BASE_CURRENCY:
#             result = {
#                 "requested_date": rate_date.isoformat(),
#                 "date": rate_date.isoformat(),
#                 "base": BASE_CURRENCY,
#                 "quote": BASE_CURRENCY,
#                 "rate": 1,
#             }

#         else:
#             result = service.get_rate(
#                 from_currency=currency,
#                 to_currency=BASE_CURRENCY,
#                 rate_date=rate_date,
#             )

#             result["requested_date"] = rate_date.isoformat()

#         records.append(result)

#     return pd.DataFrame(records)

# def validate_exchange_rates(df: pd.DataFrame) -> None:
#     """
#     Validate the exchange-rate dataset before ingestion.
#     """

#     required_columns = {
#     "requested_date",
#     "date",
#     "base",
#     "quote",
#     "rate",
#     }

#     missing_columns = required_columns - set(df.columns)

#     if missing_columns:
#         raise ValueError(
#             f"Missing required columns: {missing_columns}"
#         )

#     if df.empty:
#         raise ValueError(
#             "Exchange-rate dataset is empty."
#         )

#     if df["date"].isna().any():
#         raise ValueError(
#             "Exchange-rate dataset contains null dates."
#         )

#     if df["rate"].isna().any():
#         raise ValueError(
#             "Exchange-rate dataset contains null rates."
#         )

#     if (df["rate"] <= 0).any():
#         raise ValueError(
#             "Exchange-rate dataset contains non-positive rates."
#         )

#     supported = set(SUPPORTED_CURRENCIES)

#     if not set(df["base"]).issubset(supported):
#         raise ValueError(
#             "Unsupported base currency found."
#         )

#     if not set(df["quote"]).issubset(supported):
#         raise ValueError(
#             "Unsupported quote currency found."
#         )

#     if df.duplicated(
#         subset=["date", "base", "quote"]
#     ).any():
#         raise ValueError(
#             "Duplicate exchange-rate records found."
#         )


# def add_ingestion_metadata(
#     df: pd.DataFrame,
#     batch_id: str,
# ) -> pd.DataFrame:
#     """Add ingestion metadata."""

#     df = df.copy()

#     df["source_file"] = "frankfurter_exchange_rate_api"
#     df["ingestion_timestamp"] = datetime.now(timezone.utc)
#     df["batch_id"] = batch_id
#     df["source_system"] = SOURCE_SYSTEM

#     return df


# def convert_to_parquet_bytes(
#     df: pd.DataFrame,
# ) -> BytesIO:
#     """Convert exchange-rate data to Parquet."""

#     buffer = BytesIO()

#     df.to_parquet(
#         buffer,
#         index=False,
#         engine="pyarrow",
#     )

#     buffer.seek(0)

#     return buffer


# def ingest_exchange_rates(rate_date=None) -> str:
#     """
#     Fetch, validate, and store exchange rates in MinIO.
#     """

#     client = create_minio_client()

#     # 1. Fetch data from API
#     df = fetch_exchange_rates(rate_date)

#     # 2. Validate data BEFORE adding metadata
#     validate_exchange_rates(df)

#     # 3. Generate batch ID
#     batch_id = generate_batch_id()

#     # 4. Add ingestion metadata
#     df = add_ingestion_metadata(
#         df=df,
#         batch_id=batch_id,
#     )

#     # 5. Convert to Parquet
#     parquet_buffer = convert_to_parquet_bytes(df)

#     # 6. Define MinIO object path
#     object_name = (
#         f"exchange_rates/"
#         f"batch_id={batch_id}/"
#         f"exchange_rates.parquet"
#     )

#     # 7. Upload to MinIO
#     client.put_object(
#         bucket_name=MINIO_RAW_BUCKET,
#         object_name=object_name,
#         data=parquet_buffer,
#         length=parquet_buffer.getbuffer().nbytes,
#         content_type="application/octet-stream",
#     )

#     return object_name


# def main():
#     object_name = ingest_exchange_rates()

#     print("✓ Exchange-rate ingestion completed")
#     print(f"✓ Bucket: {MINIO_RAW_BUCKET}")
#     print(f"✓ Object: {object_name}")


# if __name__ == "__main__":
#     main()



# # from datetime import date, datetime, timezone
# # from io import BytesIO
# # from uuid import uuid4

# # import pandas as pd

# # from Data_generator.exchange_rate.config import (
# #     BASE_CURRENCY,
# #     SUPPORTED_CURRENCIES,
# # )
# # from Data_generator.exchange_rate.service import ExchangeRateService

# # from ingestion.config import MINIO_RAW_BUCKET, SOURCE_SYSTEM
# # from ingestion.minio_client import create_minio_client


# # def generate_batch_id() -> str:
# #     """Generate a unique ingestion batch ID."""
# #     return str(uuid4())


# # def fetch_exchange_rates(
# #     start_date,
# #     end_date
# # ) -> pd.DataFrame:
# #     """
# #     Fetch historical exchange rates against EGP.
# #     """

# #     if isinstance(start_date, str):
# #         start_date = date.fromisoformat(start_date)

# #     if isinstance(end_date, str):
# #         end_date = date.fromisoformat(end_date)

# #     if start_date > end_date:
# #         raise ValueError(
# #             "start_date cannot be after end_date."
# #         )

# #     service = ExchangeRateService()

# #     records = []

# #     # --------------------------------------------------------
# #     # Foreign currencies
# #     # --------------------------------------------------------

# #     for currency in SUPPORTED_CURRENCIES:

# #         if currency == BASE_CURRENCY:
# #             continue

# #         rates = service.get_historical_rates(
# #             from_currency=currency,
# #             to_currency=BASE_CURRENCY,
# #             start_date=start_date,
# #             end_date=end_date,
# #         )

# #         for result in rates:

# #             records.append({
# #                 "requested_date": result["date"],
# #                 "date": result["date"],
# #                 "base": result["base"],
# #                 "quote": result["quote"],
# #                 "rate": result["rate"],
# #             })

# #     # --------------------------------------------------------
# #     # EGP → EGP
# #     # --------------------------------------------------------

# #     for current_date in pd.date_range(
# #         start=start_date,
# #         end=end_date,
# #         freq="D"
# #     ):

# #         records.append({
# #             "requested_date": current_date.date().isoformat(),
# #             "date": current_date.date().isoformat(),
# #             "base": BASE_CURRENCY,
# #             "quote": BASE_CURRENCY,
# #             "rate": 1,
# #         })

# #     return pd.DataFrame(records)


# ingestion/exchange_rate/ingestor.py

from datetime import date, datetime, timezone
from io import BytesIO
from uuid import uuid4

import pandas as pd

from Data_generator.exchange_rate.config import (
    BASE_CURRENCY,
    SUPPORTED_CURRENCIES,
)
from Data_generator.exchange_rate.service import ExchangeRateService

from ingestion.config import MINIO_RAW_BUCKET, SOURCE_SYSTEM
from ingestion.minio_client import create_minio_client


# ============================================================
# BATCH ID
# ============================================================

def generate_batch_id() -> str:
    """Generate a unique ingestion batch ID."""
    return str(uuid4())


# ============================================================
# FETCH HISTORICAL EXCHANGE RATES
# ============================================================

def fetch_exchange_rates(
    start_date,
    end_date
) -> pd.DataFrame:
    """
    Fetch historical exchange rates against EGP
    for the requested date range.
    """

    # --------------------------------------------------------
    # Convert strings to date objects
    # --------------------------------------------------------

    if isinstance(start_date, str):
        start_date = date.fromisoformat(start_date)

    if isinstance(end_date, str):
        end_date = date.fromisoformat(end_date)

    # --------------------------------------------------------
    # Validate date range
    # --------------------------------------------------------

    if start_date > end_date:
        raise ValueError(
            "start_date cannot be after end_date."
        )

    service = ExchangeRateService()

    records = []

    # ========================================================
    # SAR -> EGP
    # AED -> EGP
    # ========================================================

    for currency in SUPPORTED_CURRENCIES:

        if currency == BASE_CURRENCY:
            continue

        rates = service.get_historical_rates(
            from_currency=currency,
            to_currency=BASE_CURRENCY,
            start_date=start_date,
            end_date=end_date,
        )

        for result in rates:

            records.append({
                "requested_date": result["date"],
                "date": result["date"],
                "base": result["base"],
                "quote": result["quote"],
                "rate": result["rate"],
            })

    # ========================================================
    # EGP -> EGP
    #
    # EGP is our base currency.
    # Therefore:
    #
    # 1 EGP = 1 EGP
    # ========================================================

    for current_date in pd.date_range(
        start=start_date,
        end=end_date,
        freq="D"
    ):

        current_date = current_date.date()

        records.append({
            "requested_date": current_date.isoformat(),
            "date": current_date.isoformat(),
            "base": BASE_CURRENCY,
            "quote": BASE_CURRENCY,
            "rate": 1,
        })

    # ========================================================
    # DATAFRAME
    # ========================================================

    df = pd.DataFrame(records)

    return df


# ============================================================
# VALIDATION
# ============================================================

def validate_exchange_rates(
    df: pd.DataFrame
) -> None:
    """
    Validate exchange-rate data before ingestion.
    """

    required_columns = {
        "requested_date",
        "date",
        "base",
        "quote",
        "rate",
    }

    # --------------------------------------------------------
    # Required columns
    # --------------------------------------------------------

    missing_columns = (
        required_columns - set(df.columns)
    )

    if missing_columns:

        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    # --------------------------------------------------------
    # Empty dataset
    # --------------------------------------------------------

    if df.empty:

        raise ValueError(
            "Exchange-rate dataset is empty."
        )

    # --------------------------------------------------------
    # Null dates
    # --------------------------------------------------------

    if df["requested_date"].isna().any():

        raise ValueError(
            "Exchange-rate dataset contains "
            "null requested dates."
        )

    if df["date"].isna().any():

        raise ValueError(
            "Exchange-rate dataset contains "
            "null dates."
        )

    # --------------------------------------------------------
    # Null rates
    # --------------------------------------------------------

    if df["rate"].isna().any():

        raise ValueError(
            "Exchange-rate dataset contains null rates."
        )

    # --------------------------------------------------------
    # Positive rates
    # --------------------------------------------------------

    if (df["rate"] <= 0).any():

        raise ValueError(
            "Exchange-rate dataset contains "
            "non-positive rates."
        )

    # --------------------------------------------------------
    # Supported currencies
    # --------------------------------------------------------

    supported = set(
        SUPPORTED_CURRENCIES
    )

    if not set(df["base"]).issubset(supported):

        raise ValueError(
            "Unsupported base currency found."
        )

    if not set(df["quote"]).issubset(supported):

        raise ValueError(
            "Unsupported quote currency found."
        )

    # --------------------------------------------------------
    # Foreign currencies must convert TO EGP
    # --------------------------------------------------------

    foreign_rates = df[
        df["base"] != BASE_CURRENCY
    ]

    if not (
        foreign_rates["quote"] == BASE_CURRENCY
    ).all():

        raise ValueError(
            "Foreign exchange rates must use EGP "
            "as the quote currency."
        )

    # --------------------------------------------------------
    # EGP -> EGP must always equal 1
    # --------------------------------------------------------

    egp_rates = df[
        (df["base"] == BASE_CURRENCY)
        &
        (df["quote"] == BASE_CURRENCY)
    ]

    if not (egp_rates["rate"] == 1).all():

        raise ValueError(
            "EGP -> EGP exchange rate must always be 1."
        )

    # --------------------------------------------------------
    # Duplicate exchange rates
    # --------------------------------------------------------

    if df.duplicated(
        subset=[
            "date",
            "base",
            "quote"
        ]
    ).any():

        raise ValueError(
            "Duplicate exchange-rate records found."
        )


# ============================================================
# INGESTION METADATA
# ============================================================

def add_ingestion_metadata(
    df: pd.DataFrame,
    batch_id: str,
) -> pd.DataFrame:
    """
    Add ingestion metadata.
    """

    df = df.copy()

    df["source_file"] = (
        "frankfurter_exchange_rate_api"
    )

    df["ingestion_timestamp"] = (
        datetime.now(timezone.utc)
    )

    df["batch_id"] = batch_id

    df["source_system"] = SOURCE_SYSTEM

    return df


# ============================================================
# PARQUET
# ============================================================

def convert_to_parquet_bytes(
    df: pd.DataFrame,
) -> BytesIO:
    """
    Convert exchange-rate data to Parquet.
    """

    buffer = BytesIO()

    df.to_parquet(
        buffer,
        index=False,
        engine="pyarrow",
    )

    buffer.seek(0)

    return buffer


# ============================================================
# MINIO INGESTION
# ============================================================

def ingest_exchange_rates(
    start_date,
    end_date
) -> str:
    """
    Fetch, validate, and store historical
    exchange rates in MinIO.
    """

    client = create_minio_client()

    # --------------------------------------------------------
    # 1. Fetch historical data
    # --------------------------------------------------------

    df = fetch_exchange_rates(
        start_date=start_date,
        end_date=end_date
    )

    # --------------------------------------------------------
    # 2. Validate
    # --------------------------------------------------------

    validate_exchange_rates(df)

    # --------------------------------------------------------
    # 3. Generate batch ID
    # --------------------------------------------------------

    batch_id = generate_batch_id()

    # --------------------------------------------------------
    # 4. Add metadata
    # --------------------------------------------------------

    df = add_ingestion_metadata(
        df=df,
        batch_id=batch_id,
    )

    # --------------------------------------------------------
    # 5. Convert to Parquet
    # --------------------------------------------------------

    parquet_buffer = convert_to_parquet_bytes(
        df
    )

    # --------------------------------------------------------
    # 6. MinIO object path
    # --------------------------------------------------------

    object_name = (
        f"exchange_rates/"
        f"batch_id={batch_id}/"
        f"exchange_rates.parquet"
    )

    # --------------------------------------------------------
    # 7. Upload to MinIO
    # --------------------------------------------------------

    client.put_object(
        bucket_name=MINIO_RAW_BUCKET,
        object_name=object_name,
        data=parquet_buffer,
        length=parquet_buffer.getbuffer().nbytes,
        content_type="application/octet-stream",
    )

    return object_name


# ============================================================
# MAIN
# ============================================================

def main():

    # --------------------------------------------------------
    # IMPORTANT:
    # Use the actual date range of your generated orders.
    # --------------------------------------------------------

    start_date = "2015-02-15"
    end_date = "2026-08-29"

    object_name = ingest_exchange_rates(
        start_date=start_date,
        end_date=end_date
    )

    print(
        "✓ Exchange-rate ingestion completed"
    )

    print(
        f"✓ Bucket: {MINIO_RAW_BUCKET}"
    )

    print(
        f"✓ Object: {object_name}"
    )


if __name__ == "__main__":
    main()