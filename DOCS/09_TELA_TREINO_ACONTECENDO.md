# TELA TREINO ACONTECENDO

**Arquivo:** `lib/screens/tela_treino_acontecendo.dart`  
**Rota:** `/treino_acontecendo`

---

## O QUE FAZ

Executa o treino de uma rotina. Mostra cada exercício com timer regressivo, descanso automático entre exercícios, e salva o histórico no banco quando termina. Tem botões pra pausar/retomar e encerrar antes do fim.

---

## COMPONENTES USADOS

**Timer.periodic**
- Timer do exercício (1 segundo)
- Timer do descanso (1 segundo)
- Cancelados no dispose pra evitar memory leak

**StatefulBuilder**
- No dialog de descanso pra atualizar o countdown
- Sem rebuild da tela toda

**didChangeDependencies**
- Pega arguments (id_rotina)
- Busca exercícios no backend
- Só executa uma vez (_exercicios.isEmpty)

**http.post - Listar**
- Busca exercícios da rotina
- Endpoint: CrudRotinaExercicio.php

**http.post - InserirHistorico**
- Salva treino no banco quando termina
- Endpoint: CrudHistoricoDiario.php

**SharedPreferences**
- Pega id_usuario pra salvar histórico

**CircularProgressIndicator**
- Loading ao buscar exercícios

**AlertDialog**
- Descanso entre exercícios (20 segundos)
- Rotina finalizada

---

## LÓGICA DA TELA

```
1. didChangeDependencies → pega id_rotina dos arguments
2. _fetchRotina(id_rotina) → POST Listar exercícios
3. _startExerciseAtIndex(0) → inicia primeiro exercício
4. Timer.periodic decrementa _remaining a cada segundo
5. Incrementa _totalSeconds (pra salvar depois)
6. Quando _remaining = 0 → _onExerciseFinished()
7. Se não é último → _showRestDialog (20 segundos)
8. Timer do descanso → auto avança pro próximo
9. Pode pular descanso clicando no botão
10. Último exercício → _showRoutineFinished()
11. Salva no banco → POST InserirHistorico
12. Mostra "ROTINA FINALIZADA!"
```

---

## BACKEND

### Operação: Listar (exercícios)

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotinaExercicio.php`

**Requisição:**
```
POST
oper: "Listar"
id_rotina: "24"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "dados": [
    {
      "id_exercicio": 10,
      "nm_exercicio": "Inclinação lateral",
      "vl_duracao": 30
    },
    {
      "id_exercicio": 11,
      "nm_exercicio": "Rotação cervical",
      "vl_duracao": 40
    }
  ]
}
```

---

### Operação: InserirHistorico

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudHistoricoDiario.php`

**Requisição:**
```
POST
oper: "InserirHistorico"
id_usuario: "33"
id_rotina: "24"
vl_total_minutos: "120"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "Mensagem": "Histórico inserido com sucesso"
}
```

**O que faz:**
- Insere um registro na tb_historico_diario com total de segundos
- OU faz loop inserindo cada exercício individualmente
- Data/hora = agora (CURRENT_TIMESTAMP)

---

## TIMERS

**Timer do exercício:**
```dart
Timer.periodic(Duration(seconds: 1), (t) {
  _remaining--;         // decrementa tempo do exercício
  _totalSeconds++;      // incrementa total geral
  if (_remaining <= 0) {
    t.cancel();
    _onExerciseFinished();
  }
});
```

**Timer do descanso:**
```dart
Timer.periodic(Duration(seconds: 1), (t) {
  _restRemaining--;
  if (_restRemaining <= 0) {
    t.cancel();
    Navigator.pop();     // fecha dialog
    _advanceToNextExercise();
  }
});
```

**Cancelamento:**
- dispose() → cancela timers
- Troca de exercício → cancela timer anterior
- Pular descanso → cancela timer descanso

---

## ESTADOS

**_loading:**
- true: mostra CircularProgressIndicator
- false: mostra treino ou erro

**_error:**
- true: mostra mensagem de erro
- false: treino normal

**_exercicios:**
- Lista de exercícios da rotina
- Vem do backend

