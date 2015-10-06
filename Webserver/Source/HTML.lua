local HTML = Class.New("HTML")

function HTML.Table(Tab, TableAttributes)
	local HTMLCode = ""
	
	if TableAttributes then
		HTMLCode = HTMLCode .. [[<table ]] .. TableAttributes .. [[">]]
	else
		HTMLCode = HTMLCode .. [[<table border="1" style="border: 1px solid black;">]]
	end
	
	for Key, Row in IteratePairs(Tab) do
		HTMLCode = HTMLCode .. "<p><tr>"
		
		if Type(Row) == "table" then
			local Attributes = Row.Attributes or ""
			
			for Key2, Value2 in IteratePairs(Row) do
				HTMLCode = HTMLCode .. "<td " .. Attributes .. " >" .. ToString(Value2) .. "</td>"
			end
		else
			HTMLCode = HTMLCode .. "<td>" .. ToString(Row) .. "</td>"
			
		end
		
		HTMLCode = HTMLCode .. "</tr></p>"
	end
	
	HTMLCode = HTMLCode .. "</table>"
	
	return HTMLCode
end

return HTML