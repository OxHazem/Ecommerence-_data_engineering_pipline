from ingestion.config import MINIO_RAW_BUCKET
from ingestion.minio_client import create_minio_client


def clear_bucket():
    client = create_minio_client()

    if not client.bucket_exists(MINIO_RAW_BUCKET):
        print(f"Bucket '{MINIO_RAW_BUCKET}' does not exist.")
        return

    objects = client.list_objects(
        MINIO_RAW_BUCKET,
        recursive=True,
    )

    deleted = 0

    for obj in objects:
        print(f"Deleting: {obj.object_name}")

        client.remove_object(
            MINIO_RAW_BUCKET,
            obj.object_name,
        )

        deleted += 1

    print()
    print("========================================")
    print("BUCKET CLEARED")
    print("========================================")
    print(f"Objects deleted: {deleted}")


if __name__ == "__main__":
    clear_bucket()