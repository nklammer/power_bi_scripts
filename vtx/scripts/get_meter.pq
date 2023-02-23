// Get Source - V1 meter trends xlsx
let
    Source = Excel.Workbook(File.Contents("N:\bos\2023\23585-00\31 Supporting Info From Others\Client\All Buildings\Utility data\Fan Pier electric interval data\V1 meter trends.xlsx"), null, true)
in
    Source

// Get Meter
let
    Source = #"Get Source - V1 meter trends xlsx",
    #"Chart Summary SWBD1E 31309-_Sheet" = Source{[Item="Chart Summary SWBD5A",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"Chart Summary SWBD1E 31309-_Sheet", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Meter", type text}, {"Old Meter Number", type text}, {"Date", type datetime}, {"Consumption (kWh)", type number}, {"Max Demand (kW)", type number}, {"Min Demand (kW)", type number}, {"Avg Demand (kW)", type number}, {"Is Non-Billable?", type logical}, {"Temperature (°F)", type number}, {"Humidity (%)", Int64.Type}})
in
    #"Changed Type"