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

function Applications.RunLuaFile(Path, HostPath, Information)
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
			CompiledCode, Err = LoadString("return function(Application) " .. Data .. " return Application end", Path)
		end)
		
		if CompiledCode then
			local RunFunction = CompiledCode()
			
			RunFunction(Application)
		else
			Code = 500 --Internal Server Error
			PageData = HTTP.ResponseCodes[Code] .. "<br/><hr/><br/>" .. Err
		end
		
		if Code == 200 then
			--Generate the environment for our API
			local Environment = Applications.GenerateEnvironment(HostPath)
			
			SetEnvironmentFunction(Application.GET, Environment)
			
			local Ok, Err = ProtectedCall(function()
				PageData, Code = Application.GET(Information)
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
	local Data = FileSystem2.Read(Webserver.WWW .. "API_BlackList.lua")
	
	if Data then
		Utilities.LoadString(Data, Application.Blacklist)
	end
end

function Applications.GenerateEnvironment(HostPath)
	--These are the variables/functions that will be accessible by the programmer on a .lua page
	
	local Environment = Table.Clone(InitialEnvironment)
	
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