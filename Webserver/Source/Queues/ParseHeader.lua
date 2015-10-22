function HTTP.ParseHeader(Data)
	local HeaderInformation = {}

	--Pre process Connection's received data. This code will parse all the attributes in the header received and autofill in HeaderInformation's attributes. HeaderInformation is a clone of these attributes that will be passed to the sandboxed LuaPages environment.
	for Key, Value in IteratePairs(ClientConnection.IncomingData) do
		Value = Value:Trim()
		
		local Attribute = String.Match(Value, "(.*)%:")
		
		if Value:sub(1, 3) == "GET" then
			HeaderInformation.GET = String.Match(Value, "GET (.*) HTTP")
		else
			
			local Attribute = ""
			
			local Value2 = Value:Replace(" ", "")
			
			local FoundSeparator = 1
			for I = 1, #Value2 do
				local Char = Value2:Substring(I, I)
				
				if Char == ":" then
					FoundSeparator = I
					
					break
				else
					Attribute = Attribute .. Char
				end
			end
			
			if not (Attribute == "Data" or Attribute == "TotalSentBytes" or Attribute == "SentBytes" or Attribute == "DataSize" or Attribute == "BlockIndex" or Attribute == "GET" or Attribute:Substring(1, 1) == "_") then
				HeaderInformation[Attribute] = Value:Substring(FoundSeparator + 2, #Value)
			end
		end
	end

	local Start = HeaderInformation.Host:Find(":")

	if Start then
		HeaderInformation.HostFolder = HeaderInformation.Host:Substring(1, Start - 1)
		HeaderInformation.Port = HeaderInformation.Host:Substring(Start + 1, #HeaderInformation.Host)
	end

	if HeaderInformation.GET:Substring(1, 1) == "/" then
		HeaderInformation.GET = HeaderInformation.GET:Substring(2, #HeaderInformation.GET)
	end

	--Separe the path from URI parameters.
	for I = 1, #HeaderInformation.GET do
		if HeaderInformation.GET:Substring(I, I) == "?" then
			local Parameter = HeaderInformation.GET:Substring(I, #HeaderInformation.GET)
			
			--Convert URI escapes such %20, etc.
			local StartEscape = 1
			local LastEscape = 1
			local FoundEscape = false
			local NewParameter = ""
			for I = 1, #Parameter do
				if not FoundEscape then
					if Parameter:Substring(I, I) == "%" then
						StartEscape = I
						FoundEscape = true
						
						NewParameter = NewParameter .. Parameter:Substring(LastEscape, StartEscape - 1)
					end
				else
					if not ToNumber(Parameter:Substring(I, I)) or I == #Parameter then
						local Number = ToNumber("0x" .. Parameter:Substring(StartEscape + 1, I - 1))
						
						if Number then
							NewParameter = NewParameter .. String.Char(Number)
						end
						
						
						LastEscape = I
						FoundEscape = false
					end
				end
			end
			
			NewParameter = NewParameter .. Parameter:Substring(LastEscape, #Parameter)
			
			if NewParameter ~= "" then
				Parameter = NewParameter
			end
			--End of URI escapes code.
			
			HeaderInformation.GET = HeaderInformation.GET:Substring(1, I -1)
			HeaderInformation.Parameter = Parameter
			
			break
		end
	end
	
	return HeaderInformation
end