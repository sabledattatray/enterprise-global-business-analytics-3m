# Page 04 — Transaction & Channel Insights

**Title:** Global Business Analytics — Transaction & Channel Insights  
**Former Title:** Customer Insights (Renamed per PRD v1.1 to avoid implying verified individual identities)  
**Route / Navigation ID:** `page-04-transaction-channel-insights`  
**Canvas Dimensions:** 1920 × 1080 px (16:9 widescreen)  
**Layout Grid:** 18% Left Persistent Sidebar, 82% Main Dashboard Canvas  
**Visual Theme:** `powerbi/theme/enterprise-light-theme.json`  
**Background Asset:** `assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`  
**Reference Mockup:** `assets/screenshots/Customer Insights Analytics Dashboard.png`  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. P0 Customer Identity Policy & Ethical Disclosure

> [!WARNING]
> **SYNTHETIC DATA QUALITY NOTICE:**  
> The synthetic data generator created severe entity-mapping collisions in `customer_id`. As audited in SQL (`sys.tables` and `sys.columns`), single customer IDs map to up to 14 distinct customer names and 13 distinct countries. Consequently, **unique customer counts, customer retention rates, repeat buyer percentages, and Customer Lifetime Value (CLV) are mathematically unreliable and are deliberately excluded.**

This report page strictly evaluates **transaction-level behavioral segments** (sales channel preferences, payment status adoption, geographic distribution of orders, and basket sizes) without attributing them to individual humans.

---

## 2. Visual Catalog & Binding Specifications

| Container ID | Visual Type | Title / Label | Data Fields / Measures | Formatting & Thresholds |
|---|---|---|---|---|
| `notice-01`| Text Box / Callout | Data Quality Disclaimer | Prominent banner stating synthetic customer-ID limitations | Border: `#E18A24`, Background: `#FFFBEB`, Font: `#92400E` |
| `kpi-01` | Card | Total Transactions | `_Measures[Total Transactions]` | Format: `#,##0` (3,000,000) |
| `kpi-02` | Card | Active Sales Channels | Count of channels (`Online`, `Direct`, `Partner`, `Retail`) | Format: `#,##0` (4) |
| `kpi-03` | Card | Avg Basket Units | `_Measures[Average Units Per Order]` | Format: `#,##0.00` |
| `chart-01`| Clustered Bar | Transaction Volume by Channel | Y: `vw_FactSales[sales_channel]`, X: `[Total Transactions]` | High-contrast corporate blue |
| `chart-02`| Donut Chart| Payment Status Distribution | Legend: `vw_FactSales[payment_status]`, Values: `[Total Transactions]` | Paid, Pending, Failed |
| `chart-03`| Matrix Table | Channel vs. Product Category Mix | Rows: `vw_FactSales[sales_channel]`, Columns: `DimProduct[product_category]`, Values: `[Total Orders]` | Heatmap shading |
| `panel-01`| Table Visual | Synthetic Collision Summary | Displays sample multi-country collisions audited from SQL (e.g., `CUST-0659044`) | Discloses data engineering findings to reviewers |
| `slicer-01`| Slicer | Sales Channel | `vw_FactSales[sales_channel]` | Dropdown |
| `slicer-02`| Slicer | Payment Status | `vw_FactSales[payment_status]` | Dropdown |
| `slicer-03`| Slicer | Continent | `DimGeography[continent]` | Dropdown |
