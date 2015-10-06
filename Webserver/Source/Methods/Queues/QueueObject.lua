local QueueObject = Class.New("QueueObject")

QueueObject.GetSet("GET", "string")

QueueObject.GetSet("Accept", "string") --MIMEs
QueueObject.GetSet("Accept-Charset", "string")
QueueObject.GetSet("Accept-Encoding", "string")
QueueObject.GetSet("Accept-Language", "string")
QueueObject.GetSet("Cache-Control", "string")
QueueObject.GetSet("Connection", "string")
QueueObject.GetSet("Cookie", "string")
QueueObject.GetSet("Host", "string") --Site que ele ta acessando
QueueObject.GetSet("Upgrade-Insecure-Requests", "string")
QueueObject.GetSet("User-Agent", "string")

QueueObject.GetSet("TotalSentBytes", "number")
QueueObject.GetSet("SentBytes", "number")
QueueObject.GetSet("Data", "string")
QueueObject.GetSet("DataSize", "number")
QueueObject.GetSet("BlockIndex", "number")

return QueueObject