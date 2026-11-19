# Legacy-to-Cloud Migration with Automated Reconciliation

[![Azure Data Factory](https://img.shields.io/badge/Orchestration-Azure%20Data%20Factory-blue)](https://azure.microsoft.com/en-us/products/data-factory)
[![Azure Databricks](https://img.shields.io/badge/Compute-Azure%20Databricks%20(Spark)-red)](https://azure.microsoft.com/en-us/products/databricks)
[![Delta Lake](https://img.shields.io/badge/Storage%20Format-Delta%20Lake-00ADD8)](https://delta.io/)
[![ADLS Gen2](https://img.shields.io/badge/Lakehouse-ADLS%20Gen2-brightgreen)](https://azure.microsoft.com/en-us/products/storage/data-lake-storage)

---

## 📌 Executive Summary & Client Context

* **Client Problem**: A national retail chain manages critical business reporting through an on-premises legacy SQL Server data warehouse. Long-running analytical queries frequently lock operational tables, licensing and physical server maintenance are cost-prohibitive, and scalability has reached its limit.
* **Modernisation Objective**: Migrate all analytical workloads and history to a scalable, cost-efficient Lakehouse architecture on Microsoft Azure.
* **Core Requirement**: Ensure **zero data loss** and complete auditability. Every ingested and transformed record must be programmatically reconciled against the source database across counts, numeric aggregations, and null distributions.

---

## 🏗️ Architecture & Data Flow

```mermaid
flowchart LR
    subgraph Source["Simulated On-Premises"]
        SQL[("Azure SQL Database<br/>SalesLT Schema")]
    end

    subgraph Orchestration["Azure Data Factory (ADF)"]
        Ctrl["Metadata Control & Watermarks"]
        CopyAct["Parameterized Copy Activity"]
    end

    subgraph ADLS["ADLS Gen2 (Medallion Lakehouse)"]
        Bronze[("Bronze Container<br/>Raw Parquet")]
        Silver[("Silver Container<br/>Delta Tables (Cleaned)")]
        Gold[("Gold Container<br/>Delta Star Schema")]
    end

    subgraph Databricks["Azure Databricks (PySpark)"]
        D1["Cleanse & Deduplicate"]
        D2["SCD Type 2 & Star Modeling"]
        Rec["Automated Reconciliation"]
    end

    subgraph Security["Security & Secrets"]
        KV[("Azure Key Vault<br/>Managed Identity Access")]
    end

    SQL --> CopyAct
    Ctrl --> CopyAct
    KV -.-> CopyAct
    CopyAct --> Bronze
    Bronze --> D1 --> Silver
    Silver --> D2 --> Gold
    SQL -. Reconciliation Query .-> Rec
    Gold -. Aggregates .-> Rec
    Rec --> AuditReport[("Reconciliation Results<br/>Audit Log (Delta)")]
```

---

## 🧰 Tech Stack & Component Mapping

| Category | Component | Purpose in Architecture |
|---|---|---|
| **Source System** | Azure SQL Database (`adventureworkslt-db`) | Simulates the legacy on-premises warehouse using the AdventureWorksLT retail dataset. |
| **Orchestration** | Azure Data Factory (`adf-retail-dev-rg`) | Metadata-driven pipeline coordinator managing data copies, parameter passing, and job dependencies. |
| **Data Lake** | ADLS Gen2 (`stretaildevrg`) | Hierarchical namespace storage partitioned into `bronze`, `silver`, and `gold` containers. |
| **Compute & Transforms**| Azure Databricks (`dbw-retail-dev`) | PySpark execution engine applying business logic, schema enforcement, Delta MERGE, and SCD Type 2 modeling. |
| **Secret Management** | Azure Key Vault (`kv-retail-dev-rg`) | Centralized secret store evaluated via Azure RBAC and Managed Identities to avoid plaintext passwords. |
| **CI / CD** | GitHub & GitHub Actions | Source control, automated linting, test suites, and parameterized pipeline deployment. |

---

## 📂 Repository Structure

```text
retail-lakehouse-migration/
├── .gitignore                         # Strict exclusion for secrets, logs, and environments
├── README.md                          # High-level architecture and implementation runbook
├── config/
│   └── settings.example.json          # Template of environment variables and identifiers
├── sql/
│   ├── watermark/                     # Watermark definition and update stored procedures
│   └── logging/                       # Execution and pipeline audit logging DDL
├── adf/                               # Azure Data Factory pipeline and dataset definitions
├── databricks/
│   └── notebooks/                     # PySpark transformation and reconciliation notebooks
├── tests/                             # Data quality test scripts and validation checks
├── docs/                              # Design decisions, trade-offs, and operational runbook
└── .github/
    └── workflows/                     # Continuous Integration and deployment automation
```

---

## 📊 Run Metrics & Reconciliation Results

> *Metrics will be populated from live validation runs during pipeline execution.*

| Metric Category | Source (SQL DB) | Target (Gold Lakehouse) | Match Status | Notes |
|---|---|---|---|---|
| Customer Record Count | `TO FILL FROM MY RUN` | `TO FILL FROM MY RUN` | `TO FILL` | Total dimension entities |
| Product Record Count | `TO FILL FROM MY RUN` | `TO FILL FROM MY RUN` | `TO FILL` | Categorised merchandise rows |
| Sales Order Total Revenue | `TO FILL FROM MY RUN` | `TO FILL FROM MY RUN` | `TO FILL` | Checksum on LineTotal aggregates |
| Overall Integrity Verdict | — | — | `PENDING EXECUTION` | Complete source-to-target alignment |
