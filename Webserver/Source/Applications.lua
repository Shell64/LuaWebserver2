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
	
	local CompiledCode = LoadString("return function(Application)\n" .. Str .. "\n return Application end")
	
	local RunFunction = CompiledCode()
	
	RunFunction(Application)
	
	return Application
end

return Applications