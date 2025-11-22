<?php
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
