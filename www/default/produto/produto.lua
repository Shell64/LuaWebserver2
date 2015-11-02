local FormatoCadastro = {
	id = "string",
	id_fornecedor = "string",
	nome = "string",
	descricao = "string",
	valor = "string",
	qtd_estoque = "string",
}
	
local FormatoConsulta = {
	id = "number"
}

local Arquivo = "produto.txt"

function Consultar(Objeto)
	if CheckTableFormat(Objeto, FormatoConsulta) then
		local Data = FileSystem2.Read(Arquivo)
		
		Data = Data or ""
		
		local ObjetosCadastrados = JSON.Decode(Data)
		
		return "{\"d\" : [" .. JSON.Encode(ObjetosCadastrados[tonumber(Objeto.id)]) .. "]}", 200
	end
end

function ConsultarTodos()
	local Data = FileSystem2.Read(Arquivo)
	
	return "{\"d\" : " .. Data .. "}", 200
end

function Cadastrar(Objeto)
	if CheckTableFormat(Objeto, FormatoCadastro) then
		local Ok, Error = pcall(function()
			local Data = FileSystem2.Read(Arquivo)
			local ObjetosCadastrados = Data and JSON.Decode(Data) or {}
			
			Objeto.id = #ObjetosCadastrados + 1
			ObjetosCadastrados[#ObjetosCadastrados + 1] = Objeto
			
			FileSystem2.Write(Arquivo, JSON.Encode(ObjetosCadastrados))
		end)
		
		if Ok then
			return '{"d": "1"}'
		end
	end
end

function Alterar(Objeto)
	if CheckTableFormat(Objeto, FormatoCadastro) then
		local Ok, Error = pcall(function()
			local Data = FileSystem2.Read(Arquivo)
			local ObjetosCadastrados = Data and JSON.Decode(Data) or {}
			
			for Key, Value in pairs(Objeto) do
				if Key ~= "id" then
					ObjetosCadastrados[tonumber(Objeto.id)][Key] = Value
				end
			end
			
			FileSystem2.Write(Arquivo, JSON.Encode(ObjetosCadastrados))
		end)
		
		if Ok then
			return '{"d": "1"}'
		end
	end
end

function Excluir(Objeto)
	if CheckTableFormat(Objeto, FormatoConsulta) then
		local Ok, Error = pcall(function()
			local Data = FileSystem2.Read(Arquivo)
			local ObjetosCadastrados = Data and JSON.Decode(Data) or {}
			
			table.remove(ObjetosCadastrados, tonumber(Objeto.id))
			
			for Key, Value in pairs(ObjetosCadastrados) do
				Value.id = Key
			end
			
			FileSystem2.Write(Arquivo, JSON.Encode(ObjetosCadastrados))
		end)
		
		if Ok then
			return '{"d": "1"}'
		end
	end
end

function Application.POST(Information, Content)
	local Whatever, Error

	if Content then
		Content, Whatever, Error = JSON.Decode(Content)
	end
	
	if Error then
		return Error, 500
	end
		
	if Information.Parameter == "Cadastrar" then
		local Content, Error = Cadastrar(Content.objeto)
		
		if Content then
			return Content, 200
		else
			return Error, 500
		end
	
	elseif Information.Parameter == "Alterar" then
		local Content, Error = Alterar(Content.objeto)
		
		if Content then
			return Content, 200
		else
			return Error, 500
		end
	
	elseif Information.Parameter == "Excluir" then
		local Content, Error = Excluir(Content)
		
		if Content then
			return Content, 200
		else
			return Error, 500
		end
		
	elseif Information.Parameter == "Consultar" then
		local Content, Error = Consultar(Content)
		
		if Content then
			return Content, 200
		else
			return Error, 500
		end
		
	elseif Information.Parameter == "ConsultarTodos" then
		local Content, Error = ConsultarTodos()
		
		if Content then
			return Content, 200
		else
			return "", 500
		end
	else
		return 'Function not found', 404
	end
end