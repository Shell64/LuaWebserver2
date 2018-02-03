-------------------------------------
--LuaWebserver Configuration file
-------------------------------------

-------------------------------------
--Language
-------------------------------------

Webserver.Language = "en"

-------------------------------------
--Connection
-------------------------------------

Webserver.Port = 80

Webserver.MaximumWaitingConnections = 0

Webserver.KeepAlive = true

Webserver.SplitPacketSize = 256 --bytes

Webserver.Timeout = 5 --seconds, 0 disables it

Webserver.Index = {"index.html", "index.htm", "index.lua"}

-------------------------------------
--Throttle
-------------------------------------

--Throttle IS NOT WORKING YET. Ignore this part.

Webserver.EnableThrottle = false --Enable bandwidth throttle

Webserver.ConnectionMaximumIncomingSpeed = 1024 * 512 --bytes per seconds. Use 1 / 0 for inf (for interpreters)

Webserver.ConnectionMaximumOutgoingSpeed = 1024 * 512 --bytes per seconds. Use 1 / 0 for inf (for interpreters)

Webserver.MaximumIncomingSpeed = 1 / 0 --Limit globally the incoming speed for this application (it will balance between connections). bytes per seconds. Use 1 / 0 for inf (for interpreters)

Webserver.MaximumOutgoingSpeed = 1 / 0 --Limit globally the outgoing speed for this application (it will balance between connections). bytes per seconds. Use 1 / 0 for inf (for interpreters)

Webserver.EnableConnectionLimit = true --Enable maximum connections connected per address

Webserver.MaximumConnectionPerAddress = 10 --Maximum connections connected per address

-------------------------------------
--Logs
-------------------------------------

Webserver.EnableLogs = true --Disabling logs will run faster.

Webserver.LogToScreen = true --Enable the printing of log to screen, slower.

Webserver.LogToDisk = false --Enable logging to disk

Webserver.LogPath = "../../Log/"

Webserver.LogExtension = "txt"

-------------------------------------
--Cache
-------------------------------------

Webserver.EnableTemporalCache = true --Enable temporal caching, server runs faster when it's under load. But might bring issues if your web application depends on a fast file refresh response.

Webserver.CacheStaySeconds = 5 --Seconds for a file stay in cache.

Webserver.CacheFileMaximumSize = 1024 * 1024 * 8 --bytes. Use 1 / 0 for inf (for interpreters)

Webserver.CacheMaximumSize = 1024 * 1024 * 512 --bytes. Use 1 / 0 for inf (for interpreters)

-------------------------------------
--WWW, it's important to let the slash / in the end of path.
-------------------------------------

Webserver.WWW = "../../www/"