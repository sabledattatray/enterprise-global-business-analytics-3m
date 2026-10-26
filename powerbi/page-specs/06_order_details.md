# Page 06 — Order Details (Drill-Through Grid)

**Title:** Global Business Analytics — Transaction Ledger & Order Details  
**Route / Navigation ID:** `page-06-order-details`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Global Order Analytics Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Business Purpose & Acceptance Criteria

**Purpose:** Provide operational auditors, supply chain coordinators, and financial reviewers with a drill-down grid to search, filter, and inspect specific transaction lines, fulfillment dates, and order statuses.

**Acceptance Criteria:**
- Primary grid visual is paginated, searchable, and sortable across all 19 reporting columns of `dbo.vw_FactSales`.
- Handles NULL values correctly: `actual_delivery_date` displays as blank/hyphen for non-delivered orders without throwing errors.
- Delivery lead time is calculated exclusively for delivered orders.
- Reconciles filtered card totals with individual grid lines.

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `search-01`| Search Bar  | Order ID Search Filter | Text filter on `vw_FactSales[order_id]` | Instant substring search |
| `kpi-01` | Card | Filtered Orders | `_Measures[Total Orders]` | Dynamic filtered count |
| `kpi-02` | Card | Filtered Units | `_Measures[Total Units Sold]` | Dynamic filtered units |
| `kpi-03` | Card | Delivery Completion | `_Measures[Delivery Completion Rate]` | Percentage |
| `kpi-04` | Card | Cancellation Rate | `_Measures[Cancellation Rate]` | Percentage |
| `grid-01` | Table Visual | Transaction Audit Ledger | Columns: `vw_FactSales[order_id]`, `order_date`, `DimProduct[product_name]`, `DimGeography[country]`, `vw_FactSales[sales_channel]`, `vw_FactSales[quantity]`, `vw_FactSales[currency]`, `vw_FactSales[revenue]`, `vw_FactSales[order_status]`, `vw_FactSales[planned_delivery_date]`, `vw_FactSales[actual_delivery_date]` | Font: 9pt Segoe UI, alternating white/light-blue rows (`#F7FAFE`), column headers bold |
| `slicer-01`| Slicer | Order Status | `vw_FactSales[order_status]` | Dropdown |
| `slicer-02`| Slicer | Payment Status | `vw_FactSales[payment_status]` | Dropdown |
| `slicer-03`| Slicer | Country | `DimGeography[country]` | Searchable dropdown |
| `slicer-04`| Slicer | Product Name | `DimProduct[product_name]` | Searchable dropdown |
| `slicer-05`| Slicer | Order Date | `DimDate[FullDate]` | Date picker slider |
