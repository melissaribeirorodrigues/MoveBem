<?php
require_once('Base.php');

class Tb_Historico_Diario extends Base
{
    private $id_usuario;
    private $data; // YYYY-MM-DD

    function __construct($p_banco) 
    {
        parent::__construct($p_banco);
    }

    function SetIdUsuario($id) 
    { 
        $this->id_usuario = (int)$id; 
    }
    
    function SetData($data) 
    { 
        $this->data = $data; 
    }

    // lista registros de agua em uma data escolhida pelo usuario
    private function listarAguaPorData() 
    {
        $stmt = $this->conexao->prepare("
            SELECT id_usuario, dh_ingestao_agua, qt_agua_ml
            FROM TB_REGISTRO_AGUA 
            WHERE id_usuario = :IdUsuario 
            AND DATE(dh_ingestao_agua) = DATE(:Data)
            ORDER BY dh_ingestao_agua DESC
        ");
        $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
        $stmt->bindValue(':Data', $this->data, PDO::PARAM_STR);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    //  retorna total ml inseridos por dia + detalhes em uma única consulta
    public function ResumoPorData() 
    {
        header('Content-Type: application/json; charset=utf-8');
        try 
        {
            // soma total de agua + lista registros em uma única consulta
            $stmt = $this->conexao->prepare("
                SELECT 
                    SUM(qt_agua_ml) as total_ml,
                    COUNT(*) as total_registros
                FROM TB_REGISTRO_AGUA 
                WHERE id_usuario = :IdUsuario 
                AND DATE(dh_ingestao_agua) = DATE(:Data)
            ");
            $stmt->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':Data', $this->data, PDO::PARAM_STR);
            $stmt->execute();
            $totais = $stmt->fetch();

            
            // soma total de minutos de exercícios
            $stmt2 = $this->conexao->prepare("
                SELECT 
                    SUM(vl_total_minutos) as total_minutos_exercicio,
                    COUNT(*) as total_registros_exercicio
                FROM TB_HISTORICO_DIARIO
                WHERE id_usuario = :IdUsuario
                AND dt_data = DATE(:Data)
            ");
            $stmt2->bindValue(':IdUsuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt2->bindValue(':Data', $this->data, PDO::PARAM_STR);
            $stmt2->execute();
            $totaisExercicio = $stmt2->fetch();

            // buscar registros individuais
            $registros = $this->listarAguaPorData();

            echo json_encode([
                'sucesso' => true,
                'data' => $this->data,
                'total_agua_ml' => (int)($totais['total_ml'] ?? 0),
                'total_registros' => (int)($totais['total_registros'] ?? 0),
                'total_minutos_exercicio' => (int)($totaisExercicio['total_minutos_exercicio'] ?? 0),
                'total_registros_exercicio' => (int)($totaisExercicio['total_registros_exercicio'] ?? 0),
                'detalhes' => $registros
            ], JSON_UNESCAPED_UNICODE);
        } 
        catch (Exception $e) 
        {
            echo json_encode([
                'sucesso' => false, 
                'erro' => $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
        }
    }
}
?>