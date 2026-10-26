# Performance Benchmark & Engine Capacity Report

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Test Platform:** Microsoft SQL Server 2022 Developer Edition / Power BI Desktop (Oct 2026)  
**Host Environment:** Windows 11 Enterprise (Intel/AMD x64, Local SQL Instance)  
**Author:** Datta Sable (https://dattasable.com)  
**Audit Standard:** PRD v1.1 Mandatory Task 11  
**Benchmark Date:** 2026-10-26  

---

## 1. SQL Server 2022 Query Benchmarks (3,000,000 Rows)

All queries were measured using `System.Diagnostics.Stopwatch` and `SET STATISTICS TIME, IO ON` on database `[3 _M]`:

| Benchmark Workload | Description / Target | Rows Processed | Result Rows | Measured Duration | Throughput |
|---|---|---:|---:|---:|---:|
| **Benchmark 1: Monthly Aggregation by Currency** | Full table scan of `dbo.vw_FactSales` grouped by Year, Month, and Currency with 4 aggregations (`COUNT_BIG`, `SUM(quantity)`, `SUM(revenue)`, `SUM(profit)`) | 3,000,000 | 2,562 | **414 ms** | **7,246,376 rows/sec** |
| **Benchmark 2: Star Schema 3-Way Join Slicing** | Joins `dbo.vw_FactSales` to `dbo.DimProduct` and `dbo.DimGeography`, grouped by category, product, country, and currency | 3,000,000 | 20 (Top) | **237 ms** | **12,658,227 rows/sec** |
| **Benchmark 3: Core Headline Card Query** | Single-pass scan computing `COUNT(DISTINCT order_id)`, `SUM(quantity)`, and `Average Units` | 3,000,000 | 1 | **315 ms** | **9,523,809 rows/sec** |

---

## 2. Storage & Memory Footprint Analysis

| Storage Artifact | Format / Compression | File Size | Description |
|---|---|---:|---|
| **Raw Synthetic CSV** | Plain Text UTF-8 | **1,299,034,854 bytes (1.21 GB)** | Immutable original 49-column raw data |
| **SQL Server MDF File** | 8 KB Data Pages | **4,424.00 MB** (4,415.94 MB used) | Contains raw table, clean table, and dimensions |
| **SQL Server LDF File** | Write-Ahead Transaction Log | **2,184.00 MB** (901.27 MB used) | 41.27% log space utilized |
| **Power BI Model (`.pbix`)** | XPress9 Columnar Compression | **214,297,510 bytes (214.3 MB)** | VertiPaq tabular model with 4 tables |
| **Compression Ratio** | VertiPaq vs. Raw CSV | **~6.1 : 1 Compression** | 1.3 GB CSV compresses to 214 MB in RAM |

---

## 3. Power BI Desktop Refresh & Memory Performance

- **Import Mode Refresh Duration:** Importing all 3,000,000 rows from `dbo.vw_FactSales` along with the 3 dimension tables requires **~60 to 85 seconds** on local developer hardware.
- **In-Memory VertiPaq Footprint:** The decompressed columnar dictionary footprint in RAM during report interaction is **~450 MB to 650 MB**, allowing responsive slicing (< 500 ms visual cross-filtering).
- **Columnstore Index Assessment:** A clustered columnstore index on `dbo.world_business_data_3m_clean` was audited but deferred because warm-cache heap scans already return aggregated results in 237–414 ms, avoiding unnecessary disk and transaction log overhead.
