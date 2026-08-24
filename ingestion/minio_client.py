from minio import Minio

from ingestion.config import (
    MINIO_ACCESS_KEY,
    MINIO_ENDPOINT,
    MINIO_RAW_BUCKET,
    MINIO_SECRET_KEY,
    MINIO_SECURE,
)


def create_minio_client() -> Minio:
    """Create and return a MinIO client."""
    return Minio(
        endpoint=MINIO_ENDPOINT,
        access_key=MINIO_ACCESS_KEY,
        secret_key=MINIO_SECRET_KEY,
        secure=MINIO_SECURE,
    )


def check_raw_bucket(client: Minio) -> bool:
    """Check whether the configured raw bucket exists."""
    return client.bucket_exists(MINIO_RAW_BUCKET)


if __name__ == "__main__":
    client = create_minio_client()

    if check_raw_bucket(client):
        print(f"✓ Connected to MinIO")
        print(f"✓ Bucket '{MINIO_RAW_BUCKET}' exists")
    else:
        print(f"✗ Connected to MinIO, but bucket '{MINIO_RAW_BUCKET}' does not exist")