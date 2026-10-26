-- ==============================================================================
-- Script:       00_preflight_read_only.sql
-- Description:  Preflight environmental, database, file size and disk audit
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       READ-ONLY (Safe to execute in any environment)
-- Prerequisites: SQL Server 2022 instance running, SSMS 22 or sqlcmd
-- Expected Row Count Impact: 0 rows modified
-- Expected Duration: < 1 second
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '00 PREFLIGHT READ-ONLY AUDIT: Database, Engine & Storage Verification';
PRINT '==============================================================================';

-- 1. Verify Active Database and Server Instance
SELECT 
    @@SERVERNAME AS ServerInstance,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('Edition') AS EngineEdition,
    DB_NAME() AS CurrentDatabase,
    DATABASEPROPERTYEX(DB_NAME(), 'Collation') AS DatabaseCollation,
    DATABASEPROPERTYEX(DB_NAME(), 'Recovery') AS RecoveryModel;

-- 2. Check Database File Allocation, Used Space & Free Space
SELECT 
    df.name AS LogicalFileName,
    df.type_desc AS FileType,
    df.physical_name AS PhysicalPath,
    CAST(df.size * 8.0 / 1024 AS DECIMAL(18,2)) AS AllocatedMB,
    CASE 
        WHEN df.type_desc = 'ROWS' 
        THEN CAST(FILEPROPERTY(df.name, 'SpaceUsed') * 8.0 / 1024 AS DECIMAL(18,2))
        ELSE NULL 
    END AS UsedMB,
    CASE 
        WHEN df.type_desc = 'ROWS' 
        THEN CAST((df.size - FILEPROPERTY(df.name, 'SpaceUsed')) * 8.0 / 1024 AS DECIMAL(18,2))
        ELSE NULL 
    END AS FreeInsideFileMB,
    CASE 
        WHEN df.is_percent_growth = 1 THEN CONCAT(df.growth, '%')
        ELSE CONCAT(df.growth * 8 / 1024, ' MB')
    END AS AutoGrowthSetting,
    CASE 
        WHEN df.max_size = -1 THEN 'Unlimited'
        ELSE CONCAT(df.max_size * 8 / 1024, ' MB')
    END AS MaxSizeSetting
FROM sys.database_files df;

-- 3. Check Transaction Log Utilization
SELECT 
    total_log_size_in_bytes / 1048576.0 AS TotalLogMB,
    used_log_space_in_bytes / 1048576.0 AS UsedLogMB,
    used_log_space_in_percent AS LogUsedPercent
FROM sys.dm_db_log_space_usage;

-- 4. Check Underlying Disk Volume Free Space
SELECT DISTINCT
    vs.volume_mount_point AS MountPoint,
    vs.file_system_type AS FileSystem,
    CAST(vs.total_bytes / 1073741824.0 AS DECIMAL(18,2)) AS TotalDiskGB,
    CAST(vs.available_bytes / 1073741824.0 AS DECIMAL(18,2)) AS AvailableDiskGB,
    CAST(100.0 * vs.available_bytes / vs.total_bytes AS DECIMAL(5,2)) AS PercentFree
FROM sys.database_files df
CROSS APPLY sys.dm_os_volume_stats(DB_ID(), df.file_id) vs;

-- 5. Check Table Existence in dbo schema
SELECT 
    t.name AS TableName,
    t.create_date AS CreatedDate,
    t.modify_date AS ModifiedDate,
    SUM(p.rows) AS ApproxRowCount
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE t.schema_id = SCHEMA_ID('dbo') AND p.index_id IN (0,1)
GROUP BY t.name, t.create_date, t.modify_date
ORDER BY TableName;
GO
