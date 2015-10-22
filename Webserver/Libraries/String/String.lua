----------------------------------------------------------------------------------
-- Removes any additional space on left and right of string
-- http://lua-users.org/wiki/StringTrim método 12
-- @param #string
-- @return #string
function String.Trim(Str)
	local From = Str:Match("^%s*()")
	return From > #Str and "" or Str:Match(".*%S", From)
end

function String.Mask(Str)
	return Str:GSubstring("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"):GSubstring("%z", "%%z")
end

----------------------------------------------------------------------------------
-- Replaces a string in a string
-- @param #string
-- @param #string
-- @param #string
-- @return #string
function String.Replace(Str, ReplaceWhat, ReplaceWhatFor)
	ReplaceWhat = ReplaceWhat:GSubstring("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"):GSubstring("%z", "%%z")
	ReplaceWhatFor = ReplaceWhatFor:GSubstring("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"):GSubstring("%z", "%%z")
	return Str:GSubstring(ReplaceWhat, ReplaceWhatFor)
end

----------------------------------------------------------------------------------
-- Split the string in pieces depending of separator string
-- @param #string
-- @param #string
-- @param #string
-- @return #table
function String.Split(Str, Separator, Limit)
	Str = ToString(Str)

	Separator = Separator or "%s"
	Limit = Limit or 0

	local NewTable = {}
	if Limit == 0 then
		for Part in String.GMatch(Str, "([^" .. Separator .. "]+)") do
			NewTable[Count] = Part
		end
	
	else
		local Count = 1
		for Str in String.GMatch(Str, "([^" .. Separator .. "]+)") do
			NewTable[Count] = Str
			Count = Count + 1
			if Count >= Limit then
				break
			end
		end
	end

	return NewTable
end
