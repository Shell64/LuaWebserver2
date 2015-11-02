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
    objeto.nome = document.getElementById("nome").value;
    objeto.descricao = document.getElementById("descricao").value;
    objeto.valor = parseFloat(document.getElementById("valor").value).toFixed(2);
    objeto.qtd_estoque = document.getElementById("qtd_estoque").value;

    var fornecedor = document.getElementById("fornecedor");
    objeto.id_fornecedor = fornecedor.options[fornecedor.selectedIndex].value;

    $.ajax({
        type: 'POST',
        url: 'produto.lua?Cadastrar',
        data: "{\"objeto\" : " + JSON.stringify(objeto) + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d) {
                alert("Cadastrado com sucesso");
                document.location.href = "produto.html";
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
    objeto.nome = document.getElementById("nome").value;
    objeto.descricao = document.getElementById("descricao").value;
    objeto.valor = parseFloat(document.getElementById("valor").value).toFixed(2);
    objeto.qtd_estoque = document.getElementById("qtd_estoque").value;

    var fornecedor = document.getElementById("fornecedor");
    objeto.id_fornecedor = fornecedor.options[fornecedor.selectedIndex].value;

    $.ajax({
        type: 'POST',
        url: 'produto.lua?Alterar',
        data: "{\"objeto\" : " + JSON.stringify(objeto) + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d) {
                alert("Alterado com sucesso");
                document.location.href = "produto.html";
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
        url: 'produto.lua?Excluir',
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
        url: 'produto.lua?Consultar',
        data: "{\"id\" : " + vars.id + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d != null) {
                //retorno.d = dados
                $.each(retorno.d, function (i, item) {
                    document.getElementById("nome").value = item.nome;
                    document.getElementById("descricao").value = item.descricao;
                    document.getElementById("valor").value = parseFloat(item.valor).toFixed(2);
                    document.getElementById("qtd_estoque").value = item.qtd_estoque;

                    $.ajax({
                        type: 'POST',
                        url: '../fornecedor/fornecedor.lua?ConsultarTodos',
                        data: "{}",
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        success: function (retorno) {

                            if (retorno.d != null) {

                                $.each(retorno.d, function (i, item2) {
                                    var option = document.createElement("option");
                                    option.value = item2.id;
                                    option.innerHTML = item2.nome_fantasia;

                                    fornecedor.appendChild(option);
                                    if (item.id_fornecedor == item2.id) {
                                        fornecedor.selectedIndex = i;
                                    }
                                });

                            }
                            else {
                                console.log("Erro ao preencher tabela.");
                            }

                        }
                    });
                });
            }
            else {
                console.log("Erro ao preencher formulario.");
            }

        }
    });
}

function PreencherFornecedores() {
    $.ajax({
        type: 'POST',
        url: '../fornecedor/fornecedor.lua?ConsultarTodos',
        data: "{}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (retorno) {

            if (retorno.d != null) {

                $.each(retorno.d, function (i, item2) {
                    var option = document.createElement("option");
                    option.value = item2.id;
                    option.innerHTML = item2.nome_fantasia;

                    fornecedor.appendChild(option);
                });

            }
            else {
                console.log("Erro ao preencher tabela.");
            }

        }
    });
}

function PreencherTabela() {
    $.ajax({
        type: 'POST',
        url: 'produto.lua?ConsultarTodos',
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
                        '<a href="produto_alterar.html?id=' + item.id + '" target="conteudo" tabindex="-1">' +
				            '<img src="../resources/images/user_edit.png" target="conteudo" value="Alterar"/>' +
				        '</a>' +
				    '</td>' +
                    '<td class="' + classe + '">' +
				        '<a target="conteudo" onclick="Excluir(this)" target="conteudo" tabindex="-1" data-id="' + item.id + '">' +
					        '<img src="../resources/images/user_delete.png" value="Excluir"/>' +
					    '</a>' +
				    '</td>' +
                    '<td class="' + classe + '">' + item.id + '</td>' +
                    '<td class="' + classe + '">' + String(item.nome).toUpperCase() + '</td>' +
                    '<td class="' + classe + '">' + parseFloat(item.valor).toFixed(2) + '</td>' +
                    '<td class="' + classe + '">' + item.qtd_estoque + '</td>' +

                '</tr>';
    });
    $('#tb_produtos tbody').empty().append(html);
}
