// ============================================================
// Power Query M – Transactions Table
// Source: data/transactions.csv
//
// Steps performed:
//   1. Load CSV
//   2. Promote headers & set data types
//   3. Remove rows with invalid / missing dates
//   4. Remove exact duplicate rows
//   5. Trim whitespace from text columns
//   6. Replace blank / null CategoryName with "Uncategorized"
//   7. Replace blank / null Type with "Unknown"
//   8. Remove rows where Amount is negative (data-entry errors)
//   9. Add derived columns: Year, Month, MonthName, Quarter, Weekday
//  10. Sort by Date ascending
// ============================================================

let
    // ----------------------------------------------------------
    // 1. Load source CSV
    // ----------------------------------------------------------
    Source = Csv.Document(
        File.Contents("data/transactions.csv"),
        [Delimiter = ",", Columns = 9, Encoding = 65001, QuoteStyle = QuoteStyle.None]
    ),

    // ----------------------------------------------------------
    // 2. Promote first row as column headers
    // ----------------------------------------------------------
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // ----------------------------------------------------------
    // 3. Set data types
    // ----------------------------------------------------------
    TypedTable = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"TransactionID",  Int64.Type},
            {"Date",           type text},          // kept as text for validation step
            {"Description",    type text},
            {"CategoryID",     type text},
            {"CategoryName",   type text},
            {"Type",           type text},
            {"Amount",         type number},
            {"PaymentMethod",  type text},
            {"Notes",          type text}
        }
    ),

    // ----------------------------------------------------------
    // 4. Remove rows where Date is not a valid date string
    //    Valid format: YYYY-MM-DD
    // ----------------------------------------------------------
    FilterValidDates = Table.SelectRows(
        TypedTable,
        each
            try Date.FromText([Date]) otherwise null <> null
    ),

    // ----------------------------------------------------------
    // 5. Convert Date column to proper Date type
    // ----------------------------------------------------------
    ParsedDate = Table.TransformColumnTypes(
        FilterValidDates,
        {{"Date", type date}}
    ),

    // ----------------------------------------------------------
    // 6. Remove exact duplicate rows
    // ----------------------------------------------------------
    RemovedDuplicates = Table.Distinct(ParsedDate),

    // ----------------------------------------------------------
    // 7. Trim & clean all text columns
    // ----------------------------------------------------------
    TrimmedText = Table.TransformColumns(
        RemovedDuplicates,
        {
            {"Description",   each Text.Trim(Text.Clean(_)), type text},
            {"CategoryName",  each Text.Trim(Text.Clean(_)), type text},
            {"Type",          each Text.Trim(Text.Clean(_)), type text},
            {"PaymentMethod", each Text.Trim(Text.Clean(_)), type text},
            {"Notes",         each Text.Trim(Text.Clean(_)), type text}
        }
    ),

    // ----------------------------------------------------------
    // 8. Replace blank / null CategoryName with "Uncategorized"
    // ----------------------------------------------------------
    FillCategoryName = Table.ReplaceValue(
        TrimmedText,
        each [CategoryName],
        each if [CategoryName] = null or [CategoryName] = "" then "Uncategorized" else [CategoryName],
        Replacer.ReplaceValue,
        {"CategoryName"}
    ),

    // ----------------------------------------------------------
    // 9. Replace blank / null Type with "Unknown"
    // ----------------------------------------------------------
    FillType = Table.ReplaceValue(
        FillCategoryName,
        each [Type],
        each if [Type] = null or [Type] = "" then "Unknown" else [Type],
        Replacer.ReplaceValue,
        {"Type"}
    ),

    // ----------------------------------------------------------
    // 10. Remove rows where Amount <= 0 (negative / zero amounts
    //     are treated as data-entry errors in this dataset;
    //     expenses are stored as positive values)
    // ----------------------------------------------------------
    FilterPositiveAmounts = Table.SelectRows(
        FillType,
        each [Amount] > 0
    ),

    // ----------------------------------------------------------
    // 11. Add Year column
    // ----------------------------------------------------------
    AddYear = Table.AddColumn(
        FilterPositiveAmounts,
        "Year",
        each Date.Year([Date]),
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 12. Add Month number column
    // ----------------------------------------------------------
    AddMonth = Table.AddColumn(
        AddYear,
        "Month",
        each Date.Month([Date]),
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 13. Add MonthName column (short, e.g. "Jan")
    // ----------------------------------------------------------
    AddMonthName = Table.AddColumn(
        AddMonth,
        "MonthName",
        each Date.ToText([Date], "MMM"),
        type text
    ),

    // ----------------------------------------------------------
    // 14. Add Quarter column (e.g. "Q1")
    // ----------------------------------------------------------
    AddQuarter = Table.AddColumn(
        AddMonthName,
        "Quarter",
        each "Q" & Text.From(Date.QuarterOfYear([Date])),
        type text
    ),

    // ----------------------------------------------------------
    // 15. Add Weekday name column
    // ----------------------------------------------------------
    AddWeekday = Table.AddColumn(
        AddQuarter,
        "Weekday",
        each Date.ToText([Date], "ddd"),
        type text
    ),

    // ----------------------------------------------------------
    // 16. Sort by Date ascending
    // ----------------------------------------------------------
    SortedRows = Table.Sort(
        AddWeekday,
        {{"Date", Order.Ascending}}
    )

in
    SortedRows
