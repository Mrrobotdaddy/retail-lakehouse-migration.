# Architectural Decisions & Design Trade-offs

This document details key engineering design choices made during the development of the Retail Lakehouse Migration pipeline, along with their respective trade-offs.

---

## 1. Storage Architecture: ADLS Gen2 with Hierarchical Namespace (HNS)

* **Decision**: Provision Azure Data Lake Storage Gen2 with Hierarchical Namespace enabled, adopting the Medallion Architecture (`bronze`, `silver`, `gold`).
* **Why**: Spark workloads perform significantly better with true folder structures. Directory renames and file listings in HNS are atomic $O(1)$ metadata operations rather than $O(N)$ batch copies and deletes.
* **Trade-off**: HNS cannot be turned off or on after resource creation. Standard Blob storage tools without ADLS Gen2 driver support may face compatibility limitations.

---

## 2. File Format Evolution: Parquet vs Delta Lake

* **Decision**: Ingest raw source data as Parquet into `bronze`, then transform into Delta format for `silver` and `gold`.
* **Why**:
  * **Bronze (Parquet)**: Fast, immutable, columnar snapshot directly from source with zero compute overhead.
  * **Silver/Gold (Delta Lake)**: Enables ACID transactions, schema enforcement, time-travel auditing, and high-performance `MERGE` upserts essential for incremental loads and SCD Type 2.
* **Trade-off**: Delta Lake adds transaction log overhead (`_delta_log`), requiring periodic vacuuming and compaction jobs (`OPTIMIZE`) in production.

---

## 3. Secret Management: Azure Key Vault with RBAC & Managed Identity

* **Decision**: Avoid connection strings and secrets in pipeline code and configuration files. Use Azure Key Vault configured with Azure Role-Based Access Control (RBAC).
* **Why**: Managed Identities eliminate the need for credential storage in ADF or Databricks. Credentials are automatically evaluated at runtime based on the service's Azure AD principal.
* **Trade-off**: Requires proper IAM role assignments (`Key Vault Secrets User`) across service identities, adding slight provisioning setup complexity compared to legacy access policies.

---

## 4. Compute Sizing: Serverless SQL & Single-Node Databricks

* **Decision**: Use Azure SQL Serverless with auto-pause enabled and single-node Databricks clusters with a 20-minute auto-termination policy.
* **Why**: Cost protection is paramount during development. Auto-pausing SQL reduces compute costs to near zero when inactive, and single-node Databricks prevents multi-VM cluster expense.
* **Trade-off**: The initial query against a paused serverless database experiences a ~30-second cold-start latency as compute warms up.
