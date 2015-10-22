local ReceiveQueueObject = Class.New("ReceiveQueueObject")

ReceiveQueueObject.GetSet("Header", "string")

SendQueueObject.GetSet("TotalReceivedBytes", "number")
SendQueueObject.GetSet("ReceivedBytes", "number")
SendQueueObject.GetSet("Data", "string")
SendQueueObject.GetSet("DataSize", "number")

ReceiveQueueObject.GetSet("HeaderInformation", "table")

return ReceiveQueueObject