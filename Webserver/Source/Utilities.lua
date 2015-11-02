local Utilities = {}

local Date = OS.Date
local Time = OS.Time

function Utilities.Date()
	return Date("!%a, %d %b %Y %X GMT", Time())
end

function Utilities.GetDate(Time)
	return Date("!%a, %d %b %Y %X GMT", Time)
end

function Utilities.GetExtension(Str)
	for I = #Str, 1, -1 do
		if Str:Substring(I, I) == "." then
			return Str:Substring(I + 1, #Str)
		end
	end
	
	return ""
end

--Prevent paths with ../../ or with dots.
function Utilities.FixPath(Str)
	local Start = #Str
	
	for I = #Str, 1, -1 do
		if Str:Substring(I, I) == "." then
			Start = I
			break
		end
	end
	
	Str = Str:Substring(1, Start - 1):GSubstring("%.", "") .. "." .. Str:Substring(Start + 1, #Str)
	
	Str = Str == "." and "" or Str
	
	return Str
end

function Utilities.LoadString(Str, PassTable)
	local CompiledCode, Err = LoadString("return function(PassTable) \n" .. Str .. "\n return PassTable end", "LoadedString")
	
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

return Utilities