// Get Source
let
    Source = Excel.Workbook(Web.Contents("https://company365-my.sharepoint.com/personal/jdoe_company_com/Documents/PBI%20Inputs.xlsx"), null, true)
in
    Source

// V1 elec
let
    Source = #"Get Source",
    V1_Meters_DefinedName = Source{[Item="V1_Meters",Kind="DefinedName"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(V1_Meters_DefinedName, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Meter", type text}, {"StartofHour", type datetime}, {"Consumption (kWh)", type number}, {"Avg Demand (kW)", type number}, {"Temperature (°F)", type number}, {"Humidity (%)", Int64.Type}}),
    #"Filter Outlier" = Table.AddColumn(#"Changed Type", "Relative SD", each (Number.Abs([#"Consumption (kWh)"] - List.Average(#"Changed Type"[#"Consumption (kWh)"])) / List.StandardDeviation(#"Changed Type"[#"Consumption (kWh)"])), type number),
    #"Filtered Rows" = Table.SelectRows(#"Filter Outlier", each [Relative SD] < 5),
    #"Added Connected Uses Column" = Table.AddColumn(#"Filtered Rows", "Connected Uses", each if Text.Contains([Meter], "7 H411") then "house on levels 1 and 5, first floor corridor lighting, exterior lighting, facade lighting, " else if Text.Contains([Meter], "O4P21") then "generators on level 16, UPS & security, " else if Text.Contains([Meter], "SWBD2A") then "lighting on P1, EF-(2,3,5), SF-(1,2,3,4), ERC-(1,2,3), AHU-(13,14,15), REF-3, REF-4, CWC-1, elevators, " else if Text.Contains([Meter], "SWBD3A") then "house on level 8, lighting, facade lighting, CWC-2, " else if Text.Contains([Meter], "SWBD4A") then "house on penthouse level, AHU-7, AHU-8, AHU-9, AHU-10, AHU-11, AHU-12, " else if Text.Contains([Meter], "SWBD5A") then "HV-3, AHU-(1,2,3,4,5,6), RHWP-1, RHWP-2, " else if Text.Contains([Meter], "SWBD6A") then "CIF-16, CWF-1, CHWP-5, CHWP-6, CHWP-7, CHWP-8, " else if Text.Contains([Meter], "SWBD7A") then "garage P2, garage lighting, AHWP-1, AHWP-2, RCWP-1, RCWP-2, CHWP-(1,2,3,4), PCWP-1, PCWP-2, CWP-(1,2,3,4,5), CWC-3, " else if Text.Contains([Meter], "SWBD8A") then "CT-(1,2), BP-(1,2,3,4), EAHU-(1A,1B,2A,2B,3A,3B,4A,4B,5A,5B,6A,6B), HWP-(1,2,3), HV-4, EF-6, BH-1, HRP-(1,2,3), CT-(3,4), BH-(1,2), " else "other, ")
in
    #"Added Connected Uses Column"