//http://papermashup.com/read-url-get-variables-withjavascript/
function getUrlVars() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
        vars[key] = value;
    });
    return vars;
}

function Cadastrar(btn_submit) {
    //valida o form html
    if (!document.getElementById('form1').checkValidity()) { console.log("form invalido"); return; }

    var objeto = {};
    objeto.nome_fantasia = document.getElementById("nome_fantasia").value;
    objeto.razao_social = document.getElementById("razao_social").value;
    objeto.endereco = document.getElementById("endereco").value;
    objeto.bairro = document.getElementById("bairro").value;
    objeto.cidade = document.getElementById("cidade").value;
    objeto.uf = document.getElementById("uf").value;
    objeto.cep = document.getElementById("cep").value;
    objeto.email = document.getElementById("email").value;
    objeto.telefone = document.getElementById("telefone").value;
    objeto.cnpj = document.getElementById("cnpj").value;

    $.ajax({
        type: 'POST',
        url: 'Fornecedor.lua?Cadastrar',
        data: "{\"objeto\" : " + JSON.stringify(objeto) + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d) {
                alert("Cadastrado com sucesso");
                document.location.href = "fornecedor.html";
            }
            else {
                alert("Erro ao cadastrar");
            }

        }
    });
}

function Alterar(btn_submit) {
    //valida o form html
    if (!document.getElementById('form1').checkValidity()) { console.log("form invalido"); return; }

    var vars = getUrlVars();
    if (!vars.id) { console.log("Sem variaveis na url"); return; }

    var objeto = {};
    objeto.id = vars.id;
    objeto.nome_fantasia = document.getElementById("nome_fantasia").value;
    objeto.razao_social = document.getElementById("razao_social").value;
    objeto.endereco = document.getElementById("endereco").value;
    objeto.bairro = document.getElementById("bairro").value;
    objeto.cidade = document.getElementById("cidade").value;
    objeto.uf = document.getElementById("uf").value;
    objeto.cep = document.getElementById("cep").value;
    objeto.email = document.getElementById("email").value;
    objeto.telefone = document.getElementById("telefone").value;
    objeto.cnpj = document.getElementById("cnpj").value;


    $.ajax({
        type: 'POST',
        url: 'Fornecedor.lua?Alterar',
        data: "{\"objeto\" : " + JSON.stringify(objeto) + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d) {
                alert("Alterado com sucesso");
                document.location.href = "fornecedor.html";
            }
            else {
                alert("Erro ao alterar");
            }

        }
    });
}

function Excluir(elem) {
    $.ajax({
        type: 'POST',
        url: 'Fornecedor.lua?Excluir',
        data: "{ \"id\" : " + elem.getAttribute('data-id') + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d) {
                PreencherTabela();
            }
            else {
                alert("Erro ao excluir.");
            }

        }
    });
}

function PreencherFormulario() {
    var vars = getUrlVars();
    if (!vars.id) { console.log("Sem variaveis na url"); return; }

    $.ajax({
        type: 'POST',
        url: 'Fornecedor.lua?Consultar',
        data: "{\"id\" : " + vars.id + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d != null) {
                //retorno.d = dados
                $.each(retorno.d, function (i, item) {
                    document.getElementById("nome_fantasia").value = item.nome_fantasia;
                    document.getElementById("razao_social").value = item.razao_social;
                    document.getElementById("endereco").value = item.endereco;
                    document.getElementById("bairro").value = item.bairro;
                    document.getElementById("cidade").value = item.cidade;
                    document.getElementById("uf").value = item.uf;
                    document.getElementById("cep").value = item.cep;
                    document.getElementById("email").value = item.email;
                    document.getElementById("telefone").value = item.telefone;
                    document.getElementById("cnpj").value = item.cnpj;

                });
            }
            else {
                console.log("Erro ao preencher formulario.");
            }

        }
    });
}

function PreencherTabela() {
    $.ajax({
        type: 'POST',
        url: 'Fornecedor.lua?ConsultarTodos',
        data: "{}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d != null) {

                //inserir dados na tabela
                _PreencherTabela(retorno.d);

            }
            else {
                console.log("Erro ao preencher tabela.");
            }

        }
    });
}

function _PreencherTabela(dados) {
    var html = '';
    var total = 0;
    $.each(dados, function (i, item) {
        total++;
        var classe = ""
        if (total % 2 == 1) { classe = "tbl_impar" } else { classe = "tbl_par" };
        html += '<tr>' +
                    '<td class="' + classe + '">' +
                        '<a href="fornecedor_alterar.html?id=' + item.id + '" target="conteudo" tabindex="-1">' +
				            '<img src="../resources/images/user_edit.png" target="conteudo" value="Alterar"/>' +
				        '</a>' +
				    '</td>' +
                    '<td class="' + classe + '">' +
				        '<a target="conteudo" onclick="Excluir(this)" target="conteudo" tabindex="-1" data-id="' + item.id + '">' +
					        '<img src="../resources/images/user_delete.png" value="Excluir"/>' +
					    '</a>' +
				    '</td>' +
                    '<td class="' + classe + '">' + item.id + '</td>' +
                    '<td class="' + classe + '">' + String(item.nome_fantasia).toUpperCase() + '</td>' +
                    '<td class="' + classe + '">' + item.cnpj + '</td>' +

                '</tr>';
    });

    $('#tb_fornecedores tbody').empty().append(html);
}
