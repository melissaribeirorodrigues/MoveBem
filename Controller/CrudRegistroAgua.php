<?php
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Banco.php');
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Tb_Registro_Agua.php');

    $i_id_usuario       = isset($_REQUEST['id_usuario']) ? $_REQUEST['id_usuario'] : "";
    $s_dh_ingestao_agua = isset($_REQUEST['dh_ingestao_agua']) ? $_REQUEST['dh_ingestao_agua'] : "";
    $i_qt_agua_ml       = isset($_REQUEST['qt_agua_ml']) ? $_REQUEST['qt_agua_ml'] : "";


    $Oper = isset($_REQUEST['oper']) ? $_REQUEST['oper'] : "";

    try
    {  
        $banco = new Banco();
        $Tb_Registro_Agua = new Tb_Registro_Agua($banco);

        $Tb_Registro_Agua->setOper($Oper);
        $Tb_Registro_Agua->SetIdUsuario($i_id_usuario);
        $Tb_Registro_Agua->SetDhIngestaoAgua($s_dh_ingestao_agua);
        $Tb_Registro_Agua->SetQtAguaMl($i_qt_agua_ml);

        switch ($Oper) {
            case 'Inserir':
                $Tb_Registro_Agua->Inserir();
                break;
            case 'TotalDia':
                $Tb_Registro_Agua->TotalDia();
                break;
            case 'Listar':
                $Tb_Registro_Agua->Listar();
                break;
            default:
                $banco->setMensagem(1,'Operacao informada nao tratada');
                break;
        }

    echo $banco->getRetorno();
    
} catch(Exception $e) {   
    if (isset($banco)) {   
        $banco->setMensagem(0, $e->getMessage());
        echo $banco->getRetorno();
    } else {
        echo $e->getMessage();
    }
}
            
?>
