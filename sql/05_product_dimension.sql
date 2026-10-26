-- ==============================================================================
-- Script:       05_product_dimension.sql
-- Description:  Builds dbo.DimProduct (15 rows) and populates ProductKey on clean table
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       WRITE / DDL (Idempotent: skips table creation if already existing)
-- Prerequisites: `dbo.world_business_data_3m_clean` exists
-- Expected Row Count Impact: 15 rows in DimProduct; ProductKey populated across 3M rows
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '05 PRODUCT DIMENSION: Creating DimProduct and Mapping Surrogate Key';
PRINT '==============================================================================';

-- 1. Create dbo.DimProduct if not already present
IF OBJECT_ID('dbo.DimProduct', 'U') IS NULL
BEGIN
    PRINT 'Creating dbo.DimProduct table...';
    
    SELECT
        IDENTITY(INT, 1, 1) AS ProductKey,
        product_name,
        product_category,
        brand
    INTO dbo.DimProduct
    FROM (
        SELECT DISTINCT product_name, product_category, brand
        FROM dbo.world_business_data_3m_clean
    ) AS DistinctProducts;

    ALTER TABLE dbo.DimProduct
    ADD CONSTRAINT PK_DimProduct PRIMARY KEY CLUSTERED (ProductKey);

    PRINT 'dbo.DimProduct successfully created with clustered primary key.';
END
ELSE
BEGIN
    PRINT 'NOTICE: dbo.DimProduct already exists.';
END;
GO

-- 2. Add and Populate ProductKey in dbo.world_business_data_3m_clean
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.world_business_data_3m_clean') 
      AND name = 'ProductKey'
)
BEGIN
    PRINT 'Adding ProductKey column to clean fact table...';
    ALTER TABLE dbo.world_business_data_3m_clean ADD ProductKey INT NULL;
    
    PRINT 'Populating ProductKey via stable join on (product_name, product_category, brand)...';
    UPDATE f
    SET f.ProductKey = p.ProductKey
    FROM dbo.world_business_data_3m_clean AS f
    JOIN dbo.DimProduct AS p
      ON f.product_name = p.product_name
     AND f.product_category = p.product_category
     AND f.brand = p.brand;

    PRINT 'ProductKey mapping complete.';
END
ELSE
BEGIN
    PRINT 'NOTICE: ProductKey column already exists in clean table.';
END;
GO

-- 3. Validate Dimension Row Count & Key Completeness
SELECT 
    (SELECT COUNT(*) FROM dbo.DimProduct) AS DimProductRows,
    (SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m_clean WHERE ProductKey IS NULL) AS UnmappedProductKeys,
    (SELECT COUNT(DISTINCT ProductKey) FROM dbo.world_business_data_3m_clean) AS DistinctProductKeysUsed;

-- Display complete 15-product dimension table
SELECT ProductKey, product_name, product_category, brand 
FROM dbo.DimProduct 
ORDER BY ProductKey;
GO
