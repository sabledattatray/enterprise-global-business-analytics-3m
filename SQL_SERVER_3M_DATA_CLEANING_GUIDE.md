# From 3 Million Raw Rows to a Power BI–Ready SQL Server Model

**A practical, audit-first data engineering walkthrough using SQL Server 2022 Developer Edition and SSMS 22**

> **Project type:** Synthetic international business transactions · **Rows:** 3,000,000 · **Original columns:** 49 · **Countries:** 50 · **Currencies:** 42 · **Products:** 15
>
> **Important:** This is a documented case study of the completed project, **not** a one-click migration script. The source conversion view's exact original SQL is not available in this guide. Reproduce its conversions from the source schema and verify them before running any materialization or update. Scripts that modify data are clearly labeled.

## 1. What we built

We started with `dbo.world_business_data_3m`, a synthetic dataset containing **3,000,000** business transaction rows. All **49 source columns were `VARCHAR(50)`**, including dates, numeric values, and identifiers. We retained this raw source for traceability and built a typed clean table and small dimensions around it.

```text
RAW SOURCE (preserved)
  dbo.world_business_data_3m                3,000,000 rows / 49 VARCHAR columns
              |
              v
TYPE-CONVERSION VIEW
  dbo.vw_Enterprise_Business_Analytics      explicit SQL type conversions
              |
              v
CLEAN PHYSICAL TABLE
  dbo.world_business_data_3m_clean          3,000,000 typed rows
        |               |               |
        v               v               v
  dbo.DimProduct   dbo.DimGeography    dbo.DimDate
  15 products      50 countries       2,191 calendar dates
        \               |               /
         \              |              /
          v             v             v
              dbo.vw_FactSales              narrow reporting VIEW
                       |
                       v
                Power BI model              future reporting layer
```

**Why a reporting view rather than another 3-million-row fact table?** The clean table already occupies approximately **1,467.39 MB**. A narrow view exposes reporting fields without duplicating the transaction rows. Views are not automatically faster; performance must be measured.

## 2. Tools and prerequisites

- SQL Server **2022 Developer Edition** (version `16.0.1000.6` in this project).
- SQL Server Management Studio **22**.
- A database containing `dbo.world_business_data_3m`; in our environment it was named `[3 _M]` (note the space).
- Sufficient database permissions for `CREATE VIEW`, `CREATE TABLE`, `ALTER TABLE`, `UPDATE`, and foreign keys.
- A **tested backup**, adequate disk space, and a maintenance window for large updates.

Open SSMS, connect to the correct instance, and explicitly select the target database:

```sql
USE [3 _M];
GO
SELECT DB_NAME() AS CurrentDatabase;
SELECT COUNT_BIG(*) AS RawRows FROM dbo.world_business_data_3m;
```

**Expected project result:** `3 _M` and `3,000,000`. **Do not run write statements against a production database without reviewing them and taking a backup.**

## 3. Phase A — Profile the raw data before cleaning

### A1. Inspect data types and row counts (read-only)

```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'world_business_data_3m'
ORDER BY ORDINAL_POSITION;

SELECT COUNT_BIG(*) AS RawRowCount
FROM dbo.world_business_data_3m;
```

**Finding:** All 49 source fields were `VARCHAR(50)`. This matters because text values do not behave like genuine dates or numbers in sorting, aggregations, or Power BI relationships.

### A2. Audit identifiers (read-only)

```sql
SELECT
  COUNT_BIG(*) AS TotalRows,
  COUNT(DISTINCT record_id) AS DistinctRecordIDs,
  COUNT(DISTINCT order_id) AS DistinctOrderIDs,
  COUNT(DISTINCT transaction_id) AS DistinctTransactionIDs,
  COUNT(DISTINCT customer_id) AS DistinctSourceCustomerIDs,
  COUNT(DISTINCT product_id) AS DistinctSourceProductIDs
FROM dbo.world_business_data_3m;
```

**Verified findings:** 3,000,000 distinct record IDs, order IDs, and transaction IDs; **950,127** distinct source customer IDs; **15** source product IDs. Uniqueness alone is **not** evidence of correct business entity mapping.

### A3. Investigate source entity consistency

The synthetic generator produced inconsistent identifiers:

