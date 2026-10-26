# Page 07 — Profitability Analysis (Currency-Gated)

**Title:** Global Business Analytics — Profitability & Financial Margin Analysis  
**Route / Navigation ID:** `page-07-profitability-analysis`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Global Profitability Analytics Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & P0 Multi-Currency Policy

**Purpose:** Provide CFOs, financial controllers, and commercial managers with deep profitability analysis (gross revenue, cost of goods, net profit, and profit margin %) while strictly adhering to financial reporting integrity.

> [!IMPORTANT]
> **CURRENCY GATE SPECIFICATION:**  
> Because the dataset contains 42 local currencies, **all monetary visuals on this page require a single currency in the active filter context.**  
> - When `DimGeography[currency]` has exactly 1 value (e.g., `USD`, `EUR`, `CHF`), visuals render full financial metrics.  
> - When multiple currencies are selected (unfiltered global view), all financial cards return `BLANK()` and display the dynamic banner:  
>   `"⚠ Multi-currency context active (42 currencies). Select a single currency or country to view financial figures."`

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `gate-01` | Dynamic Card | Active Currency Notice | `_Measures[Currency Guardrail Notice]` | Dynamic alert text |
| `kpi-01` | Card | Net Revenue | `_Measures[Revenue (Single Currency Only)]` | Dynamic format with currency code |
| `kpi-02` | Card | Total Cost | `_Measures[Cost (Single Currency Only)]` | Dynamic format with currency code |
| `kpi-03` | Card | Net Profit | `_Measures[Profit (Single Currency Only)]` | Font color: `#16A36A` |
| `kpi-04` | Card | Profit Margin | `_Measures[Profit Margin (Single Currency Only)]` | Format: `0.00%` |
| `chart-01`| Waterfall Chart | Revenue to Profit Bridge | Category: Breakdown (`Revenue`, `Cost`, `Profit`), Values: `[Profit (Single Currency Only)]` | Standard accounting colors |
| `chart-02`| Bar Chart | Profit Margin by Product | Y: `DimProduct[product_name]`, X: `[Profit Margin (Single Currency Only)]` | Target reference line at 30% |
| `chart-03`| Scatter Plot | Revenue vs. Profit by Channel | X: `[Revenue (Single Currency Only)]`, Y: `[Profit (Single Currency Only)]`, Details: `vw_FactSales[sales_channel]` | Bubble size: `[Total Orders]` |
| `table-01`| Matrix | Product Profitability P&L | Rows: `DimProduct[product_category]`, `product_name`, Values: `[Revenue (Single Currency Only)]`, `[Cost (Single Currency Only)]`, `[Profit (Single Currency Only)]`, `[Profit Margin (Single Currency Only)]` | Formatted financial matrix |
| `slicer-01`| Slicer (P0) | Select Currency | `DimGeography[currency]` | Single-select radio button list (Default: `USD`) |
| `slicer-02`| Slicer | Country | `DimGeography[country]` | Dropdown (filtered by selected currency) |
| `slicer-03`| Slicer | Product Category | `DimProduct[product_category]` | Dropdown |
