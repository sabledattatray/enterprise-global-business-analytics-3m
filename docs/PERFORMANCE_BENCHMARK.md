# Performance Benchmark & Engine Capacity Report

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Test Platform:** Microsoft SQL Server 2022 Developer Edition (v16.0.1000.6, 64-bit)  
**Host Environment:** Windows 11 Enterprise (Intel/AMD x64, 16+ GB RAM, NVMe SSD Storage)  
**Author:** Datta Sable (https://dattasable.com)  
**Audit Standard:** PRD v1.1 Mandatory Task 11  
**Benchmark Date:** 2026-10-26  
**Reproduction Script:** [`tests/sql/run_benchmarks.ps1`](../tests/sql/run_benchmarks.ps1)

---

## 1. Hardware Specifications & Test Methodology

Benchmarking was conducted on the host developer workstation against the live `[3 _M]` database to establish production-grade sizing expectations:

- **Host Machine:** `DATTA` (Windows 11 Enterprise 64-bit)
- **Database Engine:** Microsoft SQL Server 2022 (RTM) Developer Edition (64-bit)
- **Engine Memory Limit:** Dynamic (up to 12 GB SQL buffer pool)
- **Storage Subsystem:** PCIe NVMe M.2 Solid State Drive (Sequential read > 3,000 MB/s)
- **Measurement Tool:** High-resolution `System.Diagnostics.Stopwatch` (.NET) wrapped in PowerShell, coupled with `SET STATISTICS TIME, IO ON` via T-SQL.
- **Cache Protocol:** Both cold-cache (`CHECKPOINT; DBCC DROPCLEANBUFFERS;`) and warm-buffer pool iterations were evaluated across 3 runs.

---

## 2. SQL Server 2022 Query Benchmarks (3,000,000 Rows)

All queries were measured across the full 3,000,000-row `dbo.vw_FactSales` reporting view:

| Benchmark Workload | Description / Target | Rows Processed | Result Rows | Measured Duration (Warm Cache) | Measured Duration (Cold Buffer) | Peak Throughput |
|---|---|---:|---:|---:|---:|---:|
| **Benchmark 1: Monthly Aggregation by Currency** | Full table scan of `dbo.vw_FactSales` grouped by Year, Month, and Currency with 4 aggregations (`COUNT_BIG`, `SUM(quantity)`, `SUM(revenue)`, `SUM(profit)`) | 3,000,000 | 2,562 | **414 ms** | **1,138 ms** | **7,246,376 rows/sec** |
| **Benchmark 2: Star Schema 3-Way Join Slicing** | Joins `dbo.vw_FactSales` to `dbo.DimProduct` and `dbo.DimGeography`, grouped by category, product, country, and currency | 3,000,000 | 20 (Top) | **237 ms** | **2,586 ms** | **12,658,227 rows/sec** |
| **Benchmark 3: Core Headline Card Query** | Single-pass scan computing `COUNT(DISTINCT order_id)`, `SUM(quantity)`, and `Average Units` | 3,000,000 | 1 | **315 ms** | **925 ms** | **9,523,809 rows/sec** |

### How to Reproduce Benchmarks Locally:
```powershell
powershell -ExecutionPolicy Bypass -File tests/sql/run_benchmarks.ps1
```

---

## 3. Storage & Memory Footprint Analysis

| Storage Artifact | Format / Compression | File Size | Description |
|---|---|---:|---|
| **Raw Synthetic CSV** | Plain Text UTF-8 | **1,299,034,854 bytes (1.21 GB)** | Immutable original 49-column raw data |
| **SQL Server MDF File** | 8 KB Data Pages | **4,424.00 MB** (4,415.94 MB used) | Contains raw table, clean table, and dimensions |
| **SQL Server LDF File** | Write-Ahead Transaction Log | **2,184.00 MB** (901.27 MB used) | 41.27% log space utilized |
| **Power BI Model (`.pbix`)** | XPress9 Columnar Compression | **214,297,510 bytes (214.3 MB)** | VertiPaq tabular model with 4 tables |
| **Compression Ratio** | VertiPaq vs. Raw CSV | **~6.1 : 1 Compression** | 1.3 GB CSV compresses to 214 MB in RAM |

---

## 4. Power BI Desktop Refresh & Memory Performance

- **Import Mode Refresh Duration:** Importing all 3,000,000 rows from `dbo.vw_FactSales` along with the 3 dimension tables requires **~60 to 85 seconds** on local developer hardware over local named pipes / TCP connection.
- **In-Memory VertiPaq Footprint:** The decompressed columnar dictionary footprint in RAM during report interaction is **~450 MB to 650 MB**, allowing responsive slicing (< 500 ms visual cross-filtering).
- **Columnstore Index Assessment:** A clustered columnstore index on `dbo.world_business_data_3m_clean` was evaluated during Phase 0 audit. While columnstore would compress SQL disk storage by ~4.6×, warm-cache scans on the heap table already execute in 237–414 ms, meaning the operational read overhead is already negligible for Power BI scheduled refresh.
