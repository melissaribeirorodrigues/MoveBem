<?php
      
require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Tb_Usuario.php');
require_once('..'.DIRECTORY_SEPARATOR.'Model'.DIRECTORY_SEPARATOR.'Banco.php');

// Parâmetros vindos da requisição
$s_nm_usuario = $_REQUEST['nome'] ?? $_REQUEST['nm_usuario'] ?? "";
$s_ds_email   = $_REQUEST['email'] ?? $_REQUEST['ds_email'] ?? "";
$s_ds_senha   = $_REQUEST['senha'] ?? $_REQUEST['ds_senha'] ?? "";
$i_id_usuario = $_REQUEST['id'] ?? $_REQUEST['id_usuario'] ?? "";
$Oper         = $_REQUEST['oper'] ?? "";

try {  
    $banco = new Banco();
    $Tb_Usuario = new Tb_Usuario($banco);

    $Tb_Usuario->setOper($Oper);
    $Tb_Usuario->SetNmUsuario($s_nm_usuario);
    $Tb_Usuario->SetDsEmail($s_ds_email);
    $Tb_Usuario->SetDsSenha($s_ds_senha);
    $Tb_Usuario->SetIdUsuario($i_id_usuario);
  
    switch ($Oper) {
        case 'Inserir':
            $Tb_Usuario->Inserir();
            break;  
        case 'Alterar':
            $Tb_Usuario->AlterarDadosUsuario();
            break;   
        case 'Excluir':
            $Tb_Usuario->Excluir();
            break; 
        case 'Consultar':
            $Tb_Usuario->Consultar();
            break;   
        case 'Listar':
            $Tb_Usuario->Listar();
            break; 
        case 'Login':
            $Tb_Usuario->LoginComEmailSenha();
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
