<?php

require_once('Base.php');

class Tb_Rotina_Exercicio extends Base
{
    private $id_rotina;
    private $id_exercicio;

    function __construct($p_banco)
    {
        parent::__construct($p_banco);
    }

    function SetIdRotina($p_IdRotina)
    {
        $this->id_rotina = $p_IdRotina;
    }

    function SetIdExercicio($p_IdExercicio)
    {
        $this->id_exercicio = $p_IdExercicio;
    }

    function GetIdRotina()
    {
        return $this->id_rotina;
    }

    function GetIdExercicio()
    {
        return $this->id_exercicio;
    }

    private function verificaRotinaExiste()
    {
        $stmt = $this->conexao->prepare("SELECT 1 FROM TB_ROTINA WHERE id_rotina = :IdRotina");
        $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) 
        {
            throw new Exception("Rotina não encontrada");
        }
    }

    private function verificaExercicioExiste()
    {
        $stmt = $this->conexao->prepare("SELECT 1 FROM TB_EXERCICIO WHERE id_exercicio = :IdExercicio");
        $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) 
        {
            throw new Exception("Exercício não encontrado");
        }
    }

    private function verificaRelacaoExiste()
    {
        $stmt = $this->conexao->prepare("SELECT 1 FROM TB_ROTINA_EXERCICIO WHERE id_rotina = :IdRotina AND id_exercicio = :IdExercicio");
        $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
        $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }


    public function Inserir()
    {
        try 
        {
            // Verifica se a rotina e exercício existem
            $this->verificaRotinaExiste();
            $this->verificaExercicioExiste();
            
            // Verifica se a relação já existe
            if ($this->verificaRelacaoExiste()) 
            {
                throw new Exception("Exercício já está associado a esta rotina");
            }
            
            $stmt = $this->conexao->prepare("INSERT INTO TB_ROTINA_EXERCICIO(id_rotina, id_exercicio) VALUES " .
                                            "(:IdRotina, :IdExercicio)");
           
            $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
            $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Exercício adicionado à rotina com sucesso");
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
            // Verifica se a relação existe
            if (!$this->verificaRelacaoExiste()) 
            {
                throw new Exception("Exercício não está associado a esta rotina");
            }
            
            $stmt = $this->conexao->prepare("DELETE FROM TB_ROTINA_EXERCICIO WHERE id_rotina = :IdRotina AND id_exercicio = :IdExercicio");
            $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
            $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Exercício removido da rotina com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function ListarExerciciosPorRotina()
    {
        $stmt = $this->conexao->prepare("
            SELECT e.id_exercicio, e.nm_exercicio, e.ds_exercicio, e.vl_duracao 
            FROM TB_EXERCICIO e 
            INNER JOIN TB_ROTINA_EXERCICIO re ON e.id_exercicio = re.id_exercicio 
            WHERE re.id_rotina = :IdRotina 
            ORDER BY e.nm_exercicio
        ");
        $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
        $stmt->execute();
        $ret = $stmt->fetchAll();
        
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function ListarRotinasPorExercicio()
    {
        $stmt = $this->conexao->prepare("
            SELECT r.id_rotina, r.nm_rotina, r.ds_rotina 
            FROM TB_ROTINA r 
            INNER JOIN TB_ROTINA_EXERCICIO re ON r.id_rotina = re.id_rotina 
            WHERE re.id_exercicio = :IdExercicio 
            ORDER BY r.nm_rotina
        ");
        $stmt->bindValue(':IdExercicio', $this->id_exercicio, PDO::PARAM_INT);
        $stmt->execute();
        $ret = $stmt->fetchAll();
        
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function ListarTodas()
    {
        $ret = $this->conexao->query("
            SELECT re.id_rotina, re.id_exercicio, r.nm_rotina, e.nm_exercicio, e.vl_duracao
            FROM TB_ROTINA_EXERCICIO re
            INNER JOIN TB_ROTINA r ON re.id_rotina = r.id_rotina
            INNER JOIN TB_EXERCICIO e ON re.id_exercicio = e.id_exercicio
            ORDER BY r.nm_rotina, e.nm_exercicio
        ");
        $ret = $ret->fetchAll();
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function ExcluirTodosExerciciosRotina()
    {
        try 
        {
            $stmt = $this->conexao->prepare("DELETE FROM TB_ROTINA_EXERCICIO WHERE id_rotina = :IdRotina");
            $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $affected = $stmt->rowCount();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Removidos $affected exercício(s) da rotina");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }
}
?>
