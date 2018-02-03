local HTTP = {}

local IteratePairs = IteratePairs
local Pairs = Pairs
local ToNumber = ToNumber
local Math_Floor = Math.Floor
local String_Char = String.Char
local String_Format = String.Format
local String_Match = String.Match

-------------------------------------
--HTTP End line characters
-------------------------------------
HTTP.NewLine = String_Char(0x0D) .. String_Char(0x0A)
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
	"Server: " .. String_Format("%s %i.%i.%i", Webserver.Name, Webserver.Version.Major, Webserver.Version.Minor, Webserver.Version.Revision) .. HTTP.NewLine
	
	for Key, Value in Pairs(Headers) do
		Header = Header .. ToString(Key) .. ": " .. ToString(Value) .. HTTP.NewLine
	end
	
	Header = Header .. HTTP.NewLine
	
	return Header
end

--Convert URI escapes such %20, etc.
function HTTP.ProcessUnicodeEscapes(Parameter)
	local Count = 0
	local NewStr = ""
	local LastIndex = 1
	local FoundIndex = Parameter:Find("%", nil, true)
	
	while FoundIndex do
		Count = Count + 1
		NewStr = NewStr .. Parameter:Substring(LastIndex, FoundIndex - 1)
		
		local Number = ToNumber("0x" .. Parameter:Substring(FoundIndex + 1, FoundIndex + 2))
		
		if Number then
			if Number <= 127 then
				NewStr = String_Format("%s%c", NewStr, Number)
			elseif Number < 2048 then
				NewStr = String_Format("%s%c%c", NewStr, 192 + Math_Floor (Number / 64), 128 + (Number % 64))
			elseif Number < 65536 then
				NewStr = String_Format("%s%c%c%c", NewStr, 224 + Math_Floor (Number / 4096), 128 + (Math_Floor (Number / 64) % 64), 128 + (Number % 64))
			elseif Number < 2097152 then
				NewStr = String_Format("%s%c%c%c%c", NewStr, 240 + Math_Floor (Number / 262144), 128 + (Math_Floor (Number / 4096) % 64), 128 + (Math_Floor (Number / 64) % 64), 128 + (Number % 64))
			end
		end
		
		LastIndex = FoundIndex + 3
		FoundIndex = Parameter:Find("%", LastIndex, true)
	end
	
	if Count == 0 then
		return Parameter
	else
		return NewStr
	end
end

function HTTP.ParseHeader(HTTP_Header)
	local HeaderInformation = {}

	--Pre process Connection's received data. This code will parse all the attributes in the header received and autofill in HeaderInformation's attributes. HeaderInformation is a clone of these attributes that will be passed to the sandboxed LuaPages environment.
	for Key, Value in IteratePairs(HTTP_Header:Split("\n", 32)) do
		Value = Value:Trim()
		
		local Attribute = String_Match(Value, "(.*)%:")
		
		if Value:Substring(1, 3) == "GET" then
			HeaderInformation.Method = "GET"
			HeaderInformation.MethodData = String_Match(Value, "GET (.*) HTTP")
		elseif Value:Substring(1, 4) == "POST" then
			HeaderInformation.Method = "POST"
			HeaderInformation.MethodData = String_Match(Value, "POST (.*) HTTP")
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

	HeaderInformation.Host = HeaderInformation.Host or "0:0"
	HeaderInformation.MethodData = HeaderInformation.MethodData or "/"
	
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
		HeaderInformation.MethodData = HTTP.ProcessUnicodeEscapes(HeaderInformation.MethodData)
		
		--End of URI escapes code.
		
		--Separe ? parameters
		if HeaderInformation.MethodData:Substring(I, I) == "?" then
			local Parameter = HeaderInformation.MethodData:Substring(I + 1, #HeaderInformation.MethodData)
			
			HeaderInformation.MethodData = HeaderInformation.MethodData:Substring(1, I -1)
			HeaderInformation.Parameter = Parameter
			
			break
		end
	end
	
	if HeaderInformation.HostFolder then
		HeaderInformation.HostFolder = HeaderInformation.HostFolder:GSubstring("%.", "")
	end
	
	if HeaderInformation.MethodData then
		HeaderInformation.MethodData = Utilities.FixPath(HeaderInformation.MethodData)
	end
	
	return HeaderInformation
end

return HTTP