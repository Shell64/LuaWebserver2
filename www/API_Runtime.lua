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