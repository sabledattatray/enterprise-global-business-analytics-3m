# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability or Data Leak

This project deals exclusively with **100% synthetic demonstration business data**. Although the dataset contains realistic customer names, emails, and phone numbers, all records were synthetically generated and do not represent real individuals, entities, or financial transactions.

If you discover any sensitive credential, unintentional connection string with cleartext secrets, or private personal information inadvertently committed to this repository:

1. **Do not open a public GitHub issue.**
2. Send an email directly to the project maintainer: **datta@dattasable.com** or contact via [https://dattasable.com](https://dattasable.com).
3. Include details of the file path, commit hash, and nature of the finding.
4. Vulnerability reports are acknowledged within 48 hours, and remediation will follow standard git filter-repo / secret rotation procedures.

## Security Practices Followed

- Dedicated `.gitignore` blocking `.env`, connection strings, SQL credentials, `.mdf`/`.ldf`, and backup dumps.
- Read-only preflight verification scripts before any data modifications.
- Explicit approval gates required before heavy database transformations or external publishing.
