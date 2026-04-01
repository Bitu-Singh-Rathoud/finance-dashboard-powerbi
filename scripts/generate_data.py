"""
generate_data.py
================
Generates sample CSV data files for the Personal Finance Power BI Dashboard.

Output files (written to the ``data/`` folder relative to this script):
  - transactions.csv   ~350 rows of individual transactions for 2024
  - budget.csv         108 rows  (9 expense categories × 12 months)
  - categories.csv     14 rows

Usage
-----
    python scripts/generate_data.py

Requirements: Python 3.8+  (stdlib only – no external packages)
"""

import csv
import os
import random
from datetime import date, timedelta

# ── Reproducible random data ──────────────────────────────────────────────────
random.seed(42)

# Resolve paths relative to the repo root (one level up from scripts/)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)
DATA_DIR = os.path.join(REPO_ROOT, "data")
os.makedirs(DATA_DIR, exist_ok=True)


# ── Category master data ──────────────────────────────────────────────────────
CATEGORIES = [
    {"CategoryID": 1,  "CategoryName": "Housing",       "Type": "Expense"},
    {"CategoryID": 2,  "CategoryName": "Groceries",     "Type": "Expense"},
    {"CategoryID": 3,  "CategoryName": "Utilities",     "Type": "Expense"},
    {"CategoryID": 4,  "CategoryName": "Transport",     "Type": "Expense"},
    {"CategoryID": 5,  "CategoryName": "Dining Out",    "Type": "Expense"},
    {"CategoryID": 6,  "CategoryName": "Entertainment", "Type": "Expense"},
    {"CategoryID": 7,  "CategoryName": "Healthcare",    "Type": "Expense"},
    {"CategoryID": 8,  "CategoryName": "Shopping",      "Type": "Expense"},
    {"CategoryID": 9,  "CategoryName": "Education",     "Type": "Expense"},
    {"CategoryID": 10, "CategoryName": "Savings",       "Type": "Transfer"},
    {"CategoryID": 11, "CategoryName": "Salary",        "Type": "Income"},
    {"CategoryID": 12, "CategoryName": "Freelance",     "Type": "Income"},
    {"CategoryID": 13, "CategoryName": "Investment",    "Type": "Income"},
    {"CategoryID": 14, "CategoryName": "Other Income",  "Type": "Income"},
]

# Monthly budget per expense category (CategoryID → amount)
EXPENSE_BUDGETS = {1: 1500, 2: 600, 3: 200, 4: 300, 5: 250,
                   6: 150,  7: 200, 8: 300, 9: 100}

# Description / base-amount templates per category
TEMPLATES = {
    1:  [("Rent payment", 1450), ("Mortgage installment", 1200)],
    2:  [("Supermarket", 80), ("Grocery Store", 60), ("Farmers market", 40)],
    3:  [("Electricity bill", 90), ("Water bill", 45),
         ("Internet subscription", 55), ("Gas bill", 65)],
    4:  [("Fuel", 70), ("Bus pass", 50), ("Taxi ride", 25), ("Parking fee", 15)],
    5:  [("Restaurant", 45), ("Cafe", 18), ("Fast food", 12), ("Pizza", 30)],
    6:  [("Netflix", 15), ("Cinema tickets", 35), ("Concert", 60), ("Gaming", 40)],
    7:  [("Doctor visit", 80), ("Pharmacy", 35), ("Gym membership", 50)],
    8:  [("Clothing", 120), ("Electronics", 200), ("Home goods", 75)],
    9:  [("Online course", 50), ("Books", 25)],
    10: [("Transfer to savings", 500)],
    11: [("Monthly salary", 5000), ("Bonus", 1000)],
    12: [("Freelance project", 800), ("Consulting fee", 600)],
    13: [("Dividend income", 150), ("Stock sale profit", 300)],
    14: [("Cash gift", 100), ("Tax refund", 400)],
}

PAYMENT_METHODS_FIXED    = ["Bank Transfer", "Direct Debit", "Credit Card"]
PAYMENT_METHODS_VARIABLE = ["Cash", "Credit Card", "Debit Card", "Bank Transfer"]
NOTES_OPTIONS            = ["", "", "", "Recurring", "Optional", "Planned"]

# Categories with a fixed monthly entry on the 1st
MONTHLY_FIXED_CATEGORIES = {1, 3, 10, 11}

# Categories with random variable transactions
VARIABLE_CATEGORIES = [2, 4, 5, 6, 7, 8, 9, 12, 13, 14]


def _category_by_id(cid: int) -> dict:
    return next(c for c in CATEGORIES if c["CategoryID"] == cid)


