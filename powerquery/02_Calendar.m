// ============================================================
// Power Query M – Calendar (Date Dimension) Table
//
// Generates a complete date table covering the full range of
// dates present in the Transactions table, plus time
// intelligence columns required by DAX.
//
// Columns produced:
//   Date, Year, Month, MonthName, MonthShort, Quarter,
//   QuarterName, Week, Weekday, WeekdayName, IsWeekend,
//   YearMonth (YYYYMM), YearMonthName (e.g. "Jan 2024"),
//   IsCurrentMonth, IsCurrentYear, MonthOffset
// ============================================================

let
    // ----------------------------------------------------------
    // 1. Derive min / max dates from the Transactions table
    //    (adjust table/column references if your table is named
    //     differently in your Power BI model)
    // ----------------------------------------------------------
    MinDate = List.Min(Transactions[Date]),
    MaxDate = List.Max(Transactions[Date]),

    // ----------------------------------------------------------
    // 2. Extend range to full calendar years
    // ----------------------------------------------------------
    StartDate = #date(Date.Year(MinDate), 1, 1),
    EndDate   = #date(Date.Year(MaxDate), 12, 31),

    // ----------------------------------------------------------
    // 3. Generate a list of every date in the range
    // ----------------------------------------------------------
    DateList = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1,0,0,0)),

    // ----------------------------------------------------------
    // 4. Convert list to a single-column table
    // ----------------------------------------------------------
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),

    // ----------------------------------------------------------
    // 5. Set Date column type
    // ----------------------------------------------------------
    TypedDate = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),

    // ----------------------------------------------------------
    // 6. Year
    // ----------------------------------------------------------
    AddYear = Table.AddColumn(TypedDate, "Year", each Date.Year([Date]), Int64.Type),

    // ----------------------------------------------------------
    // 7. Month number
    // ----------------------------------------------------------
    AddMonth = Table.AddColumn(AddYear, "Month", each Date.Month([Date]), Int64.Type),

    // ----------------------------------------------------------
    // 8. Full month name (e.g. "January")
    // ----------------------------------------------------------
    AddMonthName = Table.AddColumn(AddMonth, "MonthName", each Date.ToText([Date], "MMMM"), type text),

    // ----------------------------------------------------------
    // 9. Short month name (e.g. "Jan")
    // ----------------------------------------------------------
    AddMonthShort = Table.AddColumn(AddMonthName, "MonthShort", each Date.ToText([Date], "MMM"), type text),

    // ----------------------------------------------------------
    // 10. Quarter number (1-4)
    // ----------------------------------------------------------
    AddQuarterNum = Table.AddColumn(AddMonthShort, "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),

    // ----------------------------------------------------------
    // 11. Quarter label (e.g. "Q1 2024")
    // ----------------------------------------------------------
    AddQuarterName = Table.AddColumn(
        AddQuarterNum,
        "QuarterName",
        each "Q" & Text.From([Quarter]) & " " & Text.From([Year]),
        type text
    ),

    // ----------------------------------------------------------
    // 12. ISO week number
    // ----------------------------------------------------------
    AddWeek = Table.AddColumn(
        AddQuarterName,
        "Week",
        each Date.WeekOfYear([Date]),
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 13. Weekday number (1 = Monday … 7 = Sunday)
    // ----------------------------------------------------------
    AddWeekday = Table.AddColumn(
        AddWeek,
        "Weekday",
        each Date.DayOfWeek([Date], Day.Monday) + 1,
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 14. Weekday full name
    // ----------------------------------------------------------
    AddWeekdayName = Table.AddColumn(
        AddWeekday,
        "WeekdayName",
        each Date.ToText([Date], "dddd"),
        type text
    ),

    // ----------------------------------------------------------
    // 15. IsWeekend flag
    // ----------------------------------------------------------
    AddIsWeekend = Table.AddColumn(
        AddWeekdayName,
        "IsWeekend",
        each if [Weekday] >= 6 then 1 else 0,
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 16. YearMonth key (YYYYMM integer, useful for sorting)
    // ----------------------------------------------------------
    AddYearMonth = Table.AddColumn(
        AddIsWeekend,
        "YearMonth",
        each [Year] * 100 + [Month],
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 17. YearMonthName label (e.g. "Jan 2024")
    // ----------------------------------------------------------
    AddYearMonthName = Table.AddColumn(
        AddYearMonth,
        "YearMonthName",
        each [MonthShort] & " " & Text.From([Year]),
        type text
    ),

    // ----------------------------------------------------------
    // 18. MonthOffset – months relative to a reference date
    //     (0 = reference month, -1 = previous month, etc.)
    //
    //     Using DateTime.LocalNow() so the dashboard stays
    //     accurate when refreshed in future months.
    //     For a fully static / historical dataset, replace
    //     DateTime.LocalNow() with a fixed date, e.g.:
    //         ReferenceDate = #date(2024, 12, 31)
    // ----------------------------------------------------------
    Today = DateTime.Date(DateTime.LocalNow()),
    AddMonthOffset = Table.AddColumn(
        AddYearMonthName,
        "MonthOffset",
        each ([Year] - Date.Year(Today)) * 12 + ([Month] - Date.Month(Today)),
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 19. IsCurrentMonth flag
    // ----------------------------------------------------------
    AddIsCurrentMonth = Table.AddColumn(
        AddMonthOffset,
        "IsCurrentMonth",
        each if [MonthOffset] = 0 then 1 else 0,
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 20. IsCurrentYear flag
    // ----------------------------------------------------------
    AddIsCurrentYear = Table.AddColumn(
        AddIsCurrentMonth,
        "IsCurrentYear",
        each if [Year] = Date.Year(Today) then 1 else 0,
        Int64.Type
    )

in
    AddIsCurrentYear
