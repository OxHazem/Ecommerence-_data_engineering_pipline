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


def generate_batch_id() -> str:
    """Generate a unique ingestion batch ID."""
    return str(uuid4())


def fetch_exchange_rates(rate_date=None) -> pd.DataFrame:
    """
    Fetch supported currency exchange rates against the
    base currency for one specific requested date.
    """

    if rate_date is None:
        rate_date = date.today()

    if isinstance(rate_date, str):
        rate_date = date.fromisoformat(rate_date)

    service = ExchangeRateService()

    records = []

    for currency in SUPPORTED_CURRENCIES:

        if currency == BASE_CURRENCY:
            result = {
                "requested_date": rate_date.isoformat(),
                "date": rate_date.isoformat(),
                "base": BASE_CURRENCY,
                "quote": BASE_CURRENCY,
                "rate": 1,
            }

        else:
            result = service.get_rate(
                from_currency=currency,
                to_currency=BASE_CURRENCY,
                rate_date=rate_date,
            )

            result["requested_date"] = rate_date.isoformat()

        records.append(result)

    return pd.DataFrame(records)

def validate_exchange_rates(df: pd.DataFrame) -> None:
    """
    Validate the exchange-rate dataset before ingestion.
    """

    required_columns = {
    "requested_date",
    "date",
    "base",
    "quote",
    "rate",
    }

    missing_columns = required_columns - set(df.columns)

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    if df.empty:
        raise ValueError(
            "Exchange-rate dataset is empty."
        )

    if df["date"].isna().any():
        raise ValueError(
            "Exchange-rate dataset contains null dates."
        )

    if df["rate"].isna().any():
        raise ValueError(
            "Exchange-rate dataset contains null rates."
        )

    if (df["rate"] <= 0).any():
        raise ValueError(
            "Exchange-rate dataset contains non-positive rates."
        )

    supported = set(SUPPORTED_CURRENCIES)

    if not set(df["base"]).issubset(supported):
        raise ValueError(
            "Unsupported base currency found."
        )

    if not set(df["quote"]).issubset(supported):
        raise ValueError(
            "Unsupported quote currency found."
        )

    if df.duplicated(
        subset=["date", "base", "quote"]
    ).any():
        raise ValueError(
            "Duplicate exchange-rate records found."
        )


def add_ingestion_metadata(
    df: pd.DataFrame,
    batch_id: str,
) -> pd.DataFrame:
    """Add ingestion metadata."""

    df = df.copy()

    df["source_file"] = "frankfurter_exchange_rate_api"
    df["ingestion_timestamp"] = datetime.now(timezone.utc)
    df["batch_id"] = batch_id
    df["source_system"] = SOURCE_SYSTEM

    return df


def convert_to_parquet_bytes(
    df: pd.DataFrame,
) -> BytesIO:
    """Convert exchange-rate data to Parquet."""

    buffer = BytesIO()

    df.to_parquet(
        buffer,
        index=False,
        engine="pyarrow",
    )

    buffer.seek(0)

    return buffer


def ingest_exchange_rates(rate_date=None) -> str:
    """
    Fetch, validate, and store exchange rates in MinIO.
    """

    client = create_minio_client()

    # 1. Fetch data from API
    df = fetch_exchange_rates(rate_date)

    # 2. Validate data BEFORE adding metadata
    validate_exchange_rates(df)

    # 3. Generate batch ID
    batch_id = generate_batch_id()

    # 4. Add ingestion metadata
    df = add_ingestion_metadata(
        df=df,
        batch_id=batch_id,
    )

    # 5. Convert to Parquet
    parquet_buffer = convert_to_parquet_bytes(df)

    # 6. Define MinIO object path
    object_name = (
        f"exchange_rates/"
        f"batch_id={batch_id}/"
        f"exchange_rates.parquet"
    )

    # 7. Upload to MinIO
    client.put_object(
        bucket_name=MINIO_RAW_BUCKET,
        object_name=object_name,
        data=parquet_buffer,
        length=parquet_buffer.getbuffer().nbytes,
        content_type="application/octet-stream",
    )

    return object_name


def main():
    object_name = ingest_exchange_rates()

    print("✓ Exchange-rate ingestion completed")
    print(f"✓ Bucket: {MINIO_RAW_BUCKET}")
    print(f"✓ Object: {object_name}")


if __name__ == "__main__":
    main()