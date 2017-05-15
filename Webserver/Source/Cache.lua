local Cache = {}
local Webserver = Webserver

local Pairs = Pairs

if Webserver.EnableTemporalCache then
	local PutInCache
	
	OLD_FileSystem2_IsFile = FileSystem2.IsFile

	local OLD_FileSystem2_IsFile = OLD_FileSystem2_IsFile
	function FileSystem2.IsFile(Path, ...)
		if Cache[Path] then
			Cache[Path].LastUsed = Webserver.Time
			return true
		else
			return OLD_FileSystem2_IsFile(Path, ...)
		end
	end
	
	OLD_FileSystem2_GetSize = FileSystem2.GetSize

	local OLD_FileSystem2_GetSize = OLD_FileSystem2_GetSize
	function FileSystem2.GetSize(Path, ...)
		if Cache[Path] then
			Cache[Path].LastUsed = Webserver.Time
			return Cache[Path].Attributes.size
		else
			return OLD_FileSystem2_GetSize(Path, ...)
		end
	end
	
	OLD_FileSystem2_Attributes= FileSystem2.Attributes

	local OLD_FileSystem2_Attributes = OLD_FileSystem2_Attributes
	function FileSystem2.GetSize(Path, ...)
		if Cache[Path] then
			Cache[Path].LastUsed = Webserver.Time
			return Cache[Path].Attributes
		else
			return OLD_FileSystem2_Attributes(Path, ...)
		end
	end

	OLD_FileSystem2_Read = FileSystem2.Read

	local OLD_FileSystem2_Read = OLD_FileSystem2_Read
	function FileSystem2.Read(Path, ...)
		if Cache[Path] then
			Cache[Path].LastUsed = Webserver.Time
			return Cache[Path].Data
		else
			PutInCache(Path, ...)
			
			if Cache[Path] and Cache[Path].Data then
				return Cache[Path].Data
			else
				return OLD_FileSystem2_Read(Path, ...)
			end
		end
	end
	
	OLD_FileSystem2_Write = FileSystem2.Write
	
	local OLD_FileSystem2_Write = OLD_FileSystem2_Write
	function FileSystem2.Write(Path, Data)
		if Cache[Path] then
			Cache[Path].LastUsed = Webserver.Time
			Cache[Path].Data = Data
		end
		
		OLD_FileSystem2_Write(Path, Data)
	end
	
	OLD_FileSystem2_Append = FileSystem2.Append
	
	local OLD_FileSystem2_Append = OLD_FileSystem2_Append
	function FileSystem2.Append(Path, Data)
		if Cache[Path] and Cache[Path].Data then
			Cache[Path].LastUsed = Webserver.Time
			Cache[Path].Data = Cache[Path].Data .. Data
		end
		
		OLD_FileSystem2_Append(Path, Data)
	end
	
	local TotalCachedBytes = 0
	
	function PutInCache(Path)
		if not FileSystem2.IsFile(Path) then
			return
		end
		
		local FileCache = {}

		FileCache.Attributes = OLD_FileSystem2_Attributes(Path)
		local Size = FileCache.Attributes.size
		
		if Size > Webserver.CacheFileMaximumSize or TotalCachedBytes + Size > Webserver.CacheMaximumSize then
			return
		end
		
		FileCache.Data = OLD_FileSystem2_Read(Path)
		FileCache.LastUsed = Webserver.Time
		
		TotalCachedBytes = TotalCachedBytes + Size
		
		Cache[Path] = FileCache
	end
	
	local LastChecked = Webserver.Time
	
	function CheckTemporalCache()
		if Webserver.Time - LastChecked < 1 then
			return
		end
		
		for Key, Value in Pairs(Cache) do
			if Webserver.Time - Value.LastUsed > Webserver.CacheStaySeconds then
				TotalCachedBytes = TotalCachedBytes - Value.Attributes.size
				Cache[Key] = nil
			end
		end
		
		LastChecked = Webserver.Time
	end
end

return Cache