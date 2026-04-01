# Personal Finance Dashboard – Power BI

An end-to-end personal finance analysis solution built with **Power BI Desktop**,
featuring dynamic KPI cards, Power Query data-cleaning pipelines, and a rich set
of DAX measures for time-intelligence and budget-vs-actual comparisons.

---

## Features

| Feature | Details |
|---|---|
| **Dynamic KPIs** | Income, Expenses, Net Savings, Savings Rate, Budget Status – all context-aware |
| **Data Cleaning** | Power Query M scripts remove invalid dates, duplicates, blank categories, and negative amounts |
| **DAX Measures** | 40+ measures covering base aggregations, MoM comparisons, YTD, running totals, and formatting helpers |
| **5 Report Pages** | Executive Summary · Income Analysis · Expense Analysis · Budget vs Actuals · Transaction Detail |
| **Time Intelligence** | Month-over-Month, Year-to-Date, cumulative totals via `DATEADD`, `DATESYTD`, and a fully-featured Calendar table |
| **Budget Tracking** | Gauge, variance waterfall, utilisation %, and "Over/On/Under Budget" status label |
| **Drill-through** | Click any expense category to drill through to filtered transaction detail |
| **Sample Data** | 352 transactions, 108 budget rows, 14 categories – including intentionally dirty rows to showcase cleaning |

---

## Repository Structure

```
finance-dashboard-powerbi/
├── data/
│   ├── transactions.csv      # ~350 individual transactions (2024)
│   ├── budget.csv            # Monthly budget targets per category
│   └── categories.csv        # Category master data
├── powerquery/
│   ├── 01_Transactions.m     # Clean & enrich transactions
│   ├── 02_Calendar.m         # Generate date dimension table
│   ├── 03_Categories.m       # Clean categories + add CategoryGroup
│   └── 04_Budget.m           # Clean budget + add Date / YearMonth keys
├── dax/
│   ├── measures.dax          # All DAX measures (~40 measures, 9 sections)
│   └── calculated_columns.dax# Calculated columns for Transactions, Calendar, Budget
├── docs/
│   ├── dashboard_design.md   # Page-by-page visual & interaction specifications
│   └── setup_guide.md        # Step-by-step build instructions
├── scripts/
│   └── generate_data.py      # Python helper to regenerate sample CSV data
└── README.md
```

---

## Quick Start

1. **Clone the repo** and (optionally) regenerate the sample data:

   ```bash
   git clone https://github.com/Bitu-Singh-Rathoud/finance-dashboard-powerbi.git
   cd finance-dashboard-powerbi
   python scripts/generate_data.py   # Python 3.8+, no extra packages needed
   ```

2. **Open Power BI Desktop** → Get Data → import the three CSV files from `data/`.

3. **Apply Power Query M scripts** (Advanced Editor, one per query) from `powerquery/`.

4. **Set up relationships** in Model view (see `docs/setup_guide.md`, Step 5).

5. **Paste DAX** calculated columns (`dax/calculated_columns.dax`) then measures
   (`dax/measures.dax`) into the model.

6. **Build the 5 report pages** following `docs/dashboard_design.md`.

Full step-by-step instructions: [`docs/setup_guide.md`](docs/setup_guide.md)

---

## Data Model

```
Calendar ──[1:*]── Transactions
Calendar ──[1:*]── Budget
Categories ──[1:*]── Transactions
Categories ──[1:*]── Budget
```

---

## Dashboard Pages

| # | Page | Key Visuals |
|---|------|-------------|
| 1 | Executive Summary | KPI cards, Income vs Expenses bar, Cumulative Savings area, Expense donut |
| 2 | Income Analysis | Income by source stacked bar, YTD line, MoM column, transaction table |
| 3 | Expense Analysis | Treemap, monthly trend, weekday heatmap, large-expense drill-through |
| 4 | Budget vs Actuals | Gauge, clustered bar, variance waterfall, YTD summary |
| 5 | Transaction Detail | Searchable / filterable ledger table |

---

## DAX Measures (summary)

| Section | Measures |
|---|---|
| Base aggregations | `Total Amount`, `Transaction Count` |
| Income KPIs | `Total Income`, `Income This Month`, `Avg Monthly Income` |
| Expense KPIs | `Total Expenses`, `Expenses This Month`, `Avg Monthly Expenses`, `Top Expense Category` |
| Savings KPIs | `Net Savings`, `Savings Rate %`, `Net Savings This Month`, `Total Transfers to Savings` |
| Budget vs Actuals | `Total Budget`, `Budget Variance`, `Budget Utilisation %`, `Budget Status` |
| Month-over-Month | `Income MoM %`, `Expenses MoM %`, `Expenses MoM Label` |
| Year-to-Date | `Income YTD`, `Expenses YTD`, `Net Savings YTD`, `Budget Variance YTD` |
| Running totals | `Cumulative Income`, `Cumulative Expenses`, `Cumulative Net Savings` |
| Formatting helpers | `Selected Year Label`, `KPI Income Title`, `Income Display`, … |

---

## Power Query Cleaning Steps (Transactions)

1. Promote headers and set data types
2. Remove rows where **Date** is not a valid `YYYY-MM-DD` date
3. Parse Date column to `date` type
4. Remove exact **duplicate** rows
5. **Trim** & clean all text columns
6. Replace blank **CategoryName** → `"Uncategorized"`
7. Replace blank **Type** → `"Unknown"`
8. Remove rows where **Amount ≤ 0**
9. Add derived columns: `Year`, `Month`, `MonthName`, `Quarter`, `Weekday`
10. Sort by Date ascending

---

## License

MIT
