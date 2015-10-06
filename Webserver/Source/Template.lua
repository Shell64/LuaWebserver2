local Template = Class.New("Template")

Template.GetSet("PageData", "string")

Template.Property("Variables", "table")

function Template.PostInit(Object, PageData)
	if PageData then
		Object.PageData = ToString(PageData)
	end
end

function Template.SetVariable(Object, Variable, Value)
	Object.Variables[Variable] = Value
end

function Template.GetVariable(Object, Variable)
	return Object.Variables[Variable]
end

function Template.Render(Object)
	local PageData = Object.PageData
	
	if not PageData or Type(PageData) ~= "string" then
		PageData = ""
	end
	
	for Key, Value in Pairs(Object.Variables) do
		PageData = PageData:Replace("{{" .. ToString(Key) .. "}}", ToString(Value))
	end
	
	return PageData
end


return Template