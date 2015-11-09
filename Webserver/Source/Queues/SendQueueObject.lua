local SendQueueObject = Class.New("SendQueueObject")

SendQueueObject.GetSet("GET", "string")

SendQueueObject.GetSet("Accept", "string") --MIMEs
SendQueueObject.GetSet("Accept-Charset", "string")
SendQueueObject.GetSet("Accept-Encoding", "string")
SendQueueObject.GetSet("Accept-Language", "string")
SendQueueObject.GetSet("Cache-Control", "string")
SendQueueObject.GetSet("Connection", "string")
SendQueueObject.GetSet("Cookie", "string")
SendQueueObject.GetSet("Host", "string") --Site que ele ta acessando
SendQueueObject.GetSet("Upgrade-Insecure-Requests", "string")
SendQueueObject.GetSet("User-Agent", "string")

SendQueueObject.GetSet("TotalSentBytes", "number")
SendQueueObject.GetSet("SentBytes", "number")
SendQueueObject.GetSet("Data", "string")
SendQueueObject.GetSet("DataSize", "number")
SendQueueObject.GetSet("BlockIndex", "number")

return SendQueueObject