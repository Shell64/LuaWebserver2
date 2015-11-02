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
	
	Environment.JSON = Table.Clone(JSON)
	
	Environment.FileSystem2 = {}
	
	do
		local Append = FileSystem2.Append
		function Environment.FileSystem2.Append(Path, Data)
			Path = HostPath .. Utilities.FixPath(Path)
			print(Path)
			return Append(Path, Data)
		end

		local GetSize = FileSystem2.GetSize
		function Environment.FileSystem2.GetSize(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return GetSize(Path)
		end

		local CreateDirectory = FileSystem2.CreateDirectory
		function Environment.FileSystem2.CreateDirectory(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return CreateDirectory(Path)
		end

		local IsFile = FileSystem2.IsFile
		function Environment.FileSystem2.IsFile(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return IsFile(Path)
		end

		local IsDirectory = FileSystem2.IsDirectory
		function Environment.FileSystem2.IsDirectory(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return IsDirectory(Path)
		end

		local IsSymlink = FileSystem2.IsSymlink
		function Environment.FileSystem2.IsSymlink(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return IsSymlink(Path)
		end

		local Load = FileSystem2.Load
		function Environment.FileSystem2.Load(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return Load(Path)
		end

		local NewFile = FileSystem2.NewFile
		function Environment.FileSystem2.NewFile(Path, Mode)
			Path = HostPath .. Utilities.FixPath(Path)
			return NewFile(Path, Mode)
		end

		local Read = FileSystem2.Read
		function Environment.FileSystem2.Read(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return Read(Path)
		end

		local Remove = FileSystem2.Remove
		function Environment.FileSystem2.Remove(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return Remove(Path)
		end

		local Write = FileSystem2.Write
		function Environment.FileSystem2.Write(Path, Data)
			Path = HostPath .. Utilities.FixPath(Path)
			return Write(Path, Data)
		end

		local Attributes = Attributes
		function Environment.FileSystem2.Attributes(Path)
			Path = HostPath .. Utilities.FixPath(Path)
			return Attributes(Path)
		end
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