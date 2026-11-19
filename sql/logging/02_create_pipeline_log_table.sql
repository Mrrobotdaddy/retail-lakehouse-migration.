-- ==============================================================================
-- File: 02_create_pipeline_log_table.sql
-- Purpose: Creates an execution audit log table for all ADF pipeline activities.
-- Why it exists:
--   Enterprise migrations require transparency. If an extraction fails or
--   record counts drift, this log provides an indisputable record of when
--   the pipeline ran, how many rows were transferred, and execution status.
-- ==============================================================================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'control')
BEGIN
    -- Ensure control schema exists before object creation
    EXEC('CREATE SCHEMA [control]');
END
GO

IF OBJECT_ID('[control].[pipeline_run_log]', 'U') IS NULL
BEGIN
    CREATE TABLE [control].[pipeline_run_log] (
        [log_id]               BIGINT IDENTITY(1,1) NOT NULL,
        [pipeline_run_id]      NVARCHAR(100)        NOT NULL, -- Correlation ID from ADF @pipeline().RunId
        [pipeline_name]        NVARCHAR(100)        NOT NULL,
        [source_table]         NVARCHAR(100)        NOT NULL,
        [start_time]           DATETIME2(7)         NOT NULL,
        [end_time]             DATETIME2(7)         NULL,
        [rows_read]            BIGINT               NULL,     -- Rows read from source SQL query
        [rows_written]         BIGINT               NULL,     -- Rows written to ADLS Gen2 bronze Parquet
        [status]               NVARCHAR(20)         NOT NULL, -- Running, Succeeded, Failed
        [error_message]        NVARCHAR(MAX)        NULL,     -- Captured exception if activity fails
        
        CONSTRAINT PK_pipeline_run_log PRIMARY KEY CLUSTERED ([log_id])
    );

    -- Index on pipeline_run_id accelerates troubleshooting lookups during failures
    CREATE NONCLUSTERED INDEX IX_pipeline_run_log_run_id
    ON [control].[pipeline_run_log] ([pipeline_run_id]);
END
GO
