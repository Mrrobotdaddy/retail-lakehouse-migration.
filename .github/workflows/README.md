# GitHub Actions CI/CD Workflows

This directory will store GitHub Actions workflow definitions:

* `ci-pipeline.yml`: Validates SQL syntax, lints Python transformation code, and runs reconciliation test suites against mock data on every pull request.
* `cd-pipeline.yml`: Automatically publishes validated Data Factory ARM templates and Databricks notebooks across deployment environments upon merges to `main`.
