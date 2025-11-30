# TELA HISTÓRICO

**Arquivo:** `lib/screens/tela_historico.dart`  
**Rota:** `/historico`

---

## O QUE FAZ

Mostra o histórico de exercícios e água consumida por data. Tem um calendário pra escolher o dia e mostra quantos minutos de alongamento e quantos ml de água foram registrados naquele dia.

---

## COMPONENTES USADOS

**TableCalendar**
- Calendário interativo
- Dia selecionado fica rosa
- Hoje fica rosa claro
- Clique no dia → carrega dados

**SharedPreferences**
- Pega id_usuario no initState
- Se não tiver, manda pro login

**http.post**
- Busca resumo do dia no backend
- Endpoint: CrudHistoricoDiario.php
- Operação: ResumoPorData

**CircularProgressIndicator**
- Mostra loading enquanto carrega dados

**SingleChildScrollView**
- Lista de detalhes de água (pode ter vários registros)

**DateTime**
- Data selecionada
- Formato ISO pra enviar pro backend (yyyy-mm-dd)

---

## LÓGICA DA TELA

```
1. initState → _carregarDadosUsuario()
2. SharedPreferences.getString('usuario')
3. Extrai id_usuario
4. Chama _carregarDados(hoje)
5. POST ResumoPorData com id_usuario + data
6. Backend retorna total_minutos_exercicio + total_agua_ml + detalhes_agua
7. Mostra no _buildResultado()
8. Clique em outra data → _carregarDados(nova data)
9. Atualiza a tela
```

---

## BACKEND

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudHistoricoDiario.php`

**Requisição:**
```
POST
oper: "ResumoPorData"
id_usuario: "33"
data: "2025-11-30"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "total_minutos_exercicio": 180,
  "total_agua_ml": 2500,
  "detalhes_agua": [
    {
      "qt_agua_ml": 500,
      "dh_ingestao_agua": "2025-11-30 08:30:00"
    },
    {
      "qt_agua_ml": 1000,
      "dh_ingestao_agua": "2025-11-30 12:15:00"
    },
    {
      "qt_agua_ml": 1000,
      "dh_ingestao_agua": "2025-11-30 18:00:00"
    }
  ]
}
```

**O que o backend faz:**
- Busca na tb_historico_diario os exercícios do dia
- Soma total de segundos de exercício
- Busca na tb_registro_agua os registros do dia
- Soma total de ml de água
- Retorna detalhes de cada registro de água com horário

---

## CALENDÁRIO

**TableCalendar:**
- focusedDay: dia atual
- firstDay: 2023
- lastDay: 2030
- selectedDayPredicate: marca o dia selecionado
- onDaySelected: carrega dados daquele dia

**Cores:**
- Dia selecionado: `#FF4D8A` (rosa escuro)
- Hoje: Colors.pinkAccent (rosa claro)
- Outros dias: padrão

---

## FORMATO DE DATA

**Para o backend:**
```dart
data.toIso8601String().substring(0, 10)
// "2025-11-30"
```

**Para mostrar na tela:**
```dart
"${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}"
// "30/11/2025"
```

---

## ESTADOS

**_loading:**
- true: mostra CircularProgressIndicator
- false: mostra dados ou mensagem vazia

**_dados:**
- null: "Nenhum dado encontrado"
- com dados: mostra _buildResultado()

**_selectedDay:**
- Data selecionada no calendário
- Padrão: DateTime.now()

**_idUsuario:**
- null: não carrega (espera SharedPreferences)
- com valor: faz requisição

---

## NAVEGAÇÃO

**AppBar voltar:**
- Navigator.pop(context) → volta pra tela anterior (perfil)

---

## ERROS E SOLUÇÕES

**❌ Perda de dados do usuário ao navegar**
- Problema: quando navegava, perdia id_usuario
- Solução: SharedPreferences no initState

**❌ Carregava dados antes de ter id_usuario**
- Problema: _carregarDados era chamado antes do SharedPreferences
- Solução: validar `if (_idUsuario == null) return`

**❌ Data no formato errado pro backend**
- Problema: enviava DateTime completo
- Solução: substring(0, 10) pra pegar só yyyy-mm-dd

**❌ Loading infinito**
- Problema: esquecia de setar _loading = false no catch
- Solução: sempre setar false no finally ou catch

**❌ Detalhes de água como null**
- Problema: backend não retornava array vazio
- Solução: `_dados?['detalhes_agua'] ?? []`

---

## CORES

- Fundo: branco
- AppBar: branco
- Dia selecionado: `#FF4D8A`
- Hoje: Colors.pinkAccent
- Textos: preto / black54 / black87

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0
  table_calendar: ^3.0.0
  shared_preferences: ^2.2.2
```

---

## APRENDIZADOS

- TableCalendar pra calendários interativos
- isSameDay pra comparar datas
- toIso8601String() pra formatar data pro backend
- substring(0, 10) pra pegar só a parte da data
- Validar id_usuario antes de carregar dados
- Loading state pra feedback visual
- for-in pra listar detalhes dinamicamente
- Null safety com ?? operator
