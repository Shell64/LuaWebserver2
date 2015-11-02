function Table.Clone(Tab, Meta)
	local Clone = {}
	
	if Meta then
		setmetatable(Tab, Meta)
	end
	
	for Key, Value in Pairs(Tab) do
		if Type(Value) == "table" then
			Clone[Key] = {}
			for Key2, Value2 in Pairs(Value) do
				Clone[Key][Key2] = Value2
			end
		else
			Clone[Key] = Value
		end
	end
	
	return Clone
end
table.copy = Table.Clone
table.Copy = Table.Clone
table.clone = Table.Clone