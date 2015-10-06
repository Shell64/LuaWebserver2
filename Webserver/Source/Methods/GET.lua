local QueueObject = Require("Source/Methods/Queues/QueueObject")

local HTTP = HTTP

local function NotFound(URL)
	URL = "/" .. URL
	
	return [[
<html>
	<head>
		<meta content="text/html; charset=ISO-8859-1"
		http-equiv="content-type">
		<title></title>
	</head>
	<body>
		<h1
		style="color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-style: normal; font-variant: normal; letter-spacing: normal; line-height: normal; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px;">Not
		Found</h1>
		<span
		style="color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-size: medium; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px; display: inline ! important; float: none;">The
		requested URL ]] .. URL .. [[ was not found on this server.</span><br>
		<br>
		<hr>
		<span
		style="color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-size: medium; font-style: italic; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px; display: inline ! important; float: none;">
		(]] .. Webserver.Name .. " Version " .. Webserver.Version.Major .. "." .. Webserver.Version.Minor .. "." .. Webserver.Version.Revision .. " " .. ToString(jit.os) ..[[)</span><br>
		<br>
	</body>
</html>
]]
end

local function GET(ClientConnection)
	local Queue = QueueObject.New()
	
	local HeaderInformation = {}
	
	--Pre process Connection's received data. This code will parse all the attributes in the header received and autofill in Queue's attributes. HeaderInformation is a clone of these attributes that will be passed to the sandboxed LuaPages environment.
	for Key, Value in IteratePairs(ClientConnection.IncomingData) do
		Value = Value:Trim()
		
		local Attribute = String.Match(Value, "(.*)%:")
		
		if Value:sub(1, 3) == "GET" then
			Queue.GET = String.Match(Value, "GET (.*) HTTP")
			HeaderInformation.GET = Queue.GET
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
				Queue[Attribute] = Value:Substring(FoundSeparator + 1, #Value)
				HeaderInformation[Attribute] = HeaderInformation[Attribute]
			end
		end
	end
	
	--This code bellow will search for file in various directories.
	--Variable Found is false by default, unless it finds the file and it turns into a string containing the filesystem path for the requested file.
	--Variable HostPath is the path is the website folder where the requested file is. It will be passed to the LuaPages environment so it won't be able to get out of it.
	local Found = false
	local HostPath = ""
	
	if Queue.GET:Substring(1, 1) == "/" then
		Queue.GET = Queue.GET:Substring(2, #Queue.GET)
	end
	
	--Separe the path from URI parameters.
	for I = 1, #Queue.GET do
		if Queue.GET:Substring(I, I) == "?" then
			local Parameter = Queue.GET:Substring(I, #Queue.GET)
			
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
			
			Queue.GET = Queue.GET:Substring(1, I -1)
			Queue.Parameter = Parameter
			
			break
		end
	end
	
	--Try to find the requested file in the requested host directory. If it finds, Found variable will turn into a string containing the path for it, otherwise it will remain as boolean (false)
	if FileSystem2.IsFile(Webserver.WWW .. Queue.Host .. "/" .. Queue.GET) then
		Found = Webserver.WWW .. Queue.Host .. "/" .. Queue.GET
		HostPath = Webserver.WWW .. Queue.Host .. "/"
	end
	
	--If not found yet, try to find the requested file in the requested "default" directory. If it finds, Found variable will turn into a string containing the path for it, otherwise it will remain as boolean (false)
	if not Found then
		if FileSystem2.IsFile(Webserver.WWW .. "default/" .. Queue.GET) then
			Found = Webserver.WWW .. "default/" .. Queue.GET
			HostPath = Webserver.WWW .. "default/" 
		end
	end

	--Sometimes the requested file is not pointing to a file, this will try to search for index files.
	if not Found then
		for Key, Value in IteratePairs(Webserver.Index) do
		
			--Try to find the index file in requested host directory.
			if FileSystem2.IsFile(Webserver.WWW .. Queue.Host .. "/" .. Queue.GET .. Value) then
				Found = Webserver.WWW .. Queue.Host .. "/" .. Queue.GET .. Value
				HostPath = Webserver.WWW .. Queue.Host .. "/"
				break
			end
			
			--Try to find the index file in default directory.
			if FileSystem2.IsFile(Webserver.WWW .. "default/" .. Queue.GET .. Value) then
				Found = Webserver.WWW .. "default/" .. Queue.GET .. Value
				HostPath =  Webserver.WWW .. "default/"
				break
			end
		end
	end
	
	--Get's the requested file extension and turns it into a MIME
	local Extension = "*"
	
	if Found then
		for I = 1, #Found do
			if Found:Substring(#Found - I, #Found - I) == "." then
				Extension = Found:Substring(#Found - I + 1, #Found)
				break
			end
		end
	end
	
	Extension = MIME[Extension] or MIME["*"]
	
	--If file was not found, send 404 and not found page.
	if not Found then
		local IP, Port = ClientConnection.ClientTCP:getpeername()
		Log(String.Format(Language[Webserver.Language][3], ClientConnection:GetID(), ToString(IP), ToString(Port), ToString(Found or Queue.GET)))
	
		Queue.Data = HTTP.GenerateHeader(404, {
			["Last-Modified"] = Utilities.InitTime,
			["Accept-Ranges"] = "none",
			["Content-Length"] = #NotFound(Queue.GET),
			["Content-Type"] = "text/html; charset=iso-8859-1",
		})
		
		Queue.Data = Queue.Data .. NotFound(Queue.GET)
		Queue.DataSize = #Queue.Data
		
		Table.Insert(ClientConnection.Queue, Queue)

	--else, if File was found: send the data for it, if it's a compilable page (.lua) it will compile and run the code and send the returned data.
	else
	
		local IP, Port = ClientConnection.ClientTCP:getpeername()
		Log(String.Format(Language[Webserver.Language][4], ClientConnection:GetID(), ToString(IP), ToString(Port), ToString(Found)))
		
		local FileExtension = Utilities.GetExtension(ToString(Found)):Lower()
		
		--Compile and run if it's .lua
		if FileExtension == "lua" then
			local Information = {
				Header = HeaderInformation,
				Parameter = Queue.Parameter,
				ConnectionID = ClientConnection.ID,
			}
			
			local PageData, Code = Applications.RunLuaFile(Found, HostPath, Information)
			
			--Generate the HTTP header and add it to queue for sending.
			Queue.Data = HTTP.GenerateHeader(Code, {
				["Last-Modified"] = Utilities.InitTime,
				["Accept-Ranges"] = "none",
				["Content-Length"] = #PageData,
				["Content-Type"] = Extension,
			})
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.Queue, Queue)
			
			--Add the data to queue for sending.
			local Queue = QueueObject.New()
			Queue.Data = PageData
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.Queue, Queue)
			
		--Else, its a file like any other, just send the data that it contains.
		else
			local Attributes = FileSystem2.Attributes(Found)
			
			--Generate the HTTP header and add it to queue for sending.
			Queue.Data = 
			HTTP.GenerateHeader(200, {
				["Last-Modified"] = Utilities.GetDate(Attributes.modification) ,
				["Accept-Ranges"] = "none",
				["Content-Length"] = Attributes.size,
				["Content-Type"] = Extension,
			})
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.Queue, Queue)
			
			--Add the data to queue for sending.
			local Queue = QueueObject.New()
		--	Queue.Data = FileSystem2.NewFile(Found)
		--	Queue.DataSize = Attributes.size
			Queue.Data = FileSystem2.Read(Found)
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.Queue, Queue)
		end
	end
	
end

return GET