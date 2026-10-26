# SQL Server Reconciliation Report: Raw vs. Clean Pipeline

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Target Environment:** SQL Server 2022 Developer Edition / SSMS 22  
**Database:** `[3 _M]`  
**Audit Standard:** PRD v1.1 Mandatory Task 2  
**Author:** Datta Sable (https://dattasable.com)  
**Execution Date:** 2026-10-26  

---

## 1. Pipeline Row Volume Reconciliation

| Stage / Object | Object Type | Raw Rows | Cleaned Rows | Variance | Status |
|---|---|---:|---:|---:|:---:|
| Raw Source Table (`dbo.world_business_data_3m`) | Heap Table | 3,000,000 | N/A | 0 | Baseline |
| Staging Conversion View (`dbo.vw_Enterprise_Business_Analytics`) | View | 3,000,000 | 3,000,000 | 0 | :white_check_mark: Balanced |
| Clean Physical Table (`dbo.world_business_data_3m_clean`) | Physical Table | 3,000,000 | 3,000,000 | 0 | :white_check_mark: Balanced |
| Reporting Fact View (`dbo.vw_FactSales`) | View | 3,000,000 | 3,000,000 | 0 | :white_check_mark: Balanced |

---

## 2. Order Status & Fulfillment Reconciliations

| Order Status | Raw Source Count | Clean Table Count | Fact View Count | Variance | Percentage |
|---|---:|---:|---:|---:|---:|
| **Delivered** | 1,950,380 | 1,950,380 | 1,950,380 | 0 | 65.01% |
| **Shipped** | 449,974 | 449,974 | 449,974 | 0 | 15.00% |
| **Processing** | 449,322 | 449,322 | 449,322 | 0 | 14.98% |
| **Cancelled** | 150,324 | 150,324 | 150,324 | 0 | 5.01% |
| **Total** | **3,000,000** | **3,000,000** | **3,000,000** | **0** | **100.00%** |

---

## 3. Dimensional Key Mapping Reconciliation

### A. Product Dimension Mapping
- **Source Unique `(product_name, product_category, brand)` Tuples:** 15
- **Dimension Rows in `dbo.DimProduct`:** 15
- **Surrogate Key Range:** 1 to 15
- **Fact Table Rows with `ProductKey IS NULL`:** **0**
- **Fact Table Rows with Invalid `ProductKey` (<1 or >15):** **0**
- **Reconciliation Result:** `100% RECONCILED`

### B. Geography Dimension Mapping
- **Source Unique `(country, continent, currency)` Tuples:** 50
- **Dimension Rows in `dbo.DimGeography`:** 50
- **Distinct Currency Codes in Dimension:** 42
- **Fact Table Rows with `GeographyKey IS NULL`:** **0**
- **Fact Table Rows with Invalid `GeographyKey` (<1 or >50):** **0**
- **Reconciliation Result:** `100% RECONCILED`

### C. Date Dimension Mapping
- **Calendar Date Range in `dbo.DimDate`:** `2021-01-01` to `2026-12-31` (2,191 dates)
- **Fact Order Date Range in `dbo.vw_FactSales`:** `2021-10-12` to `2026-10-11` (1,826 dates)
- **Fact Table Rows with `order_date` unmapped to `DimDate[FullDate]`:** **0**
- **Reconciliation Result:** `100% RECONCILED`

---

## 4. Date Shift Lineage & Idempotency Audit

To eliminate future-dated demonstration records past the project completion date (2026-10-25), an 81-day shift was applied:

```sql
-- Transformation Audit Log:
-- Table: dbo.world_business_data_3m_clean ONLY (Raw table preserved untouched)
-- Formula: order_date = DATEADD(DAY, -81, order_date)
```

| Date Column | Original Raw Range | Reporting Clean Range | Net Shift |
|---|---|---|:---:|
| `order_date` | 2022-01-01 to 2026-12-31 | 2021-10-12 to 2026-10-11 | **-81 days** |
| `delivery_date` | 2022-01-02 to 2027-01-14 | 2021-10-13 to 2026-10-25 | **-81 days** |
| `planned_delivery_date` | N/A | 2021-10-13 to 2026-10-25 | **-81 days** |
| `actual_delivery_date` | N/A | 2021-10-13 to 2026-10-25 | **-81 days** |

**Idempotency Verification:**  
`sql/04_delivery_dates.sql` evaluates `MAX(order_date)` prior to executing `DATEADD`. If `MAX(order_date) <= '2026-10-15'`, the update is bypassed with a logged safety notice.
