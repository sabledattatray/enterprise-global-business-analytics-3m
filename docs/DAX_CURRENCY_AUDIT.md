# DAX Financial Measures & Multi-Currency Audit Report

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Audit Standard:** PRD v1.1 Mandatory Task 4  
**Author:** Datta Sable (https://dattasable.com)  
**Execution Date:** 2026-10-26  

---

## 1. Executive Directive: The Multi-Currency Challenge

The dataset contains transactions across **50 countries and 42 local currencies**. The underlying monetary columns (`revenue`, `cost`, `profit`, `tax_amount`, `unit_price`) represent transaction values in their respective domestic currencies.

An uncontrolled global aggregation:
```dax
-- FORBIDDEN GLOBAL SUM:
Global Revenue = SUM(vw_FactSales[revenue])
-- Evaluates to: 18,720,460,798.92 (Cross-currency arithmetic sum)
```
This naive total sums Japanese Yen (`JPY`), US Dollars (`USD`), Indian Rupees (`INR`), and 39 other currencies 1:1, producing an economically invalid number.

---

## 2. Comprehensive DAX Measure Audit

All DAX measure definitions in `powerbi/measures/finance_measures.dax` were audited:

### 2.1 Currency-Gated Measure Catalog

| Measure Name | DAX Logic | Multi-Currency Behavior | Single-Currency Behavior | Status |
|---|---|---|---|:---:|
| `Revenue (Single Currency Only)` | `IF(HASONEVALUE(DimGeography[currency]), SUM(vw_FactSales[revenue]), BLANK())` | Returns `BLANK()` | Formatted sum in local currency | :white_check_mark: SAFE |
| `Cost (Single Currency Only)` | `IF(HASONEVALUE(DimGeography[currency]), SUM(vw_FactSales[cost]), BLANK())` | Returns `BLANK()` | Formatted sum in local currency | :white_check_mark: SAFE |
| `Profit (Single Currency Only)` | `IF(HASONEVALUE(DimGeography[currency]), SUM(vw_FactSales[profit]), BLANK())` | Returns `BLANK()` | Formatted sum in local currency | :white_check_mark: SAFE |
| `Profit Margin (Single Currency Only)` | `DIVIDE([Profit (Single Currency Only)], [Revenue (Single Currency Only)], BLANK())` | Returns `BLANK()` | Accurate percentage margin | :white_check_mark: SAFE |
| `Average Order Value (Single Currency Only)` | `DIVIDE([Revenue (Single Currency Only)], [Total Orders], BLANK())` | Returns `BLANK()` | Accurate basket amount | :white_check_mark: SAFE |

### 2.2 Visual Notice & Transparency String
```dax
Currency Guardrail Notice = 
IF(
    HASONEVALUE(DimGeography[currency]),
    CONCATENATE("Amounts displayed in: ", SELECTEDVALUE(DimGeography[currency])),
    "⚠ Multi-currency context active (42 currencies). Select a single currency or country to view financial figures."
)
```

---

## 3. Two-Tier Reporting Mode Architecture

### Mode 1: Local Currency Mode (Implemented & Verified)
- Used across all financial pages (Page 07 Profitability Analysis, Page 05 Regional Analysis).
- Requires the user to filter by a single currency or country.
- The active currency code (e.g. `USD`, `EUR`, `CHF`) is prominently displayed on cards and visual titles.
- Non-monetary operational KPIs (`Total Orders`, `Total Units Sold`, `Average Units Per Order`) remain universally active across all currencies.

### Mode 2: Converted Reporting Mode (Future Roadmap)
- Architectural blueprint for corporate-level consolidated reporting in a unified currency (e.g. USD).
- **Prerequisites:**
  1. Materialize `dbo.DimExchangeRate(RateDate, FromCurrency, ToCurrency, SpotRate, MonthlyAvgRate)`.
  2. Implement date-matched conversion in fact view or DAX: `Revenue_USD = SUMX(vw_FactSales, vw_FactSales[revenue] * RELATED(DimExchangeRate[SpotRate]))`.
  3. Formally validate converted totals against central bank benchmark distributions.
