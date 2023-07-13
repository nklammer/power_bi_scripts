// Get Source Folder as query looks at folder contents
let
    Source = Folder.Files("C:\Utility data\electric interval data")
in
    Source

// Get Source File
let
    Source = #"Get Source Folder",
    #"Filter for File Name" = Table.SelectRows(Source, each Text.StartsWith([Name], meter_ID_num) and Text.EndsWith([Name], ".csv")),
    #"Invoke Custom Function1" = Table.AddColumn(#"Filter for File Name", "Transform File", each #"Transform File"([Content])),
    #"Removed Other Columns1" = Table.SelectColumns(#"Invoke Custom Function1", {"Name", "Transform File"}),
    #"Expanded Table Column1" = Table.ExpandTableColumn(#"Removed Other Columns1", "Transform File", Table.ColumnNames(#"Transform File"(#"Sample File"))),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Table Column1",{{"Name", type text}, {"Meter ID      ", Int64.Type}, {" Date / Time          ", type datetime}, {" KWH(ch: 1  set:0)   ", type number}, {" KVARH(ch: 2  set:0) ", type number}, {" KVAH(ch: 2  set:0)  ", type number}, {" PF(ch: 3  set:0)    ", type number}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Meter ID      ", "Meter ID"}, {" Date / Time          ", "Date"}, {" KWH(ch: 1  set:0)   ", "kWh"}, {" KVARH(ch: 2  set:0) ", "kVARh"}, {" KVAH(ch: 2  set:0)  ", "kVAh"}, {" PF(ch: 3  set:0)    ", "PF"}})
in
    #"Renamed Columns"

// meter_ID_num type: parameter
"608125529" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]


// Sample File as query imports example source content
let
    Source = #"Get Source Folder",
    #"Filtered Rows" = Table.SelectRows(Source, each Text.StartsWith([Name], meter_ID_num) and Text.EndsWith([Name], ".csv")),
    #"Sample File" = #"Filtered Rows"{[#"Folder Path"="C:\Utility data\electric interval data\",Name="608125529_20211003_20221102.csv"]}[Content]
in
    #"Sample File"

// meter_ID_num is a parameter of type text
"608125529" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

// Parameter1 is a parameter of type binary (executable)
#"Sample File" meta [IsParameterQuery=true, BinaryIdentifier=#"Sample File", Type="Binary", IsParameterQueryRequired=true]

// Transform File is a function that takes Parameter1 as arg
// "=>" is the goes-to operator
let
    Source = (Parameter1) => let
        Source = Csv.Document(Parameter1,[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),
        #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true])
    in
        #"Promoted Headers"
in
    Source

// Sample File
let
    Source = #"Get Source Folder",
    #"Filtered Rows" = Table.SelectRows(Source, each Text.StartsWith([Name], meter_ID_num) and Text.EndsWith([Name], ".csv")),
    content = #"Filtered Rows"{[#"Folder Path"="N:\bos\2023\23585-00\31 Supporting Info From Others\Client\!All Buildings\Utility data\LC1 electric interval data\",Name="608125529_20211003_20221102.csv"]}[Content]
in
    content

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
    #"Filled Missing" = Table.FillDown(#"Sorted Rows",{"Name", "Meter ID", "kWh", "kVARh", "kVAh", "PF"})
in
    #"Filled Missing"

// Data Ops - Group By Hour
let
    Source = #"Data Ops - Fill Missing",
    #"Inserted Start of Hour" = Table.AddColumn(Source, "StartofHour", each Time.StartOfHour([Date]), type datetime),
    #"Reordered Columns2" = Table.ReorderColumns(#"Inserted Start of Hour",{"Name", "Meter ID", "Date", "StartofHour", "kWh", "kVARh", "kVAh", "PF"}),
    meter_id = List.First(List.Distinct(#"Reordered Columns2"[#"Meter ID"])),
    #"Grouped By Hour" = Table.Group(#"Reordered Columns2", {"StartofHour"}, {{"Consumption (kWh)", each List.Sum([#"kWh"]), type number}, {"Max Demand (kW)", each 4 * List.Max([#"kWh"]), type number}, {"kVAh", each List.Average([#"kVAh"])}, {"kVARh", each List.Average([#"kVARh"])}, {"PF", each List.Average([#"PF"])}}),
    #"Added Custom" = Table.AddColumn(#"Grouped By Hour", "Meter", each meter_id),
    #"Reordered Columns1" = Table.ReorderColumns(#"Added Custom",{"Meter", "StartofHour", "Consumption (kWh)", "Max Demand (kW)"})
in
    #"Reordered Columns1"