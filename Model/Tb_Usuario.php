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
            
            $stmt = $this->conexao->prepare("INSERT INTO TB_USUARIO(ds_email, nm_usuario, ds_senha) VALUES " .
                                            "(:DsEmail, :NmUsuario, :DsSenha)");
           
            $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
            $stmt->bindValue(':NmUsuario', $this->nm_usuario, PDO::PARAM_STR);
            $stmt->bindValue(':DsSenha', $this->ds_senha, PDO::PARAM_STR);
           
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
            $stmt = $this->conexao->prepare("UPDATE TB_Usuario SET ds_email = :DsEmail, nm_usuario = :NmUsuario, ds_senha = :DsSenha WHERE id_usuario = :IdUsuario");
            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
            $stmt->bindValue(':NmUsuario', $this->nm_usuario, PDO::PARAM_STR);
            $stmt->bindValue(':DsSenha', $this->ds_senha, PDO::PARAM_STR);
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
 
    public function Excluir()
    {
        try 
        {
            $this->buscaUsuario();
            $stmt = $this->conexao->prepare(
                'Delete From TB_Usuario ' .
                    'WHERE id_usuario = :IdUsuario'
            );

            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();
            $this->banco->setMensagem(1, "Usuario Excluido com Sucesso");
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
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
            $sql = "SELECT id_usuario, ds_email, nm_usuario FROM TB_USUARIO WHERE ds_email = :DsEmail AND ds_senha = :DsSenha";
            $stmt = $this->conexao->prepare($sql);
            $stmt->bindValue(':DsEmail', $this->ds_email, PDO::PARAM_STR);
            $stmt->bindValue(':DsSenha', $this->ds_senha, PDO::PARAM_STR);
            $stmt->execute();
            
            $ret = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$ret) 
            {
                $this->banco->setMensagem(0, "Email ou senha incorretos");
            }
            else
            {
                $this->banco->setMensagem(1, "Login realizado com sucesso");
                $this->banco->setDados(1, $ret);
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

}
