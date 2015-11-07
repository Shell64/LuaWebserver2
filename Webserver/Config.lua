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

Webserver.Port = 9091

Webserver.MaximumWaitingConnections = 500

Webserver.KeepAlive = false

Webserver.SplitPacketSize = 128 --bytes

Webserver.Timeout = 5 --seconds, 0 disables it

Webserver.Index = {"index.html", "index.htm", "index.lua"}

-------------------------------------
--Cache
-------------------------------------

Webserver.CacheFileMaximumSize = 1024 * 1024 * 1024 --bytes

Webserver.CacheMaximumSize = 1024 * 1024 * 1024 --bytes

-------------------------------------
--WWW, it's important to let the slash / in the end of path.
-------------------------------------

Webserver.WWW = "../../www/"
