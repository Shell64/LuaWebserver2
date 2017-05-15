local Webserver = Webserver
local Socket = socket

Webserver.Connections = Webserver.Connections or {}

local Connection = Class.New("Connection")

Connection.GetSet("ClientTCP", "userdata")
Connection.GetSet("Attributes", "table")


Connection.GetSet("SendingData", "string")
Connection.GetSet("SendingByte", "number")

Connection.GetSet("Reading", "boolean", false)

Connection.GetSet("ReceivedHeader", "table")
Connection.GetSet("ContentLength", "number")
Connection.GetSet("ReceivedData", "string")

Connection.GetSet("ReceivingHeader", "boolean", true)

Connection.GetSet("Processing", "boolean", false)
Connection.GetSet("Sending", "boolean", false)

Connection.GetSet("SendQueue", "table")

Connection.GetSet("CreateTime", "number")

Connection.GetSet("ID")

function Connection.Destroy(Object)
	Object.ClientTCP:close()
	Webserver.Connections[Object.ID] = nil
	
	local IP = Object.IP
	
	if Webserver.EnableConnectionLimit then
		if Webserver.ConnectionsPerAddress[IP] == 1 then
			Webserver.ConnectionsPerAddress[IP] = nil
		else
			Webserver.ConnectionsPerAddress[IP] = Webserver.ConnectionsPerAddress[IP] - 1
		end
	end
end

function Connection.PostInit(Object, ClientTCP)
	Object.CreateTime = Socket.gettime()
	Object.ClientTCP = ClientTCP
	
	Object.ReceivingHeader = true
	
	local Trying = true
	local I = 1
	
	while Trying do
		if not Webserver.Connections[I] then
			Webserver.Connections[I] = Object
			
			Object.ID = I
			
			Trying = false
		end
		
		I = I + 1
	end
	
	--Limit amount of connections
	local IP, Port = ClientTCP:getpeername()
	Object.IP = IP
	Object.Port = Port
	
	Webserver.ConnectionsPerAddress[IP] = Webserver.ConnectionsPerAddress[IP] and Webserver.ConnectionsPerAddress[IP] + 1 or 1
	
	if Webserver.EnableConnectionLimit then
		if Webserver.ConnectionsPerAddress[IP] > Webserver.MaximumConnectionPerAddress then
			Object:Destroy()
		end
	end
end

return Connection
