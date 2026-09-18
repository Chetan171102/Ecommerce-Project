<h1 align="center"> E-Commerce Sales Performance & Profitability Analysis</h1>

<p align="center">
  An end-to-end data analytics project — from raw data to a boardroom-ready dashboard —
  covering <strong>Excel, SQL, Python, and Power BI</strong> on a 34,500-row e-commerce sales dataset.
</p>

<p align="center">
  <a href="https://ecommercesalesopearationdashboard.vercel.app/" target="_blank">
    <img src="https://img.shields.io/badge/📊_View_Live_Dashboard-1F3864?style=for-the-badge&logoColor=white" alt="View Live Dashboard">
  </a>
</p>

<p align="center">
  <a href="https://github.com/Chetan171102/Ecommerce-Project/blob/main/ecommerce_cleaned.xlsx"><img src="https://img.shields.io/badge/Excel-217346?style=flat-square&logo=microsoft-excel&logoColor=white"></a>
  <a href="https://github.com/Chetan171102/Ecommerce-Project/blob/main/ecommerce_esa.ipynb"><img src="https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white"></a>
  <a href="https://github.com/Chetan171102/Ecommerce-Project/blob/main/Ecommerce_analysis.sql"><img src="https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white"></a>
</p>

---

##  Overview

This project analyzes **34,500 e-commerce orders** (12 Sep 2023 – 11 Sep 2025) to answer
a real business question: *what's actually driving revenue and profit in this
business, and where is the business quietly losing money?*

Rather than jumping straight to a dashboard, this project follows the full analyst
workflow end to end — cleaning and validating the raw data first, analyzing it
independently in three different tools to cross-check the results, and only then
building the dashboard and writing up business recommendations.

**Headline numbers:**

| Metric | Value |
|---|---|
| Total Revenue | ₹58,65,293 |
| Total Profit | ₹9,70,019 |
| Overall Profit Margin | 16.54% |
| Total Orders | 34,500 |
| Return Rate | 5.52% |
| Avg. Delivery Time | 4.81 days |

---

##  Project Phases

### Phase 1 — Data Cleaning & Quality Check *(Excel)*
- Audited the raw dataset for missing values, duplicates, invalid values, and data type issues
- Verified `total_amount` reconciles exactly against `price × quantity × (1 - discount)` on every row
- Discovered and documented that `customer_id` and `product_id` are **not reliable entity keys**
  (repeat IDs show conflicting demographics/categories) — this shaped every later phase
- Built a live-formula **Data Quality Check** sheet and a full **Data Dictionary**
- Output: a fully cleaned, documented dataset ready for analysis

### Phase 2 — Excel Analysis
- Built pivot-style analysis tables: monthly revenue trend, category × region revenue matrix,
  customer segment analysis, return analysis, profitability analysis
- Built a live, filter-aware Excel dashboard (SUMPRODUCT-driven, no VBA)

### Phase 3 — SQL Analysis *(MySQL)*
- Designed a relational schema and loaded the cleaned data
- Wrote 30+ queries covering aggregation, `CASE WHEN` logic, joins, and window functions
- Independently validated key Phase 2 findings in a second tool

### Phase 4 — Python EDA *(Pandas)*
- Re-verified data cleanliness independently rather than trusting Phase 1's claim
- Ran descriptive statistics, correlation analysis, and outlier analysis
- Confirmed the discount → margin relationship and the delivery-time/returns
  non-relationship found in later phases

### Phase 5 — Power BI Dashboard
- Built a data model (single fact table + a genuine Date dimension — **no fabricated
  Customer/Product dimension tables**, since Phase 1 proved those keys aren't reliable)
- Wrote DAX measures for revenue, profit, margin, return rate, and time-intelligence
- Designed a 3-page dashboard: **Executive Overview**, **Profitability & Discounts**,
  **Returns & Regions** — with slicers, cross-filtering, and drill-through to order-level detail

---

##  Key Insights

- **Electronics drives 56.6% of revenue but only converts at 10.4% margin** — it's the
  volume engine, not the profit engine. Beauty converts at 32.2%, the best in the portfolio.
- **Grocery is structurally loss-making**: 95.5% of its orders individually lose money
  (–11.2% category margin) — this is a pricing/cost problem, not a few bad orders.
- **Discounting is a pure margin cost here**: margin falls steadily from 16.8% (no discount)
  to 14.7% (30% discount tier), with no evidence of a compensating rise in order volume.
- **Returns are category-driven, not operational**: Fashion returns at 8.28% vs. Grocery's
  1.31%, while delivery time and payment method show almost no relationship to returns at all.
- **Regions are balanced** — no region is a standout problem; the real gaps are at the
  category level

---

##  Tools & Skills Demonstrated

`Excel (formulas, data validation, pivot analysis)` · `SQL (joins, CTEs, window functions, CASE WHEN)` ·
`Python (Pandas, Matplotlib, Seaborn)` · `Power BI (Power Query, DAX, data modeling, dashboard design)` ·
`Data cleaning & data quality auditing`

---

##  Live Dashboard

<p>
  <a href="https://ecommercesalesopearationdashboard.vercel.app/" target="_blank">
    <strong>👉 Click here to view the interactive Power BI dashboard</strong>
  </a>
</p>

---
