// ============================================================
// Power Query M – Categories Table
// Source: data/categories.csv
//
// Steps:
//   1. Load CSV
//   2. Promote headers & apply types
//   3. Trim text columns
//   4. Remove blank / null rows
//   5. Add CategoryGroup column (groups categories for
//      high-level reporting)
// ============================================================

let
    Source = Csv.Document(
        File.Contents("data/categories.csv"),
        [Delimiter = ",", Columns = 3, Encoding = 65001, QuoteStyle = QuoteStyle.None]
    ),

    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    TypedTable = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"CategoryID",   Int64.Type},
            {"CategoryName", type text},
            {"Type",         type text}
        }
    ),

    // Trim text
    TrimmedText = Table.TransformColumns(
        TypedTable,
        {
            {"CategoryName", Text.Trim, type text},
            {"Type",         Text.Trim, type text}
        }
    ),

    // Remove blank rows
    FilteredRows = Table.SelectRows(
        TrimmedText,
        each [CategoryName] <> null and [CategoryName] <> ""
    ),

    // Add high-level group for dashboard filtering
    AddGroup = Table.AddColumn(
        FilteredRows,
        "CategoryGroup",
        each
            if [Type] = "Income"   then "Income"
            else if [Type] = "Transfer" then "Transfer"
            else if List.Contains({"Housing", "Utilities"}, [CategoryName]) then "Fixed Expenses"
            else "Variable Expenses",
        type text
    )

in
    AddGroup
