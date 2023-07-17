// query: V1 Hourly to Monthly

	
let
    Source = #"Get Source",
    V1_Meters_DefinedName = Source{[Item="V1_Meters",Kind="DefinedName"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(V1_Meters_DefinedName, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Meter", type text}, {"StartofHour", type datetime}, {"Consumption (kWh)", type number}, {"Avg Demand (kW)", type number}, {"Temperature (Â°F)", type number}, {"Humidity (%)", Int64.Type}}),
    #"Inserted Month" = Table.AddColumn(#"Changed Type", "Month", each Date.Month([StartofHour]), Int64.Type),
    #"Inserted Month Name" = Table.AddColumn(#"Inserted Month", "Month Name", each Date.MonthName([StartofHour]), type text),
    #"Inserted Year" = Table.AddColumn(#"Inserted Month Name", "Year", each Date.Year([StartofHour]), Int64.Type),
    #"Grouped Rows" = Table.Group(#"Inserted Year", {"Month Name", "Year", "Meter", "Month"}, {{"Consumption (kWh)", each List.Sum([#"Consumption (kWh)"]), type nullable number}})
in
    #"Grouped Rows"