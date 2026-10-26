# Contributing to Enterprise Global Business Analytics — 3M

Thank you for your interest in contributing to this enterprise analytics portfolio project!

## Guiding Principles & Standards

This project adheres to rigorous enterprise BI engineering practices:
1. **Preserve Truthfulness**: Design mockups are visual references, not data evidence. Never commit invented metrics, synthetic forecast accuracy claims, or false certifications.
2. **Multi-Currency Discipline**: The dataset contains 42 distinct currencies. Never aggregate mixed currencies into a single monetary sum without documented, date-matched FX rates.
3. **Customer Identity Caveat**: Source synthetic customer IDs have known collision defects. Transaction-level analytics are valid; person-level retention and CLV must remain flagged as synthetic limitations.
4. **Git Hygiene**: Never commit raw multi-gigabyte CSVs, database MDF/LDF/BAK files, or massive PBIX binaries directly to Git. The 3M raw CSV is hosted externally via Google Drive.

## How to Contribute

1. Fork the repository and create your feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Run preflight validation tests:
   ```powershell
   powershell -File tests/sql/run_all_sql_tests.ps1
   ```
3. Commit your changes with clear, descriptive messages adhering to conventional commits:
   ```bash
   git commit -m "docs: improve currency policy documentation"
   ```
4. Push to your branch and open a Pull Request.

## Code & SQL Guidelines

- Use T-SQL compatible with Microsoft SQL Server 2022.
- All SQL scripts must include standard documentation headers (purpose, safety classification, expected row impact, dependencies).
- Avoid destructive DDL/DML without rollback procedures and user approval gates.
- Format DAX measures using standard DAX formatting with comments explaining context transition and filter logic.

---
Project Owner: [Datta Sable](https://dattasable.com)
