-- ==============================================================================
-- Script:       01_source_profile.sql
-- Description:  Raw data profiling, schema inspection and entity defect audit
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       READ-ONLY (Safe to execute in any environment)
-- Prerequisites: `dbo.world_business_data_3m` loaded in `[3 _M]`
-- Expected Row Count Impact: 0 rows modified
-- Expected Duration: 10–25 seconds
-- Source Data Link: https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '01 SOURCE PROFILE: Profiling 3M Raw Synthetic Transactions';
PRINT '==============================================================================';

-- 1. Inspect All 49 Raw Columns and Data Types
-- Verified finding: All 49 columns were loaded as VARCHAR(50)
SELECT 
    ORDINAL_POSITION AS Position,
    COLUMN_NAME AS ColumnName,
    DATA_TYPE AS DataType,
    CHARACTER_MAXIMUM_LENGTH AS MaxLength,
    IS_NULLABLE AS IsNullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'world_business_data_3m'
ORDER BY ORDINAL_POSITION;

-- 2. Audit Identifier Uniqueness across 3,000,000 Rows
SELECT 
    COUNT_BIG(*) AS TotalRawRows,
    COUNT(DISTINCT record_id) AS DistinctRecordIDs,
    COUNT(DISTINCT order_id) AS DistinctOrderIDs,
    COUNT(DISTINCT transaction_id) AS DistinctTransactionIDs,
    COUNT(DISTINCT customer_id) AS DistinctCustomerIDs,
    COUNT(DISTINCT product_id) AS DistinctProductIDs
FROM dbo.world_business_data_3m;

-- 3. Document Known Synthetic Entity Collisions
-- Finding A: Customer ID Inconsistency (1 ID linked to multiple people/countries)
SELECT TOP (10)
    customer_id,
    COUNT(DISTINCT country) AS DistinctCountries,
    COUNT(DISTINCT first_name + ' ' + last_name) AS DistinctCustomerNames,
    COUNT(*) AS TotalOrders
FROM dbo.world_business_data_3m
GROUP BY customer_id
HAVING COUNT(DISTINCT country) > 1 OR COUNT(DISTINCT first_name + ' ' + last_name) > 1
ORDER BY DistinctCustomerNames DESC, DistinctCountries DESC;

-- Finding B: Original Product ID Inconsistency (1 ID maps to all 15 product names)
SELECT 
    product_id,
    COUNT(DISTINCT product_name) AS DistinctProductNames,
    COUNT(DISTINCT product_category) AS DistinctCategories,
    COUNT(DISTINCT brand) AS DistinctBrands,
    COUNT(*) AS TotalTransactions
FROM dbo.world_business_data_3m
GROUP BY product_id
ORDER BY DistinctProductNames DESC, product_id;

-- Finding C: Product Name/Category/Brand Stability (Surrogate Key Foundation)
-- Verified finding: (product_name, product_category, brand) is 100% 1-to-1 stable!
SELECT 
    product_name,
    product_category,
    brand,
    COUNT(*) AS TransactionCount
FROM dbo.world_business_data_3m
GROUP BY product_name, product_category, brand
ORDER BY product_category, product_name;

-- 4. Status Distributions in Raw Data
SELECT 
    order_status,
    COUNT(*) AS StatusCount,
    CAST(100.0 * COUNT(*) / 3000000.0 AS DECIMAL(5,2)) AS PercentOfTotal
FROM dbo.world_business_data_3m
GROUP BY order_status
ORDER BY StatusCount DESC;

SELECT 
    payment_status,
    COUNT(*) AS PaymentStatusCount,
    CAST(100.0 * COUNT(*) / 3000000.0 AS DECIMAL(5,2)) AS PercentOfTotal
FROM dbo.world_business_data_3m
GROUP BY payment_status
ORDER BY PaymentStatusCount DESC;
GO
