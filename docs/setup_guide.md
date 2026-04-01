# Setup Guide – Personal Finance Power BI Dashboard

## Prerequisites

| Requirement             | Minimum version          |
|-------------------------|--------------------------|
| Power BI Desktop        | March 2024 (or later)    |
| Operating System        | Windows 10/11            |
| Screen resolution       | 1280 × 800               |

---

## Step 1 – Clone / Download the repository

```bash
git clone https://github.com/Bitu-Singh-Rathoud/finance-dashboard-powerbi.git
cd finance-dashboard-powerbi
```

---

## Step 2 – (Optional) Regenerate sample data

A Python helper script is included if you want to regenerate or customise the
sample CSV files.

```bash
# Python 3.8+ required; no external packages needed
python scripts/generate_data.py
```

The script writes three files into `data/`:

| File                   | Description                              | Rows  |
|------------------------|------------------------------------------|-------|
| `transactions.csv`     | Individual financial transactions (2024) | ~350  |
| `budget.csv`           | Monthly budget targets per category      | 108   |
| `categories.csv`       | Category master data                     | 14    |

---

## Step 3 – Open Power BI Desktop and connect to the data

1. Open **Power BI Desktop**.
2. On the **Home** ribbon click **Get Data → Text/CSV**.
3. Navigate to the `data/` folder and import all three CSV files.
4. Repeat for each file; Power BI will create three queries automatically.

---

## Step 4 – Apply Power Query transformations

For each query, open the **Power Query Editor** (Home → Transform Data) and
paste the corresponding M script:

| Query name    | M script file                          |
|---------------|----------------------------------------|
| Transactions  | `powerquery/01_Transactions.m`         |
| Calendar      | `powerquery/02_Calendar.m`             |
| Categories    | `powerquery/03_Categories.m`           |
| Budget        | `powerquery/04_Budget.m`               |

**How to apply an M script:**
1. In Power Query Editor, right-click the query → **Advanced Editor**.
2. Select all existing code and replace it with the contents of the `.m` file.
3. Click **Done**.
4. Click **Close & Apply** once all four scripts have been applied.

> **Note:** The `Calendar` query references the `Transactions` table.  
> Make sure `Transactions` is loaded **before** you apply the Calendar script.

---

## Step 5 – Build the Data Model relationships

In the **Model** view, create the following relationships (all active, many-to-one):

| From (many side)            | To (one side)           | Cardinality |
|-----------------------------|-------------------------|-------------|
| `Transactions[Date]`        | `Calendar[Date]`        | Many → One  |
| `Transactions[CategoryID]`  | `Categories[CategoryID]`| Many → One  |
| `Budget[Date]`              | `Calendar[Date]`        | Many → One  |
| `Budget[CategoryID]`        | `Categories[CategoryID]`| Many → One  |

Set **Calendar[Date]** as the date table:  
Right-click `Calendar` table → **Mark as date table** → select `Date` column.

---

## Step 6 – Add DAX calculated columns

In the **Data** view, select the target table and paste each calculated column
from `dax/calculated_columns.dax`.  The file header indicates which table each
column belongs to.

---

## Step 7 – Create the _Measures table and add DAX measures

1. In the **Home** ribbon, click **Enter Data**, name the table `_Measures`,
   add a dummy column (it can be empty), and click **Load**.
2. Select the `_Measures` table in the Fields pane.
3. For each measure in `dax/measures.dax`, click **New Measure** on the ribbon
   and paste the DAX expression.

> All measures are prefixed with a descriptive comment; paste only the DAX
> expression (everything after the `//` comment block).

---

## Step 8 – Build the report pages

Follow the visual specifications in `docs/dashboard_design.md` to build each
page.  Recommended build order:

1. Executive Summary (Page 1) – validates that all key measures work.
2. Income Analysis (Page 2)
3. Expense Analysis (Page 3)
4. Budget vs Actuals (Page 4)
5. Transaction Detail (Page 5)

---

## Step 9 – Apply the theme and conditional formatting

- Import the optional JSON theme file (if provided) via  
  **View → Themes → Browse for themes**.
- Apply conditional formatting rules described in `docs/dashboard_design.md`
  to the relevant visuals.

---

## Troubleshooting

| Symptom                              | Likely cause                             | Fix                                                   |
|--------------------------------------|------------------------------------------|-------------------------------------------------------|
| Calendar query errors on load        | Transactions not loaded yet              | Load Transactions first; refresh Calendar             |
| Measures return blank                | Calendar not marked as date table        | Right-click Calendar → Mark as date table             |
| Time-intelligence functions fail     | Relationship to Calendar not active      | Check and activate relationship in Model view         |
| Duplicate rows visible               | Power Query step not applied             | Re-apply `01_Transactions.m` Advanced Editor script   |
| Budget visuals show no data          | Budget[Date] not linked to Calendar[Date]| Verify relationship in Model view                     |

---

## Folder Structure

```
finance-dashboard-powerbi/
├── data/
│   ├── transactions.csv      # Raw transaction data
│   ├── budget.csv            # Monthly budget targets
│   └── categories.csv        # Category master data
├── powerquery/
│   ├── 01_Transactions.m     # M script – clean & enrich transactions
│   ├── 02_Calendar.m         # M script – generate calendar table
│   ├── 03_Categories.m       # M script – clean categories
│   └── 04_Budget.m           # M script – clean budget data
├── dax/
│   ├── measures.dax          # All DAX measures
│   └── calculated_columns.dax # DAX calculated columns
├── docs/
│   ├── dashboard_design.md   # Page-by-page visual specifications
│   └── setup_guide.md        # This file
├── scripts/
│   └── generate_data.py      # Python script to regenerate sample data
└── README.md
```
