-- ==============================================================================
-- Script:       11_performance_checks.sql
-- Description:  IO and execution time benchmarks across 3M reporting view aggregations
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       READ-ONLY (Safe to execute in any environment)
-- Prerequisites: `dbo.vw_FactSales`, `DimProduct`, `DimGeography` exist
-- Expected Row Count Impact: 0 rows modified
-- Expected Duration: ~2–5 seconds
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '11 PERFORMANCE CHECKS: Reporting View IO & Execution Time Benchmarking';
PRINT '==============================================================================';

-- Benchmark 1: Full 3,000,000-Row Monthly Currency Aggregation
PRINT '--- Running Benchmark 1: Monthly Aggregation by Currency ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    YEAR(order_date) AS OrderYear,
    MONTH(order_date) AS OrderMonth,
    currency,
    COUNT_BIG(*) AS TotalOrders,
    SUM(quantity) AS TotalUnitsSold,
    SUM(revenue) AS LocalRevenue,
    SUM(cost) AS LocalCost,
    SUM(profit) AS LocalProfit
FROM dbo.vw_FactSales
GROUP BY YEAR(order_date), MONTH(order_date), currency
ORDER BY OrderYear, OrderMonth, currency;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- Benchmark 2: Star Schema 3-Way Join Slicing (Fact + DimProduct + DimGeography)
PRINT '--- Running Benchmark 2: Star Schema 3-Way Join Slicing ---';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP (20)
    p.product_category,
    p.product_name,
    g.country,
    g.currency,
    COUNT_BIG(*) AS TotalOrders,
    SUM(f.quantity) AS TotalUnitsSold,
    SUM(f.revenue) AS LocalRevenue,
    SUM(f.profit) AS LocalProfit,
    CAST(100.0 * SUM(f.profit) / NULLIF(SUM(f.revenue), 0) AS DECIMAL(10,2)) AS ProfitMarginPct
FROM dbo.vw_FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
JOIN dbo.DimGeography AS g ON f.GeographyKey = g.GeographyKey
GROUP BY p.product_category, p.product_name, g.country, g.currency
ORDER BY TotalOrders DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
