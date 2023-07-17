// query: Hourly Heating Load Profile

	
let
    Source = #"Hourly Gas Profile",
    #"Filtered Rows" = Table.SelectRows(Source, each ([Use Category] = "heating")),
    #"Added Conditional Column" = Table.AddColumn(#"Filtered Rows", "Building Heating Load (Btu)", each if Text.Contains([Building], "Northern") then [Therms] / 0.88 else if Text.Contains([Building], "Fan") then [Therms] / 0.88 else if Text.Contains([Building], "LC1") then [Therms] / 0.88 else [Therms] / 0.8),
    #"Multiplied Column" = Table.TransformColumns(#"Added Conditional Column", {{"Building Heating Load (Btu)", each _ * Number.Power(10,5), type number}}),
    #"Merged Queries" = Table.NestedJoin(#"Multiplied Column", {"Building"}, #"Get Table - Building Summary", {"Name"}, "Get Table - Building Summary", JoinKind.LeftOuter),
    #"Expanded Get Table - Building Summary" = Table.ExpandTableColumn(#"Merged Queries", "Get Table - Building Summary", {"Name", "Area (GSF)"}, {"Name", "Area (GSF)"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded Get Table - Building Summary",{"Name"})
in
    #"Removed Columns"