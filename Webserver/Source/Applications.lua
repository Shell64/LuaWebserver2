local Applications = {}

-------------------------------------
--Request required classes
-------------------------------------
local Application = Require("Source/Application")

-------------------------------------
--Local variables for this file (faster for lua)
-------------------------------------
local LoadString = LoadString

Applications.Blacklist = {}

-------------------------------------
--Methods for Application class.
-------------------------------------

Application.Blacklist = {}

Application.Runtime = FileSystem2.Read(Webserver.WWW .. "API_Runtime.lua")

function Applications.RunLuaFile(Path, HostPath, Method, Host, Information, HeaderContent)
	local Data = FileSystem2.Read(Path)
	
	local PageData = nil
	local Code = 200
		
	if not Data then
		Code = 410 --Gone
		PageData = HTTP.ResponseCodes[Code]
		
	else
			
		--Compiles the string
		local Application = Application.New()
		
		
		local CompiledCode, Err
		
		ProtectedCall(function()
			CompiledCode, Err = LoadString("return function(Application) \n" .. Application.Runtime .. "\n" .. Data .. "\n return Application end", Path)
		end)
		
		local Environment
		if CompiledCode then
			--Generate the environment for our API
			Environment = Applications.GenerateEnvironment(HostPath, Host)
			
			
			SetEnvironmentFunction(CompiledCode, Environment)
			local RunFunction = CompiledCode()
			
			SetEnvironmentFunction(RunFunction, Environment)
			RunFunction(Application)
		else
			Code = 500 --Internal Server Error
			PageData = HTTP.ResponseCodes[Code] .. "<br/><hr/><br/>" .. Err
		end
		
		if Code == 200 then
			SetEnvironmentFunction(Application[Method], Environment)
			
			local Ok, Err = ProtectedCall(function()
				PageData, Code = Application[Method](Information, HeaderContent)
				Code = Code or 200
			end)
			
			if not Ok then
				Code = 500 --Internal Server Error
				PageData = HTTP.ResponseCodes[Code] .. "<br/><hr/><br/>" .. Err
			end
		end
	end
	
	return PageData or "", Code
end

function Applications.ReloadEnvironmentBlacklist()
	local Data = FileSystem2.Read(Webserver.WWW .. "API_Blacklist.lua")
	
	if Data then
		Application.Blacklist = {}
		Utilities.LoadString(Data, Application.Blacklist)
	end
end

--When initialize the library, load the first blacklist settings.
Applications.ReloadEnvironmentBlacklist()

function Applications.GenerateEnvironment(HostPath, Host)
	--These are the variables/functions that will be accessible by the programmer on a .lua page
	
	local Environment = Table.Clone(InitialEnvironment, {__index = Environment})
	
	if Application.Blacklist.Global then
		if Application.Blacklist[Host] then
			Utilities.LoadString(Application.Blacklist.Global .. Application.Blacklist[Host], Environment)
		else
			Utilities.LoadString(Application.Blacklist.Global, Environment)
		end
	elseif Application.Blacklist[Host] then
		Utilities.LoadString(Application.Blacklist[Host], Environment)
	end
	
	Environment.FileSystem2 = {}
	
	function Environment.FileSystem2.Read(Path)
		return FileSystem2.Read(HostPath .. Path)
	end
	
	Environment.HTML = {}
	
	Environment.HTML.Table = HTML.Table
	
	Environment.Template = {}
	Environment.Template.New = Template.New
	
	Environment.Webserver = {}
	Environment.Webserver.Name = Webserver.Name
	Environment.Webserver.Port = Webserver.Port
	Environment.Webserver.MaximumWaitingConnections = Webserver.MaximumWaitingConnections
	Environment.Webserver.KeepAlive = Webserver.KeepAlive
	Environment.Webserver.SplitPacketSize = Webserver.SplitPacketSize
	Environment.Webserver.Timeout = Webserver.Timeout
	Environment.Webserver.Index = Table.Copy(Webserver.Index)
	Environment.Webserver.CacheFileMaximumSize = Webserver.CacheFileMaximumSize
	Environment.Webserver.CacheMaximumSize = Webserver.CacheMaximumSize
	Environment.Webserver.WWW = Webserver.WWW
	
	Environment.Webserver.Version = {}
	Environment.Webserver.Version.Major = Webserver.Version.Major
	Environment.Webserver.Version.Minor = Webserver.Version.Minor
	Environment.Webserver.Version.Revision = Webserver.Version.Revision
	
	return Environment
end

return Applications