- The same source `product_id` could refer to **all 15 product names**.
- **801,192** source customer IDs were associated with multiple names.
- **796,571** source customer IDs were associated with multiple countries.
- There were **2,999,925** distinct emails and **75** repeated-email groups; repeated emails were consistent with one name/customer ID, but emails were not suitable as a broadly useful customer dimension because nearly every row had a different email.

**Decision:** Preserve original IDs for traceability, but **do not build `DimProduct` from the unreliable source `product_id`** or claim customer retention/unique-customer metrics based on the unreliable `customer_id`. The customer identity problem remains unresolved.

## 4. Phase B — Convert text into typed data

A SQL conversion view named `dbo.vw_Enterprise_Business_Analytics` was created to cast the original text fields into useful SQL types. The **exact source view definition is not reproduced here**; readers should create their own using the actual source column names and date formats. The following is an **illustrative conversion pattern, not the complete original view**:

```sql
-- EXAMPLE ONLY: adapt column names, formats, and validation rules.
SELECT
    TRY_CONVERT(BIGINT, NULLIF(LTRIM(RTRIM(record_id)), '')) AS record_id,
    NULLIF(LTRIM(RTRIM(order_id)), '') AS order_id,
    TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(order_date)), ''), 23) AS order_date,
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(quantity)), '')) AS quantity,
    TRY_CONVERT(DECIMAL(18,2), NULLIF(LTRIM(RTRIM(revenue)), '')) AS revenue,
    TRY_CONVERT(DECIMAL(18,2), NULLIF(LTRIM(RTRIM(cost)), '')) AS cost,
    TRY_CONVERT(DECIMAL(18,2), NULLIF(LTRIM(RTRIM(profit)), '')) AS profit
FROM dbo.world_business_data_3m;
```

`TRY_CONVERT` returns `NULL` for unconvertible values, which makes profiling safer but **does not fix invalid data**. Always inspect conversion failures and distinguish missing source values from invalid values. Do not automatically replace every invalid numeric value with zero: that can silently change business meaning.

The project's typed clean table ultimately included:

| Column | Verified SQL type |
|---|---|
| `record_id` | `BIGINT` |
| `order_date`, `delivery_date`, `planned_delivery_date`, `actual_delivery_date` | `DATE` |
| `quantity` | `INT` |
| `unit_price`, `tax_amount`, `revenue`, `cost`, `profit` | `DECIMAL(18,2)` |
| `discount_pct` | `DECIMAL(5,2)` |
| `is_repeat_customer` | `BIT` |
| `ProductKey`, `GeographyKey` | `INT` |
| `customer_id`, `order_id`, `transaction_id`, `currency`, statuses, `sales_channel` | `VARCHAR(50)` |

The inspected columns remained **nullable** in the physical table. Data quality was checked separately; constraints can be tightened after full validation.

### B1. Materialize the conversion view (write operation)

The clean table was created using this pattern:

```sql
-- Run ONLY after the conversion view is complete and validated.
-- SELECT INTO creates a NEW table; do not rerun if it already exists.
SELECT *
INTO dbo.world_business_data_3m_clean
FROM dbo.vw_Enterprise_Business_Analytics;
```

`SELECT INTO` copies query results into a new physical table, but does not automatically recreate the source's indexes, primary keys, or foreign keys. Confirm that the table has the expected row count and types before proceeding:

```sql
SELECT COUNT_BIG(*) AS CleanRows
FROM dbo.world_business_data_3m_clean;

SELECT COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='world_business_data_3m_clean'
ORDER BY ORDINAL_POSITION;
```

**Verified:** 3,000,000 clean rows. The raw source was preserved unchanged.

## 5. Phase C — Validate financial values

The dataset passed the following checks:

| Validation | Verified outcome |
|---|---|
| Missing financial values | None in the tested core financial columns |
| `profit = revenue - cost` | All 3,000,000 rows within 0.01 tolerance |
| Negative revenue, cost, or profit | None |
| Quantity range | 1–10 |
| Unit price range | 5–2,500 |
| Discount range | 0–25% |
| Revenue formula | `quantity × unit_price × (1 − discount_pct / 100)` within 0.05 tolerance |
| Tax treatment | Tax was **not included** in the recorded revenue |
| Effective tax bands | Approximately 0%, 5%, 10%, 15%, 18%, and 20%, subject to rounding |

Useful **read-only** validation query:

