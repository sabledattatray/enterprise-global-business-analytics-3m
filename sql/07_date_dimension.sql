-- ==============================================================================
-- Script:       07_date_dimension.sql
-- Description:  Builds dbo.DimDate (2,191 calendar days, 2021-01-01 to 2026-12-31)
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       WRITE / DDL (Idempotent: skips table creation if already existing)
-- Prerequisites: SQL Server 2022 instance running
-- Expected Row Count Impact: 2,191 rows in DimDate
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '07 DATE DIMENSION: Generating dbo.DimDate Calendar (2021-01-01 to 2026-12-31)';
PRINT '==============================================================================';

IF OBJECT_ID('dbo.DimDate', 'U') IS NULL
BEGIN
    PRINT 'Creating dbo.DimDate table...';

    CREATE TABLE dbo.DimDate (
        DateKey INT NOT NULL CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED,
        FullDate DATE NOT NULL CONSTRAINT UQ_DimDate_FullDate UNIQUE NONCLUSTERED,
        [Year] INT NOT NULL,
        QuarterNumber INT NOT NULL,
        QuarterName VARCHAR(2) NOT NULL,
        MonthNumber INT NOT NULL,
        MonthName VARCHAR(20) NOT NULL,
        YearMonth CHAR(7) NOT NULL,
        YearMonthSort INT NOT NULL,
        DayOfMonth INT NOT NULL,
        DayOfWeekNumber INT NOT NULL,
        DayOfWeekName VARCHAR(20) NOT NULL,
        IsWeekend BIT NOT NULL
    );

    PRINT 'Populating calendar dates via recursive CTE (2021-01-01 to 2026-12-31)...';

    ;WITH DateSeries AS (
        SELECT CAST('2021-01-01' AS DATE) AS CalendarDate
        UNION ALL
        SELECT DATEADD(DAY, 1, CalendarDate)
        FROM DateSeries
        WHERE CalendarDate < '2026-12-31'
    )
    INSERT INTO dbo.DimDate (
        DateKey, FullDate, [Year], QuarterNumber, QuarterName,
        MonthNumber, MonthName, YearMonth, YearMonthSort,
        DayOfMonth, DayOfWeekNumber, DayOfWeekName, IsWeekend
    )
    SELECT
        YEAR(CalendarDate) * 10000 + MONTH(CalendarDate) * 100 + DAY(CalendarDate) AS DateKey,
        CalendarDate AS FullDate,
        YEAR(CalendarDate) AS [Year],
        DATEPART(QUARTER, CalendarDate) AS QuarterNumber,
        CONCAT('Q', DATEPART(QUARTER, CalendarDate)) AS QuarterName,
        MONTH(CalendarDate) AS MonthNumber,
        DATENAME(MONTH, CalendarDate) AS MonthName,
        CONVERT(CHAR(7), CalendarDate, 120) AS YearMonth,
        YEAR(CalendarDate) * 100 + MONTH(CalendarDate) AS YearMonthSort,
        DAY(CalendarDate) AS DayOfMonth,
        ((DATEDIFF(DAY, '1900-01-01', CalendarDate) % 7) + 1) AS DayOfWeekNumber, -- Monday = 1
        DATENAME(WEEKDAY, CalendarDate) AS DayOfWeekName,
        CASE WHEN (DATEDIFF(DAY, '1900-01-01', CalendarDate) % 7) IN (5, 6) THEN 1 ELSE 0 END AS IsWeekend
    FROM DateSeries
    OPTION (MAXRECURSION 3000);

    PRINT 'dbo.DimDate generation complete.';
END
ELSE
BEGIN
    PRINT 'NOTICE: dbo.DimDate already exists.';
END;
GO

-- Validate Date Dimension Metrics
SELECT 
    COUNT(*) AS TotalDates,
    MIN(FullDate) AS MinCalendarDate,
    MAX(FullDate) AS MaxCalendarDate,
    SUM(CASE WHEN IsWeekend = 1 THEN 1 ELSE 0 END) AS WeekendDays,
    SUM(CASE WHEN IsWeekend = 0 THEN 1 ELSE 0 END) AS Weekdays
FROM dbo.DimDate;

-- Verify complete fact order_date coverage
SELECT 
    MIN(c.order_date) AS FactMinOrderDate,
    MAX(c.order_date) AS FactMaxOrderDate,
    COUNT(DISTINCT c.order_date) AS DistinctOrderDates,
    SUM(CASE WHEN d.FullDate IS NULL THEN 1 ELSE 0 END) AS UnmappedOrderDates
FROM dbo.world_business_data_3m_clean c
LEFT JOIN dbo.DimDate d ON c.order_date = d.FullDate;
GO
