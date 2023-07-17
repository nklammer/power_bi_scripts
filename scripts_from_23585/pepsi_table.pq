// query: Pepsi Table

let
    Source = Table.NestedJoin(#"Hourly Cooling Load Profile - Renamed", {"StartofHour", "Attribute"}, #"Hourly Heating Load Profile - Renamed", {"Start of Hour", "Building"}, "Hourly Heating Load Profile - Renamed", JoinKind.LeftOuter),
    #"Expanded Hourly Heating Load Profile - Renamed" = Table.ExpandTableColumn(Source, "Hourly Heating Load Profile - Renamed", {"Building", "Start of Hour", "Building Heating Load (Btu)"}, {"Hourly Heating Load Profile - Renamed.Building", "Hourly Heating Load Profile - Renamed.Start of Hour", "Hourly Heating Load Profile - Renamed.Building Heating Load (Btu)"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded Hourly Heating Load Profile - Renamed",{"Hourly Heating Load Profile - Renamed.Building", "Hourly Heating Load Profile - Renamed.Start of Hour"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"Hourly Heating Load Profile - Renamed.Building Heating Load (Btu)", "Heating Load (Btu)"}, {"Attribute", "Building"}}),
    #"Sorted Rows" = Table.Sort(#"Renamed Columns",{{"StartofHour", Order.Ascending}}),
    #"Convert to MBH" = Table.TransformColumns(#"Sorted Rows", {{"Cooling Load (tons)", each _ * 12, type number}}),
    #"Renamed Units MBH" = Table.RenameColumns(#"Convert to MBH",{{"Cooling Load (tons)", "Cooling Load (MBH)"}}),
    #"Divided Column" = Table.TransformColumns(#"Renamed Units MBH", {{"Heating Load (Btu)", each _ / 1000, type number}}),
    #"Renamed Units MBH 2" = Table.RenameColumns(#"Divided Column",{{"Heating Load (Btu)", "Heating Load (MBH)"}}),
    #"Switch sign of heating" = Table.TransformColumns(#"Renamed Units MBH 2", {{"Heating Load (MBH)", each _ * -1, type number}}),
    #"Unpivoted Only Selected Columns" = Table.Unpivot(#"Switch sign of heating", {"Cooling Load (MBH)", "Heating Load (MBH)"}, "Attribute", "Value")
in
    #"Unpivoted Only Selected Columns"