```sql
SELECT
    COUNT_BIG(*) AS RowsChecked,
    SUM(CASE WHEN revenue IS NULL OR cost IS NULL OR profit IS NULL
             THEN 1 ELSE 0 END) AS MissingFinancials,
    SUM(CASE WHEN ABS(profit - (revenue - cost)) > 0.01
             THEN 1 ELSE 0 END) AS ProfitMismatches,
    SUM(CASE WHEN revenue < 0 OR cost < 0 OR profit < 0
             THEN 1 ELSE 0 END) AS NegativeFinancialRows,
    SUM(CASE WHEN ABS(
        revenue - (quantity * unit_price * (1 - discount_pct / 100.0))
    ) > 0.05 THEN 1 ELSE 0 END) AS RevenueFormulaMismatches
FROM dbo.world_business_data_3m_clean;
```

**CRITICAL MULTI-CURRENCY WARNING:** This dataset has **42 currencies**. The unconverted cross-currency sums — `18,720,460,798.92` revenue, `12,167,245,997.51` cost, and `6,553,214,801.41` profit — are **mathematical sums of unlike monetary units, not meaningful consolidated currency KPIs**. Never label them USD, INR, or “global revenue.” Aggregate monetary measures within the same currency, or build a documented, date-appropriate FX conversion model first.

## 6. Phase D — Correct the synthetic date timeline

Originally, source order dates ran from **2022-01-01 to 2026-12-31**, and delivery dates extended into **2027-01-14**. Because the project was being prepared on **2026-10-25**, future-dated synthetic transactions would distort “as of today” dashboards.

The project applied an explicitly approved **81-day backward shift to the CLEAN TABLE ONLY**, not the raw source. The resulting order-date range was **2021-10-12 through 2026-10-11**, and the delivery-date range was **2021-10-13 through 2026-10-25**.

### D1. Separate planned and actual delivery dates

The original `delivery_date` was preserved in the clean table. Two columns were added:

- `planned_delivery_date`: copied from the existing delivery date for all records.
- `actual_delivery_date`: populated only for `order_status = 'Delivered'`; `NULL` otherwise.

**Illustrative implementation for a fresh clean table (write operation):**

```sql
-- Do not rerun on a table that already contains these columns.
ALTER TABLE dbo.world_business_data_3m_clean
ADD planned_delivery_date DATE NULL,
    actual_delivery_date DATE NULL;
GO

UPDATE dbo.world_business_data_3m_clean
SET planned_delivery_date = delivery_date,
    actual_delivery_date = CASE
        WHEN order_status = 'Delivered' THEN delivery_date
        ELSE NULL
    END;
```

### D2. Shift all relevant clean-table dates consistently

**Historical project operation — DO NOT RUN AGAIN on the finished project.** Reapplying it would shift dates another 81 days.

```sql
-- DOCUMENTATION ONLY. Requires explicit approval and a tested backup.
-- Applies the historical project's fixed synthetic-data adjustment.
UPDATE dbo.world_business_data_3m_clean
SET order_date           = DATEADD(DAY, -81, order_date),
    delivery_date        = DATEADD(DAY, -81, delivery_date),
    planned_delivery_date = DATEADD(DAY, -81, planned_delivery_date),
    actual_delivery_date  = DATEADD(DAY, -81, actual_delivery_date);
```

The shift is a **demonstration-data adjustment**, not a recommended method for real transaction history. In a real system, preserve actual event dates and handle future-dated records explicitly.

### D3. Validate the results (read-only)

```sql
SELECT
    MIN(order_date) AS FirstOrder,
    MAX(order_date) AS LastOrder,
    MIN(delivery_date) AS FirstDelivery,
    MAX(delivery_date) AS LastDelivery,
    SUM(CASE WHEN order_date > CONVERT(date, GETDATE())
             THEN 1 ELSE 0 END) AS FutureOrders,
    SUM(CASE WHEN actual_delivery_date IS NOT NULL
                   AND actual_delivery_date < order_date
             THEN 1 ELSE 0 END) AS ActualDeliveryBeforeOrder,
    SUM(CASE WHEN order_status = 'Delivered'
                   AND actual_delivery_date IS NULL
             THEN 1 ELSE 0 END) AS DeliveredWithoutActualDate
FROM dbo.world_business_data_3m_clean;
```

