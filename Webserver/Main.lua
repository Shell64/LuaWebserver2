#!/bin/luajit

local Require = require

local function CloneTable(Tab)
	local Clone = {}
	
	for Key, Value in pairs(Tab) do
		if type(Value) == "table" then
			Clone[Key] = {}
			for Key2, Value2 in pairs(Value) do
				Clone[Key][Key2] = Value2
			end
		else
			Clone[Key] = Value
		end
	end
	
	return Clone
end

-------------------------------------
--Add library paths
-------------------------------------
package.cpath = package.cpath .. ";../../Webserver/?.dll;../../Webserver/?.so"
package.path = package.path .. ";../../Webserver/?.lua"

-------------------------------------
--Request required libraries
-------------------------------------
InitialEnvironment = CloneTable(_G)
				Require("Libraries/Wrap/Wrap")
				Require("Libraries/Table/Table")
				Require("Libraries/String/String")
Class = 		Require("Libraries/Class/Class")
FileSystem2 = 	Require("Libraries/FileSystem2/FileSystem2")
JSON =			Require("Libraries/DKJSON/DKJSON")

Require("socket")

-------------------------------------
--Webserver
-------------------------------------

Webserver = {}
Webserver.Name = "LuaWebserver"
Webserver.Version = {Major = 2, Minor = 0, Revision = 0}

Require("Config")

-------------------------------------
--Webserver Cache
-------------------------------------
Webserver.Cache = {} --cache de arquivos

--Webserver.LineHeaderTimeout = 0.1 --seconds, the max time to wait for a incoming header

-------------------------------------
--Request required classes
-------------------------------------
Language = 				Require("Source/Language")
MIME = 					Require("Source/MIME")
HTTP = 					Require("Source/HTTP")
SendQueueObject = 		Require("Source/Queues/SendQueueObject")
ReceiveQueueObject = 	Require("Source/Queues/ReceiveQueueObject")
Connection = 			Require("Source/Connection")
Utilities = 			Require("Source/Utilities")
Template = 				Require("Source/Template")
HTML = 					Require("Source/HTML")
Applications = 			Require("Source/Applications")

GET = 		Require("Source/Methods/GET")
POST = 		Require("Source/Methods/POST")
PUT = 		Require("Source/Methods/PUT")
HEAD = 		Require("Source/Methods/HEAD")
DELETE = 	Require("Source/Methods/DELETE")
OPTIONS = 	Require("Source/Methods/OPTIONS")

-------------------------------------
--Local variables for this file (faster for Lua)
-------------------------------------
local Socket = socket
local Webserver = Webserver

-------------------------------------
--Initialize Socket
-------------------------------------
Log(String.Format(Language[Webserver.Language][5], ToString(Webserver.Port)))

local Trying = true

local ServerTCP = Socket.tcp()

while ToString(ServerTCP):Substring(1, 3) ~= "tcp" or not ProtectedCall(function() ServerTCP:accept() end) do
	ServerTCP = Socket.tcp()
	ServerTCP:bind('*', Webserver.Port)
	ServerTCP:settimeout(0)
	ServerTCP:listen(Webserver.MaximumWaitingConnections)
end

Log(String.Format(Language[Webserver.Language][6], Webserver.Port))

-------------------------------------
--Webserver
-------------------------------------
Webserver.ServerTCP = ServerTCP
Webserver.Connections = {}

