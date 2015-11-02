--The code inside this file will be included before any .lua page runs

do
	local Required = {}

	function Include(Path)
		if not Required[Path] then
			local Data = FileSystem2.Read(Path)
			
			if Data then
				local Ok, Err = loadstring(Data)
				
				if not Ok then
					error("Could not find include " .. Path .. " Error: " .. Err)
				else
					Required[Path] = {Ok()}
					return unpack(Required[Path])
				end
			else
				error("Could not find include " .. Path)
			end
		else
			return unpack(Required[Path])
		end
	end
end

--Check if a table has the right format (useful for checking json tables)
--Format example:
--[[
	Format = {
		address = "string",
		age = "number",
		name = "string",
		inventory = {
			["%n"] = "string"
		}
	}
]]
function CheckTableFormat(Table, Format)
	for Key, Value in pairs(Table) do
		if type(Key) == "number" then
			Key = "%n"
		end
		
		if type(Value) ~= "table" then
			if not Format[Key] then
				return false
			else
				if Format[Key] ~= type(Value) then
					return false
				end
			end
		else
			local Result = CheckFormat(Table, Format[Key])
			if not Result then
				return false
			end
		end
		
	end
	
	return true
end