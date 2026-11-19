# Databricks PySpark Notebooks

This directory contains version-controlled source code for notebooks executed on Azure Databricks:

* `01_bronze_to_silver_cleaning.py`: Ingests raw bronze Parquet files, handles nulls, trims string fields, casts strict data types, and quarantines invalid rows into a rejects table.
* `02_silver_to_gold_modeling.py`: Implements dimensional star-schema modeling, including Slowly Changing Dimensions (SCD Type 2) tracking historical attribute evolution (e.g., customer address changes).
* `03_source_to_gold_reconciliation.py`: Programmatically runs checksums, counts, and null distributions comparing Azure SQL against Gold Delta tables, generating an automated audit report.
