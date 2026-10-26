-- ==============================================================================
-- Script:       10_data_quality_checks.sql
-- Description:  Comprehensive automated validation matrix reconciling all PRD criteria
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       READ-ONLY (Safe to execute in any environment)
-- Prerequisites: All pipeline views, tables and dimensions created
-- Expected Row Count Impact: 0 rows modified
-- Expected Duration: ~15–30 seconds
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '10 DATA QUALITY CHECKS: Executing PRD Validation Matrix';
PRINT '==============================================================================';

-- 1. Row Count & Dimension Volume Reconciliations
SELECT 
    '1. Row Counts' AS CheckCategory,
    (SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m) AS RawSourceRows,
    (SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m_clean) AS CleanRows,
    (SELECT COUNT_BIG(*) FROM dbo.vw_FactSales) AS FactSalesRows,
    (SELECT COUNT(*) FROM dbo.DimProduct) AS DimProductRows,
    (SELECT COUNT(*) FROM dbo.DimGeography) AS DimGeographyRows,
    (SELECT COUNT(*) FROM dbo.DimDate) AS DimDateRows;

-- 2. Foreign Key Integrity on Fact Records
SELECT 
    '2. Dimension Key Integrity' AS CheckCategory,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS MissingProductKeys,
    SUM(CASE WHEN GeographyKey IS NULL THEN 1 ELSE 0 END) AS MissingGeographyKeys,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS MissingOrderDates
FROM dbo.world_business_data_3m_clean;

-- 3. Date Boundary & Calendar Alignment
SELECT 
    '3. Date Boundaries' AS CheckCategory,
    MIN(c.order_date) AS MinOrderDate,
    MAX(c.order_date) AS MaxOrderDate,
    COUNT(DISTINCT c.order_date) AS DistinctOrderDates,
    SUM(CASE WHEN d.FullDate IS NULL THEN 1 ELSE 0 END) AS UnmappedCalendarDates
FROM dbo.world_business_data_3m_clean c
LEFT JOIN dbo.DimDate d ON c.order_date = d.FullDate;

-- 4. Financial Calculation Integrity
-- Target: profit = revenue - cost within cent-level rounding tolerance
SELECT 
    '4. Financial Integrity' AS CheckCategory,
    COUNT_BIG(*) AS RowsChecked,
    SUM(CASE WHEN ABS(profit - (revenue - cost)) > 0.01 THEN 1 ELSE 0 END) AS ProfitFormulaMismatches,
    SUM(CASE WHEN revenue < 0 OR cost < 0 OR profit < 0 THEN 1 ELSE 0 END) AS NegativeFinancialRows,
    MIN(quantity) AS MinQuantity,
    MAX(quantity) AS MaxQuantity,
    MIN(discount_pct) AS MinDiscountPct,
    MAX(discount_pct) AS MaxDiscountPct
FROM dbo.world_business_data_3m_clean;

-- 5. Order Status & Fulfillment Lifecycle Validation
SELECT 
    order_status,
    COUNT_BIG(*) AS StatusCount,
    SUM(CASE WHEN planned_delivery_date IS NULL THEN 1 ELSE 0 END) AS MissingPlannedDates,
    SUM(CASE WHEN actual_delivery_date IS NULL THEN 1 ELSE 0 END) AS NullActualDates,
    SUM(CASE WHEN actual_delivery_date IS NOT NULL AND actual_delivery_date < order_date THEN 1 ELSE 0 END) AS InvalidEarlyDeliveries
FROM dbo.world_business_data_3m_clean
GROUP BY order_status
ORDER BY StatusCount DESC;

-- 6. Disclosed Known Synthetic Identity Defects
PRINT '--- Disclosed Known Defect: Customer ID Collision ---';
SELECT TOP (5)
    customer_id,
    COUNT(DISTINCT country) AS DistinctCountries,
    COUNT(DISTINCT first_name + ' ' + last_name) AS DistinctCustomerNames,
    COUNT(*) AS TotalOrders
FROM dbo.world_business_data_3m_clean
GROUP BY customer_id
HAVING COUNT(DISTINCT country) > 1 OR COUNT(DISTINCT first_name + ' ' + last_name) > 1
ORDER BY DistinctCustomerNames DESC;

PRINT '--- Disclosed Known Defect: Original Product ID Inconsistency ---';
SELECT TOP (5)
    product_id,
    COUNT(DISTINCT product_name) AS DistinctProductNamesMapped
FROM dbo.world_business_data_3m_clean
GROUP BY product_id
ORDER BY DistinctProductNamesMapped DESC;
GO
