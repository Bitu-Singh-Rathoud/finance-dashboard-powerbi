// ============================================================
// Power Query M – Budget Table
// Source: data/budget.csv
//
// Steps:
//   1. Load CSV
//   2. Promote headers & apply types
//   3. Remove rows with missing budget amounts
//   4. Add Date column (first day of the budget month) for
//      easy relationship / time-intelligence alignment
//   5. Add YearMonth key (YYYYMM) to match Calendar table
// ============================================================

let
    Source = Csv.Document(
        File.Contents("data/budget.csv"),
        [Delimiter = ",", Columns = 5, Encoding = 65001, QuoteStyle = QuoteStyle.None]
    ),

    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    TypedTable = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"BudgetID",     Int64.Type},
            {"Year",         Int64.Type},
            {"Month",        Int64.Type},
            {"CategoryID",   Int64.Type},
            {"BudgetAmount", type number}
        }
    ),

    // Remove rows where BudgetAmount is null or zero
    FilteredRows = Table.SelectRows(
        TypedTable,
        each [BudgetAmount] <> null and [BudgetAmount] > 0
    ),

    // Add a proper Date column (first day of each budget month)
    AddDate = Table.AddColumn(
        FilteredRows,
        "Date",
        each #date([Year], [Month], 1),
        type date
    ),

    // Add YearMonth key matching Calendar[YearMonth]
    AddYearMonth = Table.AddColumn(
        AddDate,
        "YearMonth",
        each [Year] * 100 + [Month],
        Int64.Type
    )

in
    AddYearMonth
