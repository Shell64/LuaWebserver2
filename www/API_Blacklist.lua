--This file restricts methods and global values that developers have access.


--Block for all websites hosted.
PassTable.Global = {
	"rawequal",
	"rawget",
	"rawset",
	"select",
	"setfenv",
	"setmetatable",
	"coroutine",
	"module",
	"require",
	"package",
	"string.dump",
	"math.randomseed",
	"io",
	"os",
	"debug",
}

--Block for "default" website only.
PassTable.default = {
	
}

--Other websites can be added below.