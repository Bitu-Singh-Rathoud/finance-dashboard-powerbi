# Dashboard Design – Personal Finance Power BI Dashboard

## Overview

This document describes the layout, visuals, slicers, and interactions for each
report page in the **Personal Finance Dashboard** Power BI file.

---

## Data Model

```
Calendar ──[1:*]── Transactions
Calendar ──[1:*]── Budget
Categories ──[1:*]── Transactions
Categories ──[1:*]── Budget
```

| Table        | Key column           | Role                         |
|--------------|----------------------|------------------------------|
| Transactions | Date, CategoryID     | Fact table                   |
| Budget       | Date (month), CategoryID | Budget fact table        |
| Calendar     | Date                 | Date dimension               |
| Categories   | CategoryID           | Category dimension           |

---

## Pages

### Page 1 – Executive Summary

**Purpose:** High-level snapshot of income, expenses, savings, and budget health.

| Visual                  | Type              | Fields / Measure                                   |
|-------------------------|-------------------|----------------------------------------------------|
| Total Income KPI        | Card              | `Total Income`, dynamic title from `KPI Income Title` |
| Total Expenses KPI      | Card              | `Total Expenses`, dynamic title                    |
| Net Savings KPI         | Card              | `Net Savings`, conditional formatting (green/red)  |
| Savings Rate KPI        | Card              | `Savings Rate %`                                   |
| Budget Status KPI       | Card              | `Budget Status` (text)                             |
| Income vs Expenses      | Clustered bar     | Calendar[MonthShort] × [Total Income], [Total Expenses] |
| Cumulative Net Savings  | Area chart        | Calendar[Date] × [Cumulative Net Savings]          |
| Expense Breakdown       | Donut chart       | Categories[CategoryName] × [Total Expenses]        |
| MoM Expense Change      | KPI visual        | [Total Expenses], goal = [Expenses Previous Month] |

**Slicers:** Year, Month, Category Type

---

### Page 2 – Income Analysis

**Purpose:** Drill into income sources and trends.

| Visual                   | Type          | Fields / Measure                                       |
|--------------------------|---------------|--------------------------------------------------------|
| Income by Source         | Stacked bar   | Calendar[MonthShort] × Categories[CategoryName] × [Total Income] |
| Income Trend (YTD)       | Line chart    | Calendar[Date] × [Income YTD]                         |
| Income MoM Change        | Column chart  | Calendar[MonthShort] × [Income MoM Change]            |
| Avg Monthly Income       | Card          | `Avg Monthly Income`                                   |
| Transaction Detail Table | Table visual  | Date, Description, CategoryName, Amount (filtered to Income) |

**Slicers:** Year, Income Category

---

### Page 3 – Expense Analysis

**Purpose:** Track and analyse spending patterns.

| Visual                     | Type              | Fields / Measure                                       |
|----------------------------|-------------------|--------------------------------------------------------|
| Expenses by Category       | Treemap           | Categories[CategoryName] × [Total Expenses]           |
| Monthly Expense Trend      | Line + column     | Calendar[MonthShort] × [Total Expenses], [Avg Monthly Expenses] |
| Expense Heatmap            | Matrix            | Calendar[WeekdayName] × Calendar[Week] × [Total Expenses] |
| Top Expense Category       | Card              | `Top Expense Category`                                 |
| Large Expense Drill-through| Table             | Transactions[IsLargeExpense] = "Large Expense"        |
| Expenses MoM %             | Card              | `Expenses MoM Label`                                   |

**Slicers:** Year, Month, CategoryGroup, Payment Method

---

### Page 4 – Budget vs Actuals

**Purpose:** Compare planned vs actual spend per category.

| Visual                    | Type            | Fields / Measure                              |
|---------------------------|-----------------|-----------------------------------------------|
| Budget Utilisation Gauge  | Gauge           | [Budget Utilisation %] (target = 1)           |
| Budget vs Actual by Month | Clustered bar   | Calendar[MonthShort] × [Total Budget], [Total Expenses] |
| Variance by Category      | Waterfall chart | Categories[CategoryName] × [Budget Variance]  |
| Budget Variance Table     | Matrix          | Month × Category × Budget / Actual / Variance |
| YTD Budget Status         | Card            | `Budget Variance YTD`                         |

**Slicers:** Year, Month, Category

---

### Page 5 – Transaction Detail

**Purpose:** Searchable ledger with full transaction history.

| Visual             | Type         | Fields                                                        |
|--------------------|--------------|---------------------------------------------------------------|
| Transaction Table  | Table visual | Date, Description, CategoryName, Type, Amount, PaymentMethod, Notes |
| Search bar         | Slicer       | Transactions[Description] (text / contains mode)             |
| Amount Range       | Slicer       | Transactions[Amount] (numeric range)                         |

**Slicers:** Year, Month, Type, CategoryName, PaymentMethod

---

## Conditional Formatting Rules

| Visual                   | Column        | Rule                                                 |
|--------------------------|---------------|------------------------------------------------------|
| Net Savings KPI card     | Value         | Green if > 0, Red if < 0                             |
| Budget Status card       | Text          | Green = "Under Budget", Amber = "On Track", Red = "Over Budget" |
| Budget Variance table    | Variance col  | Data bars, red-white-green diverging scale           |
| MoM Expense column chart | Bar colour    | Green if MoM < 0 (spending down), Red if MoM > 0    |

---

## Interactions & Drill-through

- **Cross-filter:** All visuals on the same page cross-filter each other by default.
- **Drill-through from Page 3:** Right-click any expense category → drill through to
  Page 5 (Transaction Detail), pre-filtered to that category.
- **Drill-through from Page 4:** Right-click any month bar → drill through to Page 3,
  pre-filtered to that month.
- **Bookmarks:**
  - `Executive View` – Page 1, no slicers applied
  - `Current Month` – Page 1, MonthOffset = 0 filter applied
  - `YTD View` – Page 1, current year, all months

---

## Theme & Formatting

- **Font:** Segoe UI
- **Accent colour:** `#1F6FEB` (blue)
- **Positive/negative:** `#28A745` green / `#DC3545` red
- **Background:** `#F8F9FA` (light grey)
- **Card border-radius:** 8 px
- **KPI cards:** Use the "New card" visual with bold title, large value, and trend indicator
