<?php
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Banco.php');
    require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Tb_Rotina_Exercicio.php');

    $i_id_rotina     = isset($_REQUEST['id_rotina']) ? $_REQUEST['id_rotina'] : "";
    $i_id_exercicio  = isset($_REQUEST['id_exercicio']) ? $_REQUEST['id_exercicio'] : "";


    $Oper = isset($_REQUEST['oper']) ? $_REQUEST['oper'] : "";

    try
    {  
        $banco = new Banco();
        $Tb_Rotina_Exercicio = new Tb_Rotina_Exercicio($banco);

        $Tb_Rotina_Exercicio->setOper($Oper);
        $Tb_Rotina_Exercicio->SetIdRotina($i_id_rotina);
        $Tb_Rotina_Exercicio->SetIdExercicio($i_id_exercicio);

        switch ($Oper) {
            case 'Inserir':
                $Tb_Rotina_Exercicio->Inserir();
                break;  
            case 'Excluir':
                $Tb_Rotina_Exercicio->Excluir();
                break; 
            case 'Listar':
                if (!empty($i_id_rotina)) {
                    $Tb_Rotina_Exercicio->ListarExerciciosPorRotina();
                } else {
                    $Tb_Rotina_Exercicio->ListarTodas();
                }
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
