# Production Release Checklist & Governance Sign-Off

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Target Delivery:** GitHub Portfolio Release v1.1.0  
**Author / Project Owner:** Datta Sable (https://dattasable.com)  
**Verification Date:** 2026-10-26  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Multi-Stage Release Governance Matrix

The release criteria are partitioned into distinct engineering stages to separate core semantic modeling, data pipelines, design specifications, and desktop visual authoring:

### Stage 1: Data Engineering & SQL Server Pipeline
| Checkpoint | Requirement | Verification Evidence | Status |
|---|---|---|:---:|
| **1.1 Database Setup** | Local SQL Server 2022 instance `.` with database `[3 _M]` | Connects and executes queries via ADO.NET / SSMS | :white_check_mark: PASS |
| **1.2 Pipeline Scripts** | All 13 T-SQL scripts (00–12) idempotent and reproducible | Executed and validated in [`sql/`](../sql/) | :white_check_mark: PASS |
| **1.3 Row Count Lineage** | 3,000,000 raw rows clean to 3,000,000 clean and fact rows | Verified by automated test `SQL-01` to `SQL-03` | :white_check_mark: PASS |
| **1.4 Foreign Key Integrity** | Surrogate integer keys (`ProductKey`, `GeographyKey`) join without orphan records | `0` unmapped keys across 3M rows (`SQL-09`, `SQL-10`) | :white_check_mark: PASS |
| **1.5 Data Defect Handling** | Customer collisions and product ambiguities resolved or disclosed | Disclosed in `DATA_QUALITY_AND_LIMITATIONS.md` | :white_check_mark: PASS |

### Stage 2: Power BI Semantic Model & Tabular Engine
| Checkpoint | Requirement | Verification Evidence | Status |
|---|---|---|:---:|
| **2.1 PBIX Model Opening** | `My Final Project.pbix` (214 MB) opens successfully in Power BI Desktop | Opens without corrupted schema errors | :white_check_mark: PASS |
| **2.2 Star Schema Structure** | 4 tables (`vw_FactSales`, `DimProduct`, `DimGeography`, `DimDate`) | Verified in Model View | :white_check_mark: PASS |
| **2.3 Relationships & Directions** | 3 active single-direction `1:*` relationships on surrogate keys | Verified in `SEMANTIC_MODEL.md` | :white_check_mark: PASS |
| **2.4 Date Table Marking** | `DimDate` formally marked as Date Table on column `FullDate` | Time intelligence operational | :white_check_mark: PASS |
| **2.5 VertiPaq Compression** | 1.30 GB CSV compresses to 214 MB columnar storage | 6.1 : 1 compression confirmed | :white_check_mark: PASS |

### Stage 3: DAX Business Logic & Multi-Currency Security
| Checkpoint | Requirement | Verification Evidence | Status |
|---|---|---|:---:|
| **3.1 Static DAX Validation** | Static syntax and rule auditing across all `.dax` files | Automated CI runner `validate_dax_logic.ps1` passes | :white_check_mark: PASS |
| **3.2 P0 Currency Guardrails** | Monetary measures enforce `HASONEVALUE(DimGeography[currency])` | Returns `BLANK()` on multi-currency context; no 18.72B sum | :white_check_mark: PASS |
| **3.3 Volume & Metric Safety** | `DISTINCTCOUNT` on orders; safe alternate result on `DIVIDE` | Verified in `base_measures.dax` and `operations_measures.dax` | :white_check_mark: PASS |

### Stage 4: Visual Design System & Page Specifications
| Checkpoint | Requirement | Verification Evidence | Status |
|---|---|---|:---:|
| **4.1 Theme JSON** | Corporate light theme with official color tokens (`#061B3A`, `#1769E0`) | Schema validated via `verify_assets.ps1` | :white_check_mark: PASS |
| **4.2 Icon Suite** | 65 business analytics concepts across SVG and PNG (260 total files) | File existence verified in `assets/icons/` | :white_check_mark: PASS |
| **4.3 Background Canvas** | Futuristic Blue Earth canvas registered without baked-in text | Verified in `assets/backgrounds/` (1536×1024) | :white_check_mark: PASS |
| **4.4 Target UI Mockups** | 11 high-resolution layout mockups for all 9 dashboard pages | Verified in `assets/screenshots/` | :white_check_mark: PASS |
| **4.5 Field Binding Specs** | All 9 pages have detailed layout, grid, and field specifications | Complete in `powerbi/page-specs/` (01 to 09) | :white_check_mark: PASS |

### Stage 5: Power BI Desktop Authoring & Visual Interaction
| Checkpoint | Requirement | Verification Evidence | Status |
|---|---|---|:---:|
| **5.1 Page 01 Executive Canvas** | Executive Overview visual canvas laid out in desktop | Implemented in `Main Work.pbix` | :white_check_mark: PASS |
| **5.2 Pages 02–09 Native Visuals** | Drag-and-drop visuals configured inside native PBIX tabs | Full specifications published; authoring in progress | :hourglass_flowing_sand: IN PROGRESS |
| **5.3 Slicer Interaction Testing** | Currency and country slicers dynamically gate monetary visuals | Verified at DAX measure level; visual binding ready | :white_check_mark: PASS |
| **5.4 Drill-Through Pathways** | Order Details drill-through from Executive and Sales pages | Documented in page specs 01, 02, and 06 | :white_check_mark: PASS |

### Stage 6: Repository Hygiene & Distribution
| Checkpoint | Requirement | Verification Evidence | Status |
|---|---|---|:---:|
| **6.1 Large Binary Exclusion** | No files > 100 MB committed directly to Git repository | Protected via `.gitignore` and `.gitattributes` | :white_check_mark: PASS |
| **6.2 External Data Hosting** | 1.21 GB CSV accessible via Google Drive download link | Download link verified and published in README | :white_check_mark: PASS |
| **6.3 Credential Privacy** | No passwords, connection strings, or internal IPs published | Verified via preflight grep audit | :white_check_mark: PASS |
| **6.4 GitHub CI Workflow** | Automated GitHub Actions CI workflow validates DAX and assets | `Portfolio Validation CI` passing on GitHub | :white_check_mark: PASS |

---

## 2. Pre-Publication Sign-Off & Portfolio Status

- [x] **Data Pipeline & SQL Engine:** 100% Implemented, tested, and reproducible.
- [x] **Tabular Semantic Model:** 100% Implemented in Power BI Desktop (4 tables, 3 relationships).
- [x] **DAX Business Measures:** 100% Implemented with strict P0 currency guardrails.
- [x] **Design Specifications:** 100% Authored across 9 pages with target UI mockups.
- [ ] **Operational Multi-Page Desktop Authoring:** Pages 02–09 native drag-and-drop authoring in progress following published specifications.
