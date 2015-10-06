local Utilities = {}

local Date = OS.Date
local Time = OS.Time

local GMT = -1
local FuseTime = Time({year = 1970, month = 1, day = 1, hour = 0}) + 3600 * -GMT

function Utilities.Date()
	return Date("Date: %a, %d %b %Y %X GMT", Time() + FuseTime)
end

function Utilities.GetDate(Time)
	return Date("Date: %a, %d %b %Y %X GMT", Time + FuseTime)
end

function Utilities.GetExtension(Str)
	for I = #Str, 1, -1 do
		if Str:Substring(I, I) == "." then
			return Str:Substring(I + 1, #Str)
		end
	end
	
	return ""
end

--Data de inicializacao do webserver, util para dizer a data de modificacao de páginas integradas dentro do webserver como o notfound.
Utilities.InitTime = Utilities.Date()

return Utilities