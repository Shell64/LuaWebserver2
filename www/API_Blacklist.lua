--This file restricts methods and global values that developers have access.


--Block for all websites hosted.
PassTable.Global = [[
	local oldloadstring = PassTable.loadstring
	local setfenv = PassTable.setfenv
	local getfenv = PassTable.getfenv
	
	function PassTable.loadstring(s, chunkname)
		local f, message = oldloadstring(s, chunkname)
		
		if not f then
			return f, message
		end
		
		setfenv(f, getfenv(2))
		
		return f
	end

	PassTable.rawequal = nil
	PassTable.rawget = nil
	PassTable.rawset = nil
	PassTable.select = nil
	PassTable.setfenv = nil
	PassTable.setmetatable = nil
	PassTable.coroutine = nil
	PassTable.module = nil
	PassTable.require = nil
	PassTable.package = nil
	PassTable.string.dump = nil
	PassTable.math.randomseed = nil
	PassTable.io = nil
	PassTable.os = nil
	PassTable.debug = nil
]]

--Block for "default" website only.
PassTable.default = [[
	
]]

--Other websites can be added below.