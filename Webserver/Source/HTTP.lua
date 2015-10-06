local HTTP = {}

HTTP.NewLine = String.Char(0x0D) .. String.Char(0x0A)
HTTP.End = HTTP.NewLine .. HTTP.NewLine

return HTTP