<?php
// Configurações para API
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Informações da API MoveBem
$api_info = array(
    "nome" => "MoveBem API",
    "versao" => "1.0.0",
    "descricao" => "API Backend para aplicativo MoveBem",
    "status" => "online",
    "servidor" => "IF Gravataí (200.19.1.19)",
    "data_hora" => date('Y-m-d H:i:s'),
    "endpoints" => array(
        "usuarios" => array(
            "url" => "Controller/CrudUsuario.php",
            "operacoes" => array(
                "Inserir" => "Cadastrar novo usuário (nm_usuario, ds_email, ds_senha)",
                "Login" => "Fazer login (ds_email, ds_senha)",
                "Listar" => "Listar todos os usuários",
                "Consultar" => "Consultar usuário específico (id_usuario)",
                "Alterar" => "Alterar dados do usuário (id_usuario, nm_usuario, ds_email, ds_senha)",
                "Excluir" => "Excluir usuário (id_usuario)"
            )
        )
    ),
    "exemplo_requisicao" => array(
        "metodo" => "POST",
        "url" => "Controller/CrudUsuario.php",
        "parametros" => array(
            "oper" => "Login",
            "ds_email" => "usuario@email.com",
            "ds_senha" => "123456"
        )
    ),
    "exemplo_resposta" => array(
        "operacao" => "Login",
        "NumMens" => 1,
        "Mensagem" => "Login realizado com sucesso",
        "registros" => 1,
        "dados" => array(
            "id_usuario" => 1,
            "ds_email" => "usuario@email.com",
            "nm_usuario" => "Nome do Usuario"
        )
    )
);

echo json_encode($api_info, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>