**_index:**
- Índice do exercício atual (0, 1, 2...)
- Mostra "Exercício 2/5"

**_remaining:**
- Segundos restantes do exercício atual
- Formato: mm:ss

**_isRunning:**
- true: timer rodando
- false: pausado
- Botão PAUSAR/RETOMAR

**_restRemaining:**
- Segundos restantes do descanso (20)

**_totalSeconds:**
- Total de segundos do treino inteiro
- Salvo no banco no final

**_saved:**
- Flag pra não salvar duplicado
- true: já salvou
- false: ainda não salvou

---

## DESCANSO

**Duração:** 20 segundos (_restSeconds)

**Dialog:**
- Fundo rosa claro
- Mostra nome do próximo exercício
- Timer regressivo
- Botão "PULAR DESCANSO"
- Auto-fecha quando chega em 0

**StatefulBuilder:**
- Permite atualizar só o dialog
- Não rebuild da tela toda

---

## PAUSAR/RETOMAR

```dart
setState(() {
  _isRunning = !_isRunning;
});
```

Timer verifica `_isRunning` antes de decrementar:
```dart
if (!_isRunning || !mounted) return;
```

---

## ENCERRAR TREINO

Botão "ENCERRAR TREINO":
- Salva no banco (_saveToDatabase)
- Navigator.pop() volta pra tela anterior

AppBar voltar:
- Salva no banco antes de sair
- Navigator.pop()

dispose():
- Cancela timers
- Salva se ainda não salvou (_saveIfNotSaved)

---

## FORMATO DE TEMPO

```dart
String _formatSeconds(int secs) {
  final m = (secs ~/ 60).toString().padLeft(2, '0');
  final s = (secs % 60).toString().padLeft(2, '0');
  return "$m:$s";
}
```

Exemplos:
- 90 → "01:30"
- 30 → "00:30"
- 125 → "02:05"

---

## NAVEGAÇÃO

**Recebe de /exercicio_rotina:**
```dart
arguments: {
  "id_rotina": 24
}
```

**Envia pra /descricao_exercicio:**
```dart
arguments: {
  "exercicio": {...}  // exercício atual
}
```

**Ícone info no AppBar:**
- Abre descrição do exercício atual
- Navigator.pushNamed('/descricao_exercicio')

---

## ERROS E SOLUÇÕES

**❌ Timer continuava após dispose**
- Problema: memory leak e erros
- Solução: cancelar timers no dispose()

**❌ Salvava múltiplas vezes no banco**
- Problema: toda vez que voltava salvava de novo
- Solução: flag _saved pra salvar só uma vez

**❌ Dialog de descanso não atualizava**
- Problema: setState não funcionava no dialog
- Solução: StatefulBuilder pra atualizar só o dialog

**❌ Timer do descanso criado múltiplas vezes**
- Problema: múltiplos timers rodando ao mesmo tempo
- Solução: `_restTimer ??=` só cria se for null

**❌ Duração vinha como String do backend**
- Problema: erro ao decrementar
- Solução: int.tryParse(vl_duracao.toString())

**❌ Não salvava se saísse antes do fim**
- Problema: perdia progresso
- Solução: salvar no dispose() e no botão voltar

**❌ Arguments null**
- Problema: id_rotina não vinha
- Solução: validar e mostrar erro

---

## CORES

- Fundo: branco
- Rosa escuro: `#FF4D8A`
- Rosa claro: `#FFA7C4`
- Dialog descanso: Colors.pink.shade50
- Texto "Mantenha a respiração": rosa

---

## ASSETS

Mesmas imagens da tela de exercícios:
- AM_1.png até AM_6.png
- logo.png (fallback)

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

---

## APRENDIZADOS

- Timer.periodic pra countdown
- Cancelar timers no dispose()
- StatefulBuilder pra atualizar dialogs
- Flags pra evitar ações duplicadas (_saved)
- Incrementar total enquanto decrementa parcial
- `_restTimer ??=` pra criar só se null
- Validar mounted antes de setState após async
- int.tryParse pra conversão segura
- Salvar progresso ao sair (dispose, voltar, encerrar)
- `Navigator.popUntil` pra voltar múltiplas telas
