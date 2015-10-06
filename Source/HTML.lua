HTML = {}
local HTML = HTML

HTML.Code = ""

function HTML.Start()
	HTML.Code = HTML.Code .. "<html>\n"
end

function HTML.End()
	HTML.Code = HTML.Code .. "</html>\n"
end