**Verified:** No future dates as of 2026-10-25, no deliveries before orders, and no delivered records missing an actual delivery date. Status counts: **Delivered 1,950,380; Shipped 449,974; Processing 449,322; Cancelled 150,324**. Observed delivery lag was **1–14 days**.

## 7. Phase E — Repair the product dimension

Because source `product_id` was unreliable, we defined product identity from the stable combination of **product name, category, and brand**. Each of the 15 names consistently mapped to one category and brand.

### E1. Create `DimProduct` (write operation; fresh environment only)

```sql
-- Do not execute if dbo.DimProduct already exists.
SELECT
    IDENTITY(INT, 1, 1) AS ProductKey,
    product_name,
    product_category,
    brand
INTO dbo.DimProduct
FROM (
    SELECT DISTINCT product_name, product_category, brand
    FROM dbo.world_business_data_3m_clean
) AS Products;
GO

ALTER TABLE dbo.DimProduct
ADD CONSTRAINT PK_DimProduct PRIMARY KEY CLUSTERED (ProductKey);
GO
```

**Verified:** 15 dimension rows. Sample product names: Monitor, Laptop, Smartphone, Headphones, T-Shirt, Jacket, Desk, Office Chair, Backpack, Printer, Fitness Tracker, Snack Box, Coffee Pack, Skin Care Kit, and Business Book.

### E2. Add the product surrogate key to clean transactions

```sql
-- Fresh environment only; existing project already has this column.
ALTER TABLE dbo.world_business_data_3m_clean ADD ProductKey INT NULL;
GO

UPDATE f
SET f.ProductKey = p.ProductKey
FROM dbo.world_business_data_3m_clean AS f
JOIN dbo.DimProduct AS p
  ON f.product_name = p.product_name
 AND f.product_category = p.product_category
 AND f.brand = p.brand;
GO
```

**Verified:** 3,000,000 rows mapped; **0 NULL product keys**, **15 keys used**, **0 orphan mappings**.

### E3. Enforce referential integrity

```sql
ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK
ADD CONSTRAINT FK_BusinessData_DimProduct
FOREIGN KEY (ProductKey) REFERENCES dbo.DimProduct(ProductKey);
GO
```

> A nullable foreign key permits `NULL`. Validate mapping completeness separately before optionally enforcing `NOT NULL`.

## 8. Phase F — Create the geography dimension

The source contained **50 countries**, each associated with exactly **one continent and one currency**; **42 distinct currencies** overall. Nine countries shared EUR. Country-level geography was selected to avoid introducing unsupported city/region uniqueness assumptions.

### F1. Create `DimGeography` (write operation; fresh environment only)

```sql
SELECT
    IDENTITY(INT, 1, 1) AS GeographyKey,
    country,
    continent,
    currency
INTO dbo.DimGeography
FROM (
    SELECT DISTINCT country, continent, currency
    FROM dbo.world_business_data_3m_clean
) AS Geography;
GO

ALTER TABLE dbo.DimGeography
ADD CONSTRAINT PK_DimGeography PRIMARY KEY CLUSTERED (GeographyKey);
GO
```

### F2. Populate fact-side geography keys

```sql
ALTER TABLE dbo.world_business_data_3m_clean ADD GeographyKey INT NULL;
GO

UPDATE f
SET f.GeographyKey = g.GeographyKey
FROM dbo.world_business_data_3m_clean AS f
JOIN dbo.DimGeography AS g
  ON f.country = g.country
 AND f.continent = g.continent
 AND f.currency = g.currency;
GO

ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK
ADD CONSTRAINT FK_BusinessData_DimGeography
FOREIGN KEY (GeographyKey) REFERENCES dbo.DimGeography(GeographyKey);
GO
```

**Verified:** 50 geography rows; 3,000,000 transactions mapped; **0 missing geography keys**. Country/currency consistency checks passed.

## 9. Phase G — Build a date dimension

`dbo.DimDate` covers **2021-01-01 to 2026-12-31** (inclusive): **2,191 calendar days**, including **626 weekend days**. It has `DateKey` as `YYYYMMDD` integer and `FullDate` as a unique `DATE` field. The date table also includes year, quarter, month, day, weekend, and sorting fields.

The original date-dimension creation SQL is not preserved here; the following is a **reproducible equivalent**, not a claim that it is the exact script originally run.

