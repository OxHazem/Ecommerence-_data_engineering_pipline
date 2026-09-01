from io import BytesIO

import pandas as pd
import psycopg2

from ingestion.config import (
    MINIO_RAW_BUCKET,
)

from ingestion.config import (
    POSTGRES_HOST,
    POSTGRES_PORT,
    POSTGRES_DB,
    POSTGRES_USER,
    POSTGRES_PASSWORD,
)

from ingestion.minio_client import create_minio_client


# ============================================================
# MinIO → Bronze table mapping
# ============================================================

TABLE_MAPPING = {
    "customers": "customer",
    "products": "product",
    "orders": "orders",
    "order_items": "order_item",
    "payments": "payment",
    "shipping": "shipping",
    "reviews": "review",
    "marketing_events": "marketing_event",
    "exchange_rates": "exchange_rate",
}




# ============================================================
# PostgreSQL connection
# ============================================================

def create_postgres_connection():
    """Create a PostgreSQL connection."""

    return psycopg2.connect(
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
    )


# ============================================================
# Read Parquet from MinIO
# ============================================================

def read_parquet_from_minio(
    client,
    object_name: str,
) -> pd.DataFrame:
    """Read one Parquet object from MinIO."""

    response = client.get_object(
        MINIO_RAW_BUCKET,
        object_name,
    )

    try:
        data = response.read()
        return pd.read_parquet(BytesIO(data))

    finally:
        response.close()
        response.release_conn()


# ============================================================
# Determine Bronze table
# ============================================================

def get_bronze_table(object_name: str) -> str:
    """
    Determine the Bronze table from the MinIO object path.

    Example:

    customers/batch_id=.../customers.parquet
        ↓
    bronze.customer
    """

    dataset_name = object_name.split("/", 1)[0]

    if dataset_name not in TABLE_MAPPING:
        raise ValueError(
            f"No Bronze table mapping exists for "
            f"dataset '{dataset_name}'."
        )

    return TABLE_MAPPING[dataset_name]


# ============================================================
# Insert DataFrame into Bronze
# ============================================================

def load_dataframe_to_bronze(
    df: pd.DataFrame,
    table_name: str,
    connection,
) -> int:
    """
    Insert a DataFrame into a Bronze table.

    Bronze intentionally does not perform data cleansing.
    """

    if df.empty:
        return 0

    columns = list(df.columns)

    column_sql = ", ".join(
        f'"{column}"'
        for column in columns
    )

    placeholders = ", ".join(
        ["%s"] * len(columns)
    )

    insert_sql = f"""
        INSERT INTO bronze.{table_name}
        ({column_sql})
        VALUES ({placeholders})
    """

    records = [
        tuple(row)
        for row in df.itertuples(index=False, name=None)
    ]

    with connection.cursor() as cursor:
        cursor.executemany(
            insert_sql,
            records,
        )

    connection.commit()

    return len(records)


# ============================================================
# Load one MinIO object
# ============================================================

def load_object_to_bronze(
    client,
    connection,
    object_name: str,
) -> int:
    """Load one MinIO Parquet object into Bronze."""

    print(f"Reading: {object_name}")

    table_name = get_bronze_table(object_name)

    df = read_parquet_from_minio(
        client=client,
        object_name=object_name,
    )

    print(f"  Target: bronze.{table_name}")
    print(f"  Rows:   {len(df)}")

    row_count = load_dataframe_to_bronze(
        df=df,
        table_name=table_name,
        connection=connection,
    )

    print(f"  ✓ Loaded: {row_count} rows")

    return row_count


# ============================================================
# Load all MinIO objects
# ============================================================

def load_all_objects_to_bronze():
    """Load all objects from the raw MinIO bucket."""

    minio_client = create_minio_client()
    postgres_connection = create_postgres_connection()

    total_rows = 0
    total_objects = 0

    try:

        objects = list(
            minio_client.list_objects(
                MINIO_RAW_BUCKET,
                recursive=True,
            )
        )

        print("========================================")
        print("MINIO → BRONZE")
        print("========================================")
        print(f"Bucket: {MINIO_RAW_BUCKET}")
        print(f"Objects found: {len(objects)}")
        print()

        for obj in objects:

            object_name = obj.object_name

            if not object_name.endswith(".parquet"):
                continue

            rows_loaded = load_object_to_bronze(
                client=minio_client,
                connection=postgres_connection,
                object_name=object_name,
            )

            total_rows += rows_loaded
            total_objects += 1

            print()

        print("========================================")
        print("BRONZE LOAD COMPLETED")
        print("========================================")
        print(f"Objects loaded: {total_objects}")
        print(f"Rows loaded:    {total_rows}")

    finally:
        postgres_connection.close()

# ============================================================
# Load specific MinIO object to Bronze
# ============================================================

def load_specific_object_to_bronze(object_name: str):
    """
    Load one specific Parquet object from MinIO into Bronze.
    """

    minio_client = create_minio_client()
    postgres_connection = create_postgres_connection()

    try:

        print("========================================")
        print("MINIO → BRONZE")
        print("========================================")
        print(f"Bucket: {MINIO_RAW_BUCKET}")
        print(f"Object: {object_name}")
        print()

        rows_loaded = load_object_to_bronze(
            client=minio_client,
            connection=postgres_connection,
            object_name=object_name,
        )

        print()
        print("========================================")
        print("BRONZE LOAD COMPLETED")
        print("========================================")
        print(f"Objects loaded: 1")
        print(f"Rows loaded:    {rows_loaded}")

    finally:
        postgres_connection.close()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # load_all_objects_to_bronze()
    object_name = (
        "exchange_rates/"
        "batch_id=b43d7395-b7cd-412a-87f2-19148f35fe80/"
        "exchange_rates.parquet"
    )

    load_specific_object_to_bronze(object_name)