<?php
require_once('Base.php');

class Tb_Historico_Diario extends Base
{
    private $id_usuario;
    private $data; 

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

    /**
     * Lista de registros de água em uma data escolhida pelo usuário
     */
    private function listarAguaPorData() 
    {
        $stmt = $this->conexao->prepare("
            SELECT id_usuario, dh_ingestao_agua, qt_agua_ml
              FROM TB_REGISTRO_AGUA 
             WHERE id_usuario = :id_usuario 
               AND DATE(dh_ingestao_agua) = DATE(:Data)
          ORDER BY dh_ingestao_agua DESC
        ");
        $stmt->bindValue(':id_usuario', $this->id_usuario, PDO::PARAM_INT);
        $stmt->bindValue(':Data', $this->data, PDO::PARAM_STR);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Insere um registro de histórico de exercícios
     */
    public function InserirHistorico($id_rotina, $minutos)
    {
        header('Content-Type: application/json; charset=utf-8');

        try {
            if (empty($this->id_usuario)) {
                throw new Exception("Usuário não informado");
            }

            if (empty($id_rotina)) {
                throw new Exception("Rotina não informada");
            }

            $minTotal = (int)$minutos;
            if ($minTotal <= 0) {
                throw new Exception("Total de minutos inválido");
            }

            $stmt = $this->conexao->prepare("
                INSERT INTO TB_HISTORICO_DIARIO
                    (id_usuario, id_rotina, dt_data, vl_total_minutos)
                VALUES
                    (:id_usuario, :id_rotina, CURRENT_DATE, :minutos)
            ");

            $stmt->bindValue(':id_usuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':id_rotina', $id_rotina, PDO::PARAM_INT);
            $stmt->bindValue(':minutos', $minTotal, PDO::PARAM_INT);

            $stmt->execute();

            echo json_encode([
                'sucesso'  => true,
                'operacao' => 'InserirHistorico',
                'mensagem' => 'Registro de treino salvo com sucesso'
            ], JSON_UNESCAPED_UNICODE);

        } catch (Exception $e) {
            echo json_encode([
                'sucesso' => false,
                'erro'    => $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
        }
    }

    /**
     * Retorna resumo do dia (água + exercícios)
     */
    public function ResumoPorData() 
    {
        // Limpa qualquer output anterior e buffer
        while (ob_get_level()) {
            ob_end_clean();
        }
        
        header('Content-Type: application/json; charset=utf-8');
        
        try 
        {
            // Soma total de água ingerida no dia
            $stmt = $this->conexao->prepare("
                SELECT 
                    COALESCE(SUM(qt_agua_ml), 0) AS total_ml,
                    COUNT(*) AS total_registros
                  FROM TB_REGISTRO_AGUA 
                 WHERE id_usuario = :id_usuario 
                   AND DATE(dh_ingestao_agua) = DATE(:Data)
            ");
            $stmt->bindValue(':id_usuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':Data', $this->data, PDO::PARAM_STR);
            $stmt->execute();
            $totais = $stmt->fetch(PDO::FETCH_ASSOC);

            // Soma total de minutos de exercícios do dia
            $stmt2 = $this->conexao->prepare("
                SELECT 
                    COALESCE(SUM(vl_total_minutos), 0) AS total_minutos_exercicio,
                    COUNT(*) AS total_registros_exercicio
                  FROM TB_HISTORICO_DIARIO
                 WHERE id_usuario = :id_usuario
                   AND DATE(dt_data) = DATE(:Data)
            ");
            $stmt2->bindValue(':id_usuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt2->bindValue(':Data', $this->data, PDO::PARAM_STR);
            $stmt2->execute();
            $totaisExercicio = $stmt2->fetch(PDO::FETCH_ASSOC);

            // Buscar registros individuais de água
            $registrosAgua = $this->listarAguaPorData();

            // Retornar tudo em JSON
            $resultado = [
                'sucesso'                   => true,
                'data'                      => $this->data,
                'total_agua_ml'             => (int)($totais['total_ml'] ?? 0),
                'total_registros_agua'      => (int)($totais['total_registros'] ?? 0),
                'total_minutos_exercicio'   => (int)($totaisExercicio['total_minutos_exercicio'] ?? 0),
                'total_registros_exercicio' => (int)($totaisExercicio['total_registros_exercicio'] ?? 0),
                'detalhes_agua'             => $registrosAgua
            ];
            
            $json = json_encode($resultado, JSON_UNESCAPED_UNICODE);
            header('Content-Length: ' . strlen($json));
            echo $json;
            exit(0);

        } 
        catch (Exception $e) 
        {
            echo json_encode([
                'sucesso' => false, 
                'erro'    => $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
        }
    }
}
?>