```sql
-- Fresh environment only. Verify the table does not already exist.
CREATE TABLE dbo.DimDate (
    DateKey INT NOT NULL PRIMARY KEY CLUSTERED,
    FullDate DATE NOT NULL UNIQUE,
    [Year] INT NOT NULL,
    QuarterNumber INT NOT NULL,
    QuarterName VARCHAR(2) NOT NULL,
    MonthNumber INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    YearMonth CHAR(7) NOT NULL,
    YearMonthSort INT NOT NULL,
    DayOfMonth INT NOT NULL,
    DayOfWeekNumber INT NOT NULL,
    DayOfWeekName VARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL
);
GO

;WITH Dates AS (
    SELECT CAST('20210101' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM Dates
    WHERE d < '20261231'
)
INSERT INTO dbo.DimDate (
    DateKey, FullDate, [Year], QuarterNumber, QuarterName,
    MonthNumber, MonthName, YearMonth, YearMonthSort,
    DayOfMonth, DayOfWeekNumber, DayOfWeekName, IsWeekend
)
SELECT
    YEAR(d)*10000 + MONTH(d)*100 + DAY(d),
    d,
    YEAR(d),
    DATEPART(QUARTER, d),
    CONCAT('Q', DATEPART(QUARTER, d)),
    MONTH(d),
    DATENAME(MONTH, d),
    CONVERT(CHAR(7), d, 120),
    YEAR(d)*100 + MONTH(d),
    DAY(d),
    (DATEDIFF(DAY, '19000101', d) % 7) + 1, -- Monday = 1
    DATENAME(WEEKDAY, d),
    CASE WHEN DATEDIFF(DAY, '19000101', d) % 7 IN (5,6)
         THEN 1 ELSE 0 END
FROM Dates
OPTION (MAXRECURSION 0);
GO

-- This FK uses the unique FullDate DATE, not the integer DateKey.
ALTER TABLE dbo.world_business_data_3m_clean WITH CHECK
ADD CONSTRAINT FK_BusinessData_DimDate
FOREIGN KEY (order_date) REFERENCES dbo.DimDate(FullDate);
GO
```

**Verified:** 2,191 dates, 626 weekends, **1,826 distinct transaction order dates**, **0 unmatched transaction order dates**, and a trusted, enabled date foreign key. Date labels produced by `DATENAME` depend on SQL Server session language; configure Power BI formatting explicitly when needed.

## 10. Phase H — Validate the three dimension relationships

```sql
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS SourceTable,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    fk.is_disabled AS IsDisabled,
    fk.is_not_trusted AS IsNotTrusted
FROM sys.foreign_keys AS fk
WHERE fk.parent_object_id = OBJECT_ID('dbo.world_business_data_3m_clean')
ORDER BY fk.name;
```

**Verified:** All three relationships were **enabled** and **trusted**:

- `FK_BusinessData_DimDate`
- `FK_BusinessData_DimGeography`
- `FK_BusinessData_DimProduct`

The clean table remained a **heap** at the time of indexing audit. `DimDate`, `DimProduct`, and `DimGeography` had clustered primary keys; `DimDate.FullDate` also had a unique nonclustered index.

## 11. Phase I — Publish a narrow reporting view

Rather than immediately duplicating the large clean table, we created `dbo.vw_FactSales`:

```sql
CREATE OR ALTER VIEW dbo.vw_FactSales
AS
SELECT
    record_id,
    order_id,
    transaction_id,
    ProductKey,
    GeographyKey,
    order_date,
    quantity,
    unit_price,
    discount_pct,
    revenue,
    cost,
    profit,
    tax_amount,
    currency,
    order_status,
    payment_status,
    sales_channel,
    planned_delivery_date,
    actual_delivery_date
FROM dbo.world_business_data_3m_clean;
GO
```

### I1. Verify the view (read-only)

```sql
SELECT
    COUNT_BIG(*) AS Total_Transactions,
    COUNT(DISTINCT ProductKey) AS Products,
    COUNT(DISTINCT GeographyKey) AS Countries,
    COUNT(DISTINCT currency) AS Currencies,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS Missing_ProductKeys,
    SUM(CASE WHEN GeographyKey IS NULL THEN 1 ELSE 0 END) AS Missing_GeographyKeys,
    MIN(order_date) AS First_Order_Date,
    MAX(order_date) AS Last_Order_Date
FROM dbo.vw_FactSales;
```

