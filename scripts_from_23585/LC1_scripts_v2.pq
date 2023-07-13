// Get Source File
let
    Source = #"Get Source Folder",
    #"Filter for File Name" = Table.SelectRows(Source, each Text.StartsWith([Name], meter_ID_num) and Text.EndsWith([Name], ".csv")),
    Custom1 = #"Filter for File Name"[Content],
    Custom2 = Custom1{0},
    #"Imported CSV" = Csv.Document(Custom2,[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Meter ID      ", type text}, {" Date / Time          ", type datetime}, {" KWH(ch: 1  set:0)   ", type number}, {" KVARH(ch: 2  set:0) ", type number}, {" KVAH(ch: 2  set:0)  ", type number}, {" PF(ch: 3  set:0)    ", type number}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{" Date / Time          ", "Date"}, {" KWH(ch: 1  set:0)   ", "kWh"}, {" KVARH(ch: 2  set:0) ", "kVARh"}, {" KVAH(ch: 2  set:0)  ", "kVAh"}, {" PF(ch: 3  set:0)    ", "PF"}, {"Meter ID      ", "Meter ID"}})
in
    #"Renamed Columns"

// meter_ID_num
"608125529" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

// Data Ops - Fill Missing
let
    Source = #"Get Source File",
    Tbl1 = Source,
    max = List.Max(Source[#"Date"]),
    min = List.Min(Source[#"Date"]),
    count = Duration.TotalMinutes(max - min) / 15,
    listdt = List.DateTimes(min, count + 1, #duration(0, 0, 15, 0)),
    listdiff = List.Difference(listdt, Tbl1[#"Date"]),
    Tbl2 = Table.FromList(listdiff, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Tbl3 = Table.RenameColumns(Tbl2, {"Column1", "Date"}),
    Tbl4 = Table.Combine({Source, Tbl3}),
    #"Sorted Rows" = Table.Sort(Tbl4,{{"Date", Order.Ascending}}),
    #"Filled Missing" = Table.FillDown(#"Sorted Rows",{"Meter ID", "kWh", "kVARh", "kVAh", "PF"})
in
    #"Filled Missing"

// Data Ops - Group By Hour
let
    Source = #"Data Ops - Fill Missing",
    #"Inserted Start of Hour" = Table.AddColumn(Source, "StartofHour", each Time.StartOfHour([Date]), type datetime),
    #"Reordered Columns2" = Table.ReorderColumns(#"Inserted Start of Hour",{"Meter ID", "Date", "StartofHour", "kWh", "kVARh", "kVAh", "PF"}),
    meter_id = List.First(List.Distinct(#"Reordered Columns2"[#"Meter ID"])),
    #"Grouped By Hour" = Table.Group(#"Reordered Columns2", {"StartofHour"}, {{"Consumption (kWh)", each List.Sum([#"kWh"]), type number}, {"Max Demand (kW)", each 4 * List.Max([#"kWh"]), type number}, {"kVAh", each List.Average([#"kVAh"])}, {"kVARh", each List.Average([#"kVARh"])}, {"PF", each List.Average([#"PF"])}}),
    #"Added Custom" = Table.AddColumn(#"Grouped By Hour", "Meter", each meter_id),
    #"Reordered Columns1" = Table.ReorderColumns(#"Added Custom",{"Meter", "StartofHour", "Consumption (kWh)", "Max Demand (kW)"})
in
    #"Reordered Columns1"