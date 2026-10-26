# Multi-Currency Policy & Financial Reporting Guardrails

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Classification:** P0 Mandatory Data Governance Rule  
**Author:** Datta Sable (https://dattasable.com)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Problem Statement: The Multi-Currency Illusion

The synthetic dataset contains **3,000,000 transactions across 50 countries and 42 local currencies**. The monetary fields (`revenue`, `cost`, `profit`, `tax_amount`, `unit_price`) are stored as raw numeric amounts denominated in their respective local currencies.

If a developer executes a naive global aggregation:
```sql
-- DANGEROUS ARITHMETIC ILLUSION:
SELECT SUM(revenue) FROM dbo.vw_FactSales;
-- Result: 18,720,460,798.92
```

The resulting number (`18.72 Billion`) is an **economically meaningless arithmetic sum** that adds US Dollars (`USD`), Japanese Yen (`JPY`), Indian Rupees (`INR`), British Pounds (`GBP`), and 38 other disparate currencies together 1:1. 

Presenting this figure as "Global Revenue" or labeling it "$18.7B" constitutes a severe violation of financial BI engineering standards.

---

## 2. Mandatory Policy Rules

1. **No Global Monetary Sums:** Never display an unfiltered sum of revenue, cost, or profit on executive cards without currency normalization.
2. **Single-Currency Gating:** All monetary DAX measures must verify that the active filter context contains exactly one currency:
   ```dax
   Revenue (Single Currency Only) = 
   IF(
       HASONEVALUE(DimGeography[currency]),
       SUM(vw_FactSales[revenue]),
       BLANK()
   )
   ```
3. **Explicit Currency Display:** When single-currency context is active, reports must display the active 3-letter currency ISO code (e.g., `USD`, `EUR`, `JPY`) in KPI card subtitles and visual headers.
4. **Transparent Blank State:** When multiple currencies are in context, monetary visuals return `BLANK()` with an explicit instructional tooltip guiding the user to select a single currency or country slicer.
5. **Operational Metrics as Primary Global View:** Global dashboards (such as Page 01 Executive Overview) focus on mathematically universal operational KPIs:
   - Total Orders (Count of commercial transactions)
   - Total Units Sold (Physical goods volume)
   - Average Units Per Order (Basket size)
   - Delivery Completion & Cancellation Rates

---

## 3. Verified Country-to-Currency Mapping (50 Countries, 42 Currencies)

Audited directly from `dbo.DimGeography`:

| Continent | Country | Currency | Continent | Country | Currency |
|---|---|---|---|---|---|
| **North America** | United States | USD | **Europe** | Germany | EUR |
| **North America** | Canada | CAD | **Europe** | France | EUR |
| **North America** | Mexico | MXN | **Europe** | Italy | EUR |
| **South America** | Brazil | BRL | **Europe** | Spain | EUR |
| **South America** | Argentina | ARS | **Europe** | Netherlands | EUR |
| **South America** | Colombia | COP | **Europe** | Belgium | EUR |
| **South America** | Chile | CLP | **Europe** | Austria | EUR |
| **South America** | Peru | PEN | **Europe** | Ireland | EUR |
| **Asia** | India | INR | **Europe** | Portugal | EUR |
| **Asia** | Japan | JPY | **Europe** | United Kingdom | GBP |
| **Asia** | China | CNY | **Europe** | Switzerland | CHF |
| **Asia** | South Korea | KRW | **Europe** | Sweden | SEK |
| **Asia** | Singapore | SGD | **Europe** | Norway | NOK |
| **Asia** | Indonesia | IDR | **Europe** | Denmark | DKK |
| **Asia** | Thailand | THB | **Europe** | Poland | PLN |
| **Asia** | Malaysia | MYR | **Europe** | Turkey | TRY |
| **Asia** | Vietnam | VND | **Africa** | South Africa | ZAR |
| **Asia** | Philippines | PHP | **Africa** | Egypt | EGP |
| **Asia** | Pakistan | PKR | **Africa** | Nigeria | NGN |
| **Asia** | Bangladesh | BDT | **Africa** | Kenya | KES |
| **Asia** | Saudi Arabia | SAR | **Africa** | Morocco | MAD |
| **Asia** | UAE | AED | **Oceania** | Australia | AUD |
| **Asia** | Israel | ILS | **Oceania** | New Zealand | NZD |
| **Asia** | Nepal | NPR | **Africa** | Ghana | GHS |
| **Asia** | Sri Lanka | LKR | **Africa** | Ethiopia | ETB |

*(Note: 9 European countries share `EUR`, which is mathematically valid to aggregate together within the Eurozone).*

---

## 4. Requirements for Future FX Normalization

To deliver a consolidated global financial figure in a future release, the following architectural prerequisites must be met:
1. Materialize `dbo.DimExchangeRate(RateDate, FromCurrency, ToCurrency, SpotRate, MonthlyAvgRate)`.
2. Implement date-matched conversion logic: `revenue_usd = revenue * SpotRate`.
3. Account for weekend rate gaps, currency holidays, and conversion rounding policies.
4. Backtest converted totals against historical central bank benchmark distributions.
