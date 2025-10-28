<?php
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Banco.php');
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Tb_Rotina.php');

    $i_id_rotina   = isset($_REQUEST['id_rotina']) ? $_REQUEST['id_rotina'] : "";
    $s_nm_rotina   = isset($_REQUEST['nm_rotina']) ? $_REQUEST['nm_rotina'] : "";
    $s_ds_rotina   = isset($_REQUEST['ds_rotina']) ? $_REQUEST['ds_rotina'] : "";


    $Oper = isset($_REQUEST['oper']) ? $_REQUEST['oper'] : "";

    try
    {  
        $banco = new Banco();
        $Tb_Rotina = new Tb_Rotina($banco);

        $Tb_Rotina->setOper($Oper);
        $Tb_Rotina->SetIdRotina($i_id_rotina);
        $Tb_Rotina->SetNmRotina($s_nm_rotina);
        $Tb_Rotina->SetDsRotina($s_ds_rotina);

        switch ($Oper) {
            case 'Inserir':
                $Tb_Rotina->Inserir();
                break;  
            case 'Alterar':
                $Tb_Rotina->Alterar();
                break;   
            case 'Excluir':
                $Tb_Rotina->Excluir();
                break; 
            case 'Consultar':
                $Tb_Rotina->Consultar();
                break;   
            case 'Listar':
                $Tb_Rotina->Listar();
                break;
            case 'ListarDetalhado':
                $Tb_Rotina->ListarComExercicios();
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
