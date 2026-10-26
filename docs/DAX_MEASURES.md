# DAX Measure Catalog & Technical Reference

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Table Location:** `_Measures`  
**Author:** Datta Sable (https://dattasable.com)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Group 01 — Core Operational Base Measures

### 1.1 `Total Orders`
```dax
Total Orders = 
DISTINCTCOUNT(vw_FactSales[order_id])
```
- **Description:** Evaluates the distinct count of order identifiers across reporting transactions.
- **Format:** `#,##0`
- **Expected Unfiltered Result:** `3,000,000`

### 1.2 `Total Units Sold`
```dax
Total Units Sold = 
SUM(vw_FactSales[quantity])
```
- **Description:** Aggregates physical commercial units sold.
- **Format:** `#,##0`
- **Expected Unfiltered Result:** `16,498,920` (~16.5M)

### 1.3 `Average Units Per Order`
```dax
Average Units Per Order = 
DIVIDE([Total Units Sold], [Total Orders], 0)
```
- **Description:** Average basket quantity per order transaction.
- **Format:** `#,##0.00`
- **Expected Unfiltered Result:** `5.50`

### 1.4 `Total Transactions`
```dax
Total Transactions = 
DISTINCTCOUNT(vw_FactSales[transaction_id])
```
- **Description:** Unique payment and settlement transactions.
- **Format:** `#,##0`
- **Expected Unfiltered Result:** `3,000,000`

---

## 2. Group 02 — Finance Measures (P0 Multi-Currency Guardrails)

### 2.1 `Selected Currency Code`
```dax
Selected Currency Code = 
IF(
    HASONEVALUE(DimGeography[currency]),
    SELECTEDVALUE(DimGeography[currency]),
    "Multi-Currency"
)
```

### 2.2 `Revenue (Single Currency Only)`
```dax
Revenue (Single Currency Only) = 
IF(
    HASONEVALUE(DimGeography[currency]),
    SUM(vw_FactSales[revenue]),
    BLANK()
)
```
- **Description:** Strict guardrail preventing the arithmetic sum of 42 distinct local currencies. Returns `BLANK()` unless a single currency is active.
- **Format:** `#,##0.00`

### 2.3 `Cost (Single Currency Only)`
```dax
Cost (Single Currency Only) = 
IF(
    HASONEVALUE(DimGeography[currency]),
    SUM(vw_FactSales[cost]),
    BLANK()
)
```
- **Format:** `#,##0.00`

### 2.4 `Profit (Single Currency Only)`
```dax
Profit (Single Currency Only) = 
IF(
    HASONEVALUE(DimGeography[currency]),
    SUM(vw_FactSales[profit]),
    BLANK()
)
```
- **Format:** `#,##0.00`

### 2.5 `Profit Margin (Single Currency Only)`
```dax
Profit Margin (Single Currency Only) = 
DIVIDE(
    [Profit (Single Currency Only)],
    [Revenue (Single Currency Only)],
    BLANK()
)
```
- **Format:** `0.00%`

---

## 3. Group 03 — Operations & Fulfillment Measures

### 3.1 `Delivered Orders`
```dax
Delivered Orders = 
CALCULATE([Total Orders], vw_FactSales[order_status] = "Delivered")
```
- **Expected Unfiltered Result:** `1,950,380`

### 3.2 `Cancelled Orders`
```dax
Cancelled Orders = 
CALCULATE([Total Orders], vw_FactSales[order_status] = "Cancelled")
```
- **Expected Unfiltered Result:** `150,324`

### 3.3 `Delivery Completion Rate`
```dax
Delivery Completion Rate = 
DIVIDE([Delivered Orders], [Total Orders], 0)
```
- **Expected Unfiltered Result:** `65.01%`

### 3.4 `Cancellation Rate`
```dax
Cancellation Rate = 
DIVIDE([Cancelled Orders], [Total Orders], 0)
```
- **Expected Unfiltered Result:** `5.01%`

---

## 4. Group 04 — Time Intelligence Measures

### 4.1 `Orders YTD`
```dax
Orders YTD = 
TOTALYTD([Total Orders], DimDate[FullDate])
```

### 4.2 `Orders MTD`
```dax
Orders MTD = 
TOTALMTD([Total Orders], DimDate[FullDate])
```

### 4.3 `Orders Previous Month`
```dax
Orders Previous Month = 
CALCULATE([Total Orders], DATEADD(DimDate[FullDate], -1, MONTH))
```

### 4.4 `Orders MoM % Change`
```dax
Orders MoM % Change = 
VAR CurrentVal = [Total Orders]
VAR PrevVal = [Orders Previous Month]
RETURN
IF(
    ISBLANK(PrevVal) || PrevVal = 0,
    BLANK(),
    DIVIDE(CurrentVal - PrevVal, PrevVal)
)
```
- **Format:** `+0.00%;-0.00%;0.00%`
