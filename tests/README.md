# Automated Tests & Data Quality Checks

This directory houses automated test scripts for the migration pipeline:

* **Unit & Integrity Tests**: Verifies schema stability and transformation rules.
* **Reconciliation Assertions**: Validates that row counts, numeric aggregates, and primary key uniqueness hold across environments.
* **CI Execution**: Runs automated pre-deployment checks via GitHub Actions.
