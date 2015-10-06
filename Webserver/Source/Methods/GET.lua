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
	for Key, Value in IteratePairs(ClientConnection.IncomingData) do
		Value = Value:Trim()
		
		local Attribute = String.Match(Value, "(.*)%:")
		
		--pegar todos os atributos do cabeçalho GET e preencher no HeaderInformation que será passado para a página API (Se houver) e no objeto Queue que irá para a fila.
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
	
	
	local Found = false
	local HostPath = ""
	
	if Queue.GET:Substring(1, 1) == "/" then
		Queue.GET = Queue.GET:Substring(2, #Queue.GET)
	end
	
	--Consertar caminhos, alguns browsers enviam os parametros como ?v=1 no GET. Temos de remover.
	for I = 1, #Queue.GET do
		if Queue.GET:Substring(I, I) == "?" then
			local Parameter = Queue.GET:Substring(I, #Queue.GET)
			
			--Retira o escapamento da string (%)
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
			--Fim do codigo para retirar escapamentos da string
			
			Queue.GET = Queue.GET:Substring(1, I -1)
			Queue.Parameter = Parameter
			
			--print("Conexao " .. ClientConnection.ID ..": " .. "REMOVEU O PARAMETRO: " .. Parameter)
			break
		end
	end
	
	--tente procurar o arquivo, se nao encontrar no host em que ele esta acessando, procure na pasta default.
	if FileSystem2.IsFile(Webserver.WWW .. Queue.Host .. "/" .. Queue.GET) then
		Found = Webserver.WWW .. Queue.Host .. "/" .. Queue.GET
		HostPath = Webserver.WWW .. Queue.Host .. "/"
	end
	
	if not Found then
		if FileSystem2.IsFile(Webserver.WWW .. "default/" .. Queue.GET) then
			Found = Webserver.WWW .. "default/" .. Queue.GET
			HostPath = Webserver.WWW .. "default/" 
		end
	end

	--se não foi encontrado, procure por arquivos index.
	if not Found then
		for Key, Value in IteratePairs(Webserver.Index) do
			if FileSystem2.IsFile(Webserver.WWW .. Queue.Host .. "/" .. Queue.GET .. Value) then
				Found = Webserver.WWW .. Queue.Host .. "/" .. Queue.GET .. Value
				HostPath = Webserver.WWW .. Queue.Host .. "/"
				break
			end
			
			if FileSystem2.IsFile(Webserver.WWW .. "default/" .. Queue.GET .. Value) then
				Found = Webserver.WWW .. "default/" .. Queue.GET .. Value
				HostPath =  Webserver.WWW .. "default/"
				break
			end
		end
	end
	
	--pega a extensao do arquivo para pegar o MIME da tabela MIME
	local Extension = "*"
	
	if Found then
		for I = 1, #Found do
			if Found:Substring(#Found - I, #Found - I) == "." then
				Extension = Found:Substring(#Found - I + 1, #Found)
				break
			end
		end
	end
	
	--print("Conexao " .. ClientConnection.ID ..": " .. Extension)
	Extension = MIME[Extension] or MIME["*"]
	
	--print("Conexao " .. ClientConnection.ID ..": " .. Extension)
	
	--Se não foi encontrado o arquivo
	if not Found then
		local IP, Port = ClientConnection.ClientTCP:getpeername()
		print(String.Format(Language[Webserver.Language][3], ClientConnection:GetID(), ToString(IP), ToString(Port), ToString(Found or Queue.GET)))
		
		--print("Conexao " .. ClientConnection.ID ..": GET: 404 Not found " .. Queue.GET)
		Queue.Data = 
		"HTTP/1.1 404 Not Found" .. HTTP.NewLine .. 
		"Date: " .. Utilities.Date() .. HTTP.NewLine .. 
		"Server: Lua Server " .. HTTP.NewLine ..
		"Last-Modified: " .. Utilities.InitTime .. HTTP.NewLine ..
		"Accept-Ranges: none" .. HTTP.NewLine .. 
		"Content-Length: " .. #NotFound(Queue.GET) .. HTTP.NewLine .. 
		"Content-Type: " .. Extension .. HTTP.NewLine ..
		"Content-Type: text/html; charset=iso-8859-1" .. HTTP.End
		
		Queue.Data = Queue.Data .. NotFound(Queue.GET)
		Queue.DataSize = #Queue.Data
		
		Table.Insert(ClientConnection.Queue, Queue)
		
	else
		--Se foi encontrado
		
		local IP, Port = ClientConnection.ClientTCP:getpeername()
		print(String.Format(Language[Webserver.Language][4], ClientConnection:GetID(), ToString(IP), ToString(Port), ToString(Found)))
		
		local FileExtension = Utilities.GetExtension(ToString(Found)):Lower()
			
		--print("Conexao " .. ClientConnection.ID ..": " .. "ENCONTROU ARQUIVO " .. Found)
		
		--Se for .lua, compile
		if FileExtension == "lua" then
			local Attributes = FileSystem2.Attributes(Found)
			
			Webserver.ETags[Found] = SHA1(Found .. ToString(Attributes.modification))
			
			--print("Conexao " .. ClientConnection.ID ..": " .. "GET: 200 OK " .. Queue.GET)
			
			local Data = FileSystem2.Read(Found)
			local Application = Applications.RunString(Data)
			
			local Environment = Applications.GenerateEnvironment(HostPath)
			
			SetEnvironmentFunction(Application.GET, Environment)
			local PageData = ToString(Application.GET({
				Header = HeaderInformation,
				Parameter = Queue.Parameter,
				ConnectionID = ClientConnection.ID,
			}) or nil)
			
			--print("PAGE DATA:")
			--print(PageData)
			
			Queue.Data = 
			"HTTP/1.1 200 OK" .. HTTP.NewLine ..
			"Date: " .. Utilities.Date() .. HTTP.NewLine ..
			"Server: Lua Server " .. HTTP.NewLine ..
			"Last-Modified: " .. Utilities.Date() .. HTTP.NewLine ..
			"Accept-Ranges: none" .. HTTP.NewLine ..
			"Content-Length: " .. #PageData .. HTTP.NewLine ..
			"Content-Type: " .. Extension .. HTTP.End
			
			Queue.DataSize = #Queue.Data
			Table.Insert(ClientConnection.Queue, Queue)
			
			
			local Queue = QueueObject.New()
			
			Queue.Data = PageData
			
			--print(Found)
			--print("Conexao " .. ClientConnection.ID ..": " .. Found .. " tem " .. #Queue.Data .. " bytes")
			Queue.DataSize = #Queue.Data
		
			Table.Insert(ClientConnection.Queue, Queue)
			
		--Se for um arquivo qualquer, envie
		else
			--print("Conexao " .. ClientConnection.ID ..": " .. "ENCONTROU ARQUIVO " .. Found)
			local Attributes = FileSystem2.Attributes(Found)
			
			Webserver.ETags[Found] = SHA1(Found .. ToString(Attributes.modification))
			
			--print("Conexao " .. ClientConnection.ID ..": " .. "GET: 200 OK " .. Queue.GET)
			
			Queue.Data = 
			"HTTP/1.1 200 OK" .. HTTP.NewLine .. 
			"Date: " .. Utilities.Date() .. HTTP.NewLine ..
			"Server: Lua Server " .. HTTP.NewLine ..
			"Last-Modified: " .. Utilities.GetDate(Attributes.modification) .. HTTP.NewLine ..
			"Accept-Ranges: none" .. HTTP.NewLine .. 
			"Content-Length: " .. Attributes.size .. HTTP.NewLine .. 
			"Content-Type: " .. Extension .. HTTP.End
			
			Queue.DataSize = #Queue.Data
			
			Table.Insert(ClientConnection.Queue, Queue)
			
			local Queue = QueueObject.New()
			
		--	Queue.Data = FileSystem2.NewFile(Found)
		--	Queue.DataSize = Attributes.size
		
			Queue.Data = FileSystem2.Read(Found)
			
			--print(Found)
			--print("Conexao " .. ClientConnection.ID ..": " .. Found .. " tem " .. #Queue.Data .. " bytes")
			Queue.DataSize = #Queue.Data
		
			Table.Insert(ClientConnection.Queue, Queue)
		end
	end
	
end

return GET