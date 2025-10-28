<?php
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Banco.php');
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Tb_Exercicio.php');

    // Captura parâmetros da requisição
    $i_id_exercicio   = isset($_REQUEST['id_exercicio']) ? $_REQUEST['id_exercicio'] : "";
    $s_nm_exercicio   = isset($_REQUEST['nm_exercicio']) ? $_REQUEST['nm_exercicio'] : "";
    $s_ds_exercicio   = isset($_REQUEST['ds_exercicio']) ? $_REQUEST['ds_exercicio'] : "";
    $i_vl_duracao     = isset($_REQUEST['vl_duracao']) ? $_REQUEST['vl_duracao'] : "";

    /*-------------------------------------------------------------*/

    $Oper = isset($_REQUEST['oper']) ? $_REQUEST['oper'] : "";

    try
    {  
        $banco = new Banco();
        $Tb_Exercicio = new Tb_Exercicio($banco);

        $Tb_Exercicio->setOper($Oper);
        $Tb_Exercicio->SetIdExercicio($i_id_exercicio);
        $Tb_Exercicio->SetNmExercicio($s_nm_exercicio);
        $Tb_Exercicio->SetDsExercicio($s_ds_exercicio);
        $Tb_Exercicio->SetVlDuracao($i_vl_duracao);

        switch ($Oper) {
            case 'Inserir':
                $Tb_Exercicio->Inserir();
                break;  
            case 'Alterar':
                $Tb_Exercicio->Alterar();
                break;   
            case 'Excluir':
                $Tb_Exercicio->Excluir();
                break; 
            case 'Consultar':
                $Tb_Exercicio->Consultar();
                break;   
            case 'Listar':
                $Tb_Exercicio->Listar();
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
