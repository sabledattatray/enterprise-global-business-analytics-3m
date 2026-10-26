# Enterprise Test Plan & Quality Assurance Protocol

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Target Environment:** Microsoft SQL Server 2022 / SSMS 22 / Power BI Desktop 2.159.229.0  
**Author:** Datta Sable (https://dattasable.com)  
**Verification Date:** 2026-10-26  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Quality Objectives & Test Scope

This test plan defines the automated and manual verification procedures across three technical layers:
1. **SQL Server Database Layer:** Schema integrity, 3M row preservation, null key checks, foreign keys, financial reconciliation, and delivery lifecycle logic.
2. **Power BI Semantic Model Layer:** Star schema relationships, date table registration, DAX measure accuracy, and P0 multi-currency guardrails.
3. **Report Presentation & Accessibility Layer:** Visual alignment, contrast ratios, slicer synchronization, and table fallback accessibility.

---

## 2. SQL Test Matrix

| Test ID | Requirement | Validation Method | Acceptance Criteria |
|---|---|---|---|
| **SQL-01** | Raw Source Count | `SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m` | Exactly 3,000,000 |
| **SQL-02** | Clean Table Count | `SELECT COUNT_BIG(*) FROM dbo.world_business_data_3m_clean` | Exactly 3,000,000 |
| **SQL-03** | Fact View Count | `SELECT COUNT_BIG(*) FROM dbo.vw_FactSales` | Exactly 3,000,000 |
| **SQL-04** | Distinct Order IDs | `COUNT(DISTINCT order_id)` | Exactly 3,000,000 |
| **SQL-05** | Product Dimension Integrity | Check `DimProduct` row count & NULL `ProductKey` in fact | 15 rows; 0 NULL keys |
| **SQL-06** | Geography Dimension Integrity | Check `DimGeography` row count & NULL `GeographyKey` | 50 rows; 0 NULL keys |
| **SQL-07** | Date Dimension Integrity | Check `DimDate` rows & unmapped order dates | 2,191 rows; 0 unmapped dates |
| **SQL-08** | Date Boundaries | Verify `MIN` and `MAX` order date | `2021-10-12` to `2026-10-11` |
| **SQL-09** | Foreign Key State | Inspect `sys.foreign_keys` for all 3 dimension FKs | `is_disabled=0`, `is_not_trusted=0` |
| **SQL-10** | Profit Formula | Check `ABS(profit - (revenue - cost)) <= 0.01` | 0 mismatches across 3M rows |
| **SQL-11** | Delivery Lifecycle | Verify `actual_delivery_date IS NULL` for non-delivered | 100% NULL for non-delivered |
| **SQL-12** | Defect Disclosure | Query customer ID & product ID collisions | Disclose verified collisions |

---

## 3. Power BI Semantic & DAX Test Matrix

| Test ID | Requirement | Validation Method | Acceptance Criteria |
|---|---|---|---|
| **PBI-01** | Core Total Orders | DAX `[Total Orders]` unfiltered | Returns `3,000,000` |
| **PBI-02** | Core Units Sold | DAX `[Total Units Sold]` unfiltered | Returns `16,498,920` |
| **PBI-03** | Core Basket Size | DAX `[Average Units Per Order]` | Returns `5.50` |
| **PBI-04** | Country Slicer Propagation | Filter by `country = 'United States'` | All cards and visuals filter cleanly |
| **PBI-05** | Multi-Currency Gate | DAX `[Revenue (Single Currency Only)]` unfiltered | Returns `BLANK()` |
| **PBI-06** | Single-Currency Revenue | Filter by `currency = 'USD'` | Reconciles to SQL USD revenue |
| **PBI-07** | Chronological Sorting | Time series chart on `DimDate[YearMonth]` | Sorts chronologically via `YearMonthSort` |
| **PBI-08** | Date Table Registration | Inspect model properties for `DimDate` | Marked as Date Table on `FullDate` |

---

## 4. Visual & Accessibility Test Matrix

| Test ID | Requirement | Validation Method | Acceptance Criteria |
|---|---|---|---|
| **VIS-01** | Consistent Canvas | Inspect all 9 report page backgrounds | All use clean globe canvas background |
| **VIS-02** | Contrast Compliance | Contrast checker on text vs card backgrounds | Ratio >= 4.5:1 (WCAG AA compliant) |
| **VIS-03** | Map Accessibility | Review Page 05 Regional Analysis | Table fallback present alongside map |
| **VIS-04** | Icon Integrity | Inspect icon assets in `assets/icons/` | All 65 SVG and PNG icons load without error |
