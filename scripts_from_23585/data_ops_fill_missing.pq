// Data Ops - Fill Missing
let
    Source = #"Get Meter",
    Tbl1 = Source,
    max = List.Max(#"Get Meter"[Date]),
    min = List.Min(#"Get Meter"[Date]),
    count = Duration.TotalMinutes(max - min) / 15,
    listdt = List.DateTimes(min, count + 1, #duration(0, 0, 15, 0)),
    listdiff = List.Difference(listdt, Tbl1[Date]),
    Tbl2 = Table.FromList(listdiff, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Tbl3 = Table.RenameColumns(Tbl2, {"Column1", "Date"}),
    Tbl4 = Table.Combine({Source, Tbl3}),
    #"Sorted Rows" = Table.Sort(Tbl4,{{"Date", Order.Ascending}}),
    #"Filled Missing" = Table.FillDown(#"Sorted Rows",{"Meter", "Consumption (kWh)", "Max Demand (kW)", "Min Demand (kW)", "Avg Demand (kW)", "Temperature (°F)", "Humidity (%)"})
in
    #"Filled Missing"