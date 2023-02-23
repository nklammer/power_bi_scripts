// Get Source - V1 meter trends xlsx
let
    Source = Excel.Workbook(File.Contents("N:\bos\2023\23585-00\31 Supporting Info From Others\Client\All Buildings\Utility data\Fan Pier electric interval data\V1 meter trends.xlsx"), null, true)
in
    Source