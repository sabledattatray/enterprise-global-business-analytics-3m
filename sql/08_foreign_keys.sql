-- ==============================================================================
-- Script:       08_foreign_keys.sql
-- Description:  Enforces and validates trusted foreign key constraints on clean table
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       DDL / CONSTRAINT (Idempotent: verifies constraints exist and are trusted)
-- Prerequisites: `dbo.world_business_data_3m_clean`, `DimProduct`, `DimGeography`, `DimDate`
-- Expected Row Count Impact: 0 rows modified
-- Expected Duration: ~5–15 seconds
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '08 FOREIGN KEYS: Establishing and Verifying Trusted Referential Integrity';
PRINT '==============================================================================';

-- 1. Product Dimension Foreign Key
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BusinessData_DimProduct')
BEGIN
    PRINT 'Adding foreign key FK_BusinessData_DimProduct...';
    ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK
    ADD CONSTRAINT FK_BusinessData_DimProduct
    FOREIGN KEY (ProductKey) REFERENCES dbo.DimProduct(ProductKey);
END
ELSE
BEGIN
    PRINT 'Verifying FK_BusinessData_DimProduct is trusted...';
    ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK CHECK CONSTRAINT FK_BusinessData_DimProduct;
END;
GO

-- 2. Geography Dimension Foreign Key
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BusinessData_DimGeography')
BEGIN
    PRINT 'Adding foreign key FK_BusinessData_DimGeography...';
    ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK
    ADD CONSTRAINT FK_BusinessData_DimGeography
    FOREIGN KEY (GeographyKey) REFERENCES dbo.DimGeography(GeographyKey);
END
ELSE
BEGIN
    PRINT 'Verifying FK_BusinessData_DimGeography is trusted...';
    ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK CHECK CONSTRAINT FK_BusinessData_DimGeography;
END;
GO

-- 3. Date Dimension Foreign Key (references FullDate DATE, not DateKey INT)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BusinessData_DimDate')
BEGIN
    PRINT 'Adding foreign key FK_BusinessData_DimDate...';
    ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK
    ADD CONSTRAINT FK_BusinessData_DimDate
    FOREIGN KEY (order_date) REFERENCES dbo.DimDate(FullDate);
END
ELSE
BEGIN
    PRINT 'Verifying FK_BusinessData_DimDate is trusted...';
    ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK CHECK CONSTRAINT FK_BusinessData_DimDate;
END;
GO

-- 4. Audit Constraint Status in sys.foreign_keys
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS SourceTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS SourceColumn,
    OBJECT_NAME(fk.referenced_object_id) AS TargetTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS TargetColumn,
    fk.is_disabled AS IsDisabled,
    fk.is_not_trusted AS IsNotTrusted
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE fk.parent_object_id = OBJECT_ID('dbo.world_business_data_3m_clean')
ORDER BY fk.name;
GO
