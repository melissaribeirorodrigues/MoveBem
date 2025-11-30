# TELA ROTINAS

**Arquivo:** `lib/screens/tela_rotinas.dart`  
**Rota:** `/rotinas`

---

## O QUE FAZ

Tela principal do app depois do login. Mostra cards com as rotinas de exercícios disponíveis (puxadas do banco) e um card especial pra controlar água. Tem menu inferior pra navegar entre Home, Água e Perfil.

---

## COMPONENTES USADOS

**http.post**
- Busca as rotinas do backend
- Operação "Listar"

**SharedPreferences**
- Pega os dados do usuário logado
- `prefs.getString('usuario')`

**RefreshIndicator**
- Arrasta pra baixo = recarrega as rotinas
- `onRefresh: _loadRotinas`

**ListView**
- Lista rolável com os cards
- `physics: AlwaysScrollableScrollPhysics()` - permite scroll mesmo com poucos itens

**GestureDetector**
- Detecta clique nos cards
- Navega pra tela de exercícios da rotina

**Stack com Positioned**
- Sobreposição de elementos nos cards
- Quadrado rosa de fundo + quadrado principal + imagem

**Image.asset**
- Imagens diferentes pra cada rotina
- `rotina1.png`, `rotina2.png`, `rotina3.png`, `agua.png`

**BottomNavigationBar customizado**
- Container com gradiente rosa
- 3 ícones: Home, Água, Perfil

---

## LÓGICA DA TELA

```dart
// 1. Tela carrega → initState()
// 2. Carrega dados do usuário do SharedPreferences
// 3. Chama _loadRotinas() pra buscar rotinas do backend
// 4. Backend retorna lista de rotinas
// 5. Guarda na variável _rotinas = [rotina1, rotina2, rotina3]
// 6. Pra cada rotina, cria um card
// 7. Clique no card → manda o OBJETO COMPLETO da rotina pra próxima tela
```

**O que é mandado:**

NÃO manda só o ID. Manda o objeto inteiro:
```dart
arguments: {
  "id_rotina": 24,
  "nm_rotina": "Rotina Matinal",
  "ds_rotina": "Exercícios leves para começar o dia"
}
```

**Por quê mandar tudo?**
- Próxima tela precisa do ID pra buscar os exercícios no banco
- Também precisa do NOME pra mostrar no título da tela
- E da DESCRIÇÃO (mesmo que não use agora, já tá disponível)

**Como funciona:**

1. Usuário clica no card "Rotina Matinal"
2. Flutter pega o objeto daquela rotina: `{id: 24, nome: "Matinal", desc: "..."}`
3. Manda esse objeto completo via `arguments`
4. Próxima tela recebe e pode usar:
   - `rotina['id_rotina']` → pra buscar exercícios
   - `rotina['nm_rotina']` → pra mostrar no AppBar

---

## BACKEND

**Endpoint:** `http://200.19.1.19/usuario03/MoveBem/Controller/CrudRotina.php`

**Requisição:**
```
POST
oper: "Listar"
```

**Resposta:**
```json
{
  "NumMens": 1,
  "dados": [
    {
      "id_rotina": 24,
      "nm_rotina": "Rotina Matinal",
      "ds_rotina": "Exercícios leves para começar o dia"
    },
    {
      "id_rotina": 25,
      "nm_rotina": "Rotina Vespertina",
      "ds_rotina": "Alongamentos do meio do dia"
    },
    {
      "id_rotina": 26,
      "nm_rotina": "Rotina Noturna",
      "ds_rotina": "Relaxamento antes de dormir"
    }
  ]
}
```

**O que o backend faz:**
- SELECT na tabela `tb_rotina`
- Retorna todas as rotinas cadastradas
- Sem filtro de usuário (rotinas são as mesmas pra todos)

---

## MAPEAMENTO DE IMAGENS

```dart
String imagePath = 'assets/rotina1.png'; // padrão

String idString = idRotina.toString();

if (idString == '24') {
  imagePath = 'assets/rotina1.png';
} else if (idString == '25') {
  imagePath = 'assets/rotina2.png';
} else if (idString == '26') {
  imagePath = 'assets/rotina3.png';
}
```

