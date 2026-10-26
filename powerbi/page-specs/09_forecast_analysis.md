# Page 09 — Trend Analysis & Forecast Roadmap

**Title:** Global Business Analytics — Trend Analysis & Predictive Forecast Roadmap  
**Former Title:** Forecast Analysis (Renamed per PRD v1.1 to distinguish historical moving averages from trained out-of-sample ML forecasts)  
**Route / Navigation ID:** `page-09-trend-analysis-forecast-roadmap`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Futuristic Forecast Analytics Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Model Readiness Gate & Scientific Integrity

> [!IMPORTANT]
> **PREDICTIVE MODEL READINESS STANDARD (PRD v1.1):**  
> UI design mockups illustrate hypothetical forward projections and decorative accuracy percentages. In strict adherence to enterprise data governance:  
> - **No trained machine learning forecasting model has yet been deployed or backtested against out-of-time holdouts.**  
> - **Decorative accuracy statistics (e.g. "98.4% Accuracy") are explicitly excluded from production reporting.**  
> - This page provides **verified 5-year historical trend decomposition, moving averages, and seasonal pattern baselines**, accompanied by the formal data science forecasting roadmap required for future deployment.

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `status-01`| Banner Callout | Model Readiness Status | `"Forecasting Pipeline: Historical Baseline & Trend Decomposition Phase (Production ML in Development)"` | Badge: `#0A2854`, Background: `#EAF4FF` |
| `kpi-01` | Card | Historical Order Base | `_Measures[Total Orders]` | 3,000,000 orders |
| `kpi-02` | Card | Historical Units Base | `_Measures[Total Units Sold]` | ~16.5M units |
| `kpi-03` | Card | Active Order Days | Count of distinct order dates in range | 1,826 days |
| `kpi-04` | Card | Daily Order Velocity | `DIVIDE([Total Orders], 1826)` | ~1,643 orders/day |
| `chart-01`| Line Chart | Historical Demand Velocity & Moving Average | X: `DimDate[FullDate]`, Y: `[Total Orders]`, 30-Day Moving Average | Line: `#1769E0`, Trendline on |
| `chart-02`| Column Chart | Day-of-Week Seasonality Pattern | X: `DimDate[DayOfWeekName]`, Y: `[Total Orders]` | Sorted Monday → Sunday |
| `chart-03`| Area Chart | Monthly Category Volume Seasonality | X: `DimDate[MonthNumber]`, Y: `[Total Units Sold]`, Legend: `DimProduct[product_category]` | Demonstrates annual seasonality |
| `roadmap-01`| Card / Panel | Production ML Roadmap | Outlines planned Prophet / LightGBM / SARIMAX pipeline, 12-month horizon, MAE/sMAPE backtesting, and normalized FX prerequisites | Structured text panel |
| `slicer-01`| Slicer | Product Category | `DimProduct[product_category]` | Dropdown |
| `slicer-02`| Slicer | Sales Channel | `vw_FactSales[sales_channel]` | Dropdown |
| `slicer-03`| Slicer | Year | `DimDate[Year]` | Tile buttons |
