-- ==============================================================================
-- File: 01_create_watermark_table.sql
-- Purpose: Creates the control table that tracks the high-watermark timestamp
--          for each source table being incrementally extracted.
-- Why it exists:
--   Instead of copying the full table every run (slow and expensive),
--   incremental extraction only queries rows modified after the last watermark.
--   This table persists that state between pipeline executions.
-- ==============================================================================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'control')
BEGIN
    -- Separate schema prevents mixing operational retail data with ETL metadata
    EXEC('CREATE SCHEMA [control]');
END
GO

IF OBJECT_ID('[control].[watermark_log]', 'U') IS NULL
BEGIN
    CREATE TABLE [control].[watermark_log] (
        [source_schema]        NVARCHAR(50)  NOT NULL,
        [source_table]         NVARCHAR(100) NOT NULL,
        [watermark_column]     NVARCHAR(50)  NOT NULL, -- Typically ModifiedDate
        [last_watermark_value] DATETIME2(7)  NOT NULL, -- Timestamp of highest record ingested
        [updated_at]           DATETIME2(7)  NOT NULL CONSTRAINT DF_watermark_updated DEFAULT SYSUTCDATETIME(),
        
        -- Primary key on schema + table ensures one state record per replicated entity
        CONSTRAINT PK_watermark_log PRIMARY KEY CLUSTERED ([source_schema], [source_table])
    );
END
GO
