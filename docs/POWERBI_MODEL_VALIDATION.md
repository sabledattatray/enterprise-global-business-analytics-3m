# Power BI Model Validation & Semantic Audit

**Platform:** Microsoft Power BI Desktop (October 2026 Release / Version 2.159.229.0)  
**Model Architecture:** Kimball Star Schema (Import Mode)  
**Audit Standard:** PRD v1.1 Mandatory Task 3  
**Author:** Datta Sable (https://dattasable.com)  
**Verification Date:** 2026-10-26  

---

## 1. Semantic Model Architecture & Relationships

Direct inspection of `DiagramLayout` and metadata inside the Power BI model confirmed the star schema structure:

```mermaid
classDiagram
    DimProduct "1" --> "*" vw_FactSales : ProductKey (1:*)
    DimGeography "1" --> "*" vw_FactSales : GeographyKey (1:*)
    DimDate "1" --> "*" vw_FactSales : FullDate to order_date (1:*)

    class vw_FactSales {
        +BIGINT record_id
        +VARCHAR order_id
        +INT ProductKey
        +INT GeographyKey
        +DATE order_date
        +INT quantity
        +DECIMAL revenue
        +DECIMAL cost
        +DECIMAL profit
        +VARCHAR currency
        +VARCHAR order_status
        +VARCHAR payment_status
        +VARCHAR sales_channel
    }
    class DimProduct {
        +INT ProductKey (PK)
        +VARCHAR product_name
        +VARCHAR product_category
        +VARCHAR brand
    }
    class DimGeography {
        +INT GeographyKey (PK)
        +VARCHAR country
        +VARCHAR continent
        +VARCHAR currency
    }
    class DimDate {
        +INT DateKey (PK)
        +DATE FullDate (UQ)
        +INT Year
        +CHAR YearMonth
        +INT YearMonthSort
    }
```

### Relationship Properties Audit

| From Table (Many) | Foreign Key Column | To Table (One) | Primary Key Column | Cardinality | Cross Filter Direction | Active Status |
|---|---|---|---|---|---|:---:|
| `vw_FactSales` | `ProductKey` | `DimProduct` | `ProductKey` | Many-to-One (*:1) | Single | **Active** |
| `vw_FactSales` | `GeographyKey` | `DimGeography` | `GeographyKey` | Many-to-One (*:1) | Single | **Active** |
| `vw_FactSales` | `order_date` | `DimDate` | `FullDate` | Many-to-One (*:1) | Single | **Active** |

---

## 2. PBIX Artifact Inspection & State Summary

| Inspection Item | Observed Property | Verification Evidence |
|---|---|---|
| **Primary File Analyzed** | `D:\Datasets\BI_Projects\My Final Project.pbix` | File Size: **214,297,510 bytes (~214.3 MB)** |
| **PBIX Internal Engine** | Microsoft SQL Server Analysis Services Tabular | DataModel size: `213,005,371 bytes` (XPress9 compressed) |
| **Power BI Release** | October 2026 (`2026.10`) | Version: `2.159.229.0` |
| **Imported Tables** | `vw_FactSales`, `DimDate`, `DimGeography`, `DimProduct` | Verified via `DiagramLayout` nodes and lineage tags |
| **Registered Resources** | `Futuristic_Blue_Earth_Dashboar31639535737597213.png` | 1,491,565 bytes (Registered in `resourcePackages`) |
| **Visual Containers** | Canvas background image container | 1920×1080 canvas fit (`Stretch` mode) |
| **Secondary File Analyzed**| `D:\Datasets\BI_Projects\Main Work.pbix` | File Size: **241,601,819 bytes (~241.6 MB)** |
| **Main Work Visuals** | 2 pages ("Executive Overview" and "Page 1") | Contains slicers for Currency, Order Status, Category |

---

## 3. Modeling Best Practices Compliance

1. **Selective Table Import Verified:** Only `dbo.vw_FactSales`, `dbo.DimProduct`, `dbo.DimGeography`, and `dbo.DimDate` are imported. Neither the 49-column raw table nor wide clean tables are imported.
2. **Date Dimension Configuration:** `DimDate` is configured with `FullDate` as the unique date key. `YearMonth` is sorted by integer `YearMonthSort`.
3. **No Bi-Directional Filtering:** All relationships use single-direction filtering (Dimension filters Fact), avoiding ambiguous filter paths.
4. **Surrogate Keys:** Technical surrogate keys (`ProductKey`, `GeographyKey`, `record_id`) are kept for relationship integrity and hidden from report slicers.
