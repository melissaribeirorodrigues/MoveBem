<?php

require_once('Base.php');

class Tb_Exercicio extends Base
{
    private $id_exercicio;
    private $nm_exercicio;
    private $ds_exercicio;
    private $vl_duracao;

    function __construct($p_banco)
    {
        parent::__construct($p_banco);
    }

    function SetIdExercicio($p_IdExercicio)
    {
        $this->id_exercicio = $p_IdExercicio;
    }

    function SetNmExercicio($p_NmExercicio)
    {
        $this->nm_exercicio = $p_NmExercicio;
    }

    function SetDsExercicio($p_DsExercicio)
    {
        $this->ds_exercicio = $p_DsExercicio;
    }

    function SetVlDuracao($p_VlDuracao)
    {
        $this->vl_duracao = $p_VlDuracao;
    }

    function GetIdExercicio()
    {
        return $this->id_exercicio;
    }

    function GetNmExercicio()
    {
        return $this->nm_exercicio;
    }

    function GetDsExercicio()
    {
        return $this->ds_exercicio;
    }

    function GetVlDuracao()
    {
        return $this->vl_duracao;
    }


    public function verificaExistencia()
    {
        $consulta = $this->conexao->query(
            "SELECT 1 FROM TB_EXERCICIO WHERE id_exercicio = $this->id_exercicio");

        $ret = $consulta->fetch(PDO::FETCH_ASSOC);
        if (!$ret) 
        {
            throw new Exception("Exercício não localizado");
        }
        return $ret;
    }

    private function verificaExercicioExistente()
    {
        $stmt = $this->conexao->prepare("SELECT id_exercicio FROM TB_EXERCICIO WHERE UPPER(nm_exercicio) = UPPER(:NmExercicio)");
        $stmt->bindValue(':NmExercicio', $this->nm_exercicio, PDO::PARAM_STR);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) 
        {
            throw new Exception("Já existe um exercício com este nome");
        }
    }

    public function Inserir()
    {
        try 
        {
            // Verifica se o nome do exercício já existe
            $this->verificaExercicioExistente();
            
            $stmt = $this->conexao->prepare("INSERT INTO TB_EXERCICIO(nm_exercicio, ds_exercicio, vl_duracao) VALUES " .
                                            "(:NmExercicio, :DsExercicio, :VlDuracao)");
           
            $stmt->bindValue(':NmExercicio', $this->nm_exercicio, PDO::PARAM_STR);
            $stmt->bindValue(':DsExercicio', $this->ds_exercicio, PDO::PARAM_STR);
            $stmt->bindValue(':VlDuracao', $this->vl_duracao, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Exercício incluído com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function Alterar()
    {
        try 
        {
            // Verifica se o exercício existe
            $this->verificaExistencia();
            
            // Verifica se não existe outro exercício com o mesmo nome
            $stmt = $this->conexao->prepare("SELECT id_exercicio FROM TB_EXERCICIO WHERE UPPER(nm_exercicio) = UPPER(:NmExercicio) AND id_exercicio != :IdExercicio");
            $stmt->bindValue(':NmExercicio', $this->nm_exercicio, PDO::PARAM_STR);
            $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
            $stmt->execute();
            
            if ($stmt->rowCount() > 0) 
            {
                throw new Exception("Já existe um exercício com este nome");
            }
            
            $stmt = $this->conexao->prepare("UPDATE TB_EXERCICIO SET nm_exercicio = :NmExercicio, ds_exercicio = :DsExercicio, vl_duracao = :VlDuracao WHERE id_exercicio = :IdExercicio");
           
            $stmt->bindValue(':NmExercicio', $this->nm_exercicio, PDO::PARAM_STR);
            $stmt->bindValue(':DsExercicio', $this->ds_exercicio, PDO::PARAM_STR);
            $stmt->bindValue(':VlDuracao', $this->vl_duracao, PDO::PARAM_INT);
            $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Exercício alterado com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function Excluir()
    {
        try 
        {
            // Verifica se o exercício existe
            $this->verificaExistencia();
            
            // Verifica se o exercício está sendo usado em alguma rotina
            $stmt = $this->conexao->prepare("SELECT COUNT(*) as total FROM TB_ROTINA_EXERCICIO WHERE id_exercicio = :IdExercicio");
            $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
            $stmt->execute();
            $result = $stmt->fetch();
            
            if ($result['total'] > 0) 
            {
                throw new Exception("Não é possível excluir: exercício está sendo usado em " . $result['total'] . " rotina(s)");
            }
            
            $stmt = $this->conexao->prepare("DELETE FROM TB_EXERCICIO WHERE id_exercicio = :IdExercicio");
            $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Exercício excluído com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function Listar()
    {
        $ret = $this->conexao->query("SELECT id_exercicio, nm_exercicio, ds_exercicio, vl_duracao FROM TB_EXERCICIO ORDER BY nm_exercicio;");
        $ret = $ret->fetchAll();
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function Consultar()
    {
        try
        {
            $ret = $this->verificaExistencia();
            
            $stmt = $this->conexao->prepare("SELECT id_exercicio, nm_exercicio, ds_exercicio, vl_duracao FROM TB_EXERCICIO WHERE id_exercicio = :IdExercicio");
            $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
            $stmt->execute();
            $ret = $stmt->fetchAll();
            
            $this->banco->setMensagem(1, "Exercício encontrado");
            $this->banco->setDados(count($ret), $ret);
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function Pesquisar()
    {
        $stmt = $this->conexao->prepare("SELECT id_exercicio, nm_exercicio, ds_exercicio, vl_duracao FROM TB_EXERCICIO WHERE UPPER(nm_exercicio) LIKE UPPER(:NmExercicio) ORDER BY nm_exercicio");
        $stmt->bindValue(':NmExercicio', '%' . $this->nm_exercicio . '%', PDO::PARAM_STR);
        $stmt->execute();
        $ret = $stmt->fetchAll();
        
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }
}
?>