function Webserver.Update(...)
	
	-------------------------------------
	--Receive incoming client connections and put in a Connection object.
	-------------------------------------
	local ClientTCP = ServerTCP:accept()
	
	if ClientTCP then
		ClientTCP:settimeout(0)
		
		local ClientConnection = Connection.New(ClientTCP)
		ClientConnection.Reading = true
		
		local IP, Port = ClientTCP:getpeername()
		Log(String.Format(Language[Webserver.Language][1], ClientConnection:GetID(), ToString(IP), ToString(Port)))
	end
	
	local TimeNow = Socket.gettime()
	
	-------------------------------------
	--Process each Connection object in Webserver.Connections table.
	-------------------------------------
	for Key, ClientConnection in Pairs(Webserver.Connections) do
		
		--Receive incoming data from connection
		do
			local Data, Closed

			if ClientConnection.ReceivingHeader then
				Data, Closed = ClientConnection.ClientTCP:receive("*l")
			else
				local Data2
				Data2, Closed = ClientConnection.ClientTCP:receive(1)
				
				if not Data and Data2 then
					Data = ""
				end
				
				while Data2 do
					Data = Data .. Data2
					Data2, Closed = ClientConnection.ClientTCP:receive(1)
				end
			end
			
			--If that received any data,
			if Data then
				--When a HTTP header ends, it sends a \n\n, so the incoming data in this case is "", means that the HTTP header
				--was received. As we are reading every incoming line from socket, that will be "".
				--So here, if we did receive the HTTP header,
				if ClientConnection.ReceivingHeader then
					if Data == "" then
						local HeaderInformation = HTTP.ParseHeader(ClientConnection.ReceivedData)
						
						ClientConnection.ReceivedHeader = HeaderInformation
						
						if HeaderInformation["Content-Length"] then
							ClientConnection.ContentLength = ToNumber(HeaderInformation["Content-Length"]) or 0
							if ClientConnection.ContentLength > 0 then
								ClientConnection.ReceivingHeader = false
							end
						end
						
						if ClientConnection.ContentLength == 0 then
							if HeaderInformation.Method == "GET" then
								GET(ClientConnection, HeaderInformation)
							
							elseif HeaderInformation.Method == "POST" then
								POST(ClientConnection, HeaderInformation, ClientConnection.ReceivedData)
							end
						end
						
						ClientConnection.ReceivedData = ""
					else
					--Else, it's just one more line and we need to add that to incoming data.
						ClientConnection.ReceivedData = ClientConnection.ReceivedData .. Data .. "\n"
					end
				else
					--If data is still incomming, concaternate
					if #ClientConnection.ReceivedData < ClientConnection.ContentLength then
						ClientConnection.ReceivedData = ClientConnection.ReceivedData .. Data
					
						if #ClientConnection.ReceivedData >= ClientConnection.ContentLength then
							if ClientConnection.ReceivedHeader.Method == "GET" then
								GET(ClientConnection, ClientConnection.ReceivedHeader, ClientConnection.ReceivedData)
							
							elseif ClientConnection.ReceivedHeader.Method == "POST" then
								POST(ClientConnection, ClientConnection.ReceivedHeader, ClientConnection.ReceivedData)
							end
							
							ClientConnection.ReceivedData = ""
							ClientConnection.ReceivingHeader = true
						end
					else
						print("Something impossible happened?")
					end
				end
			end
			
			if Closed == "closed" then
				local IP, Port = ClientConnection.ClientTCP:getpeername()
				Log(String.Format(Language[Webserver.Language][2], ClientConnection:GetID(), ToString(IP), ToString(Port), Closed))
				ClientConnection:Destroy()
				
			elseif Webserver.Timeout > 0 and TimeNow - ClientConnection.CreateTime > Webserver.Timeout then
				--local IP, Port = ClientConnection.ClientTCP:getpeername()
				--Log(String.Format(Language[Webserver.Language][2], ClientConnection:GetID(), ToString(IP), ToString(Port), "server timeout"))
				--ClientConnection:Destroy()
			end
		end
		
		--Send the information from "Send data queue" to client.
		do
			if ClientConnection.SendQueue[1] then
				local Queue = ClientConnection.SendQueue[1]
				
				if not Queue.BlockData or ClientConnection.SendQueue[1].SentBytes == #Queue.BlockData then
					if Type(Queue.Data) == "string" then
						Queue.BlockData = Queue.Data:Substring(Queue.BlockIndex * Webserver.SplitPacketSize + 1, Math.Minimum(Queue.BlockIndex * Webserver.SplitPacketSize + Webserver.SplitPacketSize, Queue.DataSize))
						Queue.BlockIndex = Queue.BlockIndex + 1
					else
						Queue.BlockData = Queue.Data:read(Webserver.SplitPacketSize)
						Queue.BlockIndex = Queue.BlockIndex + 1
					end
					
					ClientConnection.SendQueue[1].SentBytes = 0
				end
				
				if Queue.BlockData then
					local SentBytes, Err = ClientConnection.ClientTCP:send(Queue.BlockData:Substring(ClientConnection.SendQueue[1].SentBytes, #Queue.BlockData))
					
					if SentBytes then
						ClientConnection.SendQueue[1].SentBytes = ClientConnection.SendQueue[1].SentBytes + SentBytes
						ClientConnection.SendQueue[1].TotalSentBytes = ClientConnection.SendQueue[1].TotalSentBytes + SentBytes
					elseif SentBytes == 0 then
						--if it is not sending any bytes, then the client is timing out
					else
						--nil, the client timed out or something else happened.
					end
				end
				
				if not Queue.BlockData or ClientConnection.SendQueue[1].SentBytes == #Queue.BlockData and Queue.BlockIndex >= Math.Ceil(Queue.DataSize / Webserver.SplitPacketSize) then
					--sometimes the data we are sending from queue is not a string, it might be streaming from a file, so we need to close it.
					if Type(ClientConnection.SendQueue[1].Data) ~= "string" then
						ClientConnection.SendQueue[1].Data:close()
					end
					
					--We did finish that item from queue.
					Table.Remove(ClientConnection.SendQueue, 1)
				end
			end
		end
	end
end

while true do
	Webserver.Update()
	Socket.sleep(0.001)
end
