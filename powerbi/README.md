# Power BI Semantic Model & Report Architecture

**Platform:** Microsoft Power BI Desktop (October 2026 Release / Version 2.159.229.0)  
**Storage Mode:** Import Mode  
**Architecture:** Kimball Star Schema  
**Fact Source:** `[3 _M]`.`dbo`.`vw_FactSales` (3,000,000 records, 19 columns)  
**Dimensions:** `dbo.DimProduct` (15 rows), `dbo.DimGeography` (50 rows), `dbo.DimDate` (2,191 rows)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Star Schema Relationships

| From Table (Many Side) | Foreign Key Column | To Table (One Side) | Primary Key Column | Cardinality | Cross Filter Direction | Active |
|---|---|---|---|---|---|---|
| `vw_FactSales` | `ProductKey` | `DimProduct` | `ProductKey` | Many-to-One (*:1) | Single | **Yes** |
| `vw_FactSales` | `GeographyKey` | `DimGeography` | `GeographyKey` | Many-to-One (*:1) | Single | **Yes** |
| `vw_FactSales` | `order_date` | `DimDate` | `FullDate` | Many-to-One (*:1) | Single | **Yes** |

> **Date Table Configuration:** `DimDate` is marked as a formal Date Table using column `FullDate`.  
> Integer `DateKey` (YYYYMMDD) is **not** joined directly to date-typed `order_date`.  
> Redundant technical keys (`record_id`, `ProductKey`, `GeographyKey`) are hidden from report view.

---

## 2. Directory Structure

```text
powerbi/
├── README.md                          # Architecture and setup guide
├── Enterprise_Global_Business_Analytics_3M.pbix # Model container (distributed externally)
├── measures/
│   ├── base_measures.dax              # Core volume and order KPIs
│   ├── finance_measures.dax           # Currency-gated monetary measures (P0 Guardrail)
│   ├── operations_measures.dax        # Delivery, cancellation, and fulfillment rates
│   └── date_measures.dax              # Time intelligence, MTD, YTD, and period shifts
├── theme/
│   └── enterprise-light-theme.json    # Valid Power BI corporate light design theme
└── page-specs/
    ├── 01_executive_overview.md       # Operational snapshot & headline KPIs
    ├── 02_sales_performance.md        # Trend analysis & channel breakdown
    ├── 03_product_analysis.md         # 15 validated products & categories
    ├── 04_customer_insights.md        # Transaction segments & identity caveat
    ├── 05_region_analysis.md          # 50 countries, 42 currencies & continent maps
    ├── 06_order_details.md            # Drill-through transaction grid
    ├── 07_profitability_analysis.md   # Single-currency waterfall & margins
    ├── 08_return_analysis.md          # Cancellations & order exceptions
    └── 09_forecast_analysis.md        # Time-series history & methodology roadmap
```

---

## 3. P0 Multi-Currency Policy Enforcement

In accordance with PRD Section 7.5, monetary columns (`revenue`, `cost`, `profit`, `tax_amount`, `unit_price`) represent local transaction amounts across **42 distinct currencies**. Arithmetic aggregation across multiple currencies without FX conversion is economically meaningless.

All monetary measures in `measures/finance_measures.dax` enforce single-currency gating:
```dax
Revenue (Single Currency Only) = 
IF(
    HASONEVALUE(DimGeography[currency]),
    SUM(vw_FactSales[revenue]),
    BLANK()
)
```
When multiple currencies are in context, cards and visuals return `BLANK()` and show user-facing guidance to select a single currency or country slicer.
