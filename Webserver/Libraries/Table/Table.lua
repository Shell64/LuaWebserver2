function Table.Clone(Tab)
	local Clone = {}
	
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