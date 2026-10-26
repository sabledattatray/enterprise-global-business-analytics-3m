# Page 08 — Return Analysis & Order Exceptions

**Title:** Global Business Analytics — Order Exceptions & Cancellations  
**Route / Navigation ID:** `page-08-return-analysis`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Return Analysis Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & Data Availability Gate

**Purpose:** Track fulfillment anomalies, order cancellations, failed transactions, and supply chain exceptions across the 3-million-order dataset.

> [!CAUTION]
> **DATA AVAILABILITY GATE & TRUTHFULNESS STANDARD:**  
> The verified data model contains **order cancellations** (`order_status = 'Cancelled'`, exactly **150,324 rows**) and **payment failures** (`payment_status = 'Failed'`), but **does not contain physical return shipment scans or cash refund transaction ledgers.**  
> - In strict compliance with PRD Section 8.8 and PRD v1.1, this page is accurately titled **"Order Exceptions & Cancellations"**.  
> - **Cancelled orders are NOT relabeled as returns**, and **no fabricated return reasons or refund dollar totals are displayed.**

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `kpi-01` | Card | Cancelled Orders | `_Measures[Cancelled Orders]` | Baseline: 150,324 orders |
| `kpi-02` | Card | Cancellation Rate | `_Measures[Cancellation Rate]` | Baseline: 5.01% (Target < 6.0%) |
| `kpi-03` | Card | Delivered Orders | `_Measures[Delivered Orders]` | Baseline: 1,950,380 orders |
| `kpi-04` | Card | Completion Rate | `_Measures[Delivery Completion Rate]` | Baseline: 65.01% |
| `chart-01`| Line Chart | Cancellation Rate Trend by Month | X: `DimDate[YearMonth]`, Y: `[Cancellation Rate]` | Highlights monthly spikes with 5% target reference line |
| `chart-02`| Bar Chart | Cancellation Rate by Continent / Region | Y: `DimGeography[continent]`, X: `[Cancellation Rate]` | Regional outlier detection |
| `chart-03`| Bar Chart | Cancellation Rate by Sales Channel | Y: `vw_FactSales[sales_channel]`, X: `[Cancellation Rate]` | Channel comparison |
| `chart-04`| Table Visual | Product Exception Breakdown | Columns: `DimProduct[product_name]`, `[Total Orders]`, `[Cancelled Orders]`, `[Cancellation Rate]`, `[Delivery Completion Rate]` | Data bars on Cancellation Rate |
| `slicer-01`| Slicer | Product Category | `DimProduct[product_category]` | Dropdown |
| `slicer-02`| Slicer | Sales Channel | `vw_FactSales[sales_channel]` | Dropdown |
| `slicer-03`| Slicer | Region / Continent | `DimGeography[continent]` | Dropdown |
| `slicer-04`| Slicer | Year / Period | `DimDate[Year]` | Tile buttons |
