-- ==============================================================================
-- Script:       12_sample_reporting_queries.sql
-- Description:  Reporting queries reconciling Power BI dashboard measures and visual cards
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       READ-ONLY (Safe to execute in any environment)
-- Prerequisites: `dbo.vw_FactSales`, `DimProduct`, `DimGeography`, `DimDate`
-- Expected Row Count Impact: 0 rows modified
-- Expected Duration: ~1–4 seconds
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '12 SAMPLE REPORTING QUERIES: Power BI DAX & Card Reconciliations';
PRINT '==============================================================================';

-- Query 1: Global Operational Core KPIs (Unfiltered)
-- Reconciles Page 01 Executive Overview headline KPI cards
SELECT 
    COUNT(DISTINCT order_id) AS [Total Orders],
    SUM(quantity) AS [Total Units Sold],
    CAST(CAST(SUM(quantity) AS FLOAT) / COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS [Average Units Per Order]
FROM dbo.vw_FactSales;

-- Query 2: Operational Order Status Breakdown & Completion Rates
SELECT 
    order_status,
    COUNT(DISTINCT order_id) AS StatusOrders,
    CAST(100.0 * COUNT(DISTINCT order_id) / 3000000.0 AS DECIMAL(5,2)) AS OrderPercentage
FROM dbo.vw_FactSales
GROUP BY order_status
ORDER BY StatusOrders DESC;

-- Query 3: Top Product Categories by Orders and Units
SELECT 
    p.product_category,
    COUNT(DISTINCT f.order_id) AS TotalOrders,
    SUM(f.quantity) AS TotalUnitsSold,
    CAST(CAST(SUM(f.quantity) AS FLOAT) / COUNT(DISTINCT f.order_id) AS DECIMAL(10,2)) AS AvgUnitsPerOrder
FROM dbo.vw_FactSales f
JOIN dbo.DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY p.product_category
ORDER BY TotalOrders DESC;

-- Query 4: Single Currency Financial Summary (USD Filtered)
-- Demonstrates currency-gated reconciliation for United States transactions
SELECT 
    g.currency,
    g.country,
    COUNT(DISTINCT f.order_id) AS TotalOrders,
    SUM(f.quantity) AS TotalUnitsSold,
    SUM(f.revenue) AS Revenue_USD,
    SUM(f.cost) AS Cost_USD,
    SUM(f.profit) AS Profit_USD,
    CAST(100.0 * SUM(f.profit) / NULLIF(SUM(f.revenue), 0) AS DECIMAL(5,2)) AS ProfitMarginPct
FROM dbo.vw_FactSales f
JOIN dbo.DimGeography g ON f.GeographyKey = g.GeographyKey
WHERE g.currency = 'USD'
GROUP BY g.currency, g.country;

-- Query 5: Channel Mix and Payment Status Breakdown
SELECT 
    sales_channel,
    payment_status,
    COUNT(DISTINCT order_id) AS TotalOrders,
    SUM(quantity) AS TotalUnitsSold
FROM dbo.vw_FactSales
GROUP BY sales_channel, payment_status
ORDER BY sales_channel, TotalOrders DESC;
GO
