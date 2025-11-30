<?php

require_once('Base.php');

class Tb_Usuario extends Base
{
    private $id_usuario;
    private $nm_usuario;
    private $ds_email;
    private $ds_senha;

    function __construct($p_banco)
    {
        parent::__construct($p_banco);
    }

    function SetNmUsuario($p_NmUsuario)
    {
        $this->nm_usuario = $p_NmUsuario;
    }

    function SetIdUsuario($p_IdUsuario)
    {
        $this->id_usuario = $p_IdUsuario;
    }

    function SetDsEmail($p_DsEmail)
    {
        $this->ds_email = $p_DsEmail;
    }

    function SetDsSenha($p_DsSenha)
    {
        $this->ds_senha = $p_DsSenha;
    }

    public function verificaExistencia()
    {
        $consulta = $this->conexao->query(
            "SELECT 1 FROM Tb_Usuario where id_usuario = $this->id_usuario");

        $ret = $consulta->fetch(PDO::FETCH_ASSOC);
        if (!$ret) {
            throw new Exception("Usuario nao Localizado");
        }
        return $ret;
    }

    public function buscaUsuario()
    {

        $sql = "SELECT * FROM tb_usuario WHERE id_usuario = " . $this->id_usuario;

        $consulta = $this->conexao->query($sql);
        $ret = $consulta->fetch(PDO::FETCH_ASSOC);
        if (!$ret) 
        {
            throw new Exception("Usuario nao Localizado");
        }
        return $ret;
    }

