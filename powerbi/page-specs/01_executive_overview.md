# Page 01 — Executive Overview

**Title:** Global Business Analytics — Executive Overview  
**Route / Navigation ID:** `page-01-executive-overview`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar (345 px width), 82% Main Dashboard Canvas (1575 px width)  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Executive Business Analytics Dashboard.png`  
**Data Freshness Baseline:** As of 2026-10-25  
**Active Reporting Period:** 2021-10-12 to 2026-10-11 (1,826 active order days)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & Acceptance Criteria

**Purpose:** Provide C-suite executives and senior operations leaders with a reliable, verified operational snapshot of the global 3-million-order synthetic transaction portfolio.

**Acceptance Criteria:**
- Unfiltered `Total Orders` card displays **3,000,000**.
- Unfiltered `Total Units Sold` card displays **~16.5M** (`16,498,920`).
- Unfiltered `Average Units Per Order` displays **5.50**.
- **Financial Currency Warning:** Clear banner indicating monetary metrics require a single currency context across 42 currencies.
- Cross-filtering by Country, Product Category, Sales Channel, and Order Status updates all KPI cards and charts in unison.

---

## 2. Page Canvas Layout & Component Hierarchy

```text
+-------------------------------------------------------------------------------------------------------------------+
| SIDEBAR (345px) | HEADER ROW: Title: "Executive Overview" | Data Freshness: 2026-10-25 | Period: 2021-10 to 2026-10  |
| - Logo & Brand  +-------------------------------------------------------------------------------------------------+
| - Navigation (9)| WARNING BANNER: "Multi-Currency Portfolio (42 Currencies) — Headline KPIs Reflect Operational Units"|
|   1. Executive* +-------------------------------------------------------------------------------------------------+
|   2. Sales      | KPI ROW:                                                                                        |
|   3. Product    | [ Total Orders: 3,000,000 ] [ Total Units Sold: 16.5M ] [ Avg Units/Order: 5.50 ] [ Countries: 50 ]|
|   4. Channel    +-------------------------------------------------------------------------------------------------+
|   5. Region     | CHART ROW 1 (Middle):                                                                           |
|   6. Orders     | [ Orders Trend by Month (Area/Line) ]                 [ Order Status Breakdown (Donut) ]        |
|   7. Profit     | (DimDate[YearMonth] vs [Total Orders])                 (Delivered 65%, Shipped 15%, etc.)       |
|   8. Exceptions +-------------------------------------------------------------------------------------------------+
|   9. Forecast   | CHART ROW 2 (Bottom):                                                                           |
| - 3D Earth Globe| [ Top Categories by Volume (Bar Chart) ]              [ Sales Channel Mix (Horizontal Bar) ]    |
|                 | (Electronics, Clothing, Home, Books...)                (Online, Retail, Partner, Direct)        |
+-------------------------------------------------------------------------------------------------------------------+
```

---

## 3. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `header-01` | Header Card | Data Freshness & Period | Text: `"Data Freshness: 2026-10-25 | Active Period: 2021-10-12 to 2026-10-11"` | 10pt Segoe UI, Slate Gray (`#64748B`) |
| `warn-01`   | Alert Banner| Currency Notice | Text: `"⚠ 42 local currencies active globally. Monetary metrics are isolated to single-currency reports."` | Amber outline (`#E18A24`) |
| `kpi-01` | Card | Total Orders | `_Measures[Total Orders]` | Format: `#,##0` (3.0M display units) |
| `kpi-02` | Card | Total Units Sold | `_Measures[Total Units Sold]` | Format: `#,##0` (16.5M display units) |
| `kpi-03` | Card | Average Units Per Order | `_Measures[Average Units Per Order]` | Format: `#,##0.00` (5.50) |
| `kpi-04` | Card | Active Countries | `_Measures[Active Countries]` | Format: `#,##0` (50) |
| `chart-01`| Area Chart | Monthly Order Volume Trend | X: `DimDate[YearMonth]`, Y: `[Total Orders]` | Line: `#1769E0`, Gradient Fill: 40% |
| `chart-02`| Donut Chart| Fulfillment Order Status | Legend: `vw_FactSales[order_status]`, Values: `[Total Orders]` | Delivered (`#16A36A`), Shipped (`#2588F5`), Processing (`#E18A24`), Cancelled (`#D94B5C`) |
| `chart-03`| Stacked Bar | Orders by Product Category | Y: `DimProduct[product_category]`, X: `[Total Orders]` | Bar color: `#1769E0`, Data labels on |
| `chart-04`| Bar Chart | Sales Channel Contribution | Y: `vw_FactSales[sales_channel]`, X: `[Total Orders]` | Bar color: `#0A2854` |
| `slicer-01`| Slicer | Country | `DimGeography[country]` | Dropdown, multi-select with "Select All" |
| `slicer-02`| Slicer | Product Category | `DimProduct[product_category]` | Dropdown |
| `slicer-03`| Slicer | Order Status | `vw_FactSales[order_status]` | Dropdown |
| `slicer-04`| Slicer | Calendar Date Range | `DimDate[FullDate]` | Between date slider |
