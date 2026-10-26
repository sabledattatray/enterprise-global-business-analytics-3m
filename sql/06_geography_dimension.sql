-- ==============================================================================
-- Script:       06_geography_dimension.sql
-- Description:  Builds dbo.DimGeography (50 rows, 42 currencies) and maps GeographyKey
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       WRITE / DDL (Idempotent: skips table creation if already existing)
-- Prerequisites: `dbo.world_business_data_3m_clean` exists
-- Expected Row Count Impact: 50 rows in DimGeography; GeographyKey populated across 3M rows
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '06 GEOGRAPHY DIMENSION: Creating DimGeography and Mapping GeographyKey';
PRINT '==============================================================================';

-- 1. Create dbo.DimGeography if not already present
IF OBJECT_ID('dbo.DimGeography', 'U') IS NULL
BEGIN
    PRINT 'Creating dbo.DimGeography table...';
    
    SELECT
        IDENTITY(INT, 1, 1) AS GeographyKey,
        country,
        continent,
        currency
    INTO dbo.DimGeography
    FROM (
        SELECT DISTINCT country, continent, currency
        FROM dbo.world_business_data_3m_clean
    ) AS DistinctGeography;

    ALTER TABLE dbo.DimGeography
    ADD CONSTRAINT PK_DimGeography PRIMARY KEY CLUSTERED (GeographyKey);

    PRINT 'dbo.DimGeography successfully created with clustered primary key.';
END
ELSE
BEGIN
    PRINT 'NOTICE: dbo.DimGeography already exists.';
END;
GO

-- 2. Add and Populate GeographyKey in dbo.world_business_data_3m_clean
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.world_business_data_3m_clean') 
      AND name = 'GeographyKey'
)
BEGIN
    PRINT 'Adding GeographyKey column to clean fact table...';
    ALTER TABLE dbo.world_business_data_3m_clean ADD GeographyKey INT NULL;
    
    PRINT 'Populating GeographyKey via stable join on (country, continent, currency)...';
    UPDATE f
    SET f.GeographyKey = g.GeographyKey
    FROM dbo.world_business_data_3m_clean AS f
    JOIN dbo.DimGeography AS g
      ON f.country = g.country
     AND f.continent = g.continent
     AND f.currency = g.currency;

    PRINT 'GeographyKey mapping complete.';
END
ELSE
BEGIN
    PRINT 'NOTICE: GeographyKey column already exists in clean table.';
END;
GO

-- 3. Validate Dimension Row Count & Key Completeness
SELECT 
    (SELECT COUNT(*) FROM dbo.DimGeography) AS DimGeographyRows,
    (SELECT COUNT(DISTINCT currency) FROM dbo.DimGeography) AS DistinctCurrencies,
    (SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m_clean WHERE GeographyKey IS NULL) AS UnmappedGeographyKeys,
    (SELECT COUNT(DISTINCT GeographyKey) FROM dbo.world_business_data_3m_clean) AS DistinctGeographyKeysUsed;

-- Sample display of DimGeography
SELECT TOP (15) GeographyKey, country, continent, currency 
FROM dbo.DimGeography 
ORDER BY GeographyKey;
GO
