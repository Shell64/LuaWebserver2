local Applications = {}

-------------------------------------
--Requerir classes necessarias
-------------------------------------
local Application = Require("Source/Application")

-------------------------------------
--Variáveis locais do arquivo
-------------------------------------
local LoadString = LoadString

-------------------------------------
--Métodos
-------------------------------------
function Applications.RunString(Str)
	local Application = Application.New()
	
	local CompiledCode, Err = LoadString("return function(Application) " .. Str .. " return Application end")
	
	if CompiledCode then
		local RunFunction = CompiledCode()
		
		RunFunction(Application)
	else
		
		print("Could not load code: " .. ToString(Err))
	end
	
	return Application
end

function Applications.GenerateEnvironment(HostPath)
	--Ambiente da API, variaveis que poderão ser acessíveis pela pagina
	
	local Environment = Table.Clone(InitialEnvironment)
	
	Environment.FileSystem2 = {}
	
	function Environment.FileSystem2.Read(Path)
		return FileSystem2.Read(HostPath .. Path)
	end
	
	Environment.Template = {}
	Environment.Template.New = Template.New
	
	Environment.Webserver = {}
	Environment.Webserver.Name = Webserver.Name
	Environment.Webserver.Version = {}
	Environment.Webserver.Version.Major = Webserver.Version.Major
	Environment.Webserver.Version.Minor = Webserver.Version.Minor
	Environment.Webserver.Version.Revision = Webserver.Version.Revision
	
	return Environment
end

return Applications