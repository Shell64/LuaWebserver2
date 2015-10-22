local HTTP = {}

-------------------------------------
--HTTP End line characters
-------------------------------------
HTTP.NewLine = String.Char(0x0D) .. String.Char(0x0A)
HTTP.End = HTTP.NewLine .. HTTP.NewLine

-------------------------------------
--HTTP Response codes
-------------------------------------
HTTP.ResponseCodes = {
	[100] = "100 Continue",
	[101] = "101 Switching Protocols",

	[200] = "200 OK",
	[201] = "201 Created",
	[202] = "202 Accepted",
	[203] = "203 Non-Authoritative Information",
	[204] = "204 No Content",
	[205] = "205 Reset Content",
	[206] = "206 Partial Content",

	[300] = "300 Multiple Choices",
	[301] = "301 Moved Permanently",
	[302] = "302 Found",
	[303] = "303 See Other",
	[304] = "304 Not Modified",
	[305] = "305 Use Proxy",
	[306] = "306 (Unused)",
	[307] = "307 Temporary Redirect",

	[400] = "400 Bad Request",
	[401] = "401 Unauthorized",
	[402] = "402 Payment Required",
	[403] = "403 Forbidden",
	[404] = "404 Not Found",
	[405] = "405 Method Not Allowed",
	[406] = "406 Not Acceptable",
	[407] = "407 Proxy Authentication Required",
	[408] = "408 Request Timeout",
	[409] = "409 Conflict",
	[410] = "410 Gone",
	[411] = "411 Length Required",
	[412] = "412 Precondition Failed",
	[413] = "413 Request Entity Too Large",
	[414] = "414 Request-URI Too Long",
	[415] = "415 Unsupported Media Type",
	[416] = "416 Requested Range Not Satisfiable",
	[417] = "417 Expectation Failed",

	[500] = "500 Internal Server Error",
	[501] = "501 Not Implemented",
	[502] = "502 Bad Gateway",
	[503] = "503 Service Unavailable",
	[504] = "504 Gateway Timeout",
	[505] = "505 HTTP Version Not Supported",
}

-------------------------------------
--Methods
-------------------------------------

function HTTP.GenerateHeader(Code, Headers)
	local Header = 
	"HTTP/1.1 " .. HTTP.ResponseCodes[Code] .. HTTP.NewLine .. 
	"Date: " .. Utilities.Date() .. HTTP.NewLine .. 
	"Server: " .. String.Format("%s %i.%i.%i", Webserver.Name, Webserver.Version.Major, Webserver.Version.Minor, Webserver.Version.Revision) .. HTTP.NewLine
	
	for Key, Value in Pairs(Headers) do
		Header = Header .. ToString(Key) .. ": " .. ToString(Value) .. HTTP.NewLine
	end
	
	Header = Header .. HTTP.NewLine
	
	return Header
end

function HTTP.ParseHeader(HTTP_Header)
	local HeaderInformation = {}

	--Pre process Connection's received data. This code will parse all the attributes in the header received and autofill in HeaderInformation's attributes. HeaderInformation is a clone of these attributes that will be passed to the sandboxed LuaPages environment.
	for Key, Value in IteratePairs(HTTP_Header:Split("\n", 32)) do
		Value = Value:Trim()
		
		local Attribute = String.Match(Value, "(.*)%:")
		
		if Value:sub(1, 3) == "GET" then
			HeaderInformation.Method = "GET"
			HeaderInformation.MethodData = String.Match(Value, "GET (.*) HTTP")
		elseif Value:sub(1, 4) == "POST" then
			HeaderInformation.Method = "POST"
			HeaderInformation.MethodData = String.Match(Value, "POST (.*) HTTP")
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
			
			HeaderInformation[Attribute] = Value:Substring(FoundSeparator + 2, #Value)
		end
	end

	local Start = HeaderInformation.Host:Find(":")

	if Start then
		HeaderInformation.HostFolder = HeaderInformation.Host:Substring(1, Start - 1)
		HeaderInformation.Port = HeaderInformation.Host:Substring(Start + 1, #HeaderInformation.Host)
	end

	if HeaderInformation.MethodData:Substring(1, 1) == "/" then
		HeaderInformation.MethodData = HeaderInformation.MethodData:Substring(2, #HeaderInformation.MethodData)
	end

	--Separe the path from URI parameters.
	for I = 1, #HeaderInformation.MethodData do
		if HeaderInformation.MethodData:Substring(I, I) == "?" then
			local Parameter = HeaderInformation.MethodData:Substring(I + 1, #HeaderInformation.MethodData)
			
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
			
			HeaderInformation.MethodData = HeaderInformation.MethodData:Substring(1, I -1)
			HeaderInformation.Parameter = Parameter
			
			break
		end
	end
	
	return HeaderInformation
end

return HTTP