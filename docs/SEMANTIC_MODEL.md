# Power BI Semantic Model & Dimensional Architecture

**Platform:** Microsoft Power BI Desktop (October 2026 Release / Version 2.159.229.0)  
**Model Design:** Kimball Star Schema (1 Fact View, 3 Dimensions, 1 Local Measure Table)  
**Author:** Datta Sable (https://dattasable.com)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Dimensional Model Overview

```mermaid
erDiagram
    DimProduct ||--o{ vw_FactSales : "ProductKey (1:*)"
    DimGeography ||--o{ vw_FactSales : "GeographyKey (1:*)"
    DimDate ||--o{ vw_FactSales : "FullDate to order_date (1:*)"

    vw_FactSales {
        bigint record_id PK
        varchar order_id
        varchar transaction_id
        int ProductKey FK
        int GeographyKey FK
        date order_date FK
        int quantity
        decimal unit_price
        decimal discount_pct
        decimal revenue
        decimal cost
        decimal profit
        decimal tax_amount
        varchar currency
        varchar order_status
        varchar payment_status
        varchar sales_channel
        date planned_delivery_date
        date actual_delivery_date
    }

    DimProduct {
        int ProductKey PK
        varchar product_name
        varchar product_category
        varchar brand
    }

    DimGeography {
        int GeographyKey PK
        varchar country
        varchar continent
        varchar currency
    }

    DimDate {
        int DateKey PK
        date FullDate UQ
        int Year
        int QuarterNumber
        varchar QuarterName
        int MonthNumber
        varchar MonthName
        char YearMonth
        int YearMonthSort
        int DayOfMonth
        int DayOfWeekNumber
        varchar DayOfWeekName
        bit IsWeekend
    }
```

---

## 2. Table and Relationship Matrix

| Dimension Table | Surrogate Key | Fact Table Foreign Key | Cardinality | Cross Filter | Active | Justification |
|---|---|---|---|---|---|---|
| `DimProduct` | `ProductKey` (INT) | `vw_FactSales.ProductKey` | One-to-Many (1:*) | Single | **Yes** | Replaces unstable source `product_id`. Guaranteed 1-to-1 unique product mapping. |
| `DimGeography` | `GeographyKey` (INT) | `vw_FactSales.GeographyKey`| One-to-Many (1:*) | Single | **Yes** | Normalizes country, continent, and local currency across 50 countries. |
| `DimDate` | `FullDate` (DATE) | `vw_FactSales.order_date` | One-to-Many (1:*) | Single | **Yes** | Standard calendar table enabling DAX time intelligence across 2,191 dates. |

---

## 3. Optimization & Data Hygiene Rules

1. **Selective Table Import:** Only `dbo.vw_FactSales`, `dbo.DimProduct`, `dbo.DimGeography`, and `dbo.DimDate` are imported. Neither the 49-column raw staging table nor the wide clean table is imported.
2. **Hidden Technical Columns:** In report view, surrogate technical keys (`ProductKey`, `GeographyKey`, `record_id`, `DateKey`) are hidden from end users. Slicers and visual fields reference user-friendly dimension attributes (`DimProduct[product_name]`, `DimGeography[country]`, etc.).
3. **No Bi-Directional Filtering:** All relationships use single-direction filtering (Dimension filters Fact). Bi-directional cross-filtering is avoided to prevent ambiguous filter paths and performance degradation.
4. **Display Folders in `_Measures`:**
   - `01 Operational Base`: Volume and transaction counts
   - `02 Fulfillment & Operations`: Status counts, delivery and cancellation rates
   - `03 Finance (Single Currency)`: Revenue, cost, profit, and margin measures
   - `04 Time Intelligence`: Period-over-period growth and cumulative totals
