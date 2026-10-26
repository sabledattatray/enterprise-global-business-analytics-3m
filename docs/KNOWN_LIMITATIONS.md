# Known Technical Limitations & Analytical Boundaries

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Audit Standard:** PRD v1.1 Mandatory Task 14  
**Author:** Datta Sable (https://dattasable.com)  
**Date:** 2026-10-26  

---

## 1. Transparency Principle

A core strength of this portfolio is that it openly acknowledges the boundaries of synthetic data and current implementation phases. This document catalogs all known limitations, explaining why they exist and how they are handled.

---

## 2. Catalog of Known Limitations

### Limitation 1: Multi-Currency Normalization (P0 Boundary)
- **Nature of Limitation:** The dataset contains 42 local currencies across 50 countries.
- **Analytical Impact:** Cross-currency monetary sums (e.g. global revenue, total global profit) cannot be displayed until a verified FX conversion model is implemented.
- **Handling:** Gated via `HASONEVALUE(DimGeography[currency])`. Users must select a single currency or country to view financial figures. Universal operational metrics (Orders, Units Sold) remain universally visible.

### Limitation 2: Synthetic Customer Identifier Collisions (P0 Boundary)
- **Nature of Limitation:** In the synthetic data generator, `801,192` customer IDs map to multiple names, and `796,571` map to multiple countries.
- **Analytical Impact:** Customer retention rates, repeat buyer percentages, churn rates, and Customer Lifetime Value (CLV) are mathematically unverified.
- **Handling:** Person-level customer metrics are deliberately excluded. Page 04 is titled **"Transaction & Channel Insights"**, evaluating transaction-level channel adoption and basket size distributions.

### Limitation 3: Synthetic Demonstration Date Shift
- **Nature of Limitation:** The raw synthetic CSV dates ran from `2022-01-01` to `2026-12-31`. Future-dated transactions would distort demo dashboards.
- **Analytical Impact:** An 81-day backward shift was applied to the clean table, resulting in transaction dates spanning `2021-10-12` to `2026-10-11`.
- **Handling:** Fully documented in `docs/SQL_RECONCILIATION_REPORT.md`. An idempotency guard prevents the shift from being executed a second time.

### Limitation 4: Order Cancellations vs. Physical Returns
- **Nature of Limitation:** The dataset tracks order cancellations (`order_status = 'Cancelled'`, 150,324 rows) and payment failures, but does not include physical return shipment scans or cash refunds.
- **Analytical Impact:** Return reasons and refund dollar amounts cannot be reported.
- **Handling:** Page 08 is titled **"Order Exceptions & Cancellations"**, focusing on cancellations and supply chain fulfillment failures rather than fabricated returns.

### Limitation 5: Forecasting Model Maturity
- **Nature of Limitation:** No trained machine learning model (e.g., Prophet, LightGBM, ARIMA) has been backtested or deployed in production.
- **Analytical Impact:** Future demand predictions and accuracy percentages shown in UI mockups are conceptual designs.
- **Handling:** Page 09 is titled **"Trend Analysis & Forecast Roadmap"**, providing historical moving-average trend decomposition while detailing the formal forecasting roadmap.

### Limitation 6: PBIX Report Page Completion Boundary
- **Nature of Limitation:** The Power BI file (`My Final Project.pbix`, 214 MB) contains the complete 4-table star schema, relationships, and registered background canvas.
- **Analytical Impact:** The 9 individual visual report pages currently exist as high-resolution mockups (`assets/screenshots/`), complete engineering specifications (`powerbi/page-specs/`), verified DAX measures (`powerbi/measures/`), and corporate theme tokens (`powerbi/theme/`).
- **Handling:** Transparently disclosed in `docs/TECHNICAL_AUDIT_REPORT.md` and `docs/POWERBI_MODEL_VALIDATION.md`.