def _make_transaction(tid: int, txn_date: date, cid: int,
                      payment_methods: list, notes_options: list) -> dict:
    desc, base = random.choice(TEMPLATES[cid])
    amount = round(base * random.uniform(0.95, 1.05), 2)
    cat = _category_by_id(cid)
    return {
        "TransactionID": tid,
        "Date": txn_date.isoformat(),
        "Description": desc,
        "CategoryID": cid,
        "CategoryName": cat["CategoryName"],
        "Type": cat["Type"],
        "Amount": amount,
        "PaymentMethod": random.choice(payment_methods),
        "Notes": random.choice(notes_options),
    }


def generate_categories() -> None:
    path = os.path.join(DATA_DIR, "categories.csv")
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["CategoryID", "CategoryName", "Type"])
        writer.writeheader()
        writer.writerows(CATEGORIES)
    print(f"  categories.csv  – {len(CATEGORIES):>4} rows")


def generate_budget() -> None:
    rows = []
    bid = 1
    for month in range(1, 13):
        year = 2024
        for cid, amount in EXPENSE_BUDGETS.items():
            rows.append({
                "BudgetID": bid,
                "Year": year,
                "Month": month,
                "CategoryID": cid,
                "BudgetAmount": amount,
            })
            bid += 1

    path = os.path.join(DATA_DIR, "budget.csv")
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f, fieldnames=["BudgetID", "Year", "Month", "CategoryID", "BudgetAmount"]
        )
        writer.writeheader()
        writer.writerows(rows)
    print(f"  budget.csv      – {len(rows):>4} rows")


def generate_transactions() -> None:
    start_date = date(2024, 1, 1)
    end_date   = date(2024, 12, 31)
    rows = []
    tid = 1

    # ── Fixed monthly transactions (1st of each month) ────────────────────────
    current = start_date
    while current <= end_date:
        if current.day == 1:
            for cid in MONTHLY_FIXED_CATEGORIES:
                row = _make_transaction(
                    tid, current, cid,
                    PAYMENT_METHODS_FIXED, [""]
                )
                rows.append(row)
                tid += 1
        current += timedelta(days=1)

    # ── Variable transactions (random dates throughout the year) ──────────────
    for _ in range(300):
        cid = random.choice(VARIABLE_CATEGORIES)
        offset = random.randint(0, (end_date - start_date).days)
        txn_date = start_date + timedelta(days=offset)
        row = _make_transaction(
            tid, txn_date, cid,
            PAYMENT_METHODS_VARIABLE, NOTES_OPTIONS
        )
        rows.append(row)
        tid += 1

    # ── Intentionally dirty rows (to demonstrate Power Query cleaning) ────────
    dirty_rows = [
        {   # Invalid date – will be removed by Power Query
            "TransactionID": tid,
            "Date": "N/A",
            "Description": "Unknown charge",
            "CategoryID": "",
            "CategoryName": "Unknown",
            "Type": "",
            "Amount": -50,
            "PaymentMethod": "Credit Card",
            "Notes": "needs review",
        },
        {   # Leading whitespace in description + duplicate below
            "TransactionID": tid + 1,
            "Date": "2024-07-15",
            "Description": "  Duplicate item",
            "CategoryID": 5,
            "CategoryName": "Dining Out",
            "Type": "Expense",
            "Amount": 25.0,
            "PaymentMethod": "Cash",
            "Notes": "",
        },
        {   # Exact duplicate of the row above
            "TransactionID": tid + 2,
            "Date": "2024-07-15",
            "Description": "  Duplicate item",
            "CategoryID": 5,
            "CategoryName": "Dining Out",
            "Type": "Expense",
            "Amount": 25.0,
            "PaymentMethod": "Cash",
            "Notes": "",
        },
        {   # Missing category
            "TransactionID": tid + 3,
            "Date": "2024-11-22",
            "Description": "Missing category",
            "CategoryID": "",
            "CategoryName": "",
            "Type": "",
            "Amount": 75.5,
            "PaymentMethod": "Debit Card",
            "Notes": "",
        },
    ]
    rows.extend(dirty_rows)

    # Sort by date
    rows.sort(key=lambda r: r["Date"])

    fields = [
        "TransactionID", "Date", "Description", "CategoryID",
        "CategoryName", "Type", "Amount", "PaymentMethod", "Notes",
    ]
    path = os.path.join(DATA_DIR, "transactions.csv")
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    print(f"  transactions.csv– {len(rows):>4} rows  (includes 4 intentionally dirty rows)")


def main() -> None:
    print("Generating sample data into data/ …")
    generate_categories()
    generate_budget()
    generate_transactions()
    print("Done.")


if __name__ == "__main__":
    main()
