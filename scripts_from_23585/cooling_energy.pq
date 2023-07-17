// query: Cooling Energy

	
let
    Source = #"_8760_DBTemps_2022_Boston_AP",
    #"Changed Type1" = Table.TransformColumnTypes(Source,{{"DATE", type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type1","/2022","/2025",Replacer.ReplaceText,{"DATE"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Replaced Value",{{"DATE", type datetime}}),
    #"Merged Queries1" = Table.NestedJoin(#"Changed Type2", {"DATE"}, _8760_DBTemps_TMY_Boston_AP, {"Date"}, "_8760_DBTemps_TMY_Boston_AP", JoinKind.Inner),
    #"Expanded _8760_DBTemps_TMY_Boston_AP" = Table.ExpandTableColumn(#"Merged Queries1", "_8760_DBTemps_TMY_Boston_AP", {"Dry Bulb (°C)"}, {"Dry Bulb (°C)"}),
    #"Multiplied Column" = Table.TransformColumns(#"Expanded _8760_DBTemps_TMY_Boston_AP", {{"Dry Bulb (°C)", each (_ * 1.8) + 32, type number}}),
    #"Removed Columns" = Table.RemoveColumns(#"Multiplied Column",{"TMP"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"DATE", "StartofHour"}, {"Dry Bulb (°C)", "Temperature"}}),
    #"Inserted V1 cooling" = Table.AddColumn(#"Renamed Columns", "V1 Cooling (kWh)", each if ([Temperature] >= 50) then (([Temperature] - 50) * 17.87) else 0, type number)  // simple linear regression from average of temp bins by kWh
  // simple linear regression from average of temp bins by kWh
  // simple linear regression from average of temp bins by kWh
,
    #"Inserted V2 cooling" = Table.AddColumn(#"Inserted V1 cooling", "V2 Cooling (kWh)", each if ([Temperature] >= 50) then (([Temperature] - 50) * 10.97) else 0, type number) // simple linear regression on binned kWh by temperature
,
    #"Inserted LC1 cooling" = Table.AddColumn(#"Inserted V2 cooling", "LC1 Cooling (kWh)", each if ([Temperature] >= 45) then (([Temperature] - 45) * 17.89) else 0, type number),
    #"Merged Queries" = Table.NestedJoin(#"Inserted LC1 cooling", {"StartofHour"}, #"VMC elec", {"StartofHour"}, "VMC elec", JoinKind.LeftOuter),
    #"Expanded VMC elec" = Table.ExpandTableColumn(#"Merged Queries", "VMC elec", {"Cooling kWh"}, {"VMC elec.Cooling kWh"})
in
    #"Expanded VMC elec"