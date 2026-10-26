# Changelog

All notable changes to the **Enterprise Global Business Analytics — 3M Synthetic Transactions** portfolio project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-26

### Added
- Comprehensive Production PRD v1.0 and implementation handoff specification.
- Full Phase 0 discovery, preflight audit, and implementation gap analysis (`docs/IMPLEMENTATION_GAP_ANALYSIS.md`).
- Direct Google Drive download link for the full 3,000,000-row synthetic source CSV.
- Complete modular T-SQL transformation and validation suite (`sql/00` through `sql/12`).
- 3 validated SQL dimensions (`dbo.DimProduct`, `dbo.DimGeography`, `dbo.DimDate`) and narrow reporting view (`dbo.vw_FactSales`).
- Verified Power BI star schema with 3 active 1-to-many relationships.
- Modular DAX measure libraries (`base_measures.dax`, `finance_measures.dax`, `operations_measures.dax`, `date_measures.dax`).
- P0 multi-currency guardrail measures enforcing single-currency context via `HASONEVALUE`.
- Official Power BI report theme (`powerbi/theme/enterprise-light-theme.json`) with corporate navy/blue design tokens.
- Complete 9-page Power BI report specifications (`powerbi/page-specs/01` through `09`).
- Asset catalog featuring approved clean globe canvas background and 65-concept SVG/PNG icon library.
- Automated SQL, DAX, and asset test suites in `tests/`.
- Enterprise GitHub portfolio documentation: README, Architecture, Data Dictionary, Currency Policy, Limitations, and Setup Guides.
