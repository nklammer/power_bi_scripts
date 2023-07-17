// LC1 elec grouped by datetime

let
    Source = #"LC1 elec",
    #"Grouped Rows" = Table.Group(Source, {"StartofHour"}, {{"Sum Consumption (kWh)", each List.Sum([#"Consumption (kWh)"]), type nullable number}}),
    #"Merged Queries" = Table.NestedJoin(#"Grouped Rows", {"StartofHour"}, #"V1 elec", {"StartofHour"}, "V1 elec", JoinKind.LeftOuter),
    #"Expanded V1 elec" = Table.ExpandTableColumn(#"Merged Queries", "V1 elec", {"Meter", "StartofHour", "Consumption (kWh)", "Avg Demand (kW)", "Temperature (Â°F)", "Humidity (%)", "Connected Uses"}, {"V1 elec.Meter", "V1 elec.StartofHour", "V1 elec.Consumption (kWh)", "V1 elec.Avg Demand (kW)", "V1 elec.Temperature (Â°F)", "V1 elec.Humidity (%)", "V1 elec.Connected Uses"}),
    #"Removed Other Columns" = Table.SelectColumns(#"Expanded V1 elec",{"StartofHour", "Sum Consumption (kWh)", "V1 elec.Temperature (Â°F)", "V1 elec.Humidity (%)"}),
    #"Grouped Rows1" = Table.Group(#"Removed Other Columns", {"StartofHour"}, {{"Sum Consumption (kWh)", each List.Median([#"Sum Consumption (kWh)"]), type nullable number}, {"Temperature", each List.Median([#"V1 elec.Temperature (Â°F)"]), type nullable number}, {"Humidity (%)", each List.Median([#"V1 elec.Humidity (%)"]), type nullable number}}),
    #"Filtered Year is 2022" = Table.SelectRows(#"Grouped Rows1", each Date.Year([StartofHour]) = 2022),
    #"Merged Queries1" = Table.NestedJoin(#"Filtered Year is 2022", {"StartofHour"}, _8760_DBTemps_2022_Boston_AP, {"DATE"}, "_8760_DBTemps_2022_Boston_AP", JoinKind.LeftOuter),
    #"Expanded _8760_DBTemps_2022_Boston_AP" = Table.ExpandTableColumn(#"Merged Queries1", "_8760_DBTemps_2022_Boston_AP", {"TMP"}, {"TMP"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded _8760_DBTemps_2022_Boston_AP",{"Temperature"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"TMP", "Temperature"}})
in
    #"Renamed Columns"