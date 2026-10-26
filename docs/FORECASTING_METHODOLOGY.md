# Demand Forecasting & Predictive Modeling Methodology

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Target Delivery:** Future Model Roadmap & Data Science Engineering Specification  
**Author:** Datta Sable (https://dattasable.com)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Executive Directive: Scientific Truthfulness

> [!WARNING]
> **MODEL READINESS GATE:**  
> In accordance with PRD Section 8.9 and Section 14, **no production forecasting machine learning model is currently deployed.**  
> Decorative accuracy statistics depicted in UI mockups (e.g. "98.4% Accuracy") are visual design concepts, not measured data science outcomes. This document formalizes the rigorous, reproducible methodology required to implement a production forecasting pipeline in Phase 2.

---

## 2. Historical Baseline & Time-Series Properties

Before training predictive models, the historical dataset was audited across its 5-year timeline:
- **Total Historical Orders:** 3,000,000
- **Total Historical Units:** 16,498,920
- **Calendar Days Covered:** 1,826 distinct transaction days (2021-10-12 to 2026-10-11)
- **Mean Daily Volume:** ~1,643 orders / day (~9,035 units / day)
- **Seasonality Patterns:** Strong weekly cycle (Monday through Sunday) and annual holiday/quarter-end spikes.

---

## 3. Production Forecasting Specification

### 3.1 Forecast Targets
1. **Primary Target:** `Daily Order Volume` (`Total Orders` aggregated by `DimDate[FullDate]`, `product_category`, and `sales_channel`).
2. **Secondary Target:** `Physical Units Demand` (`Total Units Sold`).
3. **Excluded Target:** Monetary revenue forecasting is **deferred** until the FX Normalization Model (`dbo.DimExchangeRate`) is fully implemented.

### 3.2 Train / Validation / Test Split
- **Training Set:** 2021-10-12 through 2025-10-11 (First 4 years, ~80% of data)
- **Validation Holdout:** 2025-10-12 through 2026-04-11 (6-month tuning set)
- **Test Holdout (Out-of-Time):** 2026-04-12 through 2026-10-11 (Final 6 months for unbiased accuracy measurement)

### 3.3 Candidate Algorithms
| Model Family | Algorithm | Strengths |
|---|---|---|
| **Decomposition Baseline** | Facebook Prophet | Native holiday handling, additive/multiplicative seasonality decomposition |
| **Classical Econometric** | SARIMAX (p,d,q)(P,D,Q)s | Proven baseline for stationary linear time series |
| **Gradient Boosted Trees** | LightGBM / XGBoost Regressor | Handles complex cross-feature interactions (channel, category, country, lag features) |

### 3.4 Evaluation Metrics
To avoid percentage distortion when volume approaches low levels, evaluate across:
- **Mean Absolute Error (MAE):** $\frac{1}{n} \sum |y_i - \hat{y}_i|$
- **Root Mean Squared Error (RMSE):** $\sqrt{\frac{1}{n} \sum (y_i - \hat{y}_i)^2}$
- **Symmetric Mean Absolute Percentage Error (sMAPE):** $\frac{100\%}{n} \sum \frac{|y_i - \hat{y}_i|}{(|y_i| + |\hat{y}_i|) / 2}$

---

## 4. Power BI Integration Architecture

Once trained and backtested:
1. Python / Azure Machine Learning pipeline exports predictions to `dbo.FactForecast(DateKey, ProductKey, GeographyKey, PredictedOrders, LowerBound80, UpperBound80)`.
2. Power BI imports `FactForecast` into the existing star schema.
3. Historical actuals join seamlessly with predictive forecasts using `DimDate[FullDate]`.