**Verified results:** 3,000,000 transactions; 15 products; 50 countries; 42 currencies; 0 missing product keys; 0 missing geography keys; dates 2021-10-12 through 2026-10-11.

## 12. Phase J — Check SQL Server storage before indexing

The project used SQL Server 2022 Developer Edition, with database files located on the C: drive. An early audit found that the data file had only **8.06 MB unused space within its existing allocation**, but a later volume check found **80.93 GB of actual free disk space**. These are different measurements.

| Measurement | Observed value |
|---|---:|
| MDF allocated | 4,424 MB |
| MDF used | 4,415.94 MB |
| MDF free *inside allocated file* | 8.06 MB |
| LDF allocated | 2,184 MB |
| LDF used | 901.27 MB (41.27%) |
| Disk free | 80.93 GB |
| Disk total | 464.95 GB |
| Data and log autogrowth | 64 MB increments |
| MDF maximum | Unlimited (subject to edition and disk limits) |

**Read-only file-space query:**

```sql
SELECT name, type_desc,
       CAST(size*8.0/1024 AS DECIMAL(18,2)) AS AllocatedMB,
       CASE WHEN type_desc='ROWS'
            THEN CAST(FILEPROPERTY(name,'SpaceUsed')*8.0/1024 AS DECIMAL(18,2))
       END AS UsedDataMB
FROM sys.database_files;

SELECT total_log_size_in_bytes/1048576.0 AS TotalLogMB,
       used_log_space_in_bytes/1048576.0 AS UsedLogMB,
       used_log_space_in_percent AS LogUsedPercent
FROM sys.dm_db_log_space_usage;
```

Autogrowth being enabled does not eliminate the need for capacity planning or backups. Large writes may expand the log significantly.

## 13. Phase K — Benchmark the reporting view

### K1. Monthly aggregation by currency

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    YEAR(order_date) AS Sales_Year,
    MONTH(order_date) AS Sales_Month,
    currency,
    COUNT_BIG(*) AS Total_Orders,
    SUM(quantity) AS Units_Sold,
    SUM(revenue) AS Revenue,
    SUM(cost) AS Cost,
    SUM(profit) AS Profit
FROM dbo.vw_FactSales
GROUP BY YEAR(order_date), MONTH(order_date), currency
ORDER BY Sales_Year, Sales_Month, currency;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

**Observed warm-cache benchmark:**

| Metric | Value |
|---|---:|
| Scan count | 9 |
| Logical reads | 219,048 |
| Physical reads | 0 |
| CPU time | 1,077 ms |
| Elapsed time | **315 ms** |

This is a strong result for **this specific aggregation**, but does not establish general dashboard performance. CPU time can exceed elapsed time under parallel execution. Zero physical reads does not predict cold-cache performance.

### K2. Product-country join test

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP (20)
    p.product_category, p.product_name,
    g.country, g.currency,
    COUNT_BIG(*) AS Total_Orders,
    SUM(f.quantity) AS Units_Sold,
    SUM(f.revenue) AS Revenue,
    SUM(f.cost) AS Cost,
    SUM(f.profit) AS Profit,
    CAST(100.0*SUM(f.profit)/NULLIF(SUM(f.revenue),0)
         AS DECIMAL(10,2)) AS Profit_Margin_Pct
FROM dbo.vw_FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
JOIN dbo.DimGeography AS g ON f.GeographyKey = g.GeographyKey
GROUP BY p.product_category, p.product_name, g.country, g.currency
ORDER BY Total_Orders DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

**Verified query output:** The top-ranked combination by transaction count was **Monitor / Switzerland / CHF**, with **4,177 transactions**, **22,646 units**, **CHF 25,957,450.91 revenue**, **CHF 9,026,540.42 profit**, and **34.77% profit margin**. The user supplied result rows but **not the corresponding IO/time statistics**, so no performance claim is made for this join query.

**Indexing decision:** A columnstore index was **not yet created**. First benchmark representative Power BI workloads, including date filters, geography filters, product slicing, concurrent use, and cold/warm cache. Avoid blindly indexing the wide clean table.

## 14. Power BI modeling guidance

Recommended first-pass model:

