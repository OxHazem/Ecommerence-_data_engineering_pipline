from datetime import datetime, timezone
from io import BytesIO
from pathlib import Path
from uuid import uuid4
import json

import pandas as pd

from ingestion.config import (
    DIRTY_DATA_DIR,
    MINIO_RAW_BUCKET,
    SOURCE_SYSTEM,
)
from ingestion.minio_client import create_minio_client


SUPPORTED_EXTENSIONS = {".csv", ".json"}


# ============================================================
# BATCH ID
# ============================================================

def generate_batch_id() -> str:
    """Generate a unique ID for an ingestion batch."""
    return str(uuid4())


# ============================================================
# SOURCE READING
# ============================================================

def read_source_file(source_path: Path) -> pd.DataFrame:
    """
    Read a supported CSV or JSON source file.

    JSON is loaded through Python's json module rather than
    pandas.read_json() so that intentionally dirty values such
    as 'not-a-date' are not automatically converted to NaT.
    """

    extension = source_path.suffix.lower()

    if extension == ".csv":
        return pd.read_csv(
            source_path,
            keep_default_na=True,
        )

    if extension == ".json":
        with source_path.open("r", encoding="utf-8") as file:
            records = json.load(file)

        return pd.DataFrame(records)

    raise ValueError(
        f"Unsupported file format: {extension}. "
        f"Supported formats: {SUPPORTED_EXTENSIONS}"
    )


# ============================================================
# METADATA
# ============================================================

def add_ingestion_metadata(
    df: pd.DataFrame,
    source_file: str,
    batch_id: str,
) -> pd.DataFrame:
    """
    Add ingestion metadata without modifying the source data.
    """

    df = df.copy()

    df["source_file"] = source_file
    df["ingestion_timestamp"] = datetime.now(timezone.utc)
    df["batch_id"] = batch_id
    df["source_system"] = SOURCE_SYSTEM

    return df


# ============================================================
# PARQUET CONVERSION
# ============================================================

def convert_to_parquet_bytes(df: pd.DataFrame) -> BytesIO:
    """
    Convert a DataFrame into an in-memory Parquet file.

    Dirty object columns are converted to strings so that
    mixed-type values can safely be stored in Parquet.
    """

    df = df.copy()

    for column in df.columns:

        if df[column].dtype == "object":

            df[column] = df[column].astype("string")

    buffer = BytesIO()

    df.to_parquet(
        buffer,
        index=False,
        engine="pyarrow",
    )

    buffer.seek(0)

    return buffer


# ============================================================
# SINGLE FILE INGESTION
# ============================================================

def ingest_file(
    source_path: Path,
    client,
    bucket_name: str = MINIO_RAW_BUCKET,
) -> str:
    """
    Ingest one dirty source file into MinIO.
    """

    if not source_path.exists():
        raise FileNotFoundError(
            f"Source file does not exist: {source_path}"
        )

    if not source_path.is_file():
        raise ValueError(
            f"Source path is not a file: {source_path}"
        )

    if source_path.suffix.lower() not in SUPPORTED_EXTENSIONS:
        raise ValueError(
            f"Unsupported source file: {source_path.name}"
        )

    # --------------------------------------------------------
    # 1. Read source
    # --------------------------------------------------------

    df = read_source_file(source_path)

    # --------------------------------------------------------
    # 2. Generate batch ID
    # --------------------------------------------------------

    batch_id = generate_batch_id()

    # --------------------------------------------------------
    # 3. Add ingestion metadata
    # --------------------------------------------------------

    df = add_ingestion_metadata(
        df=df,
        source_file=source_path.name,
        batch_id=batch_id,
    )

    # --------------------------------------------------------
    # 4. Convert to Parquet
    # --------------------------------------------------------

    parquet_buffer = convert_to_parquet_bytes(df)

    # --------------------------------------------------------
    # 5. Build MinIO object path
    # --------------------------------------------------------

    object_name = (
        f"{source_path.stem}/"
        f"batch_id={batch_id}/"
        f"{source_path.stem}.parquet"
    )

    # --------------------------------------------------------
    # 6. Upload to MinIO
    # --------------------------------------------------------

    client.put_object(
        bucket_name=bucket_name,
        object_name=object_name,
        data=parquet_buffer,
        length=parquet_buffer.getbuffer().nbytes,
        content_type="application/parquet",
    )

    return object_name


# ============================================================
# ALL FILES
# ============================================================

def ingest_all_files(
    source_dir: Path,
    client,
    bucket_name: str = MINIO_RAW_BUCKET,
) -> list[str]:
    """
    Ingest all supported files from a source directory.
    """

    if not source_dir.exists():
        raise FileNotFoundError(
            f"Source directory does not exist: {source_dir}"
        )

    if not source_dir.is_dir():
        raise ValueError(
            f"Source path is not a directory: {source_dir}"
        )

    object_names = []

    for source_path in sorted(source_dir.iterdir()):

        if not source_path.is_file():
            continue

        if source_path.suffix.lower() not in SUPPORTED_EXTENSIONS:
            continue

        print(f"Ingesting: {source_path.name}")

        object_name = ingest_file(
            source_path=source_path,
            client=client,
            bucket_name=bucket_name,
        )

        object_names.append(object_name)

        print(f"  ✓ Uploaded: {object_name}")

    return object_names


# ============================================================
# MAIN
# ============================================================

def main() -> None:
    """
    Ingest all dirty source datasets into the MinIO raw bucket.
    """

    print("========================================")
    print("MINIO RAW INGESTION")
    print("========================================")

    print(f"Source directory: {DIRTY_DATA_DIR}")
    print(f"Target bucket:    {MINIO_RAW_BUCKET}")
    print()

    client = create_minio_client()

    object_names = ingest_all_files(
        source_dir=DIRTY_DATA_DIR,
        client=client,
        bucket_name=MINIO_RAW_BUCKET,
    )

    print()
    print("========================================")
    print("INGESTION COMPLETED")
    print("========================================")
    print(f"Files ingested: {len(object_names)}")

    for object_name in object_names:
        print(f"  ✓ {object_name}")


if __name__ == "__main__":
    main()