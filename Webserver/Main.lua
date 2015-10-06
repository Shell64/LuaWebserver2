﻿#!/bin/luajit

local Require = require

-------------------------------------
--Adicionar caminhos para as bibliotecas
-------------------------------------
package.cpath = package.cpath .. ";../../Webserver/?.dll;../../Webserver/?.so"
package.path = package.path .. ";../../Webserver/?.lua"

-------------------------------------
--Requerir bibliotecas necessarias
-------------------------------------
				Require("Libraries/Wrap/Wrap")
				Require("Libraries/Table/Table")
InitialEnvironment = Table.Clone(_G)
				Require("Libraries/String/String")
SHA1 = 			Require("Libraries/SHA1/SHA1")
Class = 		Require("Libraries/Class/Class")
FileSystem2 = 	Require("Libraries/FileSystem2/FileSystem2")

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

--Webserver.LineHeaderTimeout = 0.1 --segundos, o tempo máximo esperar pra receber uma linha do cabeçario quando inicia uma conexao.

-------------------------------------
--Requerir classes necessarias
-------------------------------------
Language = 		Require("Source/Language")
MIME = 			Require("Source/MIME")
HTTP = 			Require("Source/HTTP")
Connection = 	Require("Source/Connection")
Utilities = 	Require("Source/Utilities")
Template = 		Require("Source/Template")
HTML = 			Require("Source/HTML")
Applications = 	Require("Source/Applications")

GET = 	Require("Source/Methods/GET")

-------------------------------------
--Variáveis locais do arquivo
-------------------------------------
local Socket = socket
local Webserver = Webserver

-------------------------------------
--Inicialização do Socket
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
	--Receber conexoes
	local ClientTCP = ServerTCP:accept()
	
	if ClientTCP then
		ClientTCP:settimeout(0)
		
		local ClientConnection = Connection.New(ClientTCP)
		ClientConnection.Reading = true
		
		local IP, Port = ClientTCP:getpeername()
		Log(String.Format(Language[Webserver.Language][1], ClientConnection:GetID(), ToString(IP), ToString(Port)))
	end
	
	local TimeNow = Socket.gettime()
	
	--Processar conexoes
	for Key, ClientConnection in Pairs(Webserver.Connections) do
		
		--Receber dados
		do
			local Data, Closed = ClientConnection.ClientTCP:receive("*l")
			
			--Se recebeu algum dado
			if Data then
				--Se recebeu um cabeçalho do HTTP
				if Data == "" then
					
					for Key, Value in IteratePairs(ClientConnection.IncomingData) do
						--print(Value)
					end
					
					if ClientConnection.IncomingData[1]:Substring(1, 3):Trim() == "GET" then
						--print("Foi recebido um GET da conexao " .. ClientConnection.ID .. ", inserindo na fila.")
						GET(ClientConnection)
						ClientConnection.IncomingData = {}
					end
				else
				--Se não adicione mais uma msg recebida na tabela de mensagem recebida.
					ClientConnection.IncomingData[#ClientConnection.IncomingData + 1] = Data
					--print("Conexao " .. ClientConnection:GetID() .. " recebido: " .. Data)
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
		
		--Enviar dados
		do
			if ClientConnection.Queue[1] then
				local Queue = ClientConnection.Queue[1]
				
				if not Queue.BlockData or ClientConnection.Queue[1].SentBytes == #Queue.BlockData then
					if Type(Queue.Data) == "string" then
						Queue.BlockData = Queue.Data:Substring(Queue.BlockIndex * Webserver.SplitPacketSize + 1, Math.Minimum(Queue.BlockIndex * Webserver.SplitPacketSize + Webserver.SplitPacketSize, Queue.DataSize))
						Queue.BlockIndex = Queue.BlockIndex + 1
						--print("Processando um item da fila da conexao " .. ClientConnection.ID .. "[" .. Queue.BlockIndex .. "/" .. Math.Ceil(Queue.DataSize / Webserver.SplitPacketSize) .. "]")
						--print("Tamanho: " .. #Queue.BlockData)
					else
						Queue.BlockData = Queue.Data:read(Webserver.SplitPacketSize)
						Queue.BlockIndex = Queue.BlockIndex + 1
						--print("Processando um item da fila da conexao " .. ClientConnection.ID .. "[" .. Queue.BlockIndex .. "/" .. Math.Ceil(Queue.DataSize / Webserver.SplitPacketSize) .. "]")
						
						if Queue.BlockData then
							--print("Tamanho: " .. #Queue.BlockData)
						else
							--print("Tamanho: nil")
						end
					end
					
					ClientConnection.Queue[1].SentBytes = 0
				end
				
				if Queue.BlockData then
					local SentBytes, Err = ClientConnection.ClientTCP:send(Queue.BlockData:Substring(ClientConnection.Queue[1].SentBytes, #Queue.BlockData))
					
					if SentBytes then
						--print("Conexao " .. ClientConnection.ID ..": " .. "Enviando " .. ClientConnection.Queue[1].DataSize .. " bytes. Enviado " .. ClientConnection.Queue[1].TotalSentBytes .. "/" .. ClientConnection.Queue[1].DataSize)
						ClientConnection.Queue[1].SentBytes = ClientConnection.Queue[1].SentBytes + SentBytes
						ClientConnection.Queue[1].TotalSentBytes = ClientConnection.Queue[1].TotalSentBytes + SentBytes
					elseif SentBytes == 0 then
						--print("Conexao " .. ClientConnection.ID ..": " .. "ESTA LENTA ERRO: " .. Err)
					else
						--print("Conexao " .. ClientConnection.ID ..": " .. "NAO FOI POSSIVEL ENVIAR BLOCO ERRO: " .. Err)
					end
				end
				
				if not Queue.BlockData or ClientConnection.Queue[1].SentBytes == #Queue.BlockData and Queue.BlockIndex >= Math.Ceil(Queue.DataSize / Webserver.SplitPacketSize) then
					--print("Conexao " .. ClientConnection.ID ..": " .. "FOI ENVIADO " .. ClientConnection.Queue[1].TotalSentBytes .. " ESPERAVA " .. ClientConnection.Queue[1].DataSize)
					--se for um arquivo, fechar o arquivo
					if Type(ClientConnection.Queue[1].Data) ~= "string" then
						ClientConnection.Queue[1].Data:close()
					end
					
					Table.Remove(ClientConnection.Queue, 1)
					
					--print("Conexao " .. ClientConnection.ID ..": " .. "Processado um item da fila da conexao " .. ClientConnection.ID)
				end
			end
		end
	end
end

while true do
	Webserver.Update()
end