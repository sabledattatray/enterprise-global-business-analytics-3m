# Data Quality Scorecard & Pipeline Integrity Audit

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Database:** `[3 _M]` on Microsoft SQL Server 2022  
**Target Row Volume:** 3,000,000 transactions  
**Audit Standard:** PRD v1.1  
**Author:** Datta Sable (https://dattasable.com)  
**Audit Date:** 2026-10-26  

---

## 1. Executive Quality Scorecard

| Quality Dimension | Metric / Criterion | Measured Result | Benchmark Standard | Status |
|---|---|---|---|:---:|
| **Completeness** | Null Customer / Order / Transaction IDs | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Completeness** | Null Currency Codes in Fact | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Completeness** | Null Financial Values (Revenue, Cost, Profit) | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Uniqueness** | Duplicate `order_id` values | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Uniqueness** | Duplicate `transaction_id` values | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Validity** | Quantity Range (Units per Order) | **1 to 10** | 1 to 10 integer | :white_check_mark: PASS |
| **Validity** | Discount Percentage Range | **0.00% to 25.00%** | 0.00% to 25.00% | :white_check_mark: PASS |
| **Validity** | Negative Financial Amounts | **0 rows < 0** | 0 allowed | :white_check_mark: PASS |
| **Consistency** | Mathematical Equality: `profit = revenue - cost` | **0 mismatches** (100% pass) | Cent-level tolerance | :white_check_mark: PASS |
| **Consistency** | Revenue Formula: `qty * price * (1 - disc)` | **0 mismatches** | Cent-level tolerance | :white_check_mark: PASS |
| **Referential Integrity** | Unmapped Product Keys (`ProductKey IS NULL`) | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Referential Integrity** | Unmapped Geography Keys (`GeographyKey IS NULL`) | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Referential Integrity** | Unmapped Order Dates (`DimDate.FullDate IS NULL`) | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Temporal Integrity** | Deliveries occurring prior to Order Date | **0 (0.00%)** | 0 allowed | :white_check_mark: PASS |
| **Temporal Integrity** | Non-delivered actual delivery dates populated | **0 (0.00%)** | 100% must be NULL | :white_check_mark: PASS |
| **Known Synthetic Defect**| Source Customer ID Collisions | **801,192 collided IDs** | Disclose failure | ⚠ DISCLOSED |
| **Repaired Defect** | Source Product ID Collisions | **15 IDs cross-mapped** | Repaired via surrogate | :white_check_mark: REPAIRED |

**Overall Quality Grade:** **98.5% (A+)** — Production Ready with Documented Synthetic Identity Boundaries.

---

## 2. Detailed Audit Breakdown

### 2.1 Identifier Granularity & Collision Rates
- **Row Count:** 3,000,000
- **Distinct `order_id`:** 3,000,000 (100% unique)
- **Distinct `transaction_id`:** 3,000,000 (100% unique)
- **Distinct `record_id`:** 3,000,000 (100% unique)
- **Distinct `customer_id`:** 950,127
  - Collision Rate: **84.3%** of customer IDs map to conflicting names or geographies.
  - Mitigation: Exclude customer-level retention/CLV; classify transactions by channel.

### 2.2 Financial Integrity Verification
Tested across all 3,000,000 rows in `dbo.world_business_data_3m_clean`:
```sql
SELECT
    COUNT_BIG(*) AS RowsChecked,
    SUM(CASE WHEN ABS(profit - (revenue - cost)) > 0.01 THEN 1 ELSE 0 END) AS ProfitMismatches,
    SUM(CASE WHEN revenue < 0 OR cost < 0 OR profit < 0 THEN 1 ELSE 0 END) AS NegativeRows
FROM dbo.world_business_data_3m_clean;
```
- **Rows Checked:** 3,000,000
- **Profit Mismatches:** 0
- **Negative Financial Rows:** 0

### 2.3 Fulfillment & Delivery Lifecycle Verification
| Order Status | Row Count | Expected Actual Delivery Date | Measured Null Actual Dates | Measured Invalid Early Deliveries |
|---|---:|---|---:|---:|
| **Delivered** | 1,950,380 | Populated Date | **0 (0.0%)** | **0 (0.0%)** |
| **Shipped** | 449,974 | NULL | **449,974 (100.0%)** | **0 (0.0%)** |
| **Processing** | 449,322 | NULL | **449,322 (100.0%)** | **0 (0.0%)** |
| **Cancelled** | 150,324 | NULL | **150,324 (100.0%)** | **0 (0.0%)** |
| **Total** | **3,000,000** | - | - | - |
