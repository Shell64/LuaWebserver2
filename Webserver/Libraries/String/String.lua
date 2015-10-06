----------------------------------------------------------------------------------
-- Retira os espaços adicionais da direita e da esquerda de uma string
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
-- Substitui em uma string, uma string por uma outra.
-- @param #string
-- @param #string
-- @param #string
-- @return #string
function String.Replace(Str, ReplaceWhat, ReplaceWhatFor)
	ReplaceWhat = ReplaceWhat:GSubstring("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"):GSubstring("%z", "%%z")
	ReplaceWhatFor = ReplaceWhatFor:GSubstring("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"):GSubstring("%z", "%%z")
	return Str:GSubstring(ReplaceWhat, ReplaceWhatFor)
end