**Por quê converter pra string?** O `id_rotina` às vezes vinha como int, às vezes como string do JSON. Converter garante que a comparação funciona sempre.

---

## ESTRUTURA DOS CARDS

```dart
Stack(
  [
    // Fundo rosa claro (maior, deslocado)
    Positioned(top: 8, left: 8, right: -8, bottom: -8)
      Container(cor: #FFC4D6)
    
    // Card principal rosa
    Container(
      cor: #FF4D8A
      padding: texto à esquerda
      [Título branco]
      [Descrição branca]
    )
    
    // Imagem à direita
    Positioned(right: -25, top: 0, bottom: 0)
      Image.asset(rotina1.png)
  ]
)
```

Isso cria o efeito de profundidade com sombra rosa atrás.

---

## BOTTOM NAVIGATION BAR

```dart
Container com gradiente rosa
  Row com 3 IconButton:
    - Home (branco se selecionado, transparente se não)
    - Água (navega pra /agua)
    - Perfil (navega pra /perfil)
```

**Estado:** `_currentIndex` controla qual tá selecionado (0=home, 1=água, 2=perfil)

---

## NAVEGAÇÃO

**Recebe:** `arguments` com dados do usuário (id_usuario, nome, email)

**Envia pra /exercicio_rotina:**
```dart
arguments: rotina  // objeto completo da rotina
// {id_rotina, nm_rotina, ds_rotina}
```

**Envia pra /agua:**
```dart
arguments: {'id_usuario': idUsuario}
```

**Envia pra /perfil:**
```dart
arguments: dadosUsuario  // dados completos do usuário
```

---

## ERROS E SOLUÇÕES

**❌ Imagens não apareciam**
- Problema: não declaramos todas as imagens no pubspec
- Solução: adicionar todos os assets:
```yaml
assets:
  - assets/rotina1.png
  - assets/rotina2.png
  - assets/rotina3.png
  - assets/agua.png
```

**❌ ID da rotina não batia**
- Problema: comparação `if (idRotina == 24)` falhava porque vinha como string
- Solução: converter pra string: `idRotina.toString() == '24'`

**❌ Lista vazia não atualizava**
- Problema: se não tinha rotinas, não conseguia dar refresh
- Solução: `AlwaysScrollableScrollPhysics()` no ListView

**❌ Dados do usuário se perdiam**
- Problema: ao navegar, perdia os dados
- Solução: sempre passar `arguments` e buscar do SharedPreferences no initState

**❌ Card de água sem id_usuario**
- Problema: não sabia qual usuário tava logado
- Solução: pegar do arguments ou do SharedPreferences

**❌ Navegação do bottom bar substituía a pilha**
- Problema: ao voltar, perdia o histórico
- Solução: usar `pushNamed` pro perfil e `pushReplacementNamed` pra água/home

---

## PULL TO REFRESH

```dart
RefreshIndicator(
  onRefresh: _loadRotinas,  // recarrega do backend
  child: ListView(...)
)
```

Puxa pra baixo = atualiza as rotinas do banco.

---

## SAUDAÇÃO PERSONALIZADA

```dart
Text('Olá, $nomeUsuario!')
```

Pega o nome do SharedPreferences e mostra no topo.

---

## CORES

**Cards de rotina:**
- Fundo claro: `#FFC4D6`
- Card principal: `#FF4D8A`
- Texto: branco

**Card de água:**
- Fundo claro: `#FFE4F0`
- Card principal: branco
- Borda do título: `#FFE4F0`
- Texto: `#666666`

**Bottom bar:**
- Gradiente: `#FF4D8A` → `#F1AEC2`

---

## ASSETS

```
assets/rotina1.png
assets/rotina2.png
assets/rotina3.png
assets/agua.png
```

---

## DEPENDÊNCIAS

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

---

## APRENDIZADOS

- RefreshIndicator pra pull-to-refresh
- Stack com Positioned pra criar efeitos de profundidade
- Mapear IDs do banco pra assets específicos
- Converter tipos do JSON (.toString()) pra garantir comparações
- AlwaysScrollableScrollPhysics pra scroll funcionar sempre
- Passar dados entre telas com arguments
- Bottom navigation bar customizado (não é o padrão do Flutter)
- SharedPreferences no initState pra persistência
