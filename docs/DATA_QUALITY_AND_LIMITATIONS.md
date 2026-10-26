# Data Quality, Known Generator Defects & Limitations

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Author:** Datta Sable (https://dattasable.com)  
**Verification Date:** 2026-10-26  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Executive Summary

A defining principle of this enterprise portfolio is absolute technical truthfulness. While many portfolio projects overlook or gloss over synthetic generator anomalies, this project documents and systematically mitigates all known synthetic defects through rigorous SQL transformation and DAX modeling safeguards.

---

## 2. Identified Generator Defects & Engineering Remediations

### Defect 1: Multi-Currency Heterogeneity (P0 Guardrail)
- **Defect Description:** The source dataset spans 50 countries and **42 distinct local currency codes**. The monetary columns (`revenue`, `cost`, `profit`, `tax_amount`, `unit_price`) represent amounts denominated in their respective local currencies.
- **Data Engineering Discovery:** An unfiltered SQL sum yields `18,720,460,798.92` for revenue. This number is an arithmetic sum of mixed currencies (e.g., USD + JPY + INR + EUR) and has **no economic validity**.
- **Remediation:**
  1. The reporting view preserves `currency` as a mandatory column.
  2. All monetary DAX measures enforce `HASONEVALUE(DimGeography[currency])`.
  3. When multiple currencies are in context, monetary KPI cards display `BLANK()` and show a dynamic instructional banner.
  4. Global operational dashboards focus strictly on non-monetary metrics (Orders, Units Sold, Completion Rates).

### Defect 2: Customer Identifier Collision (P0 Guardrail)
- **Defect Description:** The synthetic CSV contains `950,127` distinct `customer_id` strings. However, auditing revealed:
  - **801,192** customer IDs are associated with multiple distinct customer names.
  - **796,571** customer IDs are associated with multiple distinct countries.
  - E.g., `CUST-0659044` appears across 13 countries and 14 distinct person names.
- **Remediation:**
  1. **Unique customer counts, customer retention rates, repeat buyer percentages, and Customer Lifetime Value (CLV) are formally excluded from this portfolio.**
  2. Page 04 is designated as **"Customer & Channel Behavioral Insights"**, focusing strictly on transaction-level channel adoption, basket size distributions, and payment methods.
  3. A dedicated data quality panel in Page 04 explicitly discloses sample collision records to technical reviewers.

### Defect 3: Original Product Identifier Collision
- **Defect Description:** The 15 distinct source `product_id` strings (e.g. `PROD-0001` through `PROD-0015`) map arbitrarily across all 15 product names (e.g., `PROD-0006` is assigned to Monitor, Laptop, T-Shirt, Coffee Pack, etc.).
- **Remediation:**
  1. SQL analysis verified that the 3-way combination `(product_name, product_category, brand)` is **100% stable and unique** across all 3,000,000 transactions.
  2. `dbo.DimProduct` was created using an auto-incrementing surrogate primary key `ProductKey`.
  3. Clean fact records join to `DimProduct` on `(product_name, product_category, brand)` to populate `ProductKey`.
  4. The original unreliable `product_id` is excluded from all relationships and reports.

### Defect 4: Synthetic Timeline & Future-Dated Records
- **Defect Description:** The raw synthetic CSV dates ran from `2022-01-01` through `2026-12-31`, with deliveries extending into 2027. Presenting future-dated transactions as completed historical events violates BI reporting standards.
- **Remediation:**
  1. A one-time **81-day backward shift** was applied exclusively to the clean physical table `dbo.world_business_data_3m_clean`.
  2. Resulting order dates span **2021-10-12 to 2026-10-11** (1,826 distinct days), with deliveries extending through 2026-10-25.
  3. Strict idempotency guards in `sql/04_delivery_dates.sql` inspect `MAX(order_date)` and prevent accidental re-execution.
  4. The raw source table `dbo.world_business_data_3m` remains un-shifted and immutable.

### Defect 5: Delivery Lifecycle Semantics
- **Defect Description:** In raw data, `delivery_date` was populated for all rows regardless of order status.
- **Remediation:**
  1. Split into `planned_delivery_date` (populated for all orders) and `actual_delivery_date` (populated ONLY when `order_status = 'Delivered'`).
  2. Verified that 100% of non-delivered orders (`Shipped`, `Processing`, `Cancelled`) have a `NULL` actual delivery date.
  3. Verified that 0 deliveries precede the order date.

### Defect 6: Predictive Forecast Accuracy Claims
- **Defect Description:** UI design mockups illustrate hypothetical future projections with decorative accuracy percentages (e.g., "98.4% Accuracy").
- **Remediation:**
  1. No trained machine learning model has yet been deployed or backtested.
  2. Page 09 is labeled honestly as **"Forecast Analysis & Demand Projections (Roadmap Phase)"**.
  3. Displays verified historical time-series velocity and moving averages while detailing the formal ML forecasting roadmap.
