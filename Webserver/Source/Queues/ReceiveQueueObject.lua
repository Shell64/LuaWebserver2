local ReceiveQueueObject = Class.New("ReceiveQueueObject")

ReceiveQueueObject.GetSet("Header", "string")

ReceiveQueueObject.GetSet("TotalReceivedBytes", "number")
ReceiveQueueObject.GetSet("ReceivedBytes", "number")
ReceiveQueueObject.GetSet("Data", "string")
ReceiveQueueObject.GetSet("DataSize", "number")

ReceiveQueueObject.GetSet("HeaderInformation", "table")

return ReceiveQueueObject