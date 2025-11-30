<?php

// Headers CORS para permitir acesso do app Flutter
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Responde a requisições OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Banco.php');
require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Tb_Historico_Diario.php');

$id_usuario        = $_REQUEST['id_usuario'] ?? "";
$data              = $_REQUEST['data'] ?? "";
$oper              = $_REQUEST['oper'] ?? "";
$id_rotina         = $_REQUEST['id_rotina'] ?? "";
$vl_total_minutos  = $_REQUEST['vl_total_minutos'] ?? "";

try {
    $banco = new Banco();
    $Tb_Historico = new Tb_Historico_Diario($banco);
    $Tb_Historico->SetIdUsuario($id_usuario);
    $Tb_Historico->SetData($data);

    switch ($oper) {
        case 'InserirHistorico':
            $Tb_Historico->InserirHistorico($id_rotina, $vl_total_minutos);
            break;

        case 'ResumoPorData':
        default:
            $Tb_Historico->ResumoPorData();
            break;
    }
} catch (Exception $e) {
    echo json_encode([
        "sucesso" => false,
        "erro" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
