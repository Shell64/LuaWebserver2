﻿local HTTP = HTTP

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

local function GET(ClientConnection, HeaderInformation, HeaderContent)
	local Queue = SendQueueObject.New()
	
	HeaderInformation.HostFolder = HeaderInformation.HostFolder or ""
	HeaderInformation.MethodData = HeaderInformation.MethodData or ""
	
	--This code bellow will search for file in various directories.
	--Variable Found is false by default, unless it finds the file and it turns into a string containing the filesystem path for the requested file.
	--Variable HostPath is the path is the website folder where the requested file is. It will be passed to the LuaPages environment so it won't be able to get out of it.
	local Found = false
	local HostPath = ""
	
	--Try to find the requested file in the requested host directory. If it finds, Found variable will turn into a string containing the path for it, otherwise it will remain as boolean (false)
	if FileSystem2.IsFile(Webserver.WWW .. HeaderInformation.HostFolder .. "/" .. HeaderInformation.MethodData) then
		Found = Webserver.WWW .. HeaderInformation.HostFolder .. "/" .. HeaderInformation.MethodData
		HostPath = Webserver.WWW .. HeaderInformation.HostFolder .. "/"
	end
	
	--If not found yet, try to find the requested file in the requested "default" directory. If it finds, Found variable will turn into a string containing the path for it, otherwise it will remain as boolean (false)
	if not Found then
		if FileSystem2.IsFile(Webserver.WWW .. "default/" .. HeaderInformation.MethodData) then
			Found = Webserver.WWW .. "default/" .. HeaderInformation.MethodData
			HostPath = Webserver.WWW .. "default/" 
		end
	end

	--Sometimes the requested file is not pointing to a file, this will try to search for index files.
	if not Found then
		for Key, Value in IteratePairs(Webserver.Index) do
		
			--Try to find the index file in requested host directory.
			if FileSystem2.IsFile(Webserver.WWW .. HeaderInformation.HostFolder .. "/" .. HeaderInformation.MethodData .. Value) then
				Found = Webserver.WWW .. HeaderInformation.HostFolder .. "/" .. HeaderInformation.MethodData .. Value
				HostPath = Webserver.WWW .. HeaderInformation.HostFolder .. "/"
				break
			end
			
			--Try to find the index file in default directory.
			if FileSystem2.IsFile(Webserver.WWW .. "default/" .. HeaderInformation.MethodData .. Value) then
				Found = Webserver.WWW .. "default/" .. HeaderInformation.MethodData .. Value
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
	
	--If file was not found, send 404 and not found page or GET path is invalid
	if not Found or HeaderInformation.MethodData:Find("..", nil, true) then
		local IP, Port = ClientConnection.ClientTCP:getpeername()
		Log(String.Format(Language[Webserver.Language][3], ClientConnection:GetID(), ToString(IP), ToString(Port), "GET", ToString(Found or HeaderInformation.MethodData)))
	
		Queue.Data = HTTP.GenerateHeader(404, {
			["Last-Modified"] = Utilities.InitTime,
			["Accept-Ranges"] = "none",
			["Content-Length"] = #NotFound(HeaderInformation.MethodData),
			["Content-Type"] = "text/html; charset=iso-8859-1",
			["ETag"] = SHA1(Utilities.Date()),
		})
		
		Queue.Data = Queue.Data .. NotFound(HeaderInformation.MethodData)
		Queue.DataSize = #Queue.Data
		
		Table.Insert(ClientConnection.SendQueue, Queue)

	--else, if File was found: send the data for it, if it's a compilable page (.lua) it will compile and run the code and send the returned data.
	else
	
		local IP, Port = ClientConnection.ClientTCP:getpeername()
		Log(String.Format(Language[Webserver.Language][4], ClientConnection:GetID(), ToString(IP), ToString(Port), "GET", ToString(Found)))
		
		local FileExtension = Utilities.GetExtension(ToString(Found)):Lower()
		
		--Compile and run if it's .lua
		if FileExtension == "lua" then
			local Information = {
				Header = Table.Clone(HeaderInformation),
				Parameter = HeaderInformation.Parameter,
				ConnectionID = ClientConnection.ID,
			}
			
			local PageData, Code, OverriderAttributes = Applications.RunLuaFile(Found, HostPath, HeaderInformation.Method, HeaderInformation.HostFolder, Information, HeaderContent)
			
			if Code and Type(Code) ~= "number" then
				Code = 500 --Internal Server Error
				PageData = HTTP.ResponseCodes[Code] .. "Page did not return a valid code."
			end
			
			if PageData and Type(PageData) ~= "string" then
				PageData = HTTP.ResponseCodes[Code] .. "Page did not return a valid content."
			end
			
			local GenerateHeaderAttributes = {
				["Last-Modified"] = Utilities.Date(),
				["Accept-Ranges"] = "none",
				["Content-Length"] = #PageData,
				["Content-Type"] = Extension,
				["ETag"] = SHA1(Found .. Utilities.Date()),
			}
			
			if #PageData == 0 then
				GenerateHeaderAttributes["Content-Length"] = nil
			end
				
			
			if OverriderAttributes and Type(OverriderAttributes) == "table" then
				for Key, Value in Pairs(OverriderAttributes) do
					GenerateHeaderAttributes[Key] = Value
				end
			end
			
			--Generate the HTTP header and add it to queue for sending.
			Queue.Data = HTTP.GenerateHeader(Code, GenerateHeaderAttributes)
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.SendQueue, Queue)
			
			--Add the data to queue for sending.
			local Queue = SendQueueObject.New()
			Queue.Data = PageData
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.SendQueue, Queue)
			
		--Else, its a file like any other, just send the data that it contains.
		else
			local Attributes = FileSystem2.Attributes(Found)
			
			--Generate the HTTP header and add it to queue for sending.
			local GenerateHeaderAttributes = {
				["Last-Modified"] = Utilities.GetDate(Attributes.modification),
				["Accept-Ranges"] = "none",
				["Content-Length"] = Attributes.size,
				["Content-Type"] = Extension,
				["Accept-Ranges"] = "bytes",
				["ETag"] = SHA1(Found .. Utilities.GetDate(Attributes.modification)),
			}
			
			--If it's being requested a part of file (Partial Content) then parse it
			local Range = HeaderInformation.Range or HeaderInformation["Content-Range"]
			local Start, End
			if Range then
				local SeparatorStart = 0
				
				for I = 1, #Range do
					if ToNumber(Range:Substring(I, I)) then
						SeparatorStart = I
						break
					end
				end
				
				Range = Range:Substring(SeparatorStart)
				
				local Separator = 0
				
				for I = 1, #Range do
					if Range:Substring(I, I) == "-" then
						Separator = I
						break
					end
				end
				
				Start = ToNumber(Range:Substring(1, Separator - 1)) or 0
				End = ToNumber(Range:Substring(Separator + 1, #Range)) or Attributes.size - 1
				
				GenerateHeaderAttributes["Content-Length"] = End - Start + 1
				GenerateHeaderAttributes["Content-Range"] = "bytes " .. ToString(Start) .. "-" .. ToString(End) .. "/" .. Attributes.size
			end
			
			
			if Range then
				Queue.Data = HTTP.GenerateHeader(206, GenerateHeaderAttributes)
			else
				Queue.Data = HTTP.GenerateHeader(200, GenerateHeaderAttributes)
			end
			
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.SendQueue, Queue)
			
			--Add the data to queue for sending.
			local Queue = SendQueueObject.New()
		--	Queue.Data = FileSystem2.NewFile(Found)
		--	Queue.DataSize = Attributes.size
		
			if Range then
				Queue.Data = FileSystem2.Read(Found):Substring(Start + 1, End + 1)
			else
				Queue.Data = FileSystem2.Read(Found)
			end
			
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.SendQueue, Queue)
		end
	end
	
end

return GET