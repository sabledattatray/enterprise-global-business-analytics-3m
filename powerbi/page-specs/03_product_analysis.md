# Page 03 — Product Analysis

**Title:** Global Business Analytics — Product & Catalog Analysis  
**Route / Navigation ID:** `page-03-product-analysis`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Product Analysis Dashboard Overview.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & Acceptance Criteria

**Purpose:** Provide deep-dive catalog analytics across the 15 validated enterprise products, evaluating category velocity, brand volume, basket density, and fulfillment performance.

**Acceptance Criteria:**
- Exposes exactly the **15 validated product entities** from `dbo.DimProduct`.
- **Zero reliance on source `product_id`**, which suffered from cross-product mapping collisions.
- Includes **Category Volume Share (%)** and **Average Units Per Order** for each product entity.

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `kpi-01` | Card | Catalog Products | `_Measures[Active Products Sold]` | Target: 15 products |
| `kpi-02` | Card | Total Orders | `_Measures[Total Orders]` | Format: `#,##0` |
| `kpi-03` | Card | Total Units Sold | `_Measures[Total Units Sold]` | Format: `#,##0` |
| `kpi-04` | Card | Average Units / Order | `_Measures[Average Units Per Order]` | Format: `#,##0.00` |
| `chart-01`| Bar Chart | Product Volume Leaderboard | Y: `DimProduct[product_name]`, X: `[Total Orders]`, Data Labels: On | Bar color: `#1769E0` |
| `chart-02`| Donut Chart| Category Share (% of Orders) | Legend: `DimProduct[product_category]`, Values: `[Total Orders]` | Percentage share labels |
| `chart-03`| 100% Stacked Bar | Order Status by Product | Y: `DimProduct[product_name]`, X: `[Total Orders]`, Legend: `order_status` | Highlights cancellation outliers |
| `chart-04`| Table Visual | Product Master Detail | Columns: `DimProduct[product_name]`, `brand`, `product_category`, `[Total Orders]`, `[Total Units Sold]`, `[Average Units Per Order]`, `[Delivery Completion Rate]`, `[Cancellation Rate]` | Auto-sort by Total Orders |
| `slicer-01`| Slicer | Product Category | `DimProduct[product_category]` | Dropdown |
| `slicer-02`| Slicer | Brand | `DimProduct[brand]` | Dropdown |
| `slicer-03`| Slicer | Country | `DimGeography[country]` | Dropdown |
