# Page 05 — Region Analysis

**Title:** Global Business Analytics — Geographic & Regional Analysis  
**Route / Navigation ID:** `page-05-region-analysis`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Global Region Analysis Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & Acceptance Criteria

**Purpose:** Provide geographic intelligence across all 50 synthetic countries, 6 continents, and 42 local currency environments.

**Acceptance Criteria:**
- Verifies all **50 countries** mapped via `dbo.DimGeography`.
- Displays regional order volume, physical units sold, and country-level currency indicators.
- Includes an **Accessible Table Fallback** alongside the geographic map to ensure full WCAG accessibility.
- Monetary values at the country level display the specific domestic currency code (`DimGeography[currency]`).

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `kpi-01` | Card | Global Countries | `_Measures[Active Countries]` | Target: 50 countries |
| `kpi-02` | Card | Distinct Currencies | Distinct count of `DimGeography[currency]` | Target: 42 currencies |
| `kpi-03` | Card | Total Orders | `_Measures[Total Orders]` | Format: `#,##0` |
| `kpi-04` | Card | Total Units Sold | `_Measures[Total Units Sold]` | Format: `#,##0` |
| `map-01`  | Map / Filled Map | Global Order Distribution | Location: `DimGeography[country]`, Bubble Size: `[Total Orders]`, Tooltip: `DimGeography[continent]`, `DimGeography[currency]`, `[Total Units Sold]` | Bubble color: `#2588F5` |
| `chart-01`| Bar Chart | Orders by Continent | Y: `DimGeography[continent]`, X: `[Total Orders]` | Data labels on |
| `chart-02`| Bar Chart | Top 10 Countries by Orders & Units | Y: `DimGeography[country]`, X: `[Total Orders]`, Tooltip: `[Total Units Sold]` | Top N filter = 10 |
| `table-01`| Table (Fallback) | Regional Master Ledger | Columns: `DimGeography[continent]`, `DimGeography[country]`, `DimGeography[currency]`, `[Total Orders]`, `[Total Units Sold]`, `[Average Units Per Order]` | Alternating row shading |
| `slicer-01`| Slicer | Continent | `DimGeography[continent]` | Multi-select buttons |
| `slicer-02`| Slicer | Currency Code | `DimGeography[currency]` | Dropdown |
| `slicer-03`| Slicer | Country | `DimGeography[country]` | Dropdown |
