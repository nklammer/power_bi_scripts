let
    Source = Table.NestedJoin(#"8760_hours_stub", {"DATE"}, Boston_Logan_AP_Global_DB, {"DATE"}, "Boston_Logan_AP_Global_DB", JoinKind.LeftOuter),
    #"Expanded Boston_Logan_AP_Global_DB" = Table.ExpandTableColumn(Source, "Boston_Logan_AP_Global_DB", {"TMP"}, {"TMP"}),
    #"Sorted Rows" = Table.Sort(#"Expanded Boston_Logan_AP_Global_DB",{{"DATE", Order.Ascending}}),
    #"Filtered Rows" = Table.SelectRows(#"Sorted Rows", each ([TMP] <> null)),
    #"Kept Rows" = Table.FirstN(#"Filtered Rows", 100),
    #"Added Custom" = Table.AddColumn(
        #"Kept Rows", "Custom", each try // for each row, try
            let currentValue_= Number.From([TMP]), // currentValue_ is the value of this row
                numSteps_ = 24 * Number.From(  // numSteps_ is the date number equivalent of the time diff
                    List.Select(
                        #"Kept Rows"[DATE], // calls the whole list, not just the row
                        (inner)=>inner> [DATE] // select all rows greater than the current row date
                    ){0}-[DATE] // take the first row of all rows greather than the current row (aka the next value)
                ), 
                nextValue_ = Table.SelectRows(
                    #"Kept Rows",
                    (inner)=>inner[DATE]> [DATE]
                    )[TMP]{0}  
            in Table.FromColumns(
                {List.Numbers(Number.From([DATE]), numSteps_, 1/24), // col 1 
                List.Numbers(  // col 2
                    currentValue_, // start as number
                    numSteps_, // count as number, multiply by hours (3 hours typ)
                    (nextValue_-currentValue_)/numSteps_ // increment as nullable number
                )}
                )
            otherwise Table.FromColumns({{Number.From([DATE])},{[TMP]}})
    ),
    #"Expanded Custom.1" = Table.ExpandTableColumn(#"Added Custom", "Custom", {"Column1", "Column2"}, {"Column1", "Column2"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Expanded Custom.1",{{"Column1", type datetime}, {"Column2", type number}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type1",{"DATE", "TMP"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"Column1", "DATE"}, {"Column2", "TMP"}})
in
    #"Renamed Columns"