    public function Inserir(){
        try 
        {
            // Verifica se o email já existe
            $this->verificaEmailExistente();
            
            // Criptografa a senha antes de salvar no banco (SEGURANÇA!)
            $senhaCriptografada = password_hash($this->ds_senha, PASSWORD_DEFAULT);
            
            $stmt = $this->conexao->prepare("INSERT INTO TB_USUARIO(ds_email, nm_usuario, ds_senha) VALUES " .
                                            "(:DsEmail, :NmUsuario, :DsSenha)");
           
            $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
            $stmt->bindValue(':NmUsuario', $this->nm_usuario, PDO::PARAM_STR);
            $stmt->bindValue(':DsSenha', $senhaCriptografada, PDO::PARAM_STR);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Usuario incluso com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function AlterarDadosUsuario(){
        try 
        {
            $this->buscaUsuario();
            
            $stmt = $this->conexao->prepare("UPDATE TB_Usuario SET ds_email = :DsEmail, nm_usuario = :NmUsuario WHERE id_usuario = :IdUsuario");
            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
            $stmt->bindValue(':NmUsuario', $this->nm_usuario, PDO::PARAM_STR);
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();
            $this->banco->setMensagem(1, "Dados do usuario Alterados");
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }

    public function AlterarSenha(){
        try 
        {
            $this->buscaUsuario();
            
            // Criptografa a senha antes de atualizar (SEGURANÇA!)
            $senhaCriptografada = password_hash($this->ds_senha, PASSWORD_DEFAULT);
            
            $stmt = $this->conexao->prepare("UPDATE TB_Usuario SET ds_senha = :DsSenha WHERE id_usuario = :IdUsuario");
            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':DsSenha', $senhaCriptografada, PDO::PARAM_STR);
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();
            $this->banco->setMensagem(1, "Senha alterada com sucesso");
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }
 
    public function Excluir()
    {
        $debugInfo = [];
        
        try 
        {
            $debugInfo[] = "Iniciando exclusão - ID: " . $this->id_usuario;
            $this->buscaUsuario();
            
            $this->conexao->beginTransaction();
            $debugInfo[] = "Transação iniciada";
            
            try {
                $this->conexao->exec('SET CONSTRAINTS ALL DEFERRED');
                $debugInfo[] = "Constraints DEFERRED";
            } catch (Exception $e) {
                $debugInfo[] = "Constraints não DEFERRABLE";
            }
            
            // 1. Excluir histórico diário do usuário
            $stmtHistorico = $this->conexao->prepare('DELETE FROM tb_historico_diario WHERE id_usuario = :IdUsuario');
            $stmtHistorico->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmtHistorico->execute();
            $debugInfo[] = "Histórico deletado: " . $stmtHistorico->rowCount();
            
            // 2. Excluir registros de água do usuário
            $stmtAgua = $this->conexao->prepare('DELETE FROM tb_registro_agua WHERE id_usuario = :IdUsuario');
            $stmtAgua->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmtAgua->execute();
            $debugInfo[] = "Água deletada: " . $stmtAgua->rowCount();
            
            // 3. Excluir o usuário
            $debugInfo[] = "Tentando deletar usuário...";
            $stmt = $this->conexao->prepare('DELETE FROM TB_Usuario WHERE id_usuario = :IdUsuario');
            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->execute();
            $debugInfo[] = "Usuário deletado com sucesso!";
            
            $this->conexao->commit();
            $this->banco->setMensagem(1, "Usuario Excluido com Sucesso");
        } 
        catch (Exception $e) 
        {
            $debugInfo[] = "ERRO: " . $e->getMessage();
            $debugInfo[] = "Code: " . $e->getCode();
            $debugInfo[] = "File: " . basename($e->getFile()) . ":" . $e->getLine();
            
            if ($this->conexao->inTransaction()) {
                $this->conexao->rollBack();
            }
            
            $debugMessage = implode(" | ", $debugInfo);
            $this->banco->setMensagem(0, $debugMessage);
        }
    }

    public function Consultar()
    {
        try 
        {
            $ret = $this->buscaUsuario();
            $this->banco->setMensagem(1, "Consulta efetuada com Sucesso");
            $this->banco->setDados(count($ret), $ret);
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }

    public function Listar()
    {
        $ret = $this->conexao->query("SELECT id_usuario, ds_email, nm_usuario FROM Tb_Usuario;");
        $ret = $ret->fetchAll();
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function Login()
    {
        try
        {
            $ret = $this->verificaExistencia();
            $this->banco->setMensagem(1, "Login Permitido");
            $this->banco->setDados(count($ret), $ret);
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, "Usuario Inexistente");
        }
    }

    public function LoginComEmailSenha()
    {
        try
        {
            // Busca usuário pelo email
            $sql = "SELECT id_usuario, ds_email, nm_usuario, ds_senha FROM TB_USUARIO WHERE ds_email = :DsEmail";
            $stmt = $this->conexao->prepare($sql);
            $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
            $stmt->execute();
            
            $ret = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$ret) 
            {
                $this->banco->setMensagem(0, "Email ou senha incorretos");
            }
            else
            {
                // Verifica a senha com bcrypt
                if (password_verify($this->ds_senha, $ret['ds_senha'])) 
                {
                    // Remove a senha do retorno (não envia pro app)
                    unset($ret['ds_senha']);
                    
                    $this->banco->setMensagem(1, "Login realizado com sucesso");
                    $this->banco->setDados(1, $ret);
                }
                else
                {
                    $this->banco->setMensagem(0, "Email ou senha incorretos");
                }
            }
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, "Erro no login: " . $e->getMessage());
        }
    }

    public function verificaEmailExistente()
    {
        $sql = "SELECT 1 FROM TB_USUARIO WHERE ds_email = :DsEmail";
        $stmt = $this->conexao->prepare($sql);
        $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
        $stmt->execute();
        
        $ret = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($ret) 
        {
            throw new Exception("Email ja cadastrado");
        }
        
        return false;
    }

    public function RecuperarSenha()
    {
        try
        {
            // Busca usuário pelo email
            $sql = "SELECT id_usuario FROM TB_USUARIO WHERE ds_email = :DsEmail";
            $stmt = $this->conexao->prepare($sql);
            $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
            $stmt->execute();
            
            $ret = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$ret) 
            {
                $this->banco->setMensagem(0, "Email nao encontrado");
            }
            else
            {
                // Criptografa a nova senha
                $senhaCriptografada = password_hash($this->ds_senha, PASSWORD_DEFAULT);
                
                // Atualiza a senha no banco
                $sqlUpdate = "UPDATE TB_USUARIO SET ds_senha = :DsSenha WHERE ds_email = :DsEmail";
                $stmtUpdate = $this->conexao->prepare($sqlUpdate);
                $stmtUpdate->bindValue(':DsSenha', $senhaCriptografada, PDO::PARAM_STR);
                $stmtUpdate->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
                
                $this->conexao->beginTransaction();
                $stmtUpdate->execute();
                $this->conexao->commit();
                
                $this->banco->setMensagem(1, "Senha alterada com sucesso");
            }
        } 
        catch (Exception $e) 
        {
            if ($this->conexao->inTransaction()) {
                $this->conexao->rollBack();
            }
            $this->banco->setMensagem(0, "Erro ao recuperar senha: " . $e->getMessage());
        }
    }

}
