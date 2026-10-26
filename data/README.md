# Dataset Distribution & Data Schemas

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Author:** Datta Sable (https://dattasable.com)  

---

## 1. Full 3-Million-Row Source Dataset

Due to GitHub's file size limitations (100 MB per file limit), the complete 1.30 GB synthetic dataset (`world_business_data_3m.csv`, 3,000,000 rows × 49 columns) is hosted externally on Google Drive:

👉 **[Download Full 3M Synthetic Transactions Dataset (Google Drive)](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)**

---

## 2. Lightweight Sample Dataset (`data/samples/`)

For reviewers, developers, or learners wishing to test the SQL Server scripts and Power BI model without downloading the entire 1.3 GB file, a lightweight representative sample is provided:
- **File:** `data/samples/sample_100_rows.csv`
- **Rows:** 100 sample transactions
- **Coverage:** Spans all 15 products, multiple countries, currencies, and order statuses.

---

## 3. Data Schemas (`data/schemas/`)

Formal JSON schemas describing the structural contracts for ingestion and reporting:
1. `data/schemas/world_business_data_3m.schema.json`: Complete 49-column landing table contract.
2. `data/schemas/vw_FactSales.schema.json`: 19-column Power BI reporting view contract.
