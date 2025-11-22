<?php
    
class Banco 
{
    private $Driver;      
    private $Host; 
    private $Porta;
    private $User;
    private $Password;
    private $Database;
    private $conexao;
    private $Mensagem;
    private $NumMensagem;
    private $Dados;
    private $NumRegistros;

    function __construct($p_Driver = null, $p_Host = null, 
                         $p_Porta = null, $p_User = null, 
                         $p_Password = null, $p_Database = null)                          
    {      
        $this->Abre_Banco($p_Driver, $p_Host, $p_Porta, $p_User, $p_Password, $p_Database);
    }

    function Abre_Banco($p_Driver, $p_Host, $p_Porta, $p_User, $p_Password, $p_Database) 
    {   
        // Atualizado em 17/11/2025 - credenciais corretas
        $this->User     = $p_User     ?? "melissarodrigues";
        $this->Password = $p_Password ?? "123456";
        $this->Database = $p_Database ?? "melissarodrigues";
        $this->Host     = $this->setHost($p_Host);
        $this->Driver   = $p_Driver   ?? "pgsql";
        $this->Porta    = $p_Porta    ?? "5432";
        $this->conexao  = null;
        
        try {
            $this->criaConexao(); 
        } catch(Exception $e) {
            throw new Exception($e->getMessage());
        }
    }

    private function setHost($p_Host)
    {
        if (is_null($p_Host)) {
            $server_ip = $_SERVER['SERVER_ADDR'] ?? '';
            $http_host = $_SERVER['HTTP_HOST'] ?? '';
            
            // Servidor externo (200.19.1.19)
            if ($server_ip === '200.19.1.19' || strpos($http_host, '200.19.1.19') !== false) {
                return "192.168.20.18";
            }
            // Servidor interno (192.168.20.19)  
            else if ($server_ip === '192.168.20.19' || strpos($http_host, '192.168.20.19') !== false) {
                return "192.168.20.18";
            }
            // XAMPP/localhost - usa servidor externo
            else {
                return "200.19.1.18";
            }
        }
        return $p_Host;
    }

    private function criaConexao()
    {  
        try {
            $this->conexao = new PDO(
                $this->Driver . ":host=" . $this->Host . ";port=" . $this->Porta . ";dbname=" . $this->Database . ";connect_timeout=30",
                $this->User,
                $this->Password,
                array(
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_TIMEOUT => 30
                )
            );
            $this->conexao->exec("SET NAMES 'UTF8'");
            $this->conexao->exec("SET statement_timeout = '30s'");
        } catch (PDOException $e) {
            echo "Erro de conexão com banco: " . $e->getMessage();
            die();
        }
    }

    public function getConexao()
    {
        return $this->conexao;
    }

    public function setMensagem($p_num, $p_mensagem)
    {
        $this->NumMensagem = $p_num;
        $this->Mensagem = $p_mensagem;
    }

    public function setDados($p_numRegistros, $p_dados)
    {
        $this->Dados = $p_dados;
        $this->NumRegistros = $p_numRegistros;
    }

    public function getRetorno()
    {
        return json_encode(array(
            "operacao" => $GLOBALS["Oper"],
            "NumMens" => $this->NumMensagem,
            "Mensagem" => $this->Mensagem,
            "registros" => $this->NumRegistros,
            "dados" => $this->Dados
        ));
    }
}
?>
