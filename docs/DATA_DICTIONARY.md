# Data Dictionary & Schema Specification

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Database:** `[3 _M]`  
**Engine:** Microsoft SQL Server 2022  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Reporting View: `dbo.vw_FactSales` (19 Columns)

This is the primary reporting fact object imported directly into Power BI Desktop.

| Column Name | SQL Data Type | Power BI Type | Nullable | Description / Business Meaning | Sample Value |
|---|---|---|---|---|---|
| `record_id` | `BIGINT` | Whole Number | Yes | Surrogate identifier assigned during synthetic generation. | `1000001` |
| `order_id` | `VARCHAR(50)` | Text | Yes | Unique commercial order identifier (3,000,000 distinct values). | `ORD-2023-847291` |
| `transaction_id` | `VARCHAR(50)` | Text | Yes | Payment processor transaction reference. | `TXN-91827461` |
| `ProductKey` | `INT` | Whole Number | Yes | Foreign key referencing `dbo.DimProduct(ProductKey)`. | `9` |
| `GeographyKey` | `INT` | Whole Number | Yes | Foreign key referencing `dbo.DimGeography(GeographyKey)`. | `9` |
| `order_date` | `DATE` | Date | Yes | Date order was placed (Foreign key to `DimDate[FullDate]`). | `2024-05-18` |
| `quantity` | `INT` | Whole Number | Yes | Physical units ordered (Range: 1 to 10). | `4` |
| `unit_price` | `DECIMAL(18,2)` | Decimal Number | Yes | Base list price per unit in local currency. | `450.00` |
| `discount_pct` | `DECIMAL(5,2)` | Decimal Number | Yes | Commercial discount applied (Range: 0.00% to 25.00%). | `10.00` |
| `revenue` | `DECIMAL(18,2)` | Decimal Number | Yes | Realized gross revenue in local currency: `qty * price * (1 - disc)`. | `1620.00` |
| `cost` | `DECIMAL(18,2)` | Decimal Number | Yes | Cost of goods sold (COGS) in local currency. | `1053.00` |
| `profit` | `DECIMAL(18,2)` | Decimal Number | Yes | Gross operational profit in local currency: `revenue - cost`. | `567.00` |
| `tax_amount` | `DECIMAL(18,2)` | Decimal Number | Yes | Assessed tax in local currency (Not included in recorded revenue). | `162.00` |
| `currency` | `VARCHAR(50)` | Text | Yes | Local currency code of transaction (42 distinct currencies). | `USD` |
| `order_status` | `VARCHAR(50)` | Text | Yes | Current fulfillment status: `Delivered`, `Shipped`, `Processing`, `Cancelled`. | `Delivered` |
| `payment_status` | `VARCHAR(50)` | Text | Yes | Transaction settlement status: `Paid`, `Pending`, `Failed`. | `Paid` |
| `sales_channel` | `VARCHAR(50)` | Text | Yes | Commercial channel: `Online`, `Direct`, `Partner`, `Retail`. | `Online` |
| `planned_delivery_date` | `DATE` | Date | Yes | Target fulfillment delivery date. | `2024-05-24` |
| `actual_delivery_date` | `DATE` | Date | Yes | Recorded actual delivery date (Populated ONLY for `Delivered` status). | `2024-05-23` |

---

## 2. Dimension Tables

### A. Product Dimension: `dbo.DimProduct` (15 Rows)

| Column Name | SQL Data Type | PK / FK | Description | Sample Values |
|---|---|---|---|---|
| `ProductKey` | `INT IDENTITY(1,1)` | **PK** | Clustered primary key surrogate. | `1`, `2`, `3` ... `15` |
| `product_name` | `VARCHAR(50)` | - | Validated standard product name. | `Monitor`, `Laptop`, `Headphones` |
| `product_category` | `VARCHAR(50)` | - | Major product grouping. | `Electronics`, `Clothing`, `Home` |
| `brand` | `VARCHAR(50)` | - | Manufacturing brand name. | `ViewMax`, `TechNova`, `SoundWave` |

### B. Geography Dimension: `dbo.DimGeography` (50 Rows)

| Column Name | SQL Data Type | PK / FK | Description | Sample Values |
|---|---|---|---|---|
| `GeographyKey` | `INT IDENTITY(1,1)` | **PK** | Clustered primary key surrogate. | `1`, `2` ... `50` |
| `country` | `VARCHAR(50)` | - | Standard country name. | `United States`, `Germany`, `India` |
| `continent` | `VARCHAR(50)` | - | Continental geographic region. | `North America`, `Europe`, `Asia` |
| `currency` | `VARCHAR(50)` | - | Primary currency ISO code. | `USD`, `EUR`, `INR`, `GBP` |

### C. Date Dimension: `dbo.DimDate` (2,191 Rows)

| Column Name | SQL Data Type | PK / FK | Description | Sample Values |
|---|---|---|---|---|
| `DateKey` | `INT` | **PK** | Integer surrogate formatted as `YYYYMMDD`. | `20240518` |
| `FullDate` | `DATE` | **UQ** | Unique calendar date (Power BI Relationship Key). | `2024-05-18` |
| `Year` | `INT` | - | 4-digit calendar year (2021 to 2026). | `2024` |
| `QuarterNumber` | `INT` | - | Quarter index (1 to 4). | `2` |
| `QuarterName` | `VARCHAR(2)` | - | Quarter label. | `Q2` |
| `MonthNumber` | `INT` | - | Month index (1 to 12). | `5` |
| `MonthName` | `VARCHAR(20)` | - | Full month name. | `May` |
| `YearMonth` | `CHAR(7)` | - | Formatted label `YYYY-MM`. | `2024-05` |
| `YearMonthSort` | `INT` | - | Sort key formatted as `YYYYMM`. | `202405` |
| `DayOfMonth` | `INT` | - | Day index in month (1 to 31). | `18` |
| `DayOfWeekNumber`| `INT` | - | Day of week index (Monday = 1, Sunday = 7). | `6` |
| `DayOfWeekName` | `VARCHAR(20)` | - | Full day of week name. | `Saturday` |
| `IsWeekend` | `BIT` | - | Weekend indicator (`1` = Saturday/Sunday, `0` = Weekday). | `1` |
