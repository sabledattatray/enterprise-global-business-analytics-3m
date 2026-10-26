-- ==============================================================================
-- Script:       04_delivery_dates.sql
-- Description:  Configures delivery date lifecycle and documents synthetic 81-day shift
-- Project:      Enterprise Global Business Analytics — 3M Synthetic Transactions
-- Author:       Datta Sable (https://dattasable.com)
-- Safety:       WRITE / SCHEMA EXTENSION (Includes strict idempotency guards)
-- Prerequisites: `dbo.world_business_data_3m_clean` exists
-- Expected Row Count Impact: Column addition and population on fresh run
-- ==============================================================================

USE [3 _M];
GO

PRINT '==============================================================================';
PRINT '04 DELIVERY DATES: Lifecycle Normalization & Synthetic Date Adjustment';
PRINT '==============================================================================';

-- 1. Ensure planned_delivery_date and actual_delivery_date exist
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.world_business_data_3m_clean') 
      AND name = 'planned_delivery_date'
)
BEGIN
    PRINT 'Adding planned_delivery_date and actual_delivery_date columns...';
    ALTER TABLE dbo.world_business_data_3m_clean
    ADD planned_delivery_date DATE NULL,
        actual_delivery_date DATE NULL;

    PRINT 'Populating delivery date lifecycle...';
    UPDATE dbo.world_business_data_3m_clean
    SET planned_delivery_date = delivery_date,
        actual_delivery_date = CASE 
            WHEN order_status = 'Delivered' THEN delivery_date
            ELSE NULL 
        END;
    PRINT 'Delivery lifecycle columns successfully initialized.';
END
ELSE
BEGIN
    PRINT 'NOTICE: planned_delivery_date and actual_delivery_date already exist.';
END;
GO

-- 2. Synthetic 81-day Demonstration Shift Guard
-- CRITICAL SAFETY RULE: The 81-day shift was a one-time adjustment applied to align 
-- the synthetic timeline with the project completion date (2026-10-25).
-- We guard against re-execution by checking the current MAX(order_date).

DECLARE @MaxOrderDate DATE;
SELECT @MaxOrderDate = MAX(order_date) FROM dbo.world_business_data_3m_clean;

IF @MaxOrderDate <= '2026-10-15'
BEGIN
    PRINT 'SAFETY GUARD TRIGGERED: MAX(order_date) is ' + CONVERT(VARCHAR(10), @MaxOrderDate, 120) + '.';
    PRINT 'The synthetic 81-day backward shift has ALREADY been applied to this clean table.';
    PRINT 'SKIPPING DATEADD UPDATE TO PREVENT CORRUPTING TRANSACTION DATES.';
END
ELSE
BEGIN
    PRINT 'Applying one-time synthetic 81-day backward date adjustment...';
    -- This block only executes if the clean table still has un-shifted future dates (e.g., max date in Dec 2026)
    UPDATE dbo.world_business_data_3m_clean
    SET order_date            = DATEADD(DAY, -81, order_date),
        delivery_date         = DATEADD(DAY, -81, delivery_date),
        planned_delivery_date = DATEADD(DAY, -81, planned_delivery_date),
        actual_delivery_date  = DATEADD(DAY, -81, actual_delivery_date);
    PRINT '81-day synthetic date adjustment completed.';
END;
GO

-- 3. Verification & Validation Query
SELECT 
    order_status,
    COUNT_BIG(*) AS StatusCount,
    SUM(CASE WHEN planned_delivery_date IS NULL THEN 1 ELSE 0 END) AS MissingPlannedDates,
    SUM(CASE WHEN actual_delivery_date IS NULL THEN 1 ELSE 0 END) AS NullActualDates,
    SUM(CASE WHEN actual_delivery_date IS NOT NULL AND actual_delivery_date < order_date THEN 1 ELSE 0 END) AS DeliveryBeforeOrder
FROM dbo.world_business_data_3m_clean
GROUP BY order_status
ORDER BY StatusCount DESC;
GO
