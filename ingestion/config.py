import os
from pathlib import Path

from dotenv import load_dotenv


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent.parent

load_dotenv(PROJECT_ROOT / ".env")

DATA_DIR = PROJECT_ROOT / "Data"
GENERATED_DATA_DIR = DATA_DIR / "generated"
DIRTY_DATA_DIR = GENERATED_DATA_DIR / "dirty"
CLEAN_DATA_DIR = GENERATED_DATA_DIR / "clean"


# ============================================================
# MinIO configuration
# ============================================================

MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY")
MINIO_SECURE = os.getenv("MINIO_SECURE", "false").lower() == "true"

MINIO_RAW_BUCKET = os.getenv("MINIO_RAW_BUCKET")


# ============================================================
# Ingestion configuration
# ============================================================

SOURCE_SYSTEM = "ecommerce"
INGESTION_FORMAT = "parquet"


# ============================================================
# Metadata
# ============================================================

METADATA_FIELDS = [
    "source_file",
    "ingestion_timestamp",
    "batch_id",
    "source_system",
]