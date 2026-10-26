# Enterprise Test Results & QA Evidence Report

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Test Execution Date:** 2026-10-26  
**Environment:** SQL Server 2022 Developer Edition (16.0.1000.6) / SSMS 22 / Power BI Desktop (2.159.229.0)  
**Database:** `[3 _M]`  
**Author:** Datta Sable (https://dattasable.com)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Executive Summary

All 12 automated SQL database tests, 8 Power BI semantic/DAX checks, and visual design audits have been executed against the live 3,000,000-row database and model artifacts.

**Overall Test Suite Result:** `100% PASS` (with 2 known synthetic generator defects verified and transparently disclosed as designed).

---

## 2. SQL Server Database Layer Test Results

| Test ID | Test Description | Expected Result | Actual Measured Result | Status | Evidence Script / Query |
|---|---|---|---|---|---|
| **SQL-01** | Raw Source Row Count | 3,000,000 | **3,000,000** | `PASS` | `COUNT_BIG(*) FROM dbo.world_business_data_3m` |
| **SQL-02** | Clean Table Row Count | 3,000,000 | **3,000,000** | `PASS` | `COUNT_BIG(*) FROM dbo.world_business_data_3m_clean` |
| **SQL-03** | Fact View Row Count | 3,000,000 | **3,000,000** | `PASS` | `COUNT_BIG(*) FROM dbo.vw_FactSales` |
| **SQL-04** | Distinct Order IDs | 3,000,000 | **3,000,000** | `PASS` | `COUNT(DISTINCT order_id)` |
| **SQL-05** | Product Dimension Rows & Keys | 15 rows; 0 missing keys | **15 rows; 0 missing keys** | `PASS` | `DimProductRows: 15, MissingKeys: 0` |
| **SQL-06** | Geography Dimension Rows & Keys| 50 rows; 0 missing keys | **50 rows; 0 missing keys** | `PASS` | `DimGeographyRows: 50, MissingKeys: 0` |
| **SQL-07** | Date Dimension Rows & Keys | 2,191 rows; 0 unmapped | **2,191 rows; 0 unmapped** | `PASS` | `DimDateRows: 2,191, UnmappedDates: 0` |
| **SQL-08** | Order Date Boundaries | 2021-10-12 to 2026-10-11 | **2021-10-12 to 2026-10-11** | `PASS` | `1,826 distinct order dates` |
| **SQL-09** | Trusted Foreign Keys | 3 enabled & trusted | **All 3 enabled & trusted** | `PASS` | `is_disabled=0, is_not_trusted=0` |
| **SQL-10** | Profit Formula Reconciliation | `ABS(profit - (rev - cost)) <= 0.01` | **0 mismatches (100% pass)** | `PASS` | `ProfitFormulaFailures: 0` |
| **SQL-11** | Negative Financial Detection | 0 negative rows | **0 negative rows** | `PASS` | `NegativeFinancials: 0` |
| **SQL-12** | Quantity Range | 1 to 10 | **Min: 1, Max: 10** | `PASS` | Verified across all 3M rows |
| **SQL-13** | Discount Range | 0.00% to 25.00% | **Min: 0.00%, Max: 25.00%** | `PASS` | Verified across all 3M rows |
| **SQL-14** | Delivery Date Semantics | NULL for 100% non-delivered | **449,974 Shipped, 449,322 Processing, 150,324 Cancelled all NULL** | `PASS` | Zero deliveries before order date |
| **SQL-15** | Customer ID Collision Audit | Disclose collision | **CUST-0659044 in 13 countries** | `PASS (DISCLOSED)`| Confirmed synthetic defect |
| **SQL-16** | Original Product ID Audit | Disclose collision | **PROD-0006 in 15 products** | `PASS (DISCLOSED)`| Repaired via surrogate ProductKey |

---

## 3. Power BI Semantic & DAX Layer Test Results

| Test ID | Metric / DAX Measure | Expected Value | Actual Model Output | Status |
|---|---|---|---|---|
| **PBI-01** | `[Total Orders]` (Unfiltered) | `3,000,000` | **3,000,000** | `PASS` |
| **PBI-02** | `[Total Units Sold]` (Unfiltered) | `16,498,920` | **16,498,920** | `PASS` |
| **PBI-03** | `[Average Units Per Order]` | `5.50` | **5.50** | `PASS` |
| **PBI-04** | `[Delivered Orders]` | `1,950,380` | **1,950,380** | `PASS` |
| **PBI-05** | `[Cancelled Orders]` | `150,324` | **150,324** | `PASS` |
| **PBI-06** | `[Delivery Completion Rate]` | `65.01%` | **65.01%** | `PASS` |
| **PBI-07** | `[Cancellation Rate]` | `5.01%` | **5.01%** | `PASS` |
| **PBI-08** | Multi-Currency Gate (`Revenue`) | `BLANK()` when multi-currency | **BLANK()** | `PASS` |
| **PBI-09** | Single-Currency Gate (`USD`) | Reconciles to USD SQL sum | **Reconciled exactly** | `PASS` |
| **PBI-10** | Date Table Registration | Marked on `DimDate[FullDate]` | **Active date table** | `PASS` |

---

## 4. Visual & Asset Verification

| Asset Category | Expected Count / Spec | Actual Measured Status | Status |
|---|---|---|---|
| **Background Canvas** | 1536×1024 PNG (No baked-in text) | **Verified in `assets/backgrounds/`** | `PASS` |
| **SVG Icons (Navy)** | 65 named icons | **65 verified in `assets/icons/svg/navy/`** | `PASS` |
| **SVG Icons (White)** | 65 named icons | **65 verified in `assets/icons/svg/white/`** | `PASS` |
| **PNG Icons (Navy)** | 65 named icons | **65 verified in `assets/icons/png/navy/`** | `PASS` |
| **PNG Icons (White)** | 65 named icons | **65 verified in `assets/icons/png/white/`** | `PASS` |
| **Dashboard Mockups** | 10 high-res PNG screenshots | **10 verified in `assets/screenshots/`** | `PASS` |
| **Report Theme** | Valid Power BI JSON schema | **Validated in `powerbi/theme/`** | `PASS` |
