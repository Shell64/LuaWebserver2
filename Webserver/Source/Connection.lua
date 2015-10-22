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
end

return Connection
