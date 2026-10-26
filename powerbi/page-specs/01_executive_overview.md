# Page 01 — Executive Overview

**Title:** Global Business Analytics — Executive Overview  
**Route / Navigation ID:** `page-01-executive-overview`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar (345 px width), 82% Main Dashboard Canvas (1575 px width)  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Executive Business Analytics Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & Acceptance Criteria

**Purpose:** Provide C-suite executives and senior operations leaders with a reliable, verified snapshot of the global 3-million-order synthetic transaction portfolio.

**Acceptance Criteria:**
- Unfiltered `Total Orders` card displays **3,000,000**.
- Unfiltered `Total Units Sold` card displays **~16.5M** (`16,498,920`).
- Unfiltered `Average Units Per Order` displays **5.50**.
- Cross-filtering by Country, Product Category, Sales Channel, and Order Status updates all KPI cards and charts in unison.
- Monetary totals are hidden or gated with `HASONEVALUE(DimGeography[currency])` to prevent invalid cross-currency addition.

---

## 2. Page Canvas Layout & Component Hierarchy

```text
+-------------------------------------------------------------------------------------------------------------------+
| SIDEBAR (345px) | HEADER ROW: Title: "Executive Overview" | Subtitle | Date Range Slicer | Reset Filters Button  |
| - Logo & Brand  +-------------------------------------------------------------------------------------------------+
| - Navigation (9)| KPI ROW:                                                                                        |
|   1. Executive* | [ Total Orders: 3,000,000 ] [ Total Units Sold: 16.5M ] [ Avg Units/Order: 5.50 ] [ Countries: 50 ]|
|   2. Sales      +-------------------------------------------------------------------------------------------------+
|   3. Product    | CHART ROW 1 (Middle):                                                                           |
|   4. Customer   | [ Orders Trend by Month (Area/Line) ]                 [ Order Status Breakdown (Donut) ]        |
|   5. Region     | (DimDate[YearMonth] vs [Total Orders])                 (Delivered 65%, Shipped 15%, etc.)       |
|   6. Orders     +-------------------------------------------------------------------------------------------------+
|   7. Profit     | CHART ROW 2 (Bottom):                                                                           |
|   8. Returns    | [ Top Categories by Volume (Bar Chart) ]              [ Sales Channel Mix (Horizontal Bar) ]    |
|   9. Forecast   | (Electronics, Clothing, Home, Books...)                (Online, Retail, Partner, Direct)        |
| - 3D Earth Globe+-------------------------------------------------------------------------------------------------+
```

---

## 3. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
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

---

## 4. Accessibility & Interaction Notes

- All charts include descriptive tooltips showing measure name, exact unrounded integer, and percentage contribution.
- Tab order flows logically from Header Slicers → KPI Row (Left to Right) → Charts (Top to Bottom).
- High-contrast visual borders (`#DFE7F2`) guarantee readability over the soft gradient canvas.
