# Bronze Layer Schema Design: Handling Dirty Data

## 1. The Problem: Strict Types vs. Raw Data
In standard database design, tables are typically built with strict data types (`INTEGER`, `DATE`, `DECIMAL(10,2)`). The original schema for the Bronze data warehouse layer (`postgres_DW/sql/bronze/Create_tables.sql`) followed this pattern.

However, a core requirement of this Data Engineering pipeline is to simulate and process **real-world dirty data**. The `DirtyDataInjector` intentionally corrupts datasets, introducing errors such as:
* Strings into date columns (e.g., `"not-a-date"` in `order_date`).
* Strings into numeric columns (e.g., `"fifty dollars"` in `price`).
* Missing values (`NaN` or `NULL`) where strict constraints might normally reject them.

When exporting this dirty data to MinIO as **Parquet files**, the parquet engine detected these mixed types and was forced to cast those columns to generic `String`/`Object` types to prevent crashing. 

When attempting to ingest these Parquet files into PostgreSQL, the pipeline failed. PostgreSQL's strict schema (`DATE`, `INTEGER`) could not accept the incoming string data (e.g., trying to insert `"not-a-date"` into a `DATE` column throws a hard cast exception), breaking the ingestion pipeline entirely.

## 2. The Architectural Dilemma
To resolve this, there were two distinct architectural paths:

**Path A: Pre-Process During Ingestion**
* Write Python/Pandas logic to coerce invalid data (e.g., turning `"not-a-date"` into `NULL`) *before* it enters PostgreSQL.
* *Drawback:* This destroys data traceability. The original erroneous values are erased before reaching the warehouse, making debugging and data quality auditing impossible. It also violates the definition of a Medallion "Bronze" layer, which should be an exact replica of the source.

**Path B: The "Lakehouse" Approach (Chosen Solution)**
* Change the Bronze schema in PostgreSQL to use `TEXT` (or `VARCHAR`) for all business columns.
* *Benefit:* This allows PostgreSQL to seamlessly accept the string-cast Parquet data directly from MinIO. The exact dirty values (`"not-a-date"`, `"fifty dollars"`) land safely in the warehouse for full auditing traceability. 

## 3. The Implementation (The Solution)
We fully adopted **Path B**.

The `postgres_DW/sql/bronze/Create_tables.sql` file was programmatically updated to convert all strict business data types (`INTEGER`, `DATE`, `DECIMAL`, `BOOLEAN`) to `TEXT`.

### Example (Before):
```sql
CREATE TABLE bronze.order (
    order_id          INTEGER,
    order_date        DATE,
    order_status      VARCHAR(20)
    -- ...
);
```

### Example (After):
```sql
CREATE TABLE bronze.order (
    order_id          TEXT,
    order_date        TEXT,
    order_status      TEXT,
    
    -- Ingestion Metadata remains strictly typed for engine operations
    source_file         TEXT,
    ingestion_timestamp TIMESTAMPTZ,
    batch_id            UUID,
    source_system       TEXT
);
```

### Key Takeaways
1. **Bulletproof Ingestion:** The pipeline from MinIO to PostgreSQL Bronze will no longer crash due to unexpected garbage data or schema drift.
2. **Preserved Metadata:** Crucially, ingestion tracking metadata (`ingestion_timestamp TIMESTAMPTZ`, `batch_id UUID`) remained strictly typed, as these are generated securely by the loading script itself, not parsed from the dirty files.
3. **Shifted Responsibility:** Data cleansing, dropping bad rows, and enforcing strict type casts (`CAST(order_date AS DATE)`) is now correctly designated as the responsibility of the **Silver Layer** (typically executed via SQL transformations like dbt).