- **Fact:** `dbo.vw_FactSales`.
- **Dimensions:** `dbo.DimProduct`, `dbo.DimGeography`, `dbo.DimDate`.
- **Relationships:** `vw_FactSales.ProductKey → DimProduct.ProductKey`; `vw_FactSales.GeographyKey → DimGeography.GeographyKey`; `vw_FactSales.order_date → DimDate.FullDate`.
- **Direction:** Prefer single-direction dimension-to-fact filtering unless a validated need requires otherwise.
- **Date table:** Mark `DimDate` as the date table using `FullDate`; sort month names by month numbers and year-month labels by `YearMonthSort`.
- **Currency:** Display currency-specific revenue/cost/profit or introduce a separately validated FX rate table. Do not sum all 42 original currencies as a single monetary KPI.
- **Customer analytics:** Do not claim accurate unique customers, customer retention, or repeat behavior from inconsistent source `customer_id` values. `is_repeat_customer` is a source flag, not proof of a consistent customer identity model.
- **Synthetic context:** Label dashboards and portfolio screenshots as synthetic demonstration data. Do not infer real-world country demand from the generated distributions.
- **Delivery analytics:** Use `planned_delivery_date` for expected delivery and `actual_delivery_date` only for delivered transactions; validate any promised SLA definitions before calling a delivery late.

The intended long-term dashboard has nine pages: Executive Overview, Sales Performance, Product Analysis, Customer Insights, Region Analysis, Order Details, Profitability Analysis, Return Analysis, and Forecast Analysis. **Not all pages are validated as ready:** customer identity needs remediation; returns need an explicit returns definition/source; forecasting needs a clearly labeled methodology. Do not invent return or retention metrics.

## 15. Reproducibility checklist

- [ ] Confirm database and source row count before changing data.
- [ ] Preserve the raw source; create transformations separately.
- [ ] Inspect all source types and test failed conversions.
- [ ] Materialize only after conversion checks pass.
- [ ] Verify financial equations and currency units.
- [ ] Document any synthetic date adjustment; never apply it twice.
- [ ] Validate product identity before generating surrogate keys.
- [ ] Validate country-to-continent and country-to-currency mapping.
- [ ] Check every fact row has valid dimension keys.
- [ ] Check foreign keys are enabled **and trusted**.
- [ ] Verify date-table range and correct relationships.
- [ ] Keep unconverted currencies separate in measures.
- [ ] Check database and disk space before large writes/indexes.
- [ ] Record logical reads, CPU time, elapsed time, and cache context.
- [ ] Clearly label synthetic data and unresolved source-quality issues.

## 16. Limitations and next steps

1. **Customer IDs are not trustworthy:** a reliable customer dimension and retention analysis cannot yet be claimed.
2. **Currency normalization is incomplete:** 42 original currencies remain; a documented FX model is needed for global financial KPIs.
3. **No columnstore index was implemented at the documented stopping point:** one measured aggregation was already fast; more workload tests are needed.
4. **The exact original conversion-view DDL is not available:** the example above is intentionally labeled illustrative. For a fully executable public repository, export the actual view definition from SSMS (`Script View as → CREATE To`) and review it before publishing.
5. **No validated returns model or forecasting model is documented:** those should be implemented and tested separately.
6. **All data are synthetic:** results are for SQL Server, modeling, and Power BI practice—not business intelligence claims about real companies or countries.

## 17. Suggested GitHub repository layout

```text
enterprise-power-bi-dashboard/
├── README.md
├── docs/
│   └── SQL_SERVER_3M_DATA_CLEANING_GUIDE.md   <-- this document
├── sql/
│   ├── 01_raw_data_profile.sql                  (optional future export)
│   ├── 02_original_conversion_view.sql          (export exact DDL from SSMS)
│   ├── 03_clean_table_and_dimensions.sql        (reviewed migration script)
│   ├── 04_fact_reporting_view.sql               (view definition above)
│   └── 05_validation_and_benchmarks.sql         (read-only tests)
└── assets/
    └── screenshots/
```

**Safety note:** SQL blocks labeled **write operation** describe operations already completed in the case study. They are **not** idempotent and must not be rerun against the finished database. Test on a fresh copy and confirm each prerequisite first.

---

**Project:** Enterprise Power BI Analytics Portfolio · **Documentation date:** 2026-10-25 · **Environment:** SQL Server 2022 Developer Edition / SSMS 22 · **Data:** Synthetic demonstration transactions.
