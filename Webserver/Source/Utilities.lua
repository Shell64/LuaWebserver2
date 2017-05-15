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

function Utilities.GetPath(Str)
	for I = #Str, 1, -1 do
		if Str:Substring(I, I) == "." then
			break
		elseif Str:Substring(I, I) == "/" or Str:Substring(I, I) == "\\" then
			return Str
		end
	end
	
	for I = #Str, 1, -1 do
		if Str:Substring(I, I) == "/" or Str:Substring(I, I) == "\\" then
			return Str:Substring(1, I)
		end
	end
	
	return Str
end

--Prevent paths with ../../ or with dots.
function Utilities.FixPath(Str)
	while Str:Find("..", nil, true) do
		Str = Str:GSubstring("%.%.", "")
		
	end
	
	while Str:Find("//", nil, true) do
		Str = Str:GSubstring("//", "/")
	end
	
	while Str:Find("\\\\", nil, true) do
		Str = Str:GSubstring("\\\\", "\\")
	end
	
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