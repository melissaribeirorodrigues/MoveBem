<?php
require_once('Base.php');

class Tb_Registro_Agua extends Base
{
    private $id_usuario;
    private $dh_ingestao_agua;
    private $qt_agua_ml;

    function __construct($p_banco)
    {
        parent::__construct($p_banco);
    }

    function SetIdUsuario($p_IdUsuario)
    {
        $this->id_usuario = $p_IdUsuario;
    }

    function SetDhIngestaoAgua($p_DhIngestaoAgua)
    {
        $this->dh_ingestao_agua = $p_DhIngestaoAgua;
    }

    function SetQtAguaMl($p_QtAguaMl)
    {
        $this->qt_agua_ml = $p_QtAguaMl;
    }

    function GetIdUsuario()
    {
        return $this->id_usuario;
    }

    function GetDhIngestaoAgua()
    {
        return $this->dh_ingestao_agua;
    }

    function GetQtAguaMl()
    {
        return $this->qt_agua_ml;
    }



    private function verificaUsuarioExiste()
    {
        $stmt = $this->conexao->prepare("SELECT 1 FROM TB_USUARIO WHERE id_usuario = :IdUsuario");
        $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
        $stmt->execute();

        if ($stmt->rowCount() == 0) 
        {
            throw new Exception("Usuário não encontado");
        }
    }

    public function Inserir()
    {
        try 
        {
            // ve se o usuario 
            $this->verificaUsuarioExiste();
            
            // Se não foi informada a data/hoa, usa a atual
            if (empty($this->dh_ingestao_agua)) {
                $this->dh_ingestao_agua = date('Y-m-d H:i:s');
            }
            
            $stmt = $this->conexao->prepare("INSERT INTO TB_REGISTRO_AGUA(id_usuario, dh_ingestao_agua, qt_agua_ml) VALUES " .
                                            "(:IdUsuario, :DhIngestaoAgua, :QtAguaMl)");

            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':DhIngestaoAgua', $this->dh_ingestao_agua, PDO::PARAM_STR);
            $stmt->bindValue(':QtAguaMl', $this->qt_agua_ml, PDO::PARAM_INT);

            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Registro de água incluído com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function TotalDia()
    {
        try 
        {
            $this->verificaUsuarioExiste();
            
            $stmt = $this->conexao->prepare("SELECT COALESCE(SUM(qt_agua_ml), 0) as total 
                                            FROM TB_REGISTRO_AGUA 
                                            WHERE id_usuario = :IdUsuario 
                                            AND DATE(dh_ingestao_agua) = CURRENT_DATE");
            
            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->execute();
            
            $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $this->banco->setMensagem(1, "Total do dia recuperado com sucesso");
            $this->banco->setDados(['total' => (int)$resultado['total']]);
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function Listar()
    {
        try 
        {
            $this->verificaUsuarioExiste();
            
            $stmt = $this->conexao->prepare("SELECT id_registro_agua, id_usuario, dh_ingestao_agua, qt_agua_ml 
                                            FROM TB_REGISTRO_AGUA 
                                            WHERE id_usuario = :IdUsuario 
                                            ORDER BY dh_ingestao_agua DESC");
            
            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->execute();
            
            $registros = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->banco->setMensagem(1, "Sucesso na Pesquisa");
            $this->banco->setDados($registros);
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }
}
?>
