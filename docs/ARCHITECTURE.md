# System Architecture & Technical Flow

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Target Architecture:** End-to-End Enterprise Data Pipeline (CSV → SQL Server 2022 → Star Schema → Power BI Desktop)  
**Author:** Datta Sable (https://dattasable.com)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. High-Level Architecture Diagram

```mermaid
flowchart TD
    subgraph S1["1. Raw Ingestion Layer"]
        CSV["Synthetic Raw CSV (1.30 GB)<br/>3,000,000 Rows / 49 Columns<br/>(Hosted on Google Drive)"]
        RAW_TBL["dbo.world_business_data_3m<br/>(Heap Table, All 49 Columns VARCHAR(50))"]
        CSV -->|Bulk Insert / SSIS| RAW_TBL
    end

    subgraph S2["2. Staging & Cleaning Transformation"]
        VIEW_STAGE["dbo.vw_Enterprise_Business_Analytics<br/>(TRY_CONVERT Type Casting, Clean Strings)"]
        CLEAN_TBL["dbo.world_business_data_3m_clean<br/>(3,000,000 Materialized Rows, Typed Schema)"]
        DATES["Delivery Date Normalization<br/>(Planned vs Actual Dates + 81-Day Shift)"]
        RAW_TBL --> VIEW_STAGE
        VIEW_STAGE --> CLEAN_TBL
        CLEAN_TBL --> DATES
    end

    subgraph S3["3. Dimensional Modeling Layer"]
        DIM_P["dbo.DimProduct<br/>(15 Validated Products, Surrogate Key)"]
        DIM_G["dbo.DimGeography<br/>(50 Countries, 42 Currencies)"]
        DIM_D["dbo.DimDate<br/>(2,191 Calendar Days, 2021-01-01 to 2026-12-31)"]
        FK["Referential Integrity Enforcement<br/>(Enabled & Trusted Foreign Keys)"]
        DATES --> DIM_P
        DATES --> DIM_G
        DATES --> DIM_D
        DIM_P --> FK
        DIM_G --> FK
        DIM_D --> FK
    end

    subgraph S4["4. Reporting View Layer"]
        FACT_VIEW["dbo.vw_FactSales<br/>(19 Core Reporting Columns)"]
        FK --> FACT_VIEW
    end

    subgraph S5["5. Semantic Model & Power BI Desktop"]
        PBI_MODEL["Power BI Tabular Model (Import Mode)<br/>- 3 Active 1:* Single Filter Relationships<br/>- DimDate Marked as Date Table<br/>- P0 Multi-Currency Gated DAX Measures"]
        REPORTS["Nine-Page Executive Dashboard Suite<br/>1. Executive Overview    4. Customer Insights    7. Profitability<br/>2. Sales Performance    5. Region Analysis      8. Returns & Exceptions<br/>3. Product Analysis     6. Order Details        9. Forecast Roadmap"]
        FACT_VIEW --> PBI_MODEL
        PBI_MODEL --> REPORTS
    end
```

---

## 2. Component Descriptions

### Ingestion Layer (`dbo.world_business_data_3m`)
- Acts as the immutable landing table.
- All 49 columns are stored as `VARCHAR(50)` to preserve raw source values exactly as generated without truncation or coercion errors.
- Never updated or mutated in place.

### Cleaning & Transformation Layer (`dbo.world_business_data_3m_clean`)
- Converts string values into strongly typed SQL Server data types (`BIGINT`, `DATE`, `DECIMAL(18,2)`, `DECIMAL(5,2)`, `INT`, `BIT`).
- Populates `planned_delivery_date` across all records and `actual_delivery_date` exclusively for delivered orders.
- Applies the synthetic 81-day shift to align transactions with the demonstration cutoff date (2026-10-25).

### Dimensional Layer (`DimProduct`, `DimGeography`, `DimDate`)
- **Product Dimension:** Bypasses unreliable source `product_id` and establishes 15 clean, 1-to-1 unique product entities joined on `(product_name, product_category, brand)`.
- **Geography Dimension:** Maps 50 countries, 6 continents, and 42 local currency codes.
- **Date Dimension:** Fully materialized calendar table spanning 6 calendar years (2,191 dates) with fiscal quarters, year-month sort keys, and weekend flags.

### Reporting Layer (`dbo.vw_FactSales`)
- A narrow, high-performance view exposing only the 19 columns required for reporting.
- Avoids duplicating 3 million physical rows in SQL Server storage while reducing Power BI Import memory footprint.

### Presentation Layer (Power BI Desktop)
- Star schema with single-direction dimension-to-fact relationships.
- DAX measure table `_Measures` enforcing currency safety via `HASONEVALUE`.
- Corporate light design theme (`#061B3A`, `#1769E0`, `#F7FAFE`) with 3D digital earth globe branding.
