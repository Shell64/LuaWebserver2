local Utilities = {}

local Date = OS.Date
local Time = OS.Time

local GMT = -1
local TimeZone = Time({year = 1970, month = 1, day = 1, hour = 0}) + 3600 * -GMT

function Utilities.Date()
	return Date("%a, %d %b %Y %X GMT", Time() + TimeZone)
end

function Utilities.GetDate(Time)
	return Date("%a, %d %b %Y %X GMT", Time + TimeZone)
end

function Utilities.GetExtension(Str)
	for I = #Str, 1, -1 do
		if Str:Substring(I, I) == "." then
			return Str:Substring(I + 1, #Str)
		end
	end
	
	return ""
end

function Utilities.LoadString(Str, PassTable)
	local CompiledCode, Err = LoadString("return function(PassTable) " .. Str .. " return PassTable end")
	
	if CompiledCode then
		local RunFunction = CompiledCode()
		
		return RunFunction(PassTable)
	else
		
		Print("Could not load string: " .. ToString(Err))
	end
end

function Log(What, ...)
	Print(Date("%x %X") .. " " .. ToString(What), ...)
end

--Stores the initial time date in this variable.
Utilities.InitTime = Utilities.Date()

--When initialize the library, load the first blacklist settings.
--Applications.ReloadEnvironmentBlacklist()

return Utilities