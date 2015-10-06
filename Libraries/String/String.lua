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
	local Str = Str:GSubstring("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"):GSubstring("%z", "%%z")
end