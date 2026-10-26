-- ==============================================================================
-- Script:       03_create_clean_table.sql
-- Description:  Materializes typed clean table from conversion view with safety guard
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       WRITE / MATERIALIZATION (Guarded against accidental re-execution)
-- Prerequisites: `dbo.vw_Enterprise_Business_Analytics` exists
-- Expected Row Count Impact: 3,000,000 rows on fresh run; 0 rows if already materialized
-- Expected Duration: ~45–75 seconds on fresh run
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '03 CREATE CLEAN TABLE: Materializing dbo.world_business_data_3m_clean';
PRINT '==============================================================================';

IF OBJECT_ID('dbo.world_business_data_3m_clean', 'U') IS NOT NULL
BEGIN
    PRINT 'NOTICE: dbo.world_business_data_3m_clean already exists in this database.';
    PRINT 'To prevent data loss or duplicate execution, SELECT INTO will NOT be re-run.';
    
    -- Verify current clean row count
    SELECT COUNT_BIG(*) AS ExistingCleanRowCount 
    FROM dbo.world_business_data_3m_clean;
END
ELSE
BEGIN
    PRINT 'Materializing clean physical table from dbo.vw_Enterprise_Business_Analytics...';

    -- SELECT INTO creates a new table with typed columns derived from the view
    SELECT *
    INTO dbo.world_business_data_3m_clean
    FROM dbo.vw_Enterprise_Business_Analytics;

    PRINT 'Materialization complete. Validating row count...';

    DECLARE @RowCount BIGINT;
    SELECT @RowCount = COUNT_BIG(*) FROM dbo.world_business_data_3m_clean;
    
    IF @RowCount = 3000000
    BEGIN
        PRINT 'SUCCESS: Exactly 3,000,000 rows successfully materialized in dbo.world_business_data_3m_clean.';
    END
    ELSE
    BEGIN
        PRINT 'WARNING: Row count mismatch! Expected 3,000,000 rows, found: ' + CAST(@RowCount AS VARCHAR(20));
    END
END;
GO
