-- ==============================================================================
-- Script:       02_create_typed_view.sql
-- Description:  Creates staging type-conversion view with safe TRY_CONVERT logic
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       IDEMPOTENT (CREATE OR ALTER VIEW — does not mutate underlying data)
-- Prerequisites: `dbo.world_business_data_3m` exists
-- Expected Row Count Impact: 0 rows modified (View object created/altered)
-- Expected Duration: < 1 second
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '02 CREATE TYPED VIEW: Creating dbo.vw_Enterprise_Business_Analytics';
PRINT '==============================================================================';

CREATE OR ALTER VIEW dbo.vw_Enterprise_Business_Analytics
AS
SELECT
    -- Identifiers
    TRY_CONVERT(BIGINT, record_id) AS record_id,
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    TRY_CONVERT(INT, age) AS age,
    gender,
    company_name,
    industry,
    department,
    job_title,

    -- Geography & Currency
    country,
    continent,
    city,
    region,
    postal_code,
    currency,

    -- Product Information
    product_id,
    product_category,
    product_name,
    brand,

    -- Transaction & Order Facts
    order_id,
    TRY_CONVERT(DATE, order_date, 23) AS order_date,
    TRY_CONVERT(INT, quantity) AS quantity,
    TRY_CONVERT(DECIMAL(18,2), unit_price) AS unit_price,
    TRY_CONVERT(DECIMAL(5,2), discount_pct) AS discount_pct,
    TRY_CONVERT(DECIMAL(18,2), tax_amount) AS tax_amount,
    TRY_CONVERT(DECIMAL(18,2), revenue) AS revenue,
    TRY_CONVERT(DECIMAL(18,2), cost) AS cost,
    TRY_CONVERT(DECIMAL(18,2), profit) AS profit,

    -- Fulfillment & Marketing Channels
    payment_method,
    payment_status,
    transaction_id,
    shipping_method,
    warehouse_id,
    TRY_CONVERT(DATE, delivery_date, 23) AS delivery_date,
    order_status,
    campaign,
    sales_channel,
    marketing_source,
    device,
    browser,
    operating_system,
    TRY_CONVERT(INT, website_visits) AS website_visits,
    TRY_CONVERT(INT, customer_satisfaction) AS customer_satisfaction,
    TRY_CONVERT(INT, support_tickets) AS support_tickets,
    loyalty_tier,

    -- Boolean normalization for repeat customer flag
    CASE
        WHEN LOWER(TRIM(is_repeat_customer)) IN ('true', '1')
            THEN CAST(1 AS BIT)
        WHEN LOWER(TRIM(is_repeat_customer)) IN ('false', '0')
            THEN CAST(0 AS BIT)
        ELSE CAST(NULL AS BIT)
    END AS is_repeat_customer
FROM dbo.world_business_data_3m;
GO

PRINT 'dbo.vw_Enterprise_Business_Analytics created / verified successfully.';
GO
