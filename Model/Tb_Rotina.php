<?php

require_once('Base.php');

class Tb_Rotina extends Base
{
    private $id_rotina;
    private $nm_rotina;
    private $ds_rotina;

    function __construct($p_banco)
    {
        parent::__construct($p_banco);
    }

    function SetIdRotina($p_IdRotina)
    {
        $this->id_rotina = $p_IdRotina;
    }

    function SetNmRotina($p_NmRotina)
    {
        $this->nm_rotina = $p_NmRotina;
    }

    function SetDsRotina($p_DsRotina)
    {
        $this->ds_rotina = $p_DsRotina;
    }

    function GetIdRotina()
    {
        return $this->id_rotina;
    }

    function GetNmRotina()
    {
        return $this->nm_rotina;
    }

    function GetDsRotina()
    {
        return $this->ds_rotina;
    }



    public function verificaExistencia()
    {
        $consulta = $this->conexao->query(
            "SELECT 1 FROM TB_ROTINA WHERE id_rotina = $this->id_rotina");

        $ret = $consulta->fetch(PDO::FETCH_ASSOC);
        if (!$ret) 
        {
            throw new Exception("Rotina não localizada");
        }
        return $ret;
    }

    private function verificaRotinaExistente()
    {
        $stmt = $this->conexao->prepare("SELECT id_rotina FROM TB_ROTINA WHERE UPPER(nm_rotina) = UPPER(:NmRotina)");
        $stmt->bindValue(':NmRotina', $this->nm_rotina, PDO::PARAM_STR);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) 
        {
            throw new Exception("Já existe uma rotina com este nome");
        }
    }



    public function Inserir()
    {
        try 
        {
            // Verifica se o nome da rotina já existe
            $this->verificaRotinaExistente();
            
            $stmt = $this->conexao->prepare("INSERT INTO TB_ROTINA(nm_rotina, ds_rotina) VALUES " .
                                            "(:NmRotina, :DsRotina)");
           
            $stmt->bindValue(':NmRotina', $this->nm_rotina, PDO::PARAM_STR);
            $stmt->bindValue(':DsRotina', $this->ds_rotina, PDO::PARAM_STR);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Rotina incluída com sucesso");
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
            // Verifica se a rotina existe
            $this->verificaExistencia();
            
            // Verifica se não existe outra rotina com o mesmo nome
            $stmt = $this->conexao->prepare("SELECT id_rotina FROM TB_ROTINA WHERE UPPER(nm_rotina) = UPPER(:NmRotina) AND id_rotina != :IdRotina");
            $stmt->bindValue(':NmRotina', $this->nm_rotina, PDO::PARAM_STR);
            $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
            $stmt->execute();
            
            if ($stmt->rowCount() > 0) 
            {
                throw new Exception("Já existe uma rotina com este nome");
            }
            
            $stmt = $this->conexao->prepare("UPDATE TB_ROTINA SET nm_rotina = :NmRotina, ds_rotina = :DsRotina WHERE id_rotina = :IdRotina");
           
            $stmt->bindValue(':NmRotina', $this->nm_rotina, PDO::PARAM_STR);
            $stmt->bindValue(':DsRotina', $this->ds_rotina, PDO::PARAM_STR);
            $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Rotina alterada com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    private function verificaExerciciosAssociados()
    {
        $stmt = $this->conexao->prepare("SELECT COUNT(*) as total FROM TB_ROTINA_EXERCICIO WHERE id_rotina = :IdRotina");
        $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
        $stmt->execute();
        
        $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
        $total = $resultado['total'];
        
        if ($total > 0) 
        {
            throw new Exception("Não é possível excluir a rotina. Ela possui $total exercício(s) associado(s). Remova os exercícios da rotina antes de excluí-la.");
        }
    }

    public function Excluir()
    {
        try 
        {
            // Verifica se a rotina existe
            $this->verificaExistencia();
            
            // Verifica se há exercícios associados
            $this->verificaExerciciosAssociados();
            
            $stmt = $this->conexao->prepare("DELETE FROM TB_ROTINA WHERE id_rotina = :IdRotina");
            $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Rotina excluída com sucesso");
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function Listar()
    {
        $ret = $this->conexao->query("SELECT id_rotina, nm_rotina, ds_rotina FROM TB_ROTINA ORDER BY nm_rotina;");
        $ret = $ret->fetchAll();
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function Consultar()
    {
        try
        {
            $ret = $this->verificaExistencia();
            
            $stmt = $this->conexao->prepare("SELECT id_rotina, nm_rotina, ds_rotina FROM TB_ROTINA WHERE id_rotina = :IdRotina");
            $stmt->bindValue(':IdRotina', $this->id_rotina, PDO::PARAM_INT);
            $stmt->execute();
            $ret = $stmt->fetchAll();
            
            $this->banco->setMensagem(1, "Rotina encontrada");
            $this->banco->setDados(count($ret), $ret);
        } 
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }

    public function Pesquisar()
    {
        $stmt = $this->conexao->prepare("SELECT id_rotina, nm_rotina, ds_rotina FROM TB_ROTINA WHERE UPPER(nm_rotina) LIKE UPPER(:NmRotina) ORDER BY nm_rotina");
        $stmt->bindValue(':NmRotina', '%' . $this->nm_rotina . '%', PDO::PARAM_STR);
        $stmt->execute();
        $ret = $stmt->fetchAll();
        
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function ListarComExercicios()
    {
        // Busca todas as rotinas
        $rotinas = $this->conexao->query("SELECT id_rotina, nm_rotina, ds_rotina FROM TB_ROTINA ORDER BY nm_rotina");
        $rotinas = $rotinas->fetchAll(PDO::FETCH_ASSOC);
        
        $resultado = [];
        
        foreach ($rotinas as $rotina) {
            // Para cada rotina, busca seus exercícios
            $stmt = $this->conexao->prepare("
                SELECT 
                    e.id_exercicio,
                    e.nm_exercicio,
                    e.ds_exercicio,
                    e.vl_duracao
                FROM TB_ROTINA_EXERCICIO re
                INNER JOIN TB_EXERCICIO e ON re.id_exercicio = e.id_exercicio
                WHERE re.id_rotina = :IdRotina
                ORDER BY e.nm_exercicio
            ");
            $stmt->bindValue(':IdRotina', $rotina['id_rotina'], PDO::PARAM_INT);
            $stmt->execute();
            $exercicios = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Adiciona os exercícios à rotina
            $rotina['exercicios'] = $exercicios;
            $rotina['total_exercicios'] = count($exercicios);
            
            $resultado[] = $rotina;
        }
        
        $this->banco->setMensagem(1, "Rotinas listadas com exercícios");
        $this->banco->setDados(count($resultado), $resultado);
    }
}
?>
