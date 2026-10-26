# Page 02 — Sales Performance

**Title:** Global Business Analytics — Sales & Channel Performance  
**Route / Navigation ID:** `page-02-sales-performance`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Global Sales Performance Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & Acceptance Criteria

**Purpose:** Analyze order pacing, volume momentum, sales channel effectiveness, and customer payment methods over time across the 3-million-transaction portfolio.

**Acceptance Criteria:**
- **Explicit Metric Separation:** Visuals and titles clearly distinguish **Order Volume Growth** (commercial transactions) from **Monetary Sales Growth** (currency-gated local revenues).
- Chronological time series sorts correctly using `DimDate[YearMonthSort]`.
- Period-over-period comparisons (`Orders MoM % Change`, `Orders YoY % Change`) calculate properly with no division-by-zero errors.
- Payment status breakdown reconciles with confirmed source distributions (Paid, Pending, Failed).

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `kpi-01` | Card | Total Orders | `_Measures[Total Orders]` | Format: `#,##0` |
| `kpi-02` | Card | Total Units Sold | `_Measures[Total Units Sold]` | Format: `#,##0` |
| `kpi-03` | Card | Order MoM Growth Rate | `_Measures[Orders MoM % Change]` | Color: Green (`#16A36A`) if >0, Red (`#D94B5C`) if <0 |
| `kpi-04` | Card | Order YoY Growth Rate | `_Measures[Orders YoY % Change]` | Dynamic variance indicator |
| `chart-01`| Line & Clustered Column | Order Volume & Period Growth | X: `DimDate[YearMonth]`, Col: `[Total Orders]`, Line: `[Orders MoM % Change]` | Double Y-axis, Column: `#1769E0`, Line: `#E18A24` |
| `chart-02`| Clustered Bar | Volume by Sales Channel | Y: `vw_FactSales[sales_channel]`, X: `[Total Orders]`, Tooltip: `[Total Units Sold]` | Sorted descending by orders |
| `chart-03`| Treemap | Volume by Payment Status | Category: `vw_FactSales[payment_status]`, Values: `[Total Orders]` | Distinct theme colors |
| `chart-04`| Matrix Table | Channel & Category Cross-Matrix | Rows: `vw_FactSales[sales_channel]`, Cols: `DimProduct[product_category]`, Values: `[Total Orders]` | Heatmap conditional formatting on cells |
| `slicer-01`| Slicer | Year | `DimDate[Year]` | Tile slicer (2021, 2022, 2023, 2024, 2025, 2026) |
| `slicer-02`| Slicer | Sales Channel | `vw_FactSales[sales_channel]` | Dropdown |
| `slicer-03`| Slicer | Payment Status | `vw_FactSales[payment_status]` | Dropdown |
