# SQL Server 2022 Setup & Database Recreation Guide

**Platform:** Microsoft SQL Server 2022 Developer Edition (v16.0.1000.6 or higher)  
**IDE:** SQL Server Management Studio (SSMS) 22 or Azure Data Studio / sqlcmd  
**Target Database:** `[3 _M]` (Note the space in name)  
**Author:** Datta Sable (https://dattasable.com)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. System Requirements & Prerequisites

- **CPU:** 4+ physical cores recommended.
- **RAM:** Minimum 16 GB (32 GB recommended for in-memory operations on 3M rows).
- **Disk Space:** At least 25 GB free disk space on target drive:
  - Raw CSV file: ~1.30 GB
  - Database Data file (`.mdf`): ~4.5 GB
  - Database Log file (`.ldf`): ~2.5 GB
  - Staging and index workspace: ~10 GB
- **Software:**
  - [SQL Server 2022 Developer Edition (Free)](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
  - [SSMS 22 (SQL Server Management Studio)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

---

## 2. Step 1: Download Source Dataset

1. Download the full 3,000,000-row synthetic CSV (`world_business_data_3m.csv`, ~1.3 GB) using our verified Google Drive link:  
   👉 **[Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)**
2. Save the file locally (e.g. `D:\Datasets\world_business_data_3m.csv`).

---

## 3. Step 2: Create Database `[3 _M]`

Open SSMS 22, connect to your local SQL Server instance, and run:

```sql
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = '3 _M')
BEGIN
    CREATE DATABASE [3 _M]
    COLLATE SQL_Latin1_General_CP1_CI_AS;
    PRINT 'Database [3 _M] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [3 _M] already exists.';
END;
GO

USE [3 _M];
GO
```

---

## 4. Step 3: Create Raw Table & Ingest CSV

Create the immutable landing table with all 49 columns defined as `VARCHAR(50)`:

```sql
USE [3 _M];
GO

IF OBJECT_ID('dbo.world_business_data_3m', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.world_business_data_3m (
        record_id VARCHAR(50),
        customer_id VARCHAR(50),
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(50),
        phone VARCHAR(50),
        age VARCHAR(50),
        gender VARCHAR(50),
        company_name VARCHAR(50),
        industry VARCHAR(50),
        department VARCHAR(50),
        job_title VARCHAR(50),
        country VARCHAR(50),
        continent VARCHAR(50),
        city VARCHAR(50),
        region VARCHAR(50),
        postal_code VARCHAR(50),
        currency VARCHAR(50),
        product_id VARCHAR(50),
        product_category VARCHAR(50),
        product_name VARCHAR(50),
        brand VARCHAR(50),
        order_id VARCHAR(50),
        order_date VARCHAR(50),
        quantity VARCHAR(50),
        unit_price VARCHAR(50),
        discount_pct VARCHAR(50),
        tax_amount VARCHAR(50),
        revenue VARCHAR(50),
        cost VARCHAR(50),
        profit VARCHAR(50),
        payment_method VARCHAR(50),
        payment_status VARCHAR(50),
        transaction_id VARCHAR(50),
        shipping_method VARCHAR(50),
        warehouse_id VARCHAR(50),
        delivery_date VARCHAR(50),
        order_status VARCHAR(50),
        campaign VARCHAR(50),
        sales_channel VARCHAR(50),
        marketing_source VARCHAR(50),
        device VARCHAR(50),
        browser VARCHAR(50),
        operating_system VARCHAR(50),
        website_visits VARCHAR(50),
        customer_satisfaction VARCHAR(50),
        support_tickets VARCHAR(50),
        loyalty_tier VARCHAR(50),
        is_repeat_customer VARCHAR(50)
    );
    PRINT 'dbo.world_business_data_3m created.';
END;
GO

-- Bulk insert from downloaded CSV (Update local file path if different)
BULK INSERT dbo.world_business_data_3m
FROM 'D:\Datasets\world_business_data_3m.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    BATCHSIZE = 100000
);
GO

SELECT COUNT_BIG(*) AS LoadedRawRows FROM dbo.world_business_data_3m;
-- Target: 3,000,000 rows
```

---

## 5. Step 4: Execute Transformation Scripts (00–12)

Execute the scripts located in the `sql/` directory in sequence:

1. `sql/00_preflight_read_only.sql` — Verify database and disk capacity.
2. `sql/01_source_profile.sql` — Audit raw data quality and identify synthetic defects.
3. `sql/02_create_typed_view.sql` — Create `dbo.vw_Enterprise_Business_Analytics`.
4. `sql/03_create_clean_table.sql` — Materialize `dbo.world_business_data_3m_clean`.
5. `sql/04_delivery_dates.sql` — Populate planned vs actual delivery dates.
6. `sql/05_product_dimension.sql` — Build `dbo.DimProduct` (15 products).
7. `sql/06_geography_dimension.sql` — Build `dbo.DimGeography` (50 countries, 42 currencies).
8. `sql/07_date_dimension.sql` — Populate `dbo.DimDate` (2,191 days).
9. `sql/08_foreign_keys.sql` — Enforce trusted referential integrity.
10. `sql/09_reporting_view.sql` — Create `dbo.vw_FactSales` (19 columns).
11. `sql/10_data_quality_checks.sql` — Validate zero missing keys and financial equations.
12. `sql/11_performance_checks.sql` — Benchmark reporting aggregations.
13. `sql/12_sample_reporting_queries.sql` — Compare SQL results to Power BI KPIs.
