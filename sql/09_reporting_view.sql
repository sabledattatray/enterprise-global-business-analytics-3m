-- ==============================================================================
-- Script:       09_reporting_view.sql
-- Description:  Creates narrow 19-column reporting view dbo.vw_FactSales for Power BI
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       IDEMPOTENT (CREATE OR ALTER VIEW — does not mutate underlying data)
-- Prerequisites: `dbo.world_business_data_3m_clean` exists
-- Expected Row Count Impact: 0 rows modified (View object created/altered)
-- Expected Duration: < 1 second
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '09 REPORTING VIEW: Creating dbo.vw_FactSales for Power BI Direct Import';
PRINT '==============================================================================';

CREATE OR ALTER VIEW dbo.vw_FactSales
AS
SELECT
    -- Identifiers
    record_id,
    order_id,
    transaction_id,

    -- Dimension Foreign Keys
    ProductKey,
    GeographyKey,
    order_date,

    -- Financial & Operational Measures
    quantity,
    unit_price,
    discount_pct,
    revenue,
    cost,
    profit,
    tax_amount,

    -- Currency Code (42 distinct values — mandatory for currency gating)
    currency,

    -- Status & Channel Segments
    order_status,
    payment_status,
    sales_channel,

    -- Fulfillment Lifecycle
    planned_delivery_date,
    actual_delivery_date

FROM dbo.world_business_data_3m_clean;
GO

PRINT 'dbo.vw_FactSales created / verified successfully.';

-- Verify column contract and row count
SELECT 
    COUNT_BIG(*) AS FactSalesRowCount,
    COUNT(DISTINCT ProductKey) AS DistinctProducts,
    COUNT(DISTINCT GeographyKey) AS DistinctCountries,
    COUNT(DISTINCT currency) AS DistinctCurrencies,
    MIN(order_date) AS EarliestOrder,
    MAX(order_date) AS LatestOrder
FROM dbo.vw_FactSales